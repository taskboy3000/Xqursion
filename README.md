# Xqursion

A tool to create a system QR codes that backend with branching and looping logic.

Typical usage might be creating a game where a series of web pages are clues
in a game.

Built with Mojolicious, DBIx, jQuery, Bootstrap.

Canonical site: http://www.xqursion.com/

By Joe Johnston <jjohn@taskboy.com>

# INSTALL

* Get your system up to perl 5.20 (at least).  Perlbrew is great for this
* Get git (obviously) and clone this repo
* In your sandbox (xqursion), pull in the perl library dependencies with carton (just type 'carton')
* Create a shell script that configures these environment variables:
** DBIC_MIGRATION_SCHEMA_CLASS (default: Schema)
** PATH                        (add `pwd`/local/bin)
** PERL5LIB                    (add `pwd`/local/lib)
** XQURSION_DBI_CONNECT        (default: dbi:SQLite:share/schema.db)
** XQURSION_HOME               (add `pwd`)
** XQURSION_PUBLIC_HOST        (e.g. www.xqursion.com)
** XQURSION_PUBLIC_PORT        (e.g. 80)
** XQURSION_PUBLIC_SCHEME      (e.g  http)
** XQURSION_SECRET             (default: 0987654321)

In bash, such a script likes like:

  export PATH=`pwd`/local/bin # etc.

* source the script you just created:

  $ source env.sh

* Currently, this app uses sqlite. Migrate the schema using: dbic-migrate install
* Run with either the dev server (script/xqursion daemon) or hypnotoad (hypnotoad script/xqursion)

 
# LICENSE

Artistic License (http://dev.perl.org/licenses/artistic.html)
This software is released under the same terms as Perl.
