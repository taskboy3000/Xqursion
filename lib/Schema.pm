use utf8;
package Schema;
use strict;
use base ('DBIx::Class::Schema');

our $VERSION = "3";

__PACKAGE__->load_namespaces();
# __PACKAGE__->load_components('Validation');
1;
