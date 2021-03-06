package Xqursion::Controller::Sessions;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';
use DateTime;

sub create {
    my ($self) = shift;

    return $self->no_auth unless $self->valid_csrf;

    if ($self->param("username") && $self->param("password")) {
        my $user = $self->app->db->resultset("User")->single({username => $self->param("username")});
        if ($user) {
            if ($user->is_password_valid($self->param("password"))) {
		$self->app->log->debug("Starting session");
                $self->session("user_id" => $user->id, "started" => scalar time());
                $user->last_login_at(DateTime->now());
                $user->update;
                return $self->redirect_to("/app/dashboard");
            } else {
                $self->flash(error => "Bad credentials");
            }
        }
    }
    $self->app->log->debug("Login failed for " . $self->param("username"));
    return $self->redirect_to("/");
}

sub destroy {
    my ($self) = shift;

    $self->app->log->debug("Ending web session");
    $self->session("user_id" => "", "started" => 0);
    $self->session(expires => 0);
    return $self->redirect_to("/");
}

1;
