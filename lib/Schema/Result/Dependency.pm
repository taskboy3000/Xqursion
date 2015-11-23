package Schema::Result::Dependency;
use Modern::Perl '2012';
use base ('Schema::ResultBase');

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("dependencies");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "dependency_group_id" => { data_type => "char", is_nullable => 0, size => 64 },
   "step_id" => { data_type => "char", is_nullable => 0, size => 64 },
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", us_nullable => 0, set_on_create => 1, set_on_update => 1, },
);

