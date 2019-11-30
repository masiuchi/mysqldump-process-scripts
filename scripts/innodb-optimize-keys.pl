#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

our $VERSION = '0.1.0';

$| = 1;

my @buffer;
my $buffering;

my $table;
my @keys;

while ( my $line = <STDIN> ) {
    if ( $line =~ /^CREATE TABLE (`.+`) / ) {
        $table     = $1;
        $buffering = 1;
    }
    elsif ( $line =~ /^\) ENGINE=/ ) {
        @keys      = pick_keys();
        $buffering = 0;
    }
    elsif ($line =~ m{^/\*!40000 ALTER TABLE `.+` ENABLE KEYS \*/}
        || $line =~ /^UNLOCK TABLES;/ )
    {
        if (@keys) {
            put_keys();
            @keys = ();
        }
    }

    if ($buffering) {
        push @buffer, $line;
    }
    else {
        if (@buffer) {
            print @buffer;
            @buffer = ();
        }
        print $line;
    }
}

sub pick_keys {
    my ( @new_buffer, @keys );

    return unless @buffer;

    for my $b (@buffer) {
        if ( $b =~ /^\s*((?:UNIQUE )?KEY .+[^,]),?\n$/ ) {
            push @keys, $1;
        }
        else {
            push @new_buffer, $b;
        }
    }

    $new_buffer[-1] =~ s/,\n$/\n/;

    @buffer = @new_buffer;

    return @keys;
}

sub put_keys {
    print "ALTER TABLE $table\n";
    print join ",\n", map {"  ADD $_"} @keys;
    print ";\n";
}

