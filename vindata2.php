<?php

/**
 * Validate a VIN.
 *
 * @param string $vin
 * @return bool
 */
function isValidVIN($vin) {
    // Check basic VIN requirements
    if (strlen($vin) !== 17 || preg_match('/[IOQ]/', $vin)) {
        return false;
    }

    // Validate checksum
    return validateVINChecksum($vin);
}

/**
 * Calculate and validate the VIN checksum.
 *
 * @param string $vin
 * @return bool
 */
function validateVINChecksum($vin) {
    // Transliteration table for VIN characters
    $transliterationTable = [
        'A' => 1, 'B' => 2, 'C' => 3, 'D' => 4, 'E' => 5, 'F' => 6, 'G' => 7, 'H' => 8,
        'J' => 1, 'K' => 2, 'L' => 3, 'M' => 4, 'N' => 5, 'P' => 7, 'R' => 9,
        'S' => 2, 'T' => 3, 'U' => 4, 'V' => 5, 'W' => 6, 'X' => 7, 'Y' => 8, 'Z' => 9,
        '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9
    ];

    // Position weights
    $weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];

    // Calculate weighted sum
    $sum = 0;
    for ($i = 0; $i < 17; $i++) {
        $char = $vin[$i];
        $value = isset($transliterationTable[$char]) ? $transliterationTable[$char] : 0;
        $sum += $value * $weights[$i];
    }

    // Calculate checksum
    $calculatedChecksum = $sum % 11;

    // Translate calculated checksum to VIN-compatible character
    $calculatedChecksumChar = $calculatedChecksum === 10 ? 'X' : (string)$calculatedChecksum;

    // Compare to the VIN's checksum character
    return $vin[8] === $calculatedChecksumChar;
}

// Example usage
$testVINs = [
    '1HGCM82633A123456', // Valid VIN
    'WDBBA48D7KA093694', // Valid VIN
    '1HGCM82633A12345X', // Invalid checksum
];

foreach ($testVINs as $vin) {
    echo "VIN: $vin - " . (isValidVIN($vin) ? "Valid" : "Invalid") . "\n";
}

