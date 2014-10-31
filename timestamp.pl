#!/usr/bin/env perl
use warnings;
use strict;
use POSIX 'strftime';
use Time::HiRes 'gettimeofday';
my $timestamp = gettimeofday;
printf "%.3f", $timestamp;
