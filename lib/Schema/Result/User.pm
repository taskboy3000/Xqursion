# This is the DDL part of the model
package Schema::Result::User;
use strict;
use base ('DBIx::Class::Core');
use Time::Duration;
use DateTime;

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "username" => { data_type => "varchar", is_nullable => 0, size=> 64},
   "email" => { data_type => "varchar", is_nullable => 0, size=> 128},
   "password_hash" => { data_type => "varchar", is_nullable => 0, size=> 128},
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", us_nullable => 0, set_on_create => 1, set_on_update => 1, },
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

use UUID::Tiny (':std');
use Digest::SHA ('sha256_hex');

sub create_id {
    my ($self) = @_;
    $self->id(uuid_to_string(create_uuid(UUID_V4)));
}

sub hash_password {
    my ($self, $plain_text) = @_;

    return sha256_hex($plain_text . ($ENV{XQURSION_PW_SECRET} || '1234'));
}

sub is_password_valid {
    my ($self, $plain_text) = @_;
    return $self->password_hash eq $self->hash_password($plain_text);
}

1;
