package FakeRedis;

use strict;
use warnings;
{

    package Redis;
    $INC{'Redis.pm'} = 1;
    our $VERSION = 2;
    our $AUTOLOAD;

    sub new {
        my ( $class, %args ) = @_;
        bless \%args => $class;
    }
    sub ping { 'PONG' }

    sub AUTOLOAD {
        shift;
        my $name = $AUTOLOAD;
        $name =~ s/.*://;
        return $name, @_;
    }
}

1;
