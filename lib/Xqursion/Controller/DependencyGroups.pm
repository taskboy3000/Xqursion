package Xqursion::Controller::DependencyGroup;
use Modern::Perl '2012';

our $BEFORE_FILTERS = { "require_authentication" => [ 'index', 'show', 'New', 'create', 'edit', 'delete' ] };

sub index {
    my $self = shift;
    my $L = $self->app->log;
    my $D = $self->app->db;

    my $current_user = $self->current_user;
    # FIXME
    $self->render();
}

# Form to create new 
sub New {
    my $self = shift;
    my $D = $self->app->db;
    my $current_user = $self->current_user;

    my $dp = $D->resultset("DependencyGroup")->new({});
    $dp->step_id($self->param("step_id"));
    $self->render(dependency_group => $dp);
}

# Form handler for new
sub create {
    my $self = shift;
    my $L = $self->app->log;
    my $D = $self->app->db;
    my $current_user = $self->current_user;

    if ($current_user && $self->param("title")) {
        my $dp = $D->resultset("DependencyGroup")->new({});
	$dp->create_id;
        $dp->step_id($self->param("step_id"));
        $dp->title($self->param("title"));
        $dp->operation($self->param("operation"));

	if ($dp->insert) {
	    $L->debug("Created dependency group: " . $dp->id);
	} else {
	    $L->warn("Failed to create dependency group");
	}
    } else {
	# XXX ERROR
    }
    
    # FIXME
    return $self->redirect_to("????index", { step_id => $self->param("step_id") });
}

# Form to edit existing
sub edit {
    my $self = shift;
    my $db = $self->app->db->resultset("DependencyGroup")->find($self->param("id"));
    $self->render(dependency_group => $db);
}

# Form handler for edit
sub update {
    my $self = shift;
    my $L = $self->app->log;
    my $D = $self->app->db;

    my $dp = $D->resultset("DependencyGroup")->find($self->param("id"));
    for my $f ("title", "operation") {
        $L->debug("Setting field '$f'");
        $dp->$f($self->param($f));
    }

    unless ($dp->update) {
        # redirect to form for validation errors
        $L->debug("Update failed");
    }

    # FIXME
    return $self->redirect_to($self->url_for("???_index", journey_id => $self->param("id")));
}

sub delete {
    my $self = shift;
    my $L = $self->app->log;
    my $D = $self->app->db;
    my $current_user = $self->current_user;

    my $dp = $D->resultset("DependencyGroup")->find($self->param("id"));
    if ($dp) {
        if ($dp->step->journey->user_id ne $current_user->id) {
            $L->warn("Permission error: user '@{$current_user->email}' tried to remove step '@{$dp->id}'");
        } else {
            $dp->delete;
        }
    }
    $self->respond_to( json => { json => { success => 1 } } );
}


1;
