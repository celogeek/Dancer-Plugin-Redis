package Dancer::Plugin::Redis;

# ABSTRACT: easy database connections for Dancer applications

=head1 SYNOPSIS

    use Dancer;
    use Dancer::Plugin::Redis;

    # Calling the redis keyword will get you a connected Redis Database handle:
    get '/widget/view/:id' => sub {
        template 'display_widget', { widget => redis->get('hash_key'); };
    };

    dance;

Redis connection details are read from your Dancer application config - see
below.


=head1 DESCRIPTION

Provides an easy way to obtain a connected Redis database handle by simply calling
the redis keyword within your L<Dancer> application.

=head1 CONFIGURATION

Connection details will be taken from your Dancer application config file, and
should be specified as, for example: 

    plugins:
        Redis:
            server: '127.0.0.1:6379'
            debug: 0
            encoding: utf8
            reconnect: 60
            connections:
                test:
                    server: '127.0.0.1:6380'
                    debug: 1
                    encoding: utf8

C<server> is the ip:port of redis server

C<debug> activate the debug of redis

C<encoding> activate auto encoding, if you want raw data, put nothing after encoding

C<reconnect> is the number of second which try to reconnect if we have lost connection, default to 60
                    
=head1 GETTING A DATABASE HANDLE

Calling C<redis> will return a connected database handle; the first time it is
called, the plugin will establish a connection to the database, and return a
reference to the DBI object.  On subsequent calls, the same DBI connection
object will be returned. The connection will be refresh automatically with the Redis C<reconnect> option.

If you have declared named connections as described above in 'DEFINING MULTIPLE
CONNECTIONS', then calling the database() keyword with the name of the
connection as specified in the config file will get you a database handle
connected with those details.

=cut

use strict;
use warnings;
use Carp;
use Data::Dumper;
use Dancer::Plugin;
use Redis 1.951;
use Try::Tiny;

# VERSION

my $_settings;
my $_handles;

register redis => sub {
    my ($name) = @_;
    $name = "_default" if not defined $name;
    return $_handles->{$name} if exists $_handles->{$name};

    $_settings ||= plugin_setting;

    my $conf = $name eq '_default' ? $_settings : $_settings->{connections}->{$name};
    croak "$name is not defined in your redis conf, please check the doc" unless defined $conf;

    return $_handles->{$name} = Redis->new(
        server => $conf->{server},
        debug => $conf->{debug},
        encoding => $conf->{encoding},
        reconnect => $conf->{reconnect} // 60,
    );

};

register_plugin;

1;
__END__
=head1 CONTRIBUTING

This module is developed on Github at:

L<https://github.com/geistteufel/Dancer-Plugin-Redis>

Feel free to fork the repo and submit pull requests!

=head1 BUGS

Please report any bugs or feature requests to C<bug-dancer-plugin-database at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dancer-Plugin-Redis>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Plugin::Redis

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dancer-Plugin-Redis>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dancer-Plugin-Redis>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dancer-Plugin-Redis>

=item * Search CPAN

L<http://search.cpan.org/dist/Dancer-Plugin-Redis/>

=item * Github project

L<https://github.com/geistteufel/Dancer-Plugin-Redis>

=back

You can find the author on IRC in the channel C<#dancer> on <irc.perl.org>.

=head1 SEE ALSO

L<Dancer>

L<DBI>

L<Redis>
