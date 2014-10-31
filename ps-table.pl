#!/usr/bin/env perl

use warnings;
use strict;

use Getopt::Long;
use POSIX qw(strftime :sys_wait_h);
use Pod::Usage;
use Time::HiRes qw(gettimeofday);

my $help = 0;
my $working_directory = '';
my $absolute_timestamps = 0;

GetOptions
  (
   'absolute-timestamps' => \$absolute_timestamps,
   'chdir|d=s' => \$working_directory,
   'help|?' => \$help,
  ) or pod2usage(1);

pod2usage(0) if $help;

chdir $working_directory if $working_directory;

my $command = '';
{
  local $" = ' ';
  $command = "@ARGV";
}
my $pid = 0;
my $process;
{
  no warnings;
  $pid = open($process, '-|', $command);
}
die "error: cannot run command ($command): $!\n" if not $pid;

my $start_time = gettimeofday;
my $kid = 0;

while (1) {
  my $timestamp = gettimeofday;
  my $rss = `ps -o 'rss=' -p "$pid"`;
  last if $rss == 0;
  if ($? == -1) {
	die "error: failed to execute ps: $!\n";
  } elsif ($? & 127) {
	die sprintf("error: ps died with signal %d %s\n", ($? & 127), ($? & 128) ? '(dumped core)' : '');
  } elsif ($? >> 8 != 0) {
	printf STDERR "warning: ps exited with nonzero status %d\n", $? >> 8;
	last;
  }
  $timestamp -= $start_time unless $absolute_timestamps;
  printf "%.3f\t%d\n", $timestamp, $rss;
  $kid = waitpid($pid, WNOHANG);
  last if $kid > 0;
}

__END__

=head1 NAME

ps-table.pl - A tool for getting a table of the resident set size (RSS) of a process.

=head1 SYNOPSIS

    ps-table.pl [OPTIONS] COMMAND

=head2 Options

=over 4

=item I<COMMAND>

The shell command to run. If I<COMMAND> contains command-line arguments, you should prefix it with C<-->.

=item B<--absolute-timestamps>

Use absolute, not relative, timestamps.

=item B<--chdir> I<DIR>, B<-d> I<DIR>

Change the working directory to I<DIR> before running I<COMMAND>.

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
