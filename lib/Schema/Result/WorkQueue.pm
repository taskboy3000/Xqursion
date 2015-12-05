# This is the DDL part of the model
package Schema::Result::WorkQueue;
use strict;
use parent ('ResBase');

our %STATUS = ( "r" => "running", "p" => "pending", "d" => "done" );

__PACKAGE__->load_components("Helper::Row::SubClass","InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("work_queue");
__PACKAGE__->add_columns(
    "id" => { data_type => "char", is_nullable => 0, size=>64},
    "model" => { data_type => "varchar", is_nullable => 0, size=> 128},
    "model_id" => { data_type => "char", is_nullable => 0, size=> 64},
    "status" => { data_type => "char", is_nullable => 0, size => 1, default => "p" },
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
__PACKAGE__->init();




1;
