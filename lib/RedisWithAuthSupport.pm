package RedisWithAuthSupport;

# ABSTRACT: add support to Redis

use strict;
use warnings;
# VERSION
use parent 'Redis';

## no critic qw(Subroutines::ProhibitUnusedPrivateSubroutines)

=method new

Add password option to Redis module

    RedisWithAuthSupport->new(password => 'yourpassword');

=cut
sub new {
    my ( $class, %param ) = @_;

    my $self = $class->SUPER::new(%param);
    $self->{password} = delete $param{password};
    $self->__auth;

    return $self;
}

sub __connect {
    my $self = shift;

    $self->SUPER::__connect;
    $self->__auth;

    return;
}

sub __auth {
    my $self = shift;

    $self->auth( $self->{password} ) if defined $self->{password};

    return;
}

1;
