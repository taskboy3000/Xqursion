use utf8;
package Schema;
use strict;
use base ('DBIx::Class::Schema');

our $VERSION = "0.01";

__PACKAGE__->load_namespaces();
__PACKAGE__->load_components('Validation');
1;
