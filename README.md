# NAME

`Device::Chip::Adapter::LinuxKernel` - A `Device::Chip::Adapter` implementation

# DESCRIPTION

This class implements the `Device::Chip::Adapter` interface for the _LinuxKernel_,
allowing an instance of [Device::Chip](https://metacpan.org/pod/Device%3A%3AChip) driver to communicate with the actual
chip hardware by using the Linux Kernel interfaces for GPIO, I2C (SMbus), and SPI.
Suitble for use on any Linux system including Raspberry PI (RPI), Beaglebone, Banana PI
or any other single board computer that exposes IO via the standard Linux Kernel
interfaces.

# CONSTRUCTOR

## new

    $adapter = Device::Chip::Adapter::LinuxKernel->new( %args )

- i2c\_bus - Optional, which i2c bus to connect to.  i2c-0, i2c-1, ...
- spi\_bus - Optional, which spi controller to use.   spidev0.0, ... 

Returns a new instance of a `Device::Chip::Adapter::LinuxKernel`.

# KNOWN ISSUES

- I2C reading likely doesn't work properly
- GPIO performance is probably horrendous.  We re-open the /value file in sysfs over and over for every action.  This could be better by storing the filehandles

# PLANS AHEAD

I'm going to release a companion module to this for Raspberry PI devices.  
It'll automatically detect which set of hardware you're on and select the appropriate busses for you.
I'll also be working to add "interrupt" support for the GPIO so that you can use `poll(2)` or `select(2)` to get a trigger on edge detection on some GPIO devices.

# AUTHOR

Ryan Voots <ryan@voots.org>

Stephen Cavilia &lt;sac+cpan@atomicradi.us>

Paul "LeoNerd" Evans <pevans@cpan.org>

# COPYRIGHT AND LICENSE

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
