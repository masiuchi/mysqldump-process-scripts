#!/usr/bin/env perl

# The MIT License (MIT)
# 
# Copyright (c) 2019 Masahiro IUCHI
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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

