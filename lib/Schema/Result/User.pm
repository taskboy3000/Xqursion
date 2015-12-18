# This is the DDL part of the model
package Schema::Result::User;
use strict;
use parent ('ResBase');
use Digest::SHA ('sha256_hex');
use URI;

our %ROLES = (USER => 1, ADMIN => 10);

__PACKAGE__->load_components("Helper::Row::SubClass","InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
                         "id" => { data_type => "char", is_nullable => 0, size=>64},
                         "username" => { data_type => "varchar", is_nullable => 0, size=> 64},
                         "email" => { data_type => "varchar", is_nullable => 0, size=> 128},
                         "password_hash" => { data_type => "varchar", is_nullable => 0, size=> 128},
                         "role" => { data_type => "char", is_nullable => 0, size=> 16, default => "USER" },
                         "reset_token" => { data_type => "char", is_nullable => 1, size=>64},
                         "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
                         "updated_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, set_on_update => 1, },
                        );

__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many("journeys" => 'Schema::Result::Journey', 'user_id');
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

sub create_reset_token {
    my ($self) = @_;
    $self->reset_token($self->uuid());
    return $self;
}

sub get_reset_url {
    my ($self) = @_;
    my $uri = URI->new(sprintf("%s://%s/user/%s/reset_password",
                               $ENV{XQURSION_PUBLIC_SCHEME},
                               $ENV{XQURSION_PUBLIC_HOST},
                               $self->id,
                              ));

    $uri->query_form(token => $self->reset_token);
    return $uri->as_string;
}

1;
