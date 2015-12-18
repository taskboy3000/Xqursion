package Xqursion::Controller::Users;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';

sub creation_thankyou {
    return shift->render();
}


sub reset_password_form {
    my ($self) = @_;
    my $userRS = $self->app->db->resultset("User");

    my $validation = $self->validation;

    my $user = $userRS->find($self->param("id"));
    unless ($user) {
        $validation->error("no_user" => "No account found for the given ID");
    }

    if ($validation->has_error) {
        my $errors = join("; ", values %{$validation->output});
        $self->flash(error => $errors);
        return $self->redirect_to("/");
    }
    
    return $self->render(this_user => $user);
}

sub reset_password_update {
    my ($self) = @_;

    return $self->no_auth unless $self->valid_csrf;

    my $userRS = $self->app->db->resultset("User");
    my $validation = $self->validation;

    my $user = $userRS->find($self->param("id"));
    unless ($user) {
        $validation->error("no_user" => "No account found for the given ID");
    }

    unless($validation->has_error) {
        if ($user->reset_token ne $self->param("token")) {
            $validation->error("token" => "Security token does not match expected");
        }
    }
    
    unless($validation->has_error) {
        if ($self->param("password")) {
            if ($self->param("password") ne $self->param("confirm_password")) {
                $validation->error("password" => "Passwords does not match");
            }
        } else {
            $validation->error("password" => "Passwords cannot be empty");
        }
    }

    if ($validation->has_error) {
        my $errors = join("; ", values %{$validation->output});
        $self->flash(error => $errors);
        return $self->redirect_to("/");
    }

    $user->password_hash($user->hash_password($self->param("password")));
    $user->reset_token(undef);

    if ($user->update) {
        $self->flash(info => "Your password has been updated.");
    } else {
        $self->flash(error => "Your password change could not be recorded");        
    }

    return $self->redirect_to("/");
}

sub request_password_reset {
    my ($self) = @_;
    
    my $userRS = $self->app->db->resultset("User");
    my $user = $userRS->find($self->param("id"));

    $user->create_reset_token;
    $user->update;
    my $msg = $self->render_mail(template => "mail/password_reset", url => $user->get_reset_url);
    $self->app->log->debug("Mailing:\n$msg\n");
    $self->mail(to => $user->email,
                subject => "Xqursion password reset",
                data => $msg
               );

    return $self->render();
}

sub create {
    my ($self) = shift;
    my $db = $self->app->db;

    return $self->no_auth unless $self->valid_csrf;

    my $validation = $self->validation;

    # Does this user exist?
    my $userRS = $db->resultset("User");
    for my $field ('username', 'email') {
        if ($userRS->count({ $field => $self->param($field) })) {
            my $error = sprintf ("%s '%s' is taken. Choose another.",
                                 ucfirst($field),
                                 $self->param("username"));
            $validation->error($field => $error);
        }
    }

    if ($validation->has_error) {
        my $errors = join "; ",  values %{$validation->output};
        $self->flash(error => "ERROR: $errors");
        $self->redirect_to("/");
    }

    my $user = $userRS->new({   
                             username => $self->param("username"), 
                             email => $self->param("email"),
                            });

    $user->create_id()->create_reset_token();
    $user->password_hash("NEWUSER"); # this is an unlikely hash value

    if ($user->insert()) {
        $self->flash(info => "Your account is created.  Please look for an email with login instructions");
        my $msg = $self->render_mail(template => "mail/welcome", url => $user->get_reset_url);
        $self->mail(to => $user->email,
                    subject => "Welcome to Xqursion",
                    data => $msg);
        return $self->redirect_to($self->url_for("user_creation_thankyou"));
    }

    $self->flash(error => "A problem occurred while creating your account.");
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
        if ($self->param("username") ne $user->username) {
            if ($db->resultset("User")->count({username => $self->param("username")}) > 0) {
                # error
                $V->error(username => ["Username name is taken"]);
            } else {
                $user->username($self->param("username"));
            }
        }
    }

    if ($self->param("email")) {
        if ($self->param("email") ne $user->email) {
            if ($db->resultset("User")->count({email => $self->param("email")}) > 0) {
                $V->error(email => ["Email name is taken"]);
            } else {
                $user->email($self->param("email"));
            }
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

    my $errors = join "; ",  map { $_->[0] } grep { length($_) > 0 } map { $V->error($_) } ('password', 'username', 'email');

    if ($errors) {
        $L->debug("Errors: $errors");
        $self->flash(error => $errors);
        return $self->redirect_to($self->url_for("user_edit", id => $user->id));
    }

    $L->debug("Updating user settings");
    unless ($user->update) {
        $L->debug("User's settings did not update");
        my $errors = join("; ", values %{$V->output});
        $self->app->log->debug($errors);
        $self->flash(error => $errors);
        return $self->redirect_to($self->url_for("user_edit", id => $user->id));
    }

    $self->flash(info => "Your account changes have been saved.");
    return $self->redirect_to($self->url_for("your_dashboard"));
}


1;
