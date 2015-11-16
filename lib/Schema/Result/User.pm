# This is the DDL part of the model
package Schema::Result::User;
use strict;
use base ('DBIx::Class::Core');
use Time::Duration;
use DateTime;

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "username" => { data_type => "varchar", is_nullable => 0, size=> 64},
   "email" => { data_type => "varchar", is_nullable => 0, size=> 128},
   "password_hash" => { data_type => "varchar", is_nullable => 0, size=> 128},
   "created_at" => { data_type => "datetime", is_nullable => 0},
   "updated_at" => { data_type => "datetime", us_nullable => 0},
);

__PACKAGE__->set_primary_key("id");
__PACKAGE__->inflate_column("created_at", {
  inflate => sub { DateTime->from_epoch(epoch => shift) }, 
  deflate => sub { shift->epoch }
});

1;
