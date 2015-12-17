package Xqursion::Controller::Application;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Controller';

sub current_user {
    my ($self) = shift;
    my $L = $self->app->log;
    
    # Check for cookie
    if (my $uid = $self->session("user_id")) {
	$L->debug("Looking up user '$uid'");
        my $user = $self->app->db->resultset("User")->single({id => $uid});
        if ($user) {
            $L->debug("Found user " . $user->email);
            return $user;
        }
    }

    $L->debug("User is not authenticated");
    return;
}

sub valid_csrf {
    my ($self) = @_;
    
    my $validation = $self->validation;
    return !$validation->csrf_protect->has_error("csrf_token");
}

sub no_auth {
    my $self = @_;
    return $self->render(text => 'Bad CSRF token!', status => 403);
}

1;
