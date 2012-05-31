package TestApp;

use Dancer;
use FakeRedis;
use Dancer::Plugin::Redis;

get '/' => sub {
    [ redis->get('foo') ];
};

true;
