package Log::Robot;

use Log::_RobotFactory;

sub new {
   my ( $class, $args ) = @_;
   _RobotFactory( log_levels => delete $args->{log_levels} )->new($args)
}

1;
