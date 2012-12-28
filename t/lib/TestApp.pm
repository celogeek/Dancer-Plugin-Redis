package TestApp;

use Dancer;
use FakeRedis;
use Dancer::Plugin::Redis;

set serializer => 'JSON';

get '/' => sub {
    [ redis->get('foo') ];
};

true;
