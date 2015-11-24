package Xqursion::Controller::Journeys;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Controller';

our $BEFORE_FILTERS = { "require_authentication" => [ 'index', 'show', 'New', 'create', 'edit', 'delete' ] };

sub index {
    my $self = shift;
    my $L = $self->app->log;
    my $current_user = $self->current_user;
    my $journeys = $current_user->journeys->all;

    $self->render(c => $self, journeys => $journeys);
}

# Form to create new 
sub New {
    my $self = shift;

    $self->render();
}

# Form handler for new
sub create {
    my $self = shift;
    my $L = $self->app->log;
    my $current_user = $self->current_user;

    if ($current_user && $self->param("name")) {
	my $journey = $self->app->db->resultset("Journey")->new;
	$journey->name = $self->param("name");
	$journey->user_id = $current_user->id;
	$journey->start_date = $self->param("start_date") if $self->param("start_date");
	$journey->end_date = $self->param("end_date") if $self->param("end_date");
	$journey->create_id;
	if ($journey->insert) {
	    $L->debug("Created journey: " . $journey->id);
	} else {
	    $L->warn("Failed to create journey");
	}
    } else {
	# XXX ERROR
    }
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
