package Xqursion::Controller::Users;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Controller';

sub create {
    my ($self) = shift;

    # Do the passwords match?
    if ($self->param("password") ne $self->param("confirm_password")) {
        return $self->redirect_to("/");
    }
    
    # Does this user exist?
    my @found = $self->db->resultset("User")->search({ username => $self->param('username'),
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

    # XXX - do something smarter
    $user->save();

    return $self->redirect_to("/");
}

1;
