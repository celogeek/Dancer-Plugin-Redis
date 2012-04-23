package Dancer::Plugin::Redis;

# ABSTRACT: easy database connections for Dancer applications

use strict;
use warnings;
use Carp;
use Data::Dumper;
use Dancer::Plugin;
use Redis;
use Try::Tiny;

# VERSION

my $_settings;
my $_handles_conf;

sub _handle {
    my ($name) = @_;
    $name = "_default" if not defined $name;

    my $h = $_handles_conf->{$name};
    if (defined $h && ($h->ping || '') eq 'PONG') {
        return $h;
    }

    my @conf;
    if ($name eq '_default') {
        @conf = (
            server => $_settings->{server},
            debug => $_settings->{debug},
            encoding => $_settings->{encoding},
        );
    } else {
        @conf = (
            server => $_settings->{connections}->{$name}->{server},
            debug => $_settings->{connections}->{$name}->{debug},
            encoding => $_settings->{connections}->{$name}->{encoding},
        );
    }

    if (@conf) {
        try {
            $h = $_handles_conf->{$name} = Redis->new(
                @conf
            );
        };
        if (defined $h && $h->ping eq 'PONG') {
            return $h;
        } else {
            croak "Can't connect to $name redis connection ...";
        }

    } else {
        croak "The redis connection conf $name doesn't exists !";
    }
}


register redis => sub {
    my ($name) = @_;
    $_settings ||= plugin_setting;
    return _handle($name);
};

register_plugin;

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

Takes care of ensuring that the database handle is still connected and valid.
If the handle was last asked for more than C<connection_check_threshold> seconds
ago, it will check that the connection is still alive, using either the 
C<< $r->ping >> method if the Redis driver supports it, or performing a simple
no-op query against the database if not.  If the connection has gone away, a new
connection will be obtained and returned.  This avoids any problems for
a long-running script where the connection to the database might go away.

=head1 CONFIGURATION

Connection details will be taken from your Dancer application config file, and
should be specified as, for example: 

    plugins:
        Redis:
            server: '127.0.0.1:6379'
            debug: 0
            encoding: utf8
            connections:
                test:
                    server: '127.0.0.1:6380'
                    debug: 1
                    encoding: utf8

The C<connectivity-check-threshold> setting is optional, if not provided, it
will default to 30 seconds.  If the database keyword was last called more than
this number of seconds ago, a quick check will be performed to ensure that we
still have a connection to the database, and will reconnect if not.  This
handles cases where the database handle hasn't been used for a while and the
underlying connection has gone away.


=head1 GETTING A DATABASE HANDLE

Calling C<redis> will return a connected database handle; the first time it is
called, the plugin will establish a connection to the database, and return a
reference to the DBI object.  On subsequent calls, the same DBI connection
object will be returned, unless it has been found to be no longer usable (the
connection has gone away), in which case a fresh connection will be obtained.

If you have declared named connections as described above in 'DEFINING MULTIPLE
CONNECTIONS', then calling the database() keyword with the name of the
connection as specified in the config file will get you a database handle
connected with those details.

=head1 AUTHOR

Christophe Nowicki, C<< <cscm@csquad.org> >>



=head1 CONTRIBUTING

This module is developed on Github at:

L<https://github.com/cscm/Dancer-Plugin-Redis>

Feel free to fork the repo and submit pull requests!


=head1 ACKNOWLEDGEMENTS

Igor Bujna, David Precious


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

=back

You can find the author on IRC in the channel C<#dancer> on <irc.perl.org>.


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Christophe Nowicki.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=head1 SEE ALSO

L<Dancer>

L<DBI>



=cut

1; # End of Dancer::Plugin::Redis
