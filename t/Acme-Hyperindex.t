#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

BEGIN {
    use_ok 'Acme::Hyperindex';
}

ok( Acme::Hyperindex->can( 'hyperindex' ), "We can hyperindex" );

{
    my $structure = [
        [
            [qw(a b c)],
            [qw(d e f)],
        ],
        [
            [qw(g h i)],
            [qw(j k l)],
        ],
    ];
    my @index = (1, 0, 2);

    is( hyperindex( $structure, @{[1, 0, 2]} ), 'i', "And works" );

    is( hyperindex( $structure, @{[0, 0, 2]} ), 'c', "And works 2" );
    is_deeply(
        hyperindex( $structure, @{[0,1]} ),
        [qw(d e f)],
        "And can also return structures"
    );
}

{
    my $structure = [[
        {
            foo => [qw(a b c)],
            bar => [qw(d e f)],
        },
        {
            foo => [qw(g h i)],
            bar => [qw(j k l)],
        },
    ]];

    my @index = (0, 0, 'foo', 0);

    is( hyperindex( $structure, @index ), 'a', "And does hashes" );
    is_deeply(
        hyperindex( $structure, @{[0, 0, 'bar']} ),
        [qw(d e f)],
        "And can also return structures",
    );
    is_deeply(
        hyperindex( $structure, @{[0, 0]} ),
        { foo => [qw(a b c)], bar => [qw(d e f)] },
        "And can also return structures 2",
    );
}

{
    my $structure = [
        { foo => [qw(a b c)] },
        { foo => [qw(e f g)] },
    ];

    is( $structure[[ 0, 'foo', 1 ]], 'b', "Sourcefilter works" );
}


