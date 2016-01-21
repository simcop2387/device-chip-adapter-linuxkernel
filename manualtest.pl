#!/usr/bin/env perl

use strict;
use warnings;

use lib './lib';
use Data::Dumper;

use Device::Chip::Adapter::LinuxKernel;
#$Device::Chip::Adapter::LinuxKernel::__TESTDIR="testdirs";

my $kernelchip = Device::Chip::Adapter::LinuxKernel->new();

my $gpio = $kernelchip->make_protocol("GPIO");
print Dumper($gpio->list_gpios);
