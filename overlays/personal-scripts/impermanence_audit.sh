#!/usr/bin/env bash
set -euo pipefail

# impermanence-audit emits JSON for files still on the current filesystem device.

# GNU stat %d is the numeric device ID for /. Files on other devices are mounted/persistent.
ROOT_DEVICE="$(stat -c %d /)"

for cmd in getent jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is required but not found" >&2
    exit 1
  fi
done

BUILTIN_IGNORES=(
  '/nix/*'
  '/tmp/*'
  '/run/*'
  '/proc/*'
  '/sys/*'
  '/dev/*'
  '/persistent/*'
  '/old_roots/*'
  '/boot/*'
  '/home/*'
  '/root/*'
)

json_array() {
  if [[ $# -eq 0 ]]; then
    echo "[]"
  else
    printf '%s\n' "$@" | jq -R . | jq -s .
  fi
}

home_for_user() {
  local user="$1"
  local entry
  entry=$(getent passwd "$user") || {
    echo "Error: user not found: $user" >&2
    exit 1
  }
  printf '%s\n' "$entry" | cut -d: -f6
}

build_find_excludes() {
  local excludes=()

  for pattern in "${BUILTIN_IGNORES[@]}"; do
    excludes+=(-not -path "$pattern")
  done

  printf '%s\n' "${excludes[@]}"
}

# Emit NUL-delimited files below root that still live on ROOT_DEVICE.
# The per-file device check catches file mountpoints that -xdev can still print.
scan_root_device_files() {
  local root="$1"
  shift
  local record file_device file

  # find emits DEVICE<TAB>PATH<NUL> records; %D is device ID and %p is path.
  # read -d '' and sort -z keep the NUL separator, so unusual paths stay intact.
  while IFS= read -r -d '' record; do
    file_device="${record%%$'\t'*}"
    file="${record#*$'\t'}"

    if [[ "$file_device" != "$ROOT_DEVICE" ]]; then
      continue
    fi

    printf '%s\0' "$file"
  done < <(find "$root" -xdev \
    "$@" \
    -type f \
    ! -type l \
    -printf '%D\t%p\0' \
    2>/dev/null | sort -z)
}

mapfile -t FIND_EXCLUDES < <(build_find_excludes)

UNTRACKED_SYSTEM=()
while IFS= read -r -d '' file; do
  [[ -z "$file" ]] && continue
  UNTRACKED_SYSTEM+=("$file")
done < <(scan_root_device_files / "${FIND_EXCLUDES[@]}")

users_json="{}"
total=${#UNTRACKED_SYSTEM[@]}

for user in "$@"; do
  user_home=$(home_for_user "$user")
  untracked_user=()

  if [[ -d "$user_home" ]]; then
    while IFS= read -r -d '' file; do
      [[ -z "$file" ]] && continue
      untracked_user+=("$file")
    done < <(scan_root_device_files "$user_home" -not -path "${user_home}/.cache/*")
  fi

  user_json=$(json_array "${untracked_user[@]}")
  users_json=$(jq --arg user "$user" --argjson files "$user_json" '. + {($user): $files}' <<< "$users_json")
  total=$((total + ${#untracked_user[@]}))
done

jq -n \
  --argjson system "$(json_array "${UNTRACKED_SYSTEM[@]}")" \
  --argjson users "$users_json" \
  --argjson total "$total" \
  '{
    system: $system,
    users: $users,
    total: $total
  }'
