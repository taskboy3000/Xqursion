package Xqursion::Plugin::Routes;
use strict;
use Mojo::Base 'Mojolicious::Plugin';

# Put all the routing stuff in one place
sub make_routes {
    my ($self, $app) = @_;
    
    # Router
    my $r = $app->routes;

    # Normal route to controller
    $r->get('/')->to('root#welcome');

    # Users
    $r->post("/user/create")->to("users#create");

    # Sessesions
    $r->post("/sessions/create")->to("sessions#create");

    # Dashboard 
    $r->get("/app/dashboard")->to("dashboards#index");
}

sub register {
    my ($self, $app) = @_;
    $app->helper( make_routes => sub { $self->make_routes($app) } );
}

1;