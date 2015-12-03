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

    # Dialogs
    $r->get("/app/dialogs/confirm")->name("dialog_confirm")->to("dialogs#confirm");
    $r->get("/app/dialogs/alert")->name("dialog_alert")->to("dialogs#alert");

    # Journeys
    $r->get("/app/journeys")->name("journeys_index")->to("journeys#index");
    $r->get("/app/journey/new")->name("journey_new")->to("journeys#New");
    $r->get("/app/journey/:id/edit")->name("journey_edit")->to("journeys#edit");
    $r->get("/app/journey/:id/download")->name("journey_download")->to("journeys#download");
    $r->post("/app/journey")->name("journey_create")->to("journeys#create");
    $r->post("/app/journey/:id")->name("journeys_update")->to("journeys#update");
    $r->delete("/app/journey/:id")->name("journey_delete")->to("journeys#delete");

    # Steps
    $r->get("/app/journey/:journey_id/steps")->name("journey_steps_index")->to("steps#index");
    $r->get("/app/journey/:journey_id/step/new")->name("journey_step_new")->to("steps#New");
    $r->get("/app/journey/:journey_id/step/:id/edit")->name("journey_step_edit")->to("steps#edit");
    $r->post("/app/journey/:journey_id/step")->name("journey_step_create")->to("steps#create");
    $r->post("/app/journey/:journey_id/step/:id")->name("journey_step_update")->to("steps#update");
    $r->delete("/app/journey/:journey_id/step/:id")->name("journey_step_delete")->to("steps#delete");

    # DependencyGroups
    $r->get("/app/step/:step_id/dependency_group/new")->name("step_dependency_group_new")->to("dependency_groups#New");
    $r->get("/app/step/:step_id/dependency_group/:id/edit")->name("step_dependency_group_edit")->to("dependency_groups#edit");
    $r->post("/app/step/:step_id/dependency_group")->name("step_dependency_group_create")->to("dependency_groups#create");
    $r->post("/app/step/:step_id/dependency_group/:id")->name("step_dependency_group_update")->to("dependency_groups#update");
    $r->delete("/app/dependency_group/:id")->name("step_dependency_group_delete")->to("dependency_groups#delete");
    
}

sub register {
    my ($self, $app) = @_;
    $app->helper( make_routes => sub { $self->make_routes($app) } );
}

1;
