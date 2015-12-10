# Xqursion

A tool to create a system QR codes that backend with branching and looping logic.

Typical usage might be creating a game where a series of web pages are clues
in a game.

Built with Mojolicious, DBIx, jQuery, Bootstrap.

Canonical site: http://www.xqursion.com/

By Joe Johnston <jjohn@taskboy.com>

# ENVIRONMENT VARIABLES

 * DBIC_MIGRATION_SCHEMA_CLASS (default: Schema)
 * PATH                        (add `pwd`/local/bin)
 * PERL5LIB                    (add `pwd`/local/lib)
 * XQURSION_DBI_CONNECT        (default: dbi:SQLite:share/schema.db)
 * XQURSION_HOME               (add `pwd`)
 * XQURSION_PUBLIC_HOST        (e.g. www.xqursion.com)
 * XQURSION_PUBLIC_PORT        (e.g. 80)
 * XQURSION_PUBLIC_SCHEME      (e.g  http)
 * XQURSION_SECRET             (default: 0987654321)
 
# LICENSE

Artistic License (http://dev.perl.org/licenses/artistic.html)
This software is released under the same terms as Perl.
