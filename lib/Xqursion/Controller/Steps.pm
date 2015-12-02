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

    # Should check that $journey->user_id eq $current_user->id
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
    $step->journey_id($self->param("journey_id"));
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
    my $L = $self->app->log;
    my $D = $self->app->db;

    my $step = $D->resultset("Step")->find($self->param("id"));
    for my $f ("title", "url", "ordering", "dependency_group_id", "error_url") {
        $L->debug("Setting field '$f'");
        $step->$f($self->param($f));
    }

    unless ($step->update) {
        # redirect to form for validation errors
        $L->debug("Update failed");
    }

    return $self->redirect_to($self->url_for("journey_steps_index", journey_id => $self->param("journey_id")));
}

sub delete {
    my $self = shift;
    my $L = $self->app->log;
    my $D = $self->app->db;
    my $current_user = $self->current_user;

    my $step = $D->resultset("Step")->find($self->param("id"));
    if ($step) {
        if ($step->journey->user_id ne $current_user->id) {
            $L->warn("Permission error: user '@{$current_user->email}' tried to remove step '@{$step->id}'");
        } else {
            $step->delete;
        }
    }
    $self->render(json => { success => 1 });
}

1;
