package Xqursion::Controller::Dependencies;
use Modern::Perl '2012';
use Mojo::Base 'Xqursion::Controller::Application';

our $BEFORE_FILTERS = { "require_authentication" => [ 'create', 'delete' ] };

# Form handler for new
sub create {
    my $self = shift;
    my $L = $self->app->log;
    my $D = $self->app->db;
    my $current_user = $self->current_user;

    my $d = $D->resultset("Dependency")->new({});
    my $dp = $D->resultset("DependencyGroup")->find($self->param("dependency_group_id"));

    if ($current_user && $self->param("step_id")) {
	$d->create_id;
        $d->dependency_group_id($self->param("dependency_group_id"));
        $d->step_id($self->param("step_id"));

	if ($d->insert) {
	    $L->debug("Created dependency: " . $dp->id);
	} else {
	    $L->warn("Failed to create dependency");
	}
    } else {
	# XXX ERROR
    }
    
    return $self->redirect_to("step_dependency_group_edit", { step_id => $dp->step->id, id => $dp->id });
}

sub delete {
    my $self = shift;
    my $L = $self->app->log;
    my $D = $self->app->db;
    my $current_user = $self->current_user;

    my $d = $D->resultset("Dependency")->find($self->param("id"));
    if ($d) {
        if ($d->step->journey->user_id ne $current_user->id) {
            $L->warn("Permission error: user '@{$current_user->email}' tried to remove step '@{$d->id}'");
        } else {
            $d->delete;
        }
    }
    $self->respond_to( json => { json => { success => 1 } } );
}


1;
