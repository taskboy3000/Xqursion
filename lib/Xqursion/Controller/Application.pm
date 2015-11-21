package Xqursion::Controller::Application;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Controller';

sub validate_user {
    my ($self) = shift;
    unless ($self->current_user) {
        $self->redirect_to("/");
    }
    return 1;
}

sub current_user {
    my ($self) = shift;

    # Check for cookie
    if (my $uid = $self->session("user_id")) {
        my $user = $self->app->db->resultset("User")->single({id => $uid});
        if ($user) {
            return $user;
        }
    }

    $self->app->log->debug("User is not authenticated");
    return;    
}


1;
