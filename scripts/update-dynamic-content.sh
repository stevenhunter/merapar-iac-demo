#!/bin/bash
clear
read -p "Enter new value for dynamic string: " dynamicString
echo
read -p "This will update the value stored to "\""$dynamicString"\""? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
aws dynamodb update-item \
    --table-name merapar-iac-storage \
    --key '{"key1" : {"S": "dynamic-content"}}' \
    --update-expression "SET #data = :d" \
    --expression-attribute-names '{ "#data": "data" }' \
    --expression-attribute-values "{\"":d\"": { "\""S"\"": "\""$dynamicString"\"" } }"
