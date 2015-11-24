package Xqursion::Controller::Application;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Controller';

sub current_user {
    my ($self) = shift;

    # Check for cookie
    if (my $uid = $self->session("user_id")) {
	$self->app->log->debug("Looking up user '$uid'");
        my $user = $self->app->db->resultset("User")->single({id => $uid});
        if ($user) {
            return $user;
        }
    }

    $self->app->log->debug("User is not authenticated");
    return;    
}


1;
