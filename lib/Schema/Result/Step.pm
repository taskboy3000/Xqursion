package Schema::Result::Step;
use Modern::Perl '2012';
use base ('Schema::ResultBase');

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("steps");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "journey_id" => { data_type => "char", is_nullable => 0, size => 64 },
   "title" => { data_type => "varchar", is_nullable => 0, size => 255 },
   "url" => { data_type => "varchar", is_nullable => 0, size => 4096 },
   "sequence" => { data_type => "int", is_nullable => 0, default => 1},
   "dependency_group_id" => { data_type => "char", size => 64 },
   "error_url" => { data_type => "varchar", size => 4096 },
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, set_on_update => 1, },
);


1;
