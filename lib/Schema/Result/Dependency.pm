package Schema::Result::Dependency;
use Modern::Perl '2012';
use parent ('ResBase');

__PACKAGE__->load_components("Helper::Row::SubClass", "InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("dependencies");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "dependency_group_id" => { data_type => "char", is_nullable => 0, size => 64 },
   "step_id" => { data_type => "char", is_nullable => 0, size => 64 },
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
__PACKAGE__->belongs_to("dependency_group", "Schema::Result::DependencyGroup", "dependency_group_id");
__PACKAGE__->belongs_to("step", "Schema::Result::Step", "step_id");
__PACKAGE__->init();
1;
