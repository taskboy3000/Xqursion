package Xqursion::Controller::Root;
use Mojo::Base 'Xqursion::Controller::Application';

# This action will render a template
sub welcome {
  my $self = shift;

  $self->render();
}

1;
