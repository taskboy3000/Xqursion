package Xqursion::Controller::DependencyGroups;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';

our $BEFORE_FILTERS = { "require_authentication" => [ 'show', 'New', 'create', 'edit', 'delete' ] };

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

    my $dp = $D->resultset("DependencyGroup")->new({});
    my $step = $D->resultset("Step")->find($self->param("step_id"));

    if ($current_user && $self->param("title")) {
	$dp->create_id;
        $dp->step_id($self->param("step_id"));
        $dp->title($self->param("title"));
        $dp->operation($self->param("operation"));

	if ($dp->insert) {
	    $L->debug("Created dependency group: " . $dp->id);
            $step->dependency_group_id($dp->id);
            $step->update;
	} else {
	    $L->warn("Failed to create dependency group");
	}
    } else {
	# XXX ERROR
    }
    
    return $self->redirect_to("step_dependency_group_edit", { step_id => $step->id, id => $dp->id });
}

# Form to edit existing
sub edit {
    my $self = shift;
    my $dg = $self->app->db->resultset("DependencyGroup")->find($self->param("id"));

    my %known_dependencies;
    for my $d ($dg->dependencies) {
	$known_dependencies{ $d->step_id } = 1;
    }

    my @tmp;
    for my $s ($dg->step->journey->steps) {
	next if $s->id eq $dg->step->id; # don't include the controlled target as a dependency!
	# don't include dependencies that are already associated with this control
	next if $known_dependencies{ $s->id };
	# don't include steps that are someone else's
	next if $s->dependency && $s->dependency->step_id eq $s->id;

        push @tmp, [$s->title, $s->id] 
    }

    my $step_collection = Mojo::Collection->new(@tmp);
    $self->render(dependency_group => $dg, step_collection => $step_collection);
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

    return $self->redirect_to("journey_steps_index", { journey_id => $dp->step->journey->id });
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
            $dp->step->dependency_group_id(undef);
            $dp->step->update;
        }
    }
    $self->respond_to( json => { json => { success => 1 } } );
}


1;
