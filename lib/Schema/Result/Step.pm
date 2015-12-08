package Schema::Result::Step;
use Modern::Perl '2012';
use parent ('ResBase');

__PACKAGE__->load_components("Helper::Row::SubClass","InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("steps");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "journey_id" => { data_type => "char", is_nullable => 0, size => 64 },
   "title" => { data_type => "varchar", is_nullable => 0, size => 255 },
   "url" => { data_type => "varchar", is_nullable => 0, size => 4096 },
   "dependency_group_id" => { data_type => "char", size => 64, is_nullable => 1 },
   "error_url" => { data_type => "varchar", is_nullable => 1, size => 4096 },
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, set_on_update => 1, },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("journey", "Schema::Result::Journey", "journey_id");
__PACKAGE__->might_have("dependency_group", "Schema::Result::DependencyGroup", "step_id");
__PACKAGE__->might_have("dependency", "Schema::Result::Dependency", "step_id");

__PACKAGE__->inflate_column("created_at", {
                                         inflate => sub { DateTime->from_epoch(epoch => shift) }, 
                                         deflate => sub { shift->epoch }
                                        });

__PACKAGE__->inflate_column("updated_at", {
                                         inflate => sub { DateTime->from_epoch(epoch => shift) }, 
                                         deflate => sub { shift->epoch }
                                        });


__PACKAGE__->subclass;
__PACKAGE__->init();

sub belongs_to_dependency_groups {
    my $self = shift;
    my $db = $self->result_source->schema;
    
    # Where is this a dependency?
    my @deps = $db->resultset('Dependency')->find({step_id => $self->id});
    return map { $_->dependency_group } @deps;
}

sub check_dependencies {
    my ($self, $session_id) = @_;
    my $dp = $self->dependency_group;
    
    return $dp->satisfied($session_id) if $dp;

    return 1;
}

1;
