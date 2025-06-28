#!/usr/bin/env python3
"""VIN (Vehicle Identification Number) Validation Module"""

import re
from typing import List, Dict, Optional

# Constants
TRANSLITERATION: Dict[str, int] = {
    'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8,
    'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'P': 7, 'R': 9, 'S': 2,
    'T': 3, 'U': 4, 'V': 5, 'W': 6, 'X': 7, 'Y': 8, 'Z': 9,
    '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6,
    '7': 7, '8': 8, '9': 9
}

WEIGHTS: List[int] = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]
INVALID_CHARS_PATTERN = re.compile(r'[IOQ]')
VIN_PATTERN = re.compile(r'\b[A-HJ-NPR-Z0-9]{17}\b')

def is_valid_vin(vin: str) -> bool:
    """
    Validates a VIN including check digit.
    
    Args:
        vin: Vehicle Identification Number to validate
        
    Returns:
        bool: True if valid, False otherwise
    """
    vin = vin.upper().strip()
    if len(vin) != 17 or INVALID_CHARS_PATTERN.search(vin):
        return False
    return _validate_check_digit(vin)

def _validate_check_digit(vin: str) -> bool:
    """
    Validates the VIN check digit (9th character).
    
    Args:
        vin: 17-character VIN
        
    Returns:
        bool: True if check digit is valid
    """
    total = 0
    
    for i, char in enumerate(vin):
        value = TRANSLITERATION.get(char)
        if value is None:
            return False
            
        # Skip check digit position (index 8)
        if i != 8:
            total += value * WEIGHTS[i]
    
    remainder = total % 11
    check_digit = vin[8]
    
    # For debugging:
    # print(f"VIN: {vin} | Computed: {10 if remainder == 10 else remainder} | Actual: {check_digit}")
    
    if remainder == 10:
        return check_digit == 'X'
    return check_digit == str(remainder)

def extract_vins(text: str) -> List[str]:
    """
    Extracts strict VIN candidates from text.
    
    Args:
        text: Input text containing potential VINs
        
    Returns:
        List[str]: List of found VIN candidates
    """
    return VIN_PATTERN.findall(text.upper())

def run_tests() -> None:
    """Test function with example VINs"""
    test_vins = {
        '1HGCM82633A004352': True,  # Valid Honda (check digit 3)
        '1M8GDM9AXKP042788': True,  # Valid (check digit X)
        'JH4TB2H26CC000000': True,  # Valid Acura (check digit 6)
        '1HGCM82633A123455': False, # Invalid (bad check digit)
        'ABC1234INVALID5678': False # Invalid (length/format)
    }
    
    for vin, expected in test_vins.items():
        result = is_valid_vin(vin)
        status = "PASS" if result == expected else "FAIL"
        print(f"VIN: {vin} | Valid: {'YES' if result else 'NO'} | "
              f"Expected: {'YES' if expected else 'NO'} | {status}")

if __name__ == "__main__":
    run_tests()
