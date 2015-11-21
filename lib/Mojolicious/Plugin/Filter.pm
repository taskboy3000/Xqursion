package Mojolicious::Plugin::Filter;
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
    my $filter_actions = ${"${class}::FILTER_ACTIONS"};

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
