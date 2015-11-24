# The primary container for steps
package Schema::Result::Journey;
use Modern::Perl '2012';
use parent ('ResBase');

__PACKAGE__->load_components("Helper::Row::SubClass","InflateColumn::DateTime", "TimeStamp", "Core",);
__PACKAGE__->table("journeys");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "name" => { data_type => "varchar", is_nullable => 0, size=> 255},
   "user_id" => { data_type => "char", is_nullable => 0, size=>64},
   "start_at" => { data_type => "date", is_nullable => 0 },
   "end_at" => { data_type => "date", is_nullable => 0 },
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, set_on_update => 1, },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("user" => "Schema::Result::User", "user_id");
__PACKAGE__->subclass;
__PACKAGE__->init();
1;
