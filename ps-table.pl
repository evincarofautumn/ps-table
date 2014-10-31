#!/usr/bin/env perl

use warnings;
use strict;

use POSIX qw(strftime :sys_wait_h);
use Pod::Usage;
use Time::HiRes qw(gettimeofday);

pod2usage(2) if @ARGV != 1;

my $command = shift @ARGV;
my $pid = 0;
my $process;
{
  no warnings;
  $pid = open($process, '-|', $command);
}
die "error: cannot run command ($command): $!\n" if not $pid;

my $start_time = gettimeofday;
my $kid = 0;
until (eof $process or $kid < 0) {
  my $timestamp = gettimeofday;
  my $rss = `ps -o 'rss=' -p "$pid"`;
  if ($? == -1) {
	die "error: failed to execute ps: $!\n";
  } elsif ($? & 127) {
	die sprintf("error: ps died with signal %d %s\n", ($? & 127), ($? & 128) ? '(dumped core)' : '');
  } elsif ($? >> 8 != 0) {
	printf STDERR "warning: ps exited with nonzero status %d\n", $? >> 8;
	last;
  }
  $timestamp -= $start_time;
  printf "%.3f\t%d\n", $timestamp, $rss;
  $kid = waitpid($pid, WNOHANG);
}

__END__

=head1 NAME

ps-table.pl - A tool for getting a table of the resident set size (RSS) of a process.

=head1 SYNOPSIS

    ps-table.pl COMMAND

=head2 Options

=over 4

=item B<COMMAND>

The shell command to run.

=back

=head1 DESCRIPTION

Watches a process and samples its RSS, writing a list of timestamp-RSS pairs on standard output.

=head1 COPYRIGHT

Copyright (C) 2014 Jon Purdy

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=head1 AUTHOR

Jon Purdy <evincarofautumn@gmail.com>

=cut
