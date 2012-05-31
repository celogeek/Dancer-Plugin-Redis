#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Dancer::Plugin::Redis' )
        or BAIL_OUT("Cannot load Dancer::Plugin::Redis");
}

diag( "Testing Dancer::Plugin::Redis, Perl $], $^X" );
