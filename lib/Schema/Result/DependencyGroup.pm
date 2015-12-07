package Schema::Result::DependencyGroup;
use Modern::Perl '2012';
use parent ('ResBase');

our %OPERATIONS = ("AND" => 1, "OR" => 1, "NOT" => 1);

__PACKAGE__->load_components("Helper::Row::SubClass","InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("dependency_groups");
__PACKAGE__->add_columns(
   "id"         => { data_type => "char", is_nullable => 0, size=>64},
   "step_id"    => { data_type => "char", is_nullable => 0, size => 64 },
   "title"      => { data_type => "varchar", is_nullable => 1, size => 255 }, 
   "operation"  => { data_type => "char", is_nullable => 0, size => 3, default => "AND" },
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, set_on_update => 1, },
);

__PACKAGE__->set_primary_key("id");
__PACKAGE__->inflate_column("created_at", {
                                         inflate => sub { DateTime->from_epoch(epoch => shift) }, 
                                         deflate => sub { shift->epoch }
                                        });

__PACKAGE__->inflate_column("updated_at", {
                                         inflate => sub { DateTime->from_epoch(epoch => shift) }, 
                                         deflate => sub { shift->epoch }
                                        });

__PACKAGE__->subclass;
__PACKAGE__->belongs_to("step", "Schema::Result::Step", "step_id");
__PACKAGE__->has_many("dependencies", "Schema::Result::Dependency", "dependency_group_id");
__PACKAGE__->init();

# Are all the dependencies satisfied?
sub satisfied {
    my ($self, $session_id) = @_;
    
    my $db = $self->result_source->schema;

    my @dependencies = $db->dependencies;
    my @logs         = $db->resultset("JourneyLog")->find({session_id => $session_id});

    return $self->_and(\@dependencies, \@logs) if $self->operation eq 'AND';
    return !$self->_or(\@dependencies, \@logs) if $self->operation eq 'NOT';
    return $self->_or(\@dependencies, \@logs)  if $self->operation eq 'OR';

    return;
}

sub _or {
    my ($self, $dependencies, $logs) = @_;

    # Any met dependency means success
    for my $d (@$dependencies) {
        for my $l (@$logs) {
            return 1 if $l->step_id eq $d->step_id;
        }
    }
    return;
}

sub _and {
    my ($self, $dependencies, $logs) = @_;

    # Have we see each dependency?
    for my $d (@$dependencies) {
        my $missing = 1;
        for my $l (@$logs) {
            $missing = 0 if $l->step_id eq $d->step_id;
        }
        return if $missing; # All dependencies must be met to succeed
    }
    return 1;
}

1;
