#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

our $VERSION = '0.1.0';

$| = 1;

exit 1 unless @ARGV;
my %selected_tables = map { $_ => 1 } @ARGV;

my @buffer;
my $buffering;

while ( my $line = <STDIN> ) {
    $buffering = 1;

    if ( $line eq "\n" ) {
        if ( is_selected_table() ) {
            $buffering = 0;
        }
        else {
            clear_buffer();
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

sub is_selected_table {
    for my $b (@buffer) {
        if ( $b =~ /`([^`]+)`/ && $selected_tables{$1} ) {
            return 1;
        }
    }
    return;
}

sub clear_buffer {
    @buffer = ();
}

