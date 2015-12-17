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

        for my $f ("title", "url", "dependency_group_id", "error_url", "create_new_session") {
            $L->debug("Setting field '$f'");
            $step->$f($self->param($f));
        }

	if ($step->insert) {
	    $L->debug("Created step: " . $step->id);
            $self->flash(info => "Created step " . $step->title);

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
    for my $f ("title", "url", "dependency_group_id", "error_url", "create_new_session") {
        $L->debug("Setting field '$f'");
        $step->$f($self->param($f));
    }

    unless ($step->update) {
        # redirect to form for validation errors
        $L->debug("Update failed");
    }

    $self->flash(info => "Updated step " . $step->title);

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
    $self->respond_to( json => { json => { success => 1 } } );
}

1;
