package Xqursion::Controller::Root;
use Mojo::Base 'Xqursion::Controller::Application';


# This action will render a template
sub welcome {
  my $self = shift;

  #  $self->flash("info" => "Welcome");
  $self->render();
}


sub privacy { shift->render() }


sub find_account {
    my ($self) = @_;
    my $userRS = $self->app->db->resultset("User");

    return $self->no_auth unless $self->valid_csrf;

    my $user;
    if ($self->param("username")) {
        $user = $userRS->search({username => $self->param("username")})->first;
    }

    if ($self->param("email")) { 
        $user = $userRS->search({email => $self->param("email")})->first;
   }

    unless ($user) {
        $self->flash(error => "Could not find account");
        return $self->redirect_to("/");
    }

    $self->redirect_to($self->url_for("user_request_password_reset", id => $user->id));
}

1;
