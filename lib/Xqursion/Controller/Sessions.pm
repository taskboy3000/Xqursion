package Xqursion::Controller::Sessions;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Controller';

sub is_valid {
    my ($self) = shift;
    unless ($self->is_user_authenticated) {
        $self->app->log->warn("User is not authenticated");
        return $self->redirect_to("/?no+auth");
    }
    return 1;
}

sub create {
    my ($self) = shift;
    
    if ($self->param("username") && $self->param("password")) {
        if (my $user_id = $self->app->authenticate($self->param("username"),
                                       $self->param("password"))) {
            $self->session(user_id => $user_id);
            return $self->redirect_to("/dashboard/");
        }
    }
    $self->app->log->warn("Login failed for " . $self->param("username"));
    return $self->redirect_to("/?login+failed");
}

1;
