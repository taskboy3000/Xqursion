package Xqursion::Controller::Users;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';

sub create {
    my ($self) = shift;

    return $self->no_auth unless $self->valid_csrf;

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
    $self->flash(info => "Your account is created.  Please log in.");
    return $self->redirect_to("/");
}

sub edit {
    my ($self) = @_;
    
    return $self->render(user => $self->current_user);
}

sub update {
    my ($self) = @_;

    return $self->no_auth unless $self->valid_csrf;

    my $user = $self->current_user;
    my $V = $self->validation;
    my $L = $self->app->log;
    
    # Usernames and email addresses must be unique
    my $db = $self->app->db;
    if ($self->param("username")) {
        if ($db->resultset("User")->count({username => $self->param("username")}) > 0) {
            # error
            $V->error(username => ["Username name is taken"]);
        } else {
            $user->username($self->param("username"));
        }
    }

    if ($self->param("email")) {
        if ($db->resultset("User")->count({email => $self->param("email")}) > 0) {
            $V->error(username => ["Email name is taken"]);
        } else {
            $user->email($self->param("email"));
        }
    }

    if ($self->param("password")) {
        if ($self->param("password") eq $self->param("confirm_password")) {
            $L->debug("Updating password");
            $user->password_hash($user->hash_password($self->param("password")));
        } else {
            $V->error(password => ["Password does not match confirmation"]);
        }
    }

    if ($V->has_error) {
        return $self->edit;
    }

    $L->debug("Updating user settings");
    unless ($user->update) {
        $L->debug("User's settings did not update");
    }

    $self->flash(info => "Your account changes have been saved.");
    return $self->redirect_to($self->url_for("your_dashboard"));
}

1;
