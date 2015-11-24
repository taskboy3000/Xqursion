package Schema::Result::DependencyGroup;
use Modern::Perl '2012';
use base ('Schema::ResultBase');

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("dependency_groups");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "step_id" => { data_type => "char", is_nullable => 0, size => 64 },
   "operation" => { data_type => "char", is_nullable => 0, size => 3, default => "AND" }, # values: [ AND | OR | XOR ]
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, set_on_update => 1, },
);
