#!/usr/bin/env bash
#
# CodeMie quick install — installs the CodeMie CLI and brings every
# supported agent up to its minimum version in one shot.
#
# Usage:
#   ./install.sh            # install + upgrade supported agents
#   ./install.sh --check    # health check only, change nothing
#   ./install.sh --no-agents  # install CLI only, skip agent upgrades
#
set -euo pipefail

CODEMIE_INSTALL_URL="${CODEMIE_INSTALL_URL:-https://raw.githubusercontent.com/codemie-ai/codemie-code/main/install/macos/install.sh}"

CHECK_ONLY=0
SKIP_AGENTS=0
for arg in "$@"; do
  case "$arg" in
    --check)     CHECK_ONLY=1 ;;
    --no-agents) SKIP_AGENTS=1 ;;
    -h|--help)
      cat <<'USAGE'
CodeMie quick install — installs the CodeMie CLI and brings every
supported agent up to its minimum version in one shot.

Usage:
  ./install.sh              install + upgrade supported agents
  ./install.sh --check      health check only, change nothing
  ./install.sh --no-agents  install CLI only, skip agent upgrades
USAGE
      exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

say()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || die "missing required tool: $1"; }

# --- prerequisites ---------------------------------------------------------
need node
need npm
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 20 ] || die "Node >= 20 required (found $(node --version))"

if [ "$CHECK_ONLY" -eq 1 ]; then
  say "Running health check only"
  if command -v codemie >/dev/null 2>&1; then
    codemie doctor || true
  else
    warn "codemie not installed yet — run ./install.sh to install it"
  fi
  exit 0
fi

# --- install the CLI -------------------------------------------------------
if command -v codemie >/dev/null 2>&1; then
  say "CodeMie already installed ($(codemie --version 2>/dev/null || echo '?')) — checking for updates"
  npm install -g @codemieai/code@latest
else
  say "Installing CodeMie CLI"
  curl -fsSL "$CODEMIE_INSTALL_URL" | bash
fi

# --- bring supported agents up to minimum ----------------------------------
if [ "$SKIP_AGENTS" -eq 0 ]; then
  say "Upgrading supported agents to minimum versions"
  for agent in claude gemini gemini-acp codex codemie-code; do
    say "install $agent --supported"
    codemie install "$agent" --supported || warn "could not upgrade $agent (continuing)"
  done
else
  warn "Skipping agent upgrades (--no-agents)"
fi

# --- final health check ----------------------------------------------------
say "Health check"
codemie doctor || true

cat <<'EOF'

Next steps:
  codemie setup        # configure your active profile (required)
  codemie doctor       # re-run the health check any time

EOF
say "Done."
