package Xqursion::Plugin::WorkQueue;
use Modern::Perl '2012';
use Mojo::Base 'Mojolicious::Plugin';

sub wq_add {
    my ($self, $model, $id) = @_;

    my $q = $self->app->db->resultset("WorkQueue")->new({model => $model, model_id => $id});
    return $q->insert;
}

sub wq_list {
    my ($self) = @_;
    return $self->app->db->resultset("WorkQueue")->all;
}

sub wq_run_next {
    my ($self) = @_;
    my @pending = $self->app->db->resultset("WorkQueue")->find({status => "p"});

    for my $p (@pending) {
	$p->status("r");
	if ($p->update({status => "p"})) {
	    $self->app->log->debug("running work queue for @{[$p->model]}.id = @{[$p->id]}");
	    $self->run_task($p);
	}
    }

    return;
}

sub run_task {
    my ($self, $p) = @_;
    my $D = $self->app->db;
    my $obj = $D->resultset($p->model)->find($p->id);

    if ($obj) {
	return $obj->run;
    }
    return;
}

sub register {
    my ($self, $app) = @_;
    for my $method ("wq_run_next", "wq_add", "wq_list") {
        $app->helper( $method => sub { $self->$method(@_) } );
    }
}

1;
