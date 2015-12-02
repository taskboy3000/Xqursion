package Xqursion::Controller::Dialogs;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';

sub confirm { 
    my $self = shift;
    $self->stash(
                 show_action_button => 1,
                 close_button_label => "Cancel",
                 action_button_label => "Yes",
                );
}

sub alert {
    my $self = shift;
    $self->stash(
                 show_action_button => 0,
                 close_button_label => "OK",
                 action_button_label => "",
                );

}

1;
