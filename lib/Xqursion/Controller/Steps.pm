package Xqursion::Controller::Steps;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';

our $BEFORE_FILTERS = { "require_authentication" => [ 'index', 'show', 'New', 'create', 'edit', 'delete' ] };

sub index {
    my $self = shift;
    my $L = $self->app->log;
    my $D = $self->app->db;

    my $current_user = $self->current_user;
    my $journey = $D->resultset("Journey")->single({id => $self->param("journey_id")});

    my $steps = [];

    if ($journey) {
        $steps = [ $journey->steps];
    }

    $self->render(journey => $journey, steps => $steps);
}

# Form to create new 
sub New {
    my $self = shift;
    my $D = $self->app->db;
    my $current_user = $self->current_user;

    my $step = $D->resultset("Step")->new({});

    $step->user_id($current_user->id);
    $self->journey_id($self->param("journey_id"));
    $self->render(step => $step);
}

# Form handler for new
sub create {
    my $self = shift;
    my $L = $self->app->log;
    my $D = $self->app->db;
    my $current_user = $self->current_user;

    if ($current_user && $self->param("title")) {
        my $step = $D->resultset("Step")->new({});
	$step->create_id;
        $step->user_id($current_user->id);
        $step->journey_id($self->param("journey_id"));
        $step->title($self->param("title"));
        $step->url($self->param("url"));

        $self->param("ordering") = 1 unless $self->param("ordering");
        $step->ordering($self->param("ordering"));

        $step->dependency_group_id($self->param("dependency_group_id"));
        $step->error_url($self->param("error_url"));

	if ($step->insert) {
	    $L->debug("Created step: " . $step->id);
	} else {
	    $L->warn("Failed to create step");
	}
    } else {
	# XXX ERROR
    }
    return $self->redirect_to("journey_steps_index", { journey_id => $self->param("journey_id") });
}

# Form to edit existing
sub edit {
    my $self = shift;
    my $step = $self->app->db->resultset("Step")->find($self->param("id"));
    $self->render(step => $step);
}

# Form handler for edit
sub update {
    my $self = shift;

    my $journey = $self->app->db->resultset("Journey")->find($self->param("id"));
    for my $f ("name", "start_at", "end_at") {
        $journey->$f($self->param($f));
    }

    unless ($journey->update) {
        # redirect to form for validation errors
    }
    $self->index;
}

sub delete {
    my $self = shift;
    $self->redirect_to("/"); # redirect to list
}

1;
