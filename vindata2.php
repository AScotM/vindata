<?php

/**
 * Validate a VIN.
 * 
 * @param string $vin
 * @return bool
 */
function isValidVIN($vin) {
    // Debugging: Output VIN being validated
    echo "Validating VIN: $vin\n";

    // Check the length
    if (strlen($vin) !== 17) {
        echo "  Invalid length for VIN: $vin\n";
        return false;
    }

    // Ensure it does not contain invalid characters
    if (preg_match('/[IOQ]/', $vin)) {
        echo "  VIN contains invalid characters: $vin\n";
        return false;
    }

    return true;
}

/**
 * Extract potential VINs from a given string.
 * 
 * @param string $text
 * @return array
 */
function extractVINs($text) {
    // More permissive regex to capture any sequence of 17 or more characters
    preg_match_all('/\b[A-Za-z0-9]{17,}\b/', $text, $matches);
    // Debugging: Output extracted VINs
    echo "Extracted potential VINs: " . implode(', ', $matches[0]) . "\n";
    return $matches[0];
}

// Example usage
$inputText = "
Here are some sample VINs:
1HGCM82633A123456, WDBBA48D7KA093694, and incorrect ones like ABC1234INVALID5678.
";

// Extract potential VINs
$vinList = extractVINs($inputText);

// Categorize VINs
$validVINs = [];
$invalidVINs = [];
foreach ($vinList as $vin) {
    if (isValidVIN($vin)) {
        $validVINs[] = $vin;
    } else {
        $invalidVINs[] = $vin;
    }
}

// Display results
echo "\nValid VINs:\n";
if (count($validVINs) > 0) {
    foreach ($validVINs as $vin) {
        echo "  $vin\n";
    }
} else {
    echo "  None\n";
}

echo "\nInvalid VINs:\n";
if (count($invalidVINs) > 0) {
    foreach ($invalidVINs as $vin) {
        echo "  $vin\n";
    }
} else {
    echo "  None\n";
}
?>
