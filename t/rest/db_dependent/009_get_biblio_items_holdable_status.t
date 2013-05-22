#!/usr/bin/env perl

use Modern::Perl;

use FindBin qw( $Bin );

use lib "$Bin/../../..";
use t::rest::lib::Mocks;
use Test::More tests => 16;
use Test::WWW::Mechanize::CGIApp;
use JSON;
use Data::Dumper;

t::rest::lib::Mocks::mock_config;

my $mech = Test::WWW::Mechanize::CGIApp->new;
$mech->app('Koha::REST::Dispatch');


t::rest::lib::Mocks::mock_preference('AllowOnShelfHolds', '0');

my $path = "/biblio/3/items_holdable_status?borrowernumber=5";
$mech->get_ok($path);
my $got = from_json( $mech->response->content );
my $expected = {
    '8' => {
        'is_holdable' => JSON::false,
        'reasons' => [],
    },
    '7' => {
        'is_holdable' => JSON::false,
        'reasons' => [],
    },
    '9' => {
        'is_holdable' => JSON::false,
        'reasons' => [],
    }
};
is_deeply( $got, $expected, q{cannot reserve items} );


$path = "/biblio/2/items_holdable_status?borrowernumber=5";
$mech->get_ok($path);
$got = from_json( $mech->response->content );
$expected = {
    '4' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    },
    '5' => {
        'is_holdable' => JSON::false,
        'reasons' => [],
    },
    '6' => {
        'is_holdable' => JSON::false,
        'reasons' => [],
    }
};
is_deeply( $got, $expected, q{can reserve 1 item} );

$path = "/biblio/4/items_holdable_status?borrowernumber=5";
$mech->get_ok($path);
$got = from_json( $mech->response->content );
$expected = {
    '10' => {
        'is_holdable' => JSON::false,
        'reasons' => [],
    },
    '11' => {
        'is_holdable' => JSON::false,
        'reasons' => [],
    },
    '12' => {
        'is_holdable' => JSON::false,
        'reasons' => [],
    }
};
is_deeply( $got, $expected, q{cannot reserve because all items are available} );

$path = "/biblio/1/items_holdable_status?borrowernumber=2";
$mech->get_ok($path);
$got = from_json( $mech->response->content );
$expected = {
    '1' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    },
    '2' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    },
    '3' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    }
};
is_deeply( $got, $expected, q{can reserve} );


t::rest::lib::Mocks::mock_preference('AllowOnShelfHolds', '1');
$path = "/biblio/3/items_holdable_status?borrowernumber=5";
$mech->get_ok($path);
$got = from_json( $mech->response->content );
$expected = {
    '8' => {
        'is_holdable' => JSON::false,
        'reasons' => [],
    },
    '7' => {
        'is_holdable' => JSON::false,
        'reasons' => [],
    },
    '9' => {
        'is_holdable' => JSON::false,
        'reasons' => [],
    }
};
is_deeply( $got, $expected, q{No items are available} );


$path = "/biblio/2/items_holdable_status?borrowernumber=5";
$mech->get_ok($path);
$got = from_json( $mech->response->content );
$expected = {
    '4' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    },
    '5' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    },
    '6' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    }
};
is_deeply( $got, $expected, q{All items are available} );

$path = "/biblio/4/items_holdable_status?borrowernumber=5";
$mech->get_ok($path);
$got = from_json( $mech->response->content );
$expected = {
    '10' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    },
    '11' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    },
    '12' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    }
};
is_deeply( $got, $expected, q{can reserve because all items are available} );

$path = "/biblio/1/items_holdable_status?borrowernumber=2";
$mech->get_ok($path);
$got = from_json( $mech->response->content );
$expected = {
    '1' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    },
    '2' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    },
    '3' => {
        'is_holdable' => JSON::true,
        'reasons' => [],
    }
};
is_deeply( $got, $expected, q{can reserve} );
