#!/usr/bin/perl
use strict;
use warnings;

# Validate a VIN.
sub isValidVIN {
    my ($vin) = @_;
    
    # Normalize to uppercase
    $vin = uc($vin);

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

    # Validate the check digit (9th character)
    if (!validateCheckDigit($vin)) {
        print "  Invalid check digit for VIN: $vin\n";
        return 0;
    }

    return 1;
}

# Validate the VIN check digit
sub validateCheckDigit {
    my ($vin) = @_;
    my %transliteration = (
        A => 1, B => 2, C => 3, D => 4, E => 5, F => 6, G => 7, H => 8,
        J => 1, K => 2, L => 3, M => 4, N => 5, P => 7, R => 9, S => 2,
        T => 3, U => 4, V => 5, W => 6, X => 7, Y => 8, Z => 9,
    );

    my @weights = (8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2);
    my $sum = 0;

    for my $i (0..16) {
        my $char = substr($vin, $i, 1);
        my $value = ($char =~ /\d/) ? $char : $transliteration{$char};
        $sum += $value * $weights[$i];
    }

    my $check_digit = substr($vin, 8, 1);
    my $computed_check_digit = ($sum % 11 == 10) ? 'X' : ($sum % 11);

    return $check_digit eq $computed_check_digit;
}

# Extract potential VINs from a given string.
sub extractVINs {
    my ($text) = @_;
    my @matches = ($text =~ /\b[A-Za-z0-9]{17}\b/g);

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
