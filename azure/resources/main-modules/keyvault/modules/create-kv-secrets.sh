#!/bin/bash

KeyvaultName=$1
ResourceGroupName=$2
Subscription=$3
CreateSecrets=$4

str="${CreateSecrets//[\'\[\]]/}" # Remove all the single quotes and square brackets
IFS=, read -r -a arr <<< "$str"

function Generate-Random-Secret {
    # Generate 16 random alphanumeric characters
    secret=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    # Select a random special character and append it to the secret
    special_characters=('#' '+' '*' '@' '!')
    special_char=$(echo "${special_characters[$RANDOM % ${#special_characters[@]}]}")
    secret=$secret$special_char
    # Shuffle the characters in the secret
    secret=$(echo "$secret" | fold -w1 | shuf | tr -d '\n')
    echo "$secret"
}

KeyvaultExists=$(az keyvault list -g $ResourceGroupName --subscription $Subscription | jq '.[].name')
if [[ "$KeyvaultName" =~ "\"$KeyvaultExists\"" ]]; then
  echo "KeyVault does not exist"
else
  ExistingSecrets=$(az keyvault secret list --vault-name $KeyvaultName --query "[].name" | jq '.[]')
  for Secret in "${arr[@]}"; do
    if [[ ! " ${ExistingSecrets[@]} " =~ "\"$Secret\"" ]]; then
      SecretValue=$(Generate-Random-Secret)
      az keyvault secret set --name $Secret --vault-name $KeyvaultName --value $SecretValue --output none --only-show-errors
    fi

    if [[ $? -ne 0 ]]; then
      echo "Unable to create secrets"
      exit 1
    fi
  done
fi

# Reference: https://docs.microsoft.com/nl-nl/cli/azure/keyvault?view=azure-cli-latest#az_keyvault_create