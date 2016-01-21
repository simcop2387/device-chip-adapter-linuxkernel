package Device::Chip::Adapter::LinuxKernel;

use strict;
use warnings;
use base qw( Device::Chip::Adapter );
use Carp qw/croak/;

our $__TESTDIR=""; # blank unless we're being pointed at a test setup

=head1 NAME

C<Device::Chip::Adapter::LinuxKernel> - A C<Device::Chip::Adapter> implementation

=head1 DESCRIPTION

This class implements the C<Device::Chip::Adapter> interface for the I<LinuxKernel>,
allowing an instance of L<Device::Chip> driver to communicate with the actual
chip hardware by using the Linux Kernel interfaces for GPIO, I2C (SMbus), and SPI.

=head1 CONSTRUCTOR
=cut

=head2 new

=head2 new

   $adapter = Device::Chip::Adapter::LinuxKernel->new( %args )

Returns a new instance of a C<Device::Chip::Adapter::Kernel>.
Takes the same named arguments as L<Gibberish>.

=cut

sub new {
   my $class = shift;

   # TODO not sure what I'll need to take here yet
   
   return bless({}, $class);
}

sub new_from_description {
   my $class = shift;
   my %args = @_;

   # TODO what does this do?
   return bless({}, $class);
}


# TODO these need to take arguments, i.e. what GPIO?
sub make_protocol_GPIO {
   my $self = shift;

   Device::Chip::Adapter::LinuxKernel::_GPIO->new();
}

sub make_protocol_SPI {
   my $self = shift;

   die 'SPI unsupported currently';
}

sub make_protocol_I2C {
    my $self = shift;

}

sub shutdown {
   my $self = shift;
   
   # delete the interfaces?
}

package
   Device::Chip::Adapter::LinuxKernel::_base;

use Carp;
use List::Util qw( first );

sub new {
   my $class = shift;

   bless { }, $class;
}

sub _find_speed {
   shift;
   my ( $max_bitrate, @speeds ) = @_;

    return first {
        my $rate = $_;
        $rate =~ s/k$/000/;
        $rate =~ s/M$/000000/;

        $rate <= $max_bitrate
    } @speeds;
}

# Most modes have no GPIO on this system
sub list_gpios { return qw( ) }

sub write_gpios {
   my $self = shift;
   my ( $gpios ) = @_;

   foreach my $pin ( keys %$gpios ) {
         croak "Unrecognised GPIO pin name $pin";
   }
}

sub read_gpios {
   my $self = shift;
   my ( $gpios ) = @_;

   my @f;
   foreach my $pin ( @$gpios ) {
     croak "Unrecognised GPIO pin name $pin";
   }
}

# there's no more efficient way to tris_gpios than just read and ignore the result
sub tris_gpios
{
   my $self = shift;
   $self->read_gpios->then_done();
}

package
    Device::Chip::Adapter::LinuxKernel::_GPIO;
    
use base qw( Device::Chip::Adapter::LinuxKernel::_base );

use List::Util 1.29 qw( pairmap );
use Carp qw/croak/;

sub configure {
    my $self = shift;
    my %args = @_;

    $self->{gpiostate} = $self->_get_exported(); # get the already exported gpio
    $self->{unexport_on_shutdown} = !!delete $args{unexport}; # Should we unexport all the gpio when we're done?

    croak "Unrecognised configuration options: " . join( ", ", keys %args ) if %args;

    return $self;
}

sub _read_gpio_info {} # TODO

sub _get_exported {
    my $self = shift;
    my @sysfs_list = $self->_get_sysfs_list;
    
    # Give back a hash for all the gpios
    return +{map {$_ => {_export_at_start => 1, $self->_read_gpio_info}} grep {!/gpiochip/} @sysfs_list};
}

sub _get_sysfs_list {
    opendir(my $sysfs, $__TESTDIR."/sys/class/gpio/") or die "Couldn't open sysfs GPIO list: $!";
    my @list = grep {!/^(un)?export$/} readdir $sysfs;
    closedir($sysfs);
    
    return @list; # TODO maybe some memoization is appropriate
}

sub _read_gpiochip_info {
    my $self = shift;
    my ($chip) = @_;
    my %info;
    
    for my $f (qw/ngpio base label/) {
      local $/;
      
      open (my $fh, "<", $__TESTDIR."/sys/class/gpio/$chip/$f") or die "Couldn't open GPIOCHIP data $chip/$f: $!";
      $info{$f} = <$fh>;
      close($fh);
    }
    
    return \%info;
}

# TODO this needs to get it from SysFS
sub list_gpios {
    my $self = shift;
    # TODO make this sort better.  I just can't think of what it should be.
    my @chips = sort {my ($l, $r) = ($a =~ /(\d+)/, $b =~ /(\d+)/); $l <=> $r}
                grep {/gpiochip/}
                $self->_get_sysfs_list();
                
    my $lastgpiochip = $chips[-1];
    
    if ($lastgpiochip) {
        # SysFS interface numbers them all from 0 to the end, so we can generate a list of them based off the final one
        my $lastgpiochip_info = $self->_read_gpiochip_info($lastgpiochip);
        
        my $count = $lastgpiochip_info->{base} + $lastgpiochip_info->{ngpio};
        
        return map {"gpio".$_} 0..$count-1;
    } else {
        return ();
    }
}

sub _export_gpio {
    my $self = shift;
    my ($gpio) = @_;
    
    
}

sub _unexport_gpio {
}

sub write_gpios {
}

sub read_gpios {
}

package 
    Device::Chip::Adapter::LinuxKernel::_I2C;

package
    Device::Chip::Adapter::LinuxKernel::_SPI;


=head1 AUTHOR

Ryan Voots <ryan@voots.org>

=cut

0x55AA;