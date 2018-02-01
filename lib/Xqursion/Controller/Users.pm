package Xqursion::Controller::Users;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';

our $BEFORE_FILTERS = { "require_authentication" => [ 'index', 'New', 'create', 'edit', 'delete', 'index' ] };

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
    my $L = $self->app->log;
    
    return $self->no_auth unless $self->valid_csrf;

    my $validation = $self->validation;

    # Does this user exist?
    my $userRS = $db->resultset("User");
    for my $field ('username', 'email') {
        if ($userRS->count({ $field => $self->param($field) })) {
            my $error = sprintf ("%s '%s' is taken. Choose another",
                                 ucfirst($field),
                                 $self->param("username"));
            $validation->error($field => $error);
            
        }

        $validation->required($field)->size(3,64);
    }

    $validation->required("email")->like(qr/^[^@]+@[^@]+$/);
    
    if ($validation->has_error) {
        my @errors;
        for my $field ('username', 'email') {
            my @e = ref $validation->error($field) ? @{$validation->error($field)} : $validation->error($field);
            push @errors, @e;
        }
        $L->error(join(",", @errors));
        $self->flash(error => "Warning: " . join("; ", @errors));
        return $self->redirect_to("/");
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
    for my $field ("username", "email") {
	if ($self->_unique_field($field, $V)) {
	    $user->$field($self->param($field));
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
        $self->flash(error => "There was a problem saving your changes");
        return $self->redirect_to($self->url_for("user_edit", id => $user->id));
    }

    $self->flash(info => "Your account changes have been saved.");
    return $self->redirect_to($self->url_for("your_dashboard"));
}

sub _unique_field {
    my ($self, $field, $validator) = @_;
    my $user = $self->current_user;
    my $U = $self->app->db->resultset("User");

    for my $field ("username", "email") {
	next unless $self->param($field);
	next if $self->param($field) eq $user->$field();

	if ($U->count({$field => $self->param($field)}) > 0) {
	    $validator->error($field => [ "$field value is already in use" ]);
	    return;
	}
    }

    return 1;
}

sub index {
    my $self = shift;

    my $users = $self->app->db->resultset('User')->search(
                                                          undef,
                                                          { page => $self->param("page") || 1,
                                                            rows => $self->param("rows") || 2
                                                          }
                                                         );

    my $pager = $users->pager;
    my @inflated_users = map { $_->TO_JSON } $users->all();

    my $page = {
                first_page => $pager->first_page,
                last_page  => $pager->last_page,
                current_page => $pager->current_page,
                total_entries => $pager->total_entries,
                entries => \@inflated_users,
               };

    $self->respond_to(
                      json => { json => $page },
                      html => { pager => $users->pager },
                     );
}


sub delete {
    my ($self) = @_;
    my $user = $self->current_user;
    if (!$user->is_admin) {
        return $self->no_auth;
    }

    $self->respond_to(
        json => sub { $self->render(json => $self->delete_from_api ) },
        any => sub { $self->no_auth }
    );
}

sub delete_from_api {
    my ($self) = @_;

    my $db = $self->app->db;
    my $L = $self->app->log;
    my $id = $self->param("id");

    my %ret = ( success => 0 );
    if (!$id) {
        $ret{error} = "No ID";
        return \%ret;
    }

    $L->info("Removing user $id");

    my $userRS = $self->app->db->resultset("User")->search({ id => $id});
    eval {
        $ret{success} = $userRS->delete();
    } or do {
        $ret{error} = "Could not delete user $id";
    };

    return \%ret;
}

1;
