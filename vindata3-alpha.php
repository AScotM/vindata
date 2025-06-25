<?php

/**
 * Validates a VIN (including check digit).
 */
function isValidVIN(string $vin): bool {
    $vin = strtoupper(trim($vin));
    if (strlen($vin) !== 17 || preg_match('/[IOQ]/', $vin)) {
        return false;
    }
    return validateCheckDigit($vin);
}

/**
 * Validates the VIN check digit (9th character).
 */
function validateCheckDigit(string $vin): bool {
    static $weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];
    static $transliteration = [
        'A' => 1, 'B' => 2, 'C' => 3, 'D' => 4, 'E' => 5, 'F' => 6, 'G' => 7, 'H' => 8,
        'J' => 1, 'K' => 2, 'L' => 3, 'M' => 4, 'N' => 5, 'P' => 7, 'R' => 9, 'S' => 2,
        'T' => 3, 'U' => 4, 'V' => 5, 'W' => 6, 'X' => 7, 'Y' => 8, 'Z' => 9,
        '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6,
        '7' => 7, '8' => 8, '9' => 9
    ];

    $sum = 0;
    for ($i = 0; $i < 17; ++$i) {
        $char = $vin[$i];
        $value = $transliteration[$char] ?? null;
        if ($value === null) {
            return false;
        }
        if ($i !== 8) {
            $sum += $value * $weights[$i];
        }
    }

    $remainder = $sum % 11;
    $checkDigit = $vin[8];

    // Debugging: Uncomment next line for troubleshooting
    // echo "VIN: $vin | Computed: " . ($remainder === 10 ? 'X' : $remainder) . " | Actual: $checkDigit\n";

    return ($remainder === 10) ? ($checkDigit === 'X') : ($checkDigit === (string)$remainder);
}

/**
 * Extracts strict VIN candidates from text.
 */
function extractVINs(string $text): array {
    $text = strtoupper($text);
    preg_match_all('/\b[A-HJ-NPR-Z0-9]{17}\b/', $text, $matches);
    return $matches[0] ?? [];
}

// === TESTING ===
if (php_sapi_name() === "cli" && basename(__FILE__) === basename($_SERVER["SCRIPT_FILENAME"])) {
    $testVINs = [
        '1HGCM82633A004352' => true,  // Valid Honda (check digit 3)
        '1M8GDM9AXKP042788' => true,  // Valid (check digit X)
        'JH4TB2H26CC000000' => true,  // Valid Acura (check digit 6)
        '1HGCM82633A123455' => false, // Invalid (bad check digit)
        'ABC1234INVALID5678' => false // Invalid (length/format)
    ];

    foreach ($testVINs as $vin => $expected) {
        $result = isValidVIN($vin);
        echo sprintf(
            "VIN: %s | Valid: %s | Expected: %s | %s\n",
            $vin,
            $result ? 'YES' : 'NO',
            $expected ? 'YES' : 'NO',
            ($result === $expected) ? 'PASS' : 'FAIL'
        );
    }
}
