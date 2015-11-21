package Xqursion::Controller::Dashboards;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Controller';

our $FILTER_ACTIONS = { "require_authentication" => [ 'index' ] };

sub index {
    my ($self) = shift;
    $self->render();
}

sub other {
    my ($self) = shift;
    return $self->render(inline => "OK, computer");
}
1;
