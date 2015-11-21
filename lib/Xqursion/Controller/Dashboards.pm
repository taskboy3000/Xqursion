package Xqursion::Controller::Dashboards;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Controller';

sub index {
    my ($self) = shift;
    $self->render();
}

1;
