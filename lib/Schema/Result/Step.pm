package Schema::Result::Step;
use Modern::Perl '2012';
use parent ('ResBase');
use Imager::QRCode;
use URI::Escape;
use File::Path qw(make_path);

__PACKAGE__->load_components("Helper::Row::SubClass","InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("steps");
__PACKAGE__->add_columns(
   "id" => { data_type => "char", is_nullable => 0, size=>64},
   "journey_id" => { data_type => "char", is_nullable => 0, size => 64 },
   "title" => { data_type => "varchar", is_nullable => 0, size => 255 },
   "url" => { data_type => "varchar", is_nullable => 0, size => 4096 },
   "error_url" => { data_type => "varchar", is_nullable => 1, size => 4096 },
   "create_new_session" => { data_type => "char", is_nullable => 0, size => 1, default_value => 0},
   "dependency_group_id" => { data_type => "char", size => 64, is_nullable => 1 },
   "qrcode_filename" => { data_type => "varchar", is_nullable => 1, size => 255 },
   "created_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, },
   "updated_at" => { data_type => "datetime", is_nullable => 0, set_on_create => 1, set_on_update => 1, },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("journey", "Schema::Result::Journey", "journey_id");
__PACKAGE__->might_have("dependency_group", "Schema::Result::DependencyGroup", "step_id");
__PACKAGE__->might_have("dependency", "Schema::Result::Dependency", "step_id");

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

sub belongs_to_dependency_groups {
    my $self = shift;
    my $db = $self->result_source->schema;
    
    # Where is this a dependency?
    my @deps = $db->resultset('Dependency')->find({step_id => $self->id});
    return map { $_->dependency_group } @deps;
}

sub check_dependencies {
    my ($self, $session_id) = @_;
    my $dp = $self->dependency_group;
    
    return $dp->satisfied($session_id) if $dp;

    return 1;
}

sub generate_qrcode {
    my ($self) = shift;

    my %args = (
	base_dir => undef, # e.g. public/downloads/[USER_ID]/[JOURNEY_ID]/[URI_ESCAPED_STEP_TITLE].png
	step_url_cb => undef,
	@_);

    make_path($args{base_dir});

    (my $file = $self->title . ".png") =~ s/([^a-z0-9_\.-])/_/gi;
    my $final_path = "$args{base_dir}/$file";

    if (-e $final_path) {
	# warn("$final_path seems to exist already\n");
	# return $file;
    }

    my $qrcode = Imager::QRCode->new(
				     size          => 4,
				     margin        => 3,
				     version       => 1,
				     level         => 'M',
				     casesensitive => 1,
				     lightcolor    => Imager::Color->new(255, 255, 255),
				     darkcolor     => Imager::Color->new(0, 0, 0),
				    );
    my $step_url = "";
    if ($args{step_url_cb}) {
	$step_url = $args{step_url_cb}->($self);
    }

    #warn("Encoding URL '$step_url' for step '@{[$self->title]}'\n");
    my $img = $qrcode->plot($step_url);
    # warn("Writing $final_path\n");
    $img->write(file => $final_path);

    if ($img->{ERRSTR}) {
	warn($img->{ERRSTR});
	return;
    }

    $self->qrcode_filename($file);
    return $file;
}

1;
