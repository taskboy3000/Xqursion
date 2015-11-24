# This is the DDL part of the model
package Schema::Result::User;
use strict;
use base ('Schema::ResultBase');
use Digest::SHA ('sha256_hex');

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "username" => { data_type => "varchar", is_nullable => 0, size=> 64},
   "email" => { data_type => "varchar", is_nullable => 0, size=> 128},
   "password_hash" => { data_type => "varchar", is_nullable => 0, size=> 128},
   "role" => { data_type => "char", is_nullable => 0, size=> 16, default => "USER" },
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, set_on_update => 1, },
);

our %ROLES = (USER => 1, ADMIN => 10);

sub new {
    my ($self, $attrs) = @_;
    $attrs->{role} = "USER" unless exists $ROLES{$attrs->{role}};
    return $self->next::method($attrs);
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
