#!/bin/bash

kubeconfig_file="$1"
cluster_type="$2"

if [ ! -f "$kubeconfig_file" ]; then
  echo "Kubeconfig file not found: $kubeconfig_file"
  exit 1
fi

cp "$kubeconfig_file" "./config"
kubeconfig_file="./config"

certificate_authority_file=$(grep -Po '(?<=certificate-authority:).*' "$kubeconfig_file" | awk '{$1=$1};1')
client_certificate_file=$(grep -Po '(?<=client-certificate:).*' "$kubeconfig_file" | awk '{$1=$1};1')
client_key_file=$(grep -Po '(?<=client-key:).*' "$kubeconfig_file" | awk '{$1=$1};1')

if grep -q "certificate-authority-data:" "$kubeconfig_file"; then
  echo "The file '$kubeconfig_file' is already converted to a standalone Kubernetes config file."
  exit 0
fi


if echo "$certificate_authority_file" | grep -qE '^[A-Za-z]:\\'; then
# using wsl need to convert windows path to linux path
  certificate_authority_file=$(wslpath -a "$certificate_authority_file")
  client_certificate_file=$(wslpath -a "$client_certificate_file")
  client_key_file=$(wslpath -a "$client_key_file")
fi

certificate_authority_data=$(base64 -w 0 "$certificate_authority_file")
client_certificate_data=$(base64 -w 0 "$client_certificate_file")
client_key_data=$(base64 -w 0 "$client_key_file")

# Replace the lines in the kubeconfig file with base64-encoded data
sed -i "s|certificate-authority:.*$|certificate-authority-data: $certificate_authority_data|" "$kubeconfig_file"
sed -i "s|client-certificate:.*$|client-certificate-data: $client_certificate_data|" "$kubeconfig_file"
sed -i "s|client-key:.*$|client-key-data: $client_key_data|" "$kubeconfig_file"

sed -i "s|server:.*$|server: https://$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' minikube):8443|" "$kubeconfig_file"

echo "The file '$(realpath $kubeconfig_file)' was successfully converted."
