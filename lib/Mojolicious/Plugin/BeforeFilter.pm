=pod

=head1 NAME

Mojolicious::Plugin::BeforeFilter - allow controllers to run filters before actions

=head1 SYNOPSIS

  # In your primary class (e.g. Myapp.pm)
  sub startup {
      my $self = shift;
      
      ...
      $self->plugin("Mojolicious::Plugin::BeforeFilter");
      $self->add_filter_class('MyApp::Filters');
  } 

  # Your class that implements the filters
  package MyApp::Filters;
  sub tattle {
     my ($class, $controller, $action) = @_;
     $controller->app->log->debug(__PACKAGE__ . ": about to execute $action");
  }
  
  sub hide {
     my ($class, $controller, $action) = @_;
     $controller->app->log->debug(__PACKAGE__ . ": hiding $action");
     $controller->redirect_to("/");
  }
  
  1;

  # One of your controllers
  package MyApp::Controller::Dashboard;
  use Mojo::Base 'Mojolicious::Controller';
  our $BEFORE_FILTERS = { tattle => [ 'index', 'show' ],
                          forbid => [ 'show' ],
                        };
  
  sub index {}
  
  sub show {}
  
  1;
  
=head1 DESCRIPTION

This Mojolicious plugin gives each controller the ability to run arbitrary filters 
before it's action methods are called.  Very typically, this functionality is used for 
authentication and authorization tasks as well as custom logging.  The functionality is 
inspired by the before_filters found in Ruby on Rails.

This implementation uses the existing Mojolicious hook of around_action to inspect the 
target controller for a global hash reference called C<$FILTER_ACTIONS>.  The referred to 
hash has keys that are method names found in the user-implemented filter classes.  The 
keys are array references to the names of the action methods in the target controller 
which will trigger the application of the custom filters. 

There are three bits to using this plugin:

=over 4

=item Create a plain old Perl class with methods to be run before controller action 
methods (q.v. L</"CREATING FILTERS">)

=item In the main Mojo application class, add one or more custom filter classes with the 
C<add_filter_class()> plugin method

=item In each controller, create a global C<$FILTER_ACTIONS> hash (q.v. 
L</"USING FILTERS IN CONTROLLERS">)

=back

=head1 METHODS

=head2 add_filter_class("MyApp::Filters")

Given a class name as a string, add this to the global list of classes to check for 
filters.

Please note that class are inspected for filtering methods in the order added.  This 
means if two classes both contain methods called "filter", the method of the class added
first will always be called.  The use of unique method names for each filter is advised.

=head1 CREATING FILTERS

A filter class is a simple Perl package with one or more methods.  Theses could be 
considered classes with only class method.  These filters are never instantiated, merely 
loaded.

A filtering method is passed the following arguments:

=over 4

=item its only class name (which is not very useful)

=item the target controller that contains the action method about to be invoked

=item the name of the action method in the target controller to be invoked

=back

As the L</"SYNOPSIS"> section shows, the filter writer has a wide latitude about what 
these filters do.

Please note that the plugin will always try to run all the matching filters.

=head1 USING FILTERS IN CONTROLLERS

=head1 SEE ALSO

=over 4

=item The lightweight L<Mojoloicious> MVC framework to learn more about it.

=item This module was inspired by the C<ActionFilter> class in 
L<Mojolicious::Plugin::AdvancedMod>, which did not quite work in the ways I needed it to.

=back



=head1 COPYRIGHT AND DISCLAIMER

Copyright Joe Johnston.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

Product and company names mentioned in this document may be the
trademarks or service marks of their respective owners.  Trademarks 
and service marks are not identified, although this must not be
construed as the author's expression of validity or invalidity of
each trademark or service mark.

=head1 AUTHOR

Joe Johnston, E<lt>jjohn@taskboy.comE<gt>, L<http://taskboy.com/>

=cut

package Mojolicious::Plugin::BeforeFilter;
use Mojo::Base 'Mojolicious::Plugin';

our $FilterClasses = [];

sub register {
    my ($self, $app) = @_;
    $app->helper( add_filter_class => \&_add_filter_class );
    $app->app->hook( around_action => \&_around_action_handler);
}

sub _add_filter_class {
    my ($c, $filter_class) = @_;
    my $L = $c->app->log;
    $L->debug(__PACKAGE__ . ": Adding user filter class - $filter_class");
    push @$FilterClasses, $filter_class;
}

sub _around_action_handler {
    my ($next, $c, $action, $is_last) = @_;
    if (_filter($c, $action)) {
	return $next->();
    }
}

sub _filter {
    my ($c, $action) = @_;
    my $class = ref($c);
    my $L = $c->app->log;

    no strict 'refs'; # lexically scoped, I'm told

    # Does this controller have a hash ref of FILTER_ACTIONS?
    my $filter_actions = ${"${class}::BEFORE_FILTERS"};

    if (ref $filter_actions eq 'HASH') {
	while (my ($filter_action, $filtered_methods) = each (%$filter_actions)) {
	    # Does action about to occur match one of the request methods to filter?
	    for my $filtered_method (@{$filtered_methods || []}) {
		my $filtered_method_ref = \&{"${class}::$filtered_method"};
		if ($action eq $filtered_method_ref) {
		    $L->debug(__PACKAGE__ . ": matched '$filter_action' to '$filtered_method'");
		    my $has_matched = 0;
		    # Find the appropriate filter in FilterClasses to apply
		    for my $filter_class (@$FilterClasses) {
			# Need to load these filter classes before I can introspect them
			eval "require $filter_class";
			if ($@) {
			    $L->error(__PACKAGE__ . ": Could not load '$filter_class'");
			}

			if ($filter_class->can($filter_action)) {
			    $L->debug(__PACKAGE__ . ": applying '${filter_class}::$filter_action' to '$filtered_method'");
			    $filter_class->$filter_action($c, $filtered_method);
			    $has_matched = 1;
			}
		    }

		    unless ($has_matched) {
			$L->warn(__PACKAGE__ . ": No filter class can implemented '$filter_action' for '$filtered_method'");
		    }
		}
	    }
	}
    }
    return 1;
}

1;
