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

