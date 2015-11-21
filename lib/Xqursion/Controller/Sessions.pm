package Xqursion::Controller::Sessions;
use Modern::Perl '2012';
#use Mojo::Base 'Xqursion::Controller::Application';
use Mojo::Base 'Mojolicious::Controller';

sub create {
    my ($self) = shift;

    if ($self->param("username") && $self->param("password")) {
        my $user = $self->app->db->resultset("User")->single({username => $self->param("username")});
        if ($user) {
            if ($user->is_password_valid($self->param("password"))) {
		$self->app->log->debug("Credentials verified");
                $self->session("user_id" => $user->id);
                return $self->redirect_to("/app/dashboard");    
            }
        }
    }
    $self->app->log->debug("Login failed for " . $self->param("username"));
    return $self->redirect_to("/?login+failed");
}

1;
