# A parent that contains common code
package ResBase;
use Modern::Perl '2012';
use parent ('DBIx::Class');
use UUID::Tiny (':std');

# These routines happen in all tables.
# All tables have an ID field that is a UUID
# All tables should have a created_at and updated_at

sub init {
    my ($class) = @_;
    $class->inflate_column("created_at", {
	inflate => sub { DateTime->from_epoch(epoch => shift) }, 
	deflate => sub { shift->epoch }
			   });
    
    $class->inflate_column("updated_at", {
	inflate => sub { DateTime->from_epoch(epoch => shift) }, 
	deflate => sub { shift->epoch }
			   });
}

sub create_id {
    my ($self) = @_;
    $self->id(uuid_to_string(create_uuid(UUID_V4)));
}


1;
