package Xqursion::Controller::Journeys;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Controller';

our $BEFORE_FILTERS = { "require_authentication" => [ 'index', 'show', 'New', 'create', 'edit', 'delete' ] };

sub index {
    my $self = shift;
    $self->render(c => $self);
}

# Form to create new 
sub New {
    my $self = shift;
   
    $self->render();
}

# Form handler for new
sub create {
    my $self = shift;
    $self->app->log->warn("OK");
    return $self->redirect_to("journeys_index");
}

# Form to edit existing
sub edit {
    my $self = shift;
    $self->render();
}

# Form handler for edit
sub update {
    my $self = shift;
    $self->index;
}

sub delete {
    my $self = shift;
    $self->redirect_to("/"); # redirect to list
}
1;
