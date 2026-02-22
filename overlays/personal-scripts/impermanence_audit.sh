#!/usr/bin/env bash
set -euo pipefail

# impermanence-audit — find files on root fs not covered by NixOS impermanence declarations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# When installed via Nix, SCRIPT_DIR is in /nix/store — fall back to known config path
if [[ -f "$SCRIPT_DIR/../flake.nix" ]]; then
  FLAKE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  FLAKE_DIR="/etc/nixos/nix-dotfile"
fi

# Defaults
HOSTNAME="$(hostname)"
USER_NAME="$(whoami)"
IGNORE_FILE=""
JSON_OUTPUT=false
PERSISTENCE_FILE=""

# Built-in ignore patterns (paths that never need persistence)
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
  '/home/*'           # user home handled separately
  '/root/*'           # root home handled separately
  '/etc/ssh/*'        # mounted via bind mount in boot.nix
  '/usr/systemd-placeholder/*'
)

usage() {
  cat <<'EOF'
Usage: impermanence-audit [OPTIONS]

Scan the root filesystem and compare against NixOS impermanence declarations
to find files that would be lost on reboot.

Options:
  --hostname NAME       NixOS hostname for nix eval (default: $(hostname))
  --user NAME           Check user home paths (default: current user)
  --ignore FILE         Additional ignore patterns file (one pattern per line)
  --persistence FILE    Provide a pre-generated persistence paths file (one path per line)
                        instead of evaluating via nix. Lines starting with "user:" are user paths.
  --json                Output as JSON
  --flake DIR           Flake directory (default: parent of script dir)
  --help                Show this help

Examples:
  sudo impermanence-audit
  sudo impermanence-audit --hostname stella --user efficacy38
  sudo impermanence-audit --json | jq '.system | length'
EOF
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --hostname)      HOSTNAME="$2"; shift 2 ;;
    --user)          USER_NAME="$2"; shift 2 ;;
    --ignore)        IGNORE_FILE="$2"; shift 2 ;;
    --persistence)   PERSISTENCE_FILE="$2"; shift 2 ;;
    --json)          JSON_OUTPUT=true; shift ;;
    --flake)         FLAKE_DIR="$2"; shift 2 ;;
    --help)          usage ;;
    *)               echo "Unknown option: $1" >&2; usage ;;
  esac
done

# Check dependencies
for cmd in jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is required but not found" >&2
    exit 1
  fi
done

stderr() { echo "$@" >&2; }

# --- Step 1: Extract declared persistence paths ---

SYSTEM_DIRS=""
SYSTEM_FILES=""
USER_DIRS=""
USER_FILES=""

extract_from_nix_eval() {
  stderr "Evaluating persistence config for host '$HOSTNAME' via nix eval..."

  local persistence_json
  persistence_json=$(nix eval --json "${FLAKE_DIR}#nixosConfigurations.${HOSTNAME}.config.environment.persistence" 2>/dev/null) || return 1

  SYSTEM_DIRS=$(echo "$persistence_json" | jq -r '
    to_entries[] |
    (
      (.value.directories // [])[] |
      if type == "object" then .directory else . end
    )
  ' 2>/dev/null | sort -u)

  SYSTEM_FILES=$(echo "$persistence_json" | jq -r '
    to_entries[] |
    (
      (.value.files // [])[] |
      if type == "object" then .file else . end
    )
  ' 2>/dev/null | sort -u)

  USER_DIRS=$(echo "$persistence_json" | jq -r --arg user "$USER_NAME" '
    to_entries[] |
    (
      (.value.users[$user].directories // [])[] |
      if type == "object" then .directory else . end
    )
  ' 2>/dev/null | sort -u)

  USER_FILES=$(echo "$persistence_json" | jq -r --arg user "$USER_NAME" '
    to_entries[] |
    (
      (.value.users[$user].files // [])[] |
      if type == "object" then .file else . end
    )
  ' 2>/dev/null | sort -u)

  return 0
}

extract_from_nix_files() {
  stderr "Falling back to parsing .nix files for persistence paths..."

  # Find files that contain environment.persistence declarations (exclude worktrees)
  local nix_files
  nix_files=$(grep -rl 'environment\.persistence' "$FLAKE_DIR" --include='*.nix' \
    | grep -v '\.worktrees/' 2>/dev/null)

  if [[ -z "$nix_files" ]]; then
    stderr "Warning: No .nix files with environment.persistence found in $FLAKE_DIR"
    return
  fi

  # Extract string literals from persistence blocks
  # Look for quoted paths that appear near environment.persistence sections
  # System dirs: lines with "/path" (absolute paths)
  SYSTEM_DIRS=$(echo "$nix_files" | xargs grep -A200 'environment\.persistence' 2>/dev/null | \
    sed -n 's/^[^"]*"\(\/[a-zA-Z][^"]*\)".*/\1/p' | \
    grep -v '^\(/persistent\|/etc/ssh\)' | \
    sort -u)
  SYSTEM_FILES=""

  # User dirs: lines with relative paths (starting with . or a letter, no /)
  USER_DIRS=$(echo "$nix_files" | xargs grep -A200 'users\.' 2>/dev/null | \
    sed -n 's/^[^"]*"\(\.[^"]*\)".*/\1/p; s/^[^"]*"\([A-Z][a-zA-Z]*\)".*/\1/p' | \
    sort -u)
  USER_FILES=""
}

extract_from_persistence_file() {
  stderr "Reading persistence paths from '$PERSISTENCE_FILE'..."

  SYSTEM_DIRS=$(grep -v '^#' "$PERSISTENCE_FILE" | grep -v '^user:' | grep '^/' | sort -u)
  SYSTEM_FILES=""
  USER_DIRS=$(grep -v '^#' "$PERSISTENCE_FILE" | sed -n 's/^user://p' | sort -u)
  USER_FILES=""
}

if [[ -n "$PERSISTENCE_FILE" ]]; then
  extract_from_persistence_file
elif command -v nix &>/dev/null && extract_from_nix_eval 2>/dev/null; then
  : # success via nix eval
else
  stderr "Warning: nix eval failed or nix not available."
  extract_from_nix_files
fi

USER_HOME=$(eval echo "~${USER_NAME}" 2>/dev/null || echo "/home/${USER_NAME}")

stderr "Found $(echo "$SYSTEM_DIRS" | grep -c . || echo 0) system dirs, $(echo "$SYSTEM_FILES" | grep -c . || echo 0) system files"
stderr "Found $(echo "$USER_DIRS" | grep -c . || echo 0) user dirs, $(echo "$USER_FILES" | grep -c . || echo 0) user files"

# --- Step 2: Build the exclude list for find ---

build_find_excludes() {
  local excludes=()

  # Built-in ignores
  for pattern in "${BUILTIN_IGNORES[@]}"; do
    excludes+=(-not -path "$pattern")
  done

  # User ignore file
  if [[ -n "$IGNORE_FILE" && -f "$IGNORE_FILE" ]]; then
    while IFS= read -r pattern; do
      [[ -z "$pattern" || "$pattern" == \#* ]] && continue
      excludes+=(-not -path "$pattern")
    done < "$IGNORE_FILE"
  fi

  # Default user ignore file
  local default_ignore="${HOME}/.config/impermanence-audit/ignore"
  if [[ -z "$IGNORE_FILE" && -f "$default_ignore" ]]; then
    while IFS= read -r pattern; do
      [[ -z "$pattern" || "$pattern" == \#* ]] && continue
      excludes+=(-not -path "$pattern")
    done < "$default_ignore"
  fi

  printf '%s\n' "${excludes[@]}"
}

# Check if a path is covered by a declared persistence directory
is_covered() {
  local file="$1"
  shift
  local dirs=("$@")

  for dir in "${dirs[@]}"; do
    [[ -z "$dir" ]] && continue
    if [[ "$file" == "$dir"/* || "$file" == "$dir" ]]; then
      return 0
    fi
  done
  return 1
}

# --- Step 3: Scan root filesystem ---

stderr "Scanning root filesystem (this may take a moment)..."

mapfile -t FIND_EXCLUDES < <(build_find_excludes)

# Convert declared dirs to arrays for matching
mapfile -t SYS_DIR_ARRAY <<< "$SYSTEM_DIRS"
mapfile -t SYS_FILE_ARRAY <<< "$SYSTEM_FILES"

# Scan system files on root fs
UNTRACKED_SYSTEM=()
while IFS= read -r file; do
  [[ -z "$file" ]] && continue

  # Check against declared system directories
  if is_covered "$file" "${SYS_DIR_ARRAY[@]}"; then
    continue
  fi

  # Check against declared system files
  local_match=false
  for declared_file in "${SYS_FILE_ARRAY[@]}"; do
    [[ -z "$declared_file" ]] && continue
    if [[ "$file" == "$declared_file" ]]; then
      local_match=true
      break
    fi
  done
  $local_match && continue

  UNTRACKED_SYSTEM+=("$file")
done < <(find / -xdev \
  "${FIND_EXCLUDES[@]}" \
  -type f \
  ! -type l \
  2>/dev/null | sort)

# --- Step 4: Scan user home ---

stderr "Scanning user home for '$USER_NAME'..."

mapfile -t USR_DIR_ARRAY <<< "$USER_DIRS"
mapfile -t USR_FILE_ARRAY <<< "$USER_FILES"

UNTRACKED_USER=()
if [[ -d "$USER_HOME" ]]; then
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue

    # Make path relative to home for matching
    rel_path="${file#${USER_HOME}/}"

    # Check against declared user directories
    if is_covered "$rel_path" "${USR_DIR_ARRAY[@]}"; then
      continue
    fi

    # Check against declared user files
    local_match=false
    for declared_file in "${USR_FILE_ARRAY[@]}"; do
      [[ -z "$declared_file" ]] && continue
      if [[ "$rel_path" == "$declared_file" ]]; then
        local_match=true
        break
      fi
    done
    $local_match && continue

    UNTRACKED_USER+=("$file")
  done < <(find "$USER_HOME" -xdev \
    -not -path "${USER_HOME}/.cache/*" \
    -type f \
    ! -type l \
    2>/dev/null | sort)
fi

# --- Step 5: Output ---

TOTAL=$(( ${#UNTRACKED_SYSTEM[@]} + ${#UNTRACKED_USER[@]} ))

if $JSON_OUTPUT; then
  sys_json="[]"
  usr_json="[]"
  if [[ ${#UNTRACKED_SYSTEM[@]} -gt 0 ]]; then
    sys_json=$(printf '%s\n' "${UNTRACKED_SYSTEM[@]}" | jq -R . | jq -s .)
  fi
  if [[ ${#UNTRACKED_USER[@]} -gt 0 ]]; then
    usr_json=$(printf '%s\n' "${UNTRACKED_USER[@]}" | jq -R . | jq -s .)
  fi

  jq -n \
    --arg hostname "$HOSTNAME" \
    --arg user "$USER_NAME" \
    --argjson system "$sys_json" \
    --argjson user_files "$usr_json" \
    --argjson total "$TOTAL" \
    '{
      hostname: $hostname,
      user: $user,
      system: $system,
      user_files: $user_files,
      total: $total
    }'
else
  echo "=== Impermanence Audit Report ==="
  echo "Hostname: $HOSTNAME"
  echo ""

  echo "--- Untracked system files (${#UNTRACKED_SYSTEM[@]}) ---"
  if [[ ${#UNTRACKED_SYSTEM[@]} -eq 0 ]]; then
    echo "(none)"
  else
    printf '%s\n' "${UNTRACKED_SYSTEM[@]}"
  fi

  echo ""
  echo "--- Untracked user files [$USER_NAME] (${#UNTRACKED_USER[@]}) ---"
  if [[ ${#UNTRACKED_USER[@]} -eq 0 ]]; then
    echo "(none)"
  else
    printf '%s\n' "${UNTRACKED_USER[@]}"
  fi

  echo ""
  echo "Total: $TOTAL untracked paths"
fi
