#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

our $VERSION = '0.1.0';

$| = 1;

my @buffer;
my $buffering;

my $columns;

while ( my $line = <STDIN> ) {
    if ( $line =~ /^CREATE TABLE / ) {
        $buffering = 1;
    }
    elsif ( $line =~ /^\) ENGINE=/ ) {
        $columns   = get_columns();
        $buffering = 0;
    }
    elsif ( $line =~ /^INSERT INTO / ) {
        $line = add_columns( $line, $columns );
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

sub get_columns {
    my @columns;

    return unless @buffer;

    for my $b (@buffer) {
        if ( $b =~ /^\s*(`.+`)/ ) {
            push @columns, $1;
        }
    }

    return '(' . join( ', ', @columns ) . ')';
}

sub add_columns {
    my ( $line, $columns ) = @_;
    $line =~ s/^(INSERT INTO `[^`]+`) (VALUES)/$1 $columns $2/;
    return $line;
}

