<?php

// Function to validate a VIN
function isValidVIN($vin) {
    // Check the length
    if (strlen($vin) !== 17) {
        return false;
    }

    // Ensure it does not contain invalid characters
    if (preg_match('/[IOQ]/', $vin)) {
        return false;
    }

    // Optional: Implement VIN checksum validation if needed
    // Skipping for simplicity; can be added later for stricter validation

    return true;
}

// Function to extract VINs from a given string
function extractVINs($text) {
    // VINs are 17-character alphanumeric strings (excluding I, O, Q)
    $pattern = '/\b([A-HJ-NPR-Z0-9]{17})\b/';
    preg_match_all($pattern, $text, $matches);
    return $matches[1]; // Return the array of matched VINs
}

// Example usage
$inputText = <<<EOT
Here are some sample VINs:
1HGCM82633A123456, WDBBA48D7KA093694, and incorrect ones like ABC1234INVALID5678.
EOT;

// Extract and validate VINs
$vinList = extractVINs($inputText);
echo "Extracted VINs:\n";
foreach ($vinList as $vin) {
    echo $vin . ' - ' . (isValidVIN($vin) ? 'Valid' : 'Invalid') . "\n";
}

