use strict;
use warnings;
use Test::More import => ['!pass'];

use File::Spec;
use Dancer::Test;
use lib File::Spec->catdir( 't', 'lib' );
use TestApp;

my $response = dancer_response 'GET' => '/';
ok $response, 'We should be able to call our routes';
is_deeply $response->content, [qw/get foo/],
  '... it should have called Redis internally';

done_testing;
