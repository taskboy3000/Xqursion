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
    $r->get("/app/dashboard")->name("your_dashboard")->to("dashboards#index");

    # Journeys
    $r->get("/app/journeys")->name("journeys_index")->to("journeys#index");
    $r->get("/app/journey/new")->name("journey_new")->to("journeys#new");
    $r->get("/app/journey/:id/edit")->name("journeys_update")->to("journeys#edit");
    $r->post("/app/journey")->name("journey_create")->to("journeys#create");
    $r->post("/app/journey/:id")->name("journeys_update")->to("journeys#update");
    $r->delete("/app/journey/:id")->name("journeys_delete")->to("journeys#delete");

}

sub register {
    my ($self, $app) = @_;
    $app->helper( make_routes => sub { $self->make_routes($app) } );
}

1;
