#!/usr/bin/env bash

# VIN Validation in Bash

## Constants
declare -A TRANSLITERATION=(
    [A]=1 [B]=2 [C]=3 [D]=4 [E]=5 [F]=6 [G]=7 [H]=8
    [J]=1 [K]=2 [L]=3 [M]=4 [N]=5 [P]=7 [R]=9 [S]=2
    [T]=3 [U]=4 [V]=5 [W]=6 [X]=7 [Y]=8 [Z]=9
    [0]=0 [1]=1 [2]=2 [3]=3 [4]=4 [5]=5 [6]=6
    [7]=7 [8]=8 [9]=9
)
WEIGHTS=(8 7 6 5 4 3 2 10 0 9 8 7 6 5 4 3 2)

## Main validation function
is_valid_vin() {
    local vin="${1^^}"  # Convert to uppercase
    vin="${vin// /}"     # Remove spaces
    
    # Length and invalid characters check
    if [[ ${#vin} -ne 17 ]] || [[ "$vin" =~ [IOQ] ]]; then
        return 1
    fi
    
    # Check digit validation
    local total=0
    for ((i=0; i<17; i++)); do
        local char="${vin:$i:1}"
        local value="${TRANSLITERATION[$char]}"
        
        # Skip check digit position (index 8)
        if [[ $i -ne 8 ]]; then
            total=$((total + value * ${WEIGHTS[$i]}))
        fi
    done
    
    local remainder=$((total % 11))
    local check_digit="${vin:8:1}"
    
    if [[ $remainder -eq 10 ]]; then
        [[ "$check_digit" == "X" ]] && return 0 || return 1
    else
        [[ "$check_digit" == "$remainder" ]] && return 0 || return 1
    fi
}

## Extract VINs from text
extract_vins() {
    local text="${1^^}"
    # Use grep to find all 17-character VIN candidates
    grep -oE '\<[A-HJ-NPR-Z0-9]{17}\>' <<< "$text"
}

## Test function
run_tests() {
    declare -A test_vins=(
        ["1HGCM82633A004352"]=true   # Valid Honda
        ["1M8GDM9AXKP042788"]=true   # Valid (check digit X)
        ["JH4TB2H26CC000000"]=true   # Valid Acura
        ["1HGCM82633A123455"]=false  # Invalid check digit
        ["ABC1234INVALID5678"]=false # Invalid format
    )
    
    for vin in "${!test_vins[@]}"; do
        is_valid_vin "$vin"
        local result=$?
        local expected="${test_vins[$vin]}"
        
        if [[ ($result -eq 0 && "$expected" == "true") || 
              ($result -ne 0 && "$expected" == "false") ]]; then
            status="PASS"
        else
            status="FAIL"
        fi
        
        printf "VIN: %-17s | Valid: %-3s | Expected: %-5s | %s\n" \
               "$vin" \
               "$([ $result -eq 0 ] && echo "YES" || echo "NO")" \
               "${expected^^}" \
               "$status"
    done
}

## Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "$1" in
        -t|--test)
            run_tests
            ;;
        -e|--extract)
            if [[ -n "$2" ]]; then
                extract_vins "$2"
            else
                echo "Usage: $0 --extract 'text with VINs'"
            fi
            ;;
        *)
            if [[ -n "$1" ]]; then
                is_valid_vin "$1"
                if [[ $? -eq 0 ]]; then
                    echo "VALID VIN: $1"
                else
                    echo "INVALID VIN: $1"
                fi
            else
                echo "Usage:"
                echo "  Validate single VIN: $0 <VIN>"
                echo "  Run tests:          $0 --test"
                echo "  Extract VINs:       $0 --extract 'text'"
            fi
            ;;
    esac
fi
