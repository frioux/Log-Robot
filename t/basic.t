use strict;
use warnings;

use Log::Robot;
use Log::Contextual ':log', ':dlog', 'set_logger';
use Message::Passing::Filter::Encoder::JSON;
use Message::Passing::Output::ZeroMQ;

use Devel::Dwarn;

my $mp = Message::Passing::Filter::Encoder::JSON->new(
   output_to => Message::Passing::Output::ZeroMQ->new(
      connect => 'tcp://127.0.0.1:5558',
   ),
);

my $robot = Log::Robot->new({
   data_to_log => [qw(
      milliseconds_since_start
      milliseconds_since_last_log
      line
      file
      package
      subroutine
      category
      priority
      date
      host
      pid
      stacktrace
   )],
   event => [
      sub { $mp->consume($_[1]) },
      sub { Dwarn $_[1] },
   ],
   is_trace => 1,
   is_info => 1,
});

set_logger($robot);

log_info { 'foo' };
log_trace { +{ message => 'test', action_time => 1.5, requests => 3 }, };
sleep 1;
