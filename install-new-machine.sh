#!/usr/bin/env bash
set -x

set -e -o pipefail

# Create a temporary directory
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
  echo cleaning up temp credentials
  rm -rf "$temp"
}
trap cleanup EXIT

# Function to validate target host format
validate_target_host() {
  local host="$1"

  # Check if format is user@host or user@ip
  if [[ ! "$host" =~ ^[a-zA-Z0-9_-]+@[a-zA-Z0-9.-]+$ ]]; then
    echo "Error: Invalid target host format. Expected format: user@hostname or user@ip"
    return 1
  fi

  # Extract hostname/IP part
  local hostname="${host#*@}"

  # Validate IP address format (IPv4)
  if [[ "$hostname" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    local IFS='.'
    local -a ip=($hostname)
    # Check each octet is between 0-255
    for octet in "${ip[@]}"; do
      if ((octet < 0 || octet > 255)); then
        echo "Error: Invalid IP address. Octets must be between 0-255"
        return 1
      fi
    done
  else
    # Validate hostname format
    if [[ ! "$hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
      echo "Error: Invalid hostname format"
      return 1
    fi
  fi

  return 0
}

# Extract available flake configurations from flake.nix
echo "Loading available NixOS configurations..."
available_flakes=$(nix eval --json .#nixosConfigurations --apply builtins.attrNames | jq -r '.[]')

if [ -z "$available_flakes" ]; then
  echo "Error: No flake configurations found in flake.nix"
  exit 1
fi

# Use fzf to select the flake configuration with retry logic
selected_flake=""
while [ -z "$selected_flake" ]; do
  echo "Select a NixOS configuration:"
  selected_flake=$(echo "$available_flakes" | fzf --prompt="NixOS Config > " --height=40% --border) || true

  if [ -z "$selected_flake" ]; then
    echo ""
    read -p "No configuration selected. Retry? (y/n): " retry
    if [[ ! "$retry" =~ ^[Yy]$ ]]; then
      echo "Installation cancelled."
      exit 1
    fi
  fi
done

echo "Selected flake: $selected_flake"
echo ""

# Read target host from user with validation and retry logic
target_host=""
while [ -z "$target_host" ]; do
  read -p "Enter target host (e.g., root@192.168.1.100 or root@hostname): " input_host

  if [ -z "$input_host" ]; then
    echo "Error: Target host cannot be empty."
    read -p "Retry? (y/n): " retry
    if [[ ! "$retry" =~ ^[Yy]$ ]]; then
      echo "Installation cancelled."
      exit 1
    fi
    continue
  fi

  if validate_target_host "$input_host"; then
    target_host="$input_host"
    echo "Target host validated: $target_host"
  else
    read -p "Retry? (y/n): " retry
    if [[ ! "$retry" =~ ^[Yy]$ ]]; then
      echo "Installation cancelled."
      exit 1
    fi
  fi
done

echo ""

# Generate SSH keys
echo "Generating SSH host keys..."
install -d -m755 "$temp/etc/ssh"
ssh-keygen -t ed25519 -f "$temp/etc/ssh/ssh_host_ed25519_key" -N ""
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

# Convert SSH public key to age key
echo ""
echo "Converting SSH key to age format..."
age_key=$(nix-shell -p ssh-to-age --run "ssh-to-age < $temp/etc/ssh/ssh_host_ed25519_key.pub")
echo "Age key: $age_key"

# Ask if user wants to add host to .sops.yaml
echo ""
read -p "Add this host to nix-secret/.sops.yaml with access to common secrets? (y/n): " add_to_sops

if [[ "$add_to_sops" =~ ^[Yy]$ ]]; then
  sops_file="nix-secret/.sops.yaml"

  if [ ! -f "$sops_file" ]; then
    echo "Warning: $sops_file not found, skipping..."
  else
    # Check if host already exists in .sops.yaml
    if grep -q "&${selected_flake} " "$sops_file"; then
      echo "Host '$selected_flake' already exists in $sops_file"
    else
      echo "Adding host '$selected_flake' to $sops_file..."

      # Use yq to add host to the hosts section and common.yaml age list
      nix-shell -p yq-go --run "
        yq eval -i '
          (.keys[] | select(has(\"hosts\")) | .hosts) += [\"&${selected_flake} ${age_key}\"] |
          (.keys[] | select(has(\"hosts\")) | .hosts[-1]) style=\"\" |
          (.creation_rules[] | select(.path_regex == \"secrets/common.yaml\") | .key_groups[] | select(has(\"age\")) | .age) += [\"*${selected_flake}\"]
        ' '$sops_file'
      "

      # Remove quotes from YAML alias references (e.g., '- '*minimum'' -> '- *minimum')
      sed -i "s/- '\(\*${selected_flake}\)'/- \1/g" "$sops_file"
      sed -i "s/- '\(&${selected_flake} ${age_key}\)'/- \1/g" "$sops_file"

      echo "Host added to $sops_file with access to secrets/common.yaml"
      echo "Please commit the changes to nix-secret submodule"
    fi
  fi
fi

# commit nix-secret submodule
pushd nix-secret
echo "upating sops secret, touch your yubikey"
sops updatekeys secrets/common.yaml || true
git add . || true
git commit -m "feat: add $selected_flake key, and access to common.yml" || true
git push || true
popd

echo ""

# nix flake update nix-secrets
nix flake update nix-secrets

# copy my nixos dot-file into /etc/nixos, zsh and nvim would refer files under
# this folder
git clone git@github.com:efficacy38/nix-dotfile.git "$temp/etc/nixos/nix-dotfile"

# Run nixos-anywhere with selected configuration
echo "Running nixos-anywhere..."
echo "Flake: .#${selected_flake}"
echo "Target: $target_host"
echo ""

nix-shell -p nixos-anywhere --run "
  nixos-anywhere --extra-files "$temp" --flake ".#${selected_flake}" --target-host "$target_host"
"
