#!/usr/bin/env bash
# Enhanced VIN Validator - Robust Bash Implementation

set -o errexit
set -o nounset
set -o pipefail

# --- Constants ---
declare -r INVALID_CHARS="IOQ"
declare -r VIN_PATTERN='^[A-HJ-NPR-Z0-9]{17}$'
declare -A TRANSLITERATION=(
    [A]=1 [B]=2 [C]=3 [D]=4 [E]=5 [F]=6 [G]=7 [H]=8
    [J]=1 [K]=2 [L]=3 [M]=4 [N]=5 [P]=7 [R]=9 [S]=2
    [T]=3 [U]=4 [V]=5 [W]=6 [X]=7 [Y]=8 [Z]=9
    [0]=0 [1]=1 [2]=2 [3]=3 [4]=4 [5]=5 [6]=6
    [7]=7 [8]=8 [9]=9
)
declare -ra WEIGHTS=(8 7 6 5 4 3 2 10 0 9 8 7 6 5 4 3 2)

# --- Core Functions ---
validate_vin() {
    local vin="${1^^}"
    vin="${vin//[[:space:]]/}"

    if [[ "${#vin}" -ne 17 ]]; then
        echo "Error: VIN must be exactly 17 characters long (got ${#vin})" >&2
        return 1
    fi
    
    if [[ ! "$vin" =~ $VIN_PATTERN ]]; then
        echo "Error: VIN contains invalid characters (only A-H,J-N,P,R-Z and 0-9 allowed)" >&2
        return 1
    fi
    
    if grep -q "[$INVALID_CHARS]" <<< "$vin"; then
        echo "Error: VIN contains invalid characters (I, O, or Q)" >&2
        return 1
    fi

    local total=0
    for ((i = 0; i < 17; i++)); do
        local char="${vin:i:1}"
        local value="${TRANSLITERATION[$char]:-}"
        
        if [[ -z "$value" ]]; then
            echo "Error: Invalid character '$char' in VIN" >&2
            return 1
        fi

        (( i != 8 )) && (( total += value * WEIGHTS[i] ))
    done

    local remainder=$(( total % 11 ))
    local check_digit="${vin:8:1}"

    case "$remainder:$check_digit" in
        10:X) return 0 ;;
        *:"$remainder") return 0 ;;
        *) 
            echo "Error: Check digit mismatch (expected $([[ $remainder -eq 10 ]] && echo X || echo $remainder), got $check_digit)" >&2
            return 1 ;;
    esac
}

extract_vins() {
    local input="${1^^}"
    # More precise pattern to reduce false positives
    grep -oE "\b[A-HJ-NPR-Z0-9]{3}[A-HJ-NPR-Z0-9]{5}[0-9X][A-HJ-NPR-Z0-9]{8}\b" <<< "$input" | while read -r vin; do
        if validate_vin "$vin" &>/dev/null; then
            echo "$vin"
        fi
    done
}

# --- Test Framework ---
run_tests() {
    local -A test_cases=(
        ["1HGCM82633A004352"]="VALID"
        ["1M8GDM9AXKP042788"]="VALID"
        ["JH4TB2H26CC000000"]="VALID"
        ["1HGCM82633A123455"]="INVALID"  # Check digit wrong
        ["ABC1234INVALID5678"]="INVALID" # Invalid format
        ["1HGCM82633A00435"]="INVALID"   # Too short
        ["1HGCM82633A0043521"]="INVALID" # Too long
        ["1HOCM82633A004352"]="INVALID"  # Contains O
        ["11111111111111111"]="VALID"    # All numbers
        ["AAAAAAAAAAAAAAAAA"]="INVALID"  # All letters (invalid check digit)
        ["1G1BL52P7GR123456"]="VALID"    # Valid with X in position 9
    )

    local passed=0 failed=0

    echo "Running VIN Validation Tests..."
    echo "-----------------------------"

    for vin in "${!test_cases[@]}"; do
        local expected="${test_cases[$vin]}"
        
        if validate_vin "$vin" &>/dev/null; then
            actual="VALID"
        else
            actual="INVALID"
        fi

        if [[ "$actual" == "$expected" ]]; then
            printf "\e[32m✓ PASS\e[0m: %-20s (Expected: %s)\n" "$vin" "$expected"
            (( passed++ ))
        else
            printf "\e[31m✗ FAIL\e[0m: %-20s (Expected: %s, Got: %s)\n" \
                   "$vin" "$expected" "$actual"
            (( failed++ ))
        fi
    done

    echo "-----------------------------"
    printf "Results: \e[32m%d PASSED\e[0m, \e[31m%d FAILED\e[0m\n" "$passed" "$failed"
    (( failed > 0 )) && return 1 || return 0
}

# --- Main Execution ---
main() {
    case "${1:-}" in
        -t|--test)
            run_tests
            ;;
        -e|--extract)
            [[ -z "${2:-}" ]] && { echo "Error: No input provided" >&2; exit 1; }
            extract_vins "$2"
            ;;
        *)
            if [[ -n "${1:-}" ]]; then
                if validate_vin "$1"; then
                    echo "VALID VIN: $1"
                else
                    exit 1
                fi
            else
                cat <<EOF
VIN Validator - Usage:

  Validate single VIN:
    $0 <VIN>

  Extract VINs from text:
    $0 --extract "text containing VINs"

  Run test cases:
    $0 --test

EOF
                exit 1
            fi
            ;;
    esac
}

# Check Bash version (associative arrays require Bash 4+)
if (( BASH_VERSINFO[0] < 4 )); then
    echo "Error: This script requires Bash version 4 or higher" >&2
    exit 1
fi

main "$@"
