package Xqursion::Controller::Dashboards;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';

our $BEFORE_FILTERS = { "require_authentication" => [ 'index' ] };

sub index {
    my ($self) = shift;
    $self->render();
}

sub other {
    my ($self) = shift;
    return $self->render(inline => "OK, computer");
}
1;
