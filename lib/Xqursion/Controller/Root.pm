package Xqursion::Controller::Root;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
  my $self = shift;

  $self->render();
}

1;
