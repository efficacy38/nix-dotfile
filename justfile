# Run all checks
default: check test static-check

# Check Nix syntax and evaluate flake
check:
    nix flake check

# Static analysis with deadnix
static-check:
    deadnix --fail
    statix check

# Run tests
test:
    nix flake check --all-systems

# Reformat all Nix files
reformat:
    nix fmt -- .

update flake:
    nix flake update {{ flake }}

update-agent: (update "llm-agents")

update-all: (update "")
