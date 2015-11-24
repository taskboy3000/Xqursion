package Schema::Result::DependencyGroup;
use Modern::Perl '2012';
use parent ('ResBase');

__PACKAGE__->load_components("Helper::Row::SubClass","InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("dependency_groups");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "step_id" => { data_type => "char", is_nullable => 0, size => 64 },
   "operation" => { data_type => "char", is_nullable => 0, size => 3, default => "AND" }, # values: [ AND | OR | XOR ]
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, set_on_update => 1, },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->subclass;
__PACKAGE__->init();

1;
