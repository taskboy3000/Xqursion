package Xqursion;
use strict;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugins;
use Schema;
use List::Util ('any');

has schema => sub {
    return Schema->connect("dbi:SQLite:" . ($ENV{XQURSION_DB} || "share/schema.db"));
};

# This method will run once at server start
sub startup {
    my $self = shift;
    
    $self->secrets([$ENV{XQURSION_APP_SECRET} || '0987654321']);

    $self->app->sessions->cookie_name($self->app->moniker);
    $self->app->sessions->default_expiration(86400);
    
    $self->helper(db => sub { $self->app->schema });

    $self->plugin("Config");
    # push @{$plugins->namespaces}, 'Xqursion::Plugin';
    $self->plugin('Xqursion::Plugin::Routes',);

    $self->make_hooks();
    $self->make_routes();
}

sub make_hooks {
    my ($self) = shift;
    # http://cpansearch.perl.org/src/GRISHKOV/Mojolicious-Plugin-AdvancedMod-0.38
    $self->app->hook(
                     around_action => sub {
			 my ($next, $c, $action, $last) = @_;
                         if (_filter($c, $action)) {
			     return $next->();    
			 }
                     }
                    );
    
}

sub _filter {
    my ($c, $action) = @_;
    
    my $class = ref($c);

    no strict 'refs';
    my $filter_actions = ${"${class}::FILTER_ACTIONS"};
    if (ref $filter_actions) {
	while (my ($filter_action, $filtered_methods) = each (%$filter_actions)) {
	    for my $filtered_method (@{$filtered_methods || []}) {
		my $ref = \&{"${class}::$filtered_method"};
		if ($ref eq $action) {
		    $c->app->log->debug("_filter: matched '$filter_action' to '$filtered_method'");
		    my $sub = \&{"_$filter_action"};
		    if (defined $sub) {
			$c->app->log->debug("_filter: applying '$filter_action' to '$filtered_method'");
			return $sub->($c, $filtered_method);
		    }
		}
	    }
	}
    }
    use strict 'refs';
}

sub _require_authentication {
    my ($c, $method) = @_;
    $c->app->log->debug("Begining _require_authentication");

    # Check for cookie
    if (my $uid = $c->session("user_id")) {
        my $user = $c->app->db->resultset("User")->single({id => $uid});
        if ($user) {
            return 1;
        }
    }

    $c->app->log->debug("User is not authenticated");
    return $c->redirect_to("/");  
}

1;
