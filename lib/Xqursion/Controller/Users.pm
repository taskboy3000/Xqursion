package Xqursion::Controller::Users;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Controller';

sub create {
    my ($self) = shift;
    $self->app->log->error("Blort");
    # Password exists?
    unless ($self->param("password")) {
        warn("No password");
        return $self->redirect_to("/");
    }

    # Do the passwords match?
    if ($self->param("password") ne $self->param("confirm_password")) {
        warn("Password doesn't match");
        return $self->redirect_to("/");
    }
    
    my $db = $self->db;
    die unless $db;

    # Does this user exist?
    my @found = $db->resultset("User")->search({ username => $self->param('username'),
                                                       email => $self->param('email')
                                                     });
    if (@found) {
        return $self->redirect_to("/");
    }

    my $user = $self->db->resultset("User")->new({   
                                                   username => $self->param("username"), 
                                                   email => $self->param("email"),
                                                 });
    $user->create_id();
    $user->password_hash($user->hash_password($self->param("password")));

    $user->insert();

    return $self->redirect_to("/");
}

1;
