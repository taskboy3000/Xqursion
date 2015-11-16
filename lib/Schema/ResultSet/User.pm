# This is the service layer part of the model
package Schema::ResultSet::User;
use Modern::Perl;
use base 'DBIx::Class::ResultSet';
use UUID::Tiny;
use Digest::SHA ('sha256_hex');

sub create_id {
    my ($self) = @_;
    $self->id(create_UUID());
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
