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
   "ordering" => { data_type => "int", is_nullable => 0, default => 1},
   "dependency_group_id" => { data_type => "char", size => 64 },
   "error_url" => { data_type => "varchar", size => 4096 },
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, set_on_update => 1, },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("journey", "Schema::Result::Journey", "journey_id");
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
1;
