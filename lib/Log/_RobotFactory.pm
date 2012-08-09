package
   Log::_RoboHeart;
use Moo;

has structured_logger => (
   is => 'ro',
   required => 1,
);

sub BUILDARGS {
   my ($self, @args) = @_;

   my $args = $self->next::method(@args);

   require Log::Structured;
   $args->{structured_logger} = Log::Structured->new({
      category => 'FALLBACK',
      log_event_listeners => (delete $args->{event} or die 'event is required!'),
      (map +(
         "log_$_" => 1,
      ), @{$args->{data_to_log}||['milliseconds_since_last_log']}),
   });

   return $args;
}

sub log { $_[0]->structured_logger->log_event($_[1]) }

package
   Log::_RobotFactory;

use strict;
use warnings;

use Package::Variant
  importing => {
     'Moo' => [],
  },
  subs => [qw(extends has)];

sub make_variant {
  my ($class, $target, %args) = @_;

  extends('Log::_RoboHeart');

  my $log_levels = $args{log_levels}
    || [qw(info trace)];

  for my $level (@$log_levels) {
     my $is_level = "is_$level";

     has($is_level => ( is => 'ro' ));

     install $level => sub {
        my ($self,@args) = @_;

        die "$level only takes one argument" if @args > 1;
        my $arg = $args[0];
        die "$level takes a string or hashref"
           if ref $arg && ref $arg ne 'HASH';

        $arg = {
           message => $arg,
        } unless ref $arg;

        $arg->{priority} = $level;

        $self->log($arg);
     };
  }
};

use Memoize;
memoize('make_variant');

1;
