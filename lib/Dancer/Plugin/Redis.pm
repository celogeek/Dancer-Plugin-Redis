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
            password: yourpassword
            connections:
                test:
                    server: '127.0.0.1:6380'
                    debug: 1
                    encoding: utf8
                    password: yourpassword

C<server> is the ip:port of redis server

C<debug> activate the debug of redis

C<encoding> activate auto encoding, if you want raw data, put nothing after encoding

C<reconnect> is the number of second which try to reconnect if we have lost connection, default to 60
                    
C<password> pass AUTH to Redis if you use the requirepass config. You can skip this option if you don't have requirepass set.

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
# VERSION
use Carp;
use Data::Dumper;
use Dancer::Plugin;
use Try::Tiny;
use Redis 1.955;

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
        password => $conf->{password},
    );

};

register_plugin;

1;
__END__
=head1 SEE ALSO

L<Dancer>

L<DBI>

L<Redis>
