#!/usr/bin/perl
use strict;
use warnings;

# Validate a VIN.
sub isValidVIN {
    my ($vin) = @_;
    
    # Debugging: Output VIN being validated
    print "Validating VIN: $vin\n";

    # Check the length
    if (length($vin) != 17) {
        print "  Invalid length for VIN: $vin\n";
        return 0;
    }

    # Ensure it does not contain invalid characters
    if ($vin =~ /[IOQ]/) {
        print "  VIN contains invalid characters: $vin\n";
        return 0;
    }

    return 1;
}

# Extract potential VINs from a given string.
sub extractVINs {
    my ($text) = @_;
    my @matches = ($text =~ /\b[A-Za-z0-9]{17,}\b/g);

    # Debugging: Output extracted VINs
    print "Extracted potential VINs: ", join(', ', @matches), "\n";
    
    return @matches;
}

# Example input
my $inputText = <<'END_TEXT';
Here are some sample VINs:
1HGCM82633A123456, WDBBA48D7KA093694, and incorrect ones like ABC1234INVALID5678.
END_TEXT

# Extract potential VINs
my @vinList = extractVINs($inputText);

# Categorize VINs
my @validVINs;
my @invalidVINs;

foreach my $vin (@vinList) {
    if (isValidVIN($vin)) {
        push @validVINs, $vin;
    } else {
        push @invalidVINs, $vin;
    }
}

# Display results
print "\nValid VINs:\n";
if (@validVINs) {
    print "  $_\n" for @validVINs;
} else {
    print "  None\n";
}

print "\nInvalid VINs:\n";
if (@invalidVINs) {
    print "  $_\n" for @invalidVINs;
} else {
    print "  None\n";
}

