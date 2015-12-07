package Xqursion::Command::queue;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Command';

has description => "Run the next available job in the work queue";
has usage => "";

sub run {
    my ($self) = shift;
    $self->wq_run_next;
}

1;
