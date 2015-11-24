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


1;
