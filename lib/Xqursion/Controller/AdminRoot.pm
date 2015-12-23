package Xqursion::Controller::AdminRoot;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';

sub index {
    my ($self) = @_;
    return $self->render;
}

1;
