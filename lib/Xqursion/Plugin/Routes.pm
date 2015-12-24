package Xqursion::Plugin::Routes;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Plugin';

# Put all the routing stuff in one place
sub make_routes {
    my ($self, $app) = @_;

    # Router
    my $r = $app->routes;

    # Normal route to controller
    $r->get('/')->name("root")->to('root#welcome');
    $r->get("/privacy")->name("privacy")->to("root#privacy");
    $r->post("/find_account")->name("find_account")->to("root#find_account");

    # Users
    $r->get("/user/:id/reset_password")->name("user_reset_password_form")->to("users#reset_password_form");
    $r->get("/user/creation_thankyou")->name("user_creation_thankyou")->to("users#creation_thankyou");
    $r->get("/user/:id/request_password_reset")->name("user_request_password_reset")->to("users#request_password_reset");
    $r->get("/users")->name("users")->to("users#index");
    $r->post("/user/create")->to("users#create");
    $r->get("/user/:id/edit")->name("user_edit")->to("users#edit"); # For authed users
    $r->post("/user/:id/reset_password")->name("user_reset_password_update")->to("users#reset_password_update"); # no auth
    $r->post("/user/:id")->name("user_update")->to("users#update");

    # Sessions
    $r->post("/sessions/create")->to("sessions#create");
    $r->delete("/sessions/destroy")->to("sessions#destroy");

    # Dashboard
    $r->get("/app/dashboard")->name("your_dashboard")->to("dashboards#index");

    # Dialogs
    $r->get("/app/dialogs/confirm")->name("dialog_confirm")->to("dialogs#confirm");
    $r->get("/app/dialogs/alert")->name("dialog_alert")->to("dialogs#alert");

    # Journeys
    $r->get("/app/journeys")->name("journeys_index")->to("journeys#index");
    $r->get("/app/journey/new")->name("journey_new")->to("journeys#New");
    $r->get("/app/journey/:id/edit")->name("journey_edit")->to("journeys#edit");
    $r->get("/app/journey/:id/download")->name("journey_download")->to("journeys#export");
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

    # Dependencies
    $r->post("/app/dependency")->name("dependency_create")->to("dependencies#create");
    $r->delete("/app/dependency/:id")->name("dependency_delete")->to("dependencies#delete");

    # Journey logs
    $r->get("/app/journey/:journey_id/logs")->name("journey_logs_index")->to("journey_logs#index");
    $r->get("/app/journey/:journey_id/log/:session_id")->name("journey_log_show")->to("journey_logs#show");

    # Public steps: where users interact with journeys
    $r->get("/step/:id")->name("porter_step_show")->to("porter_steps#show");

    # Administrators
    my $admin = $r->under("/admin" => sub { my ($c) = @_; $self->is_admin($app, $c) });
    $admin->get("/dashboard")->name("admin_dashboard")->to("admin_root#index");
}


sub is_admin {
    my ($self, $app, $controller) = @_;
    my $L = $app->log;
    
    if (my $uid = $controller->session("user_id")) {
        $L->debug("Looking up user '$uid'");
        my $user = $app->db->resultset("User")->single({id => $uid});
        if ($user) { 
            return $user->is_admin;
        } else {
            $L->debug("No user found with ID '$uid'");
        }       
    }

    $controller->flash(error => "You are not authorizated for that page");
    return $controller->redirect_to("your_dashboard");
}

sub register {
    my ($self, $app) = @_;
    $app->helper( make_routes => sub { $self->make_routes($app) } );
}

1;
