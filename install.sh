#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERR]${NC}  $*"; exit 1; }

ask() {
  local prompt="$1" default="${2:-}"
  local yn
  if [[ -n "$default" ]]; then
    read -rp "$prompt [$default]: " yn
    echo "${yn:-$default}"
  else
    read -rp "$prompt: " yn
    echo "$yn"
  fi
}

ask_yn() {
  local prompt="$1" default="${2:-y}"
  local yn
  read -rp "$prompt [Y/n]: " yn
  yn="${yn:-$default}"
  [[ "${yn,,}" == "y" ]]
}

# ── Skills catalogue ──────────────────────────────────────────────────────────
declare -A SKILL_NAMES=(
  [01-test-generation]="Generate tests from source code or spec"
  [02-test-data]="Prepare test data: builders, fixtures, factories"
  [03-failure-analysis]="Analyze failed tests, suggest fixes"
  [04-refactoring]="Refactor tests: structure, readability, DRY"
)

declare -A SKILL_FILES=(
  [01-test-generation]="test-generation.md"
  [02-test-data]="test-data.md"
  [03-failure-analysis]="failure-analysis.md"
  [04-refactoring]="refactoring.md"
)

# ── Detect project root ───────────────────────────────────────────────────────
detect_project_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/build.gradle.kts" || -f "$dir/build.gradle" || -f "$dir/pom.xml" || -f "$dir/.claude" ]]; then
      echo "$dir"
      return
    fi
    dir="$(dirname "$dir")"
  done
  echo "$PWD"
}

# ── Main ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       autotest-skills installer             ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Determine target project
default_project="$(detect_project_root)"

if [[ "$default_project" == "$REPO_ROOT" ]]; then
  info "Run this script from your test project directory, or specify it below."
  default_project="$PWD"
fi

echo -e "Target project: ${YELLOW}$default_project${NC}"
if ! ask_yn "Install skills into this project?"; then
  default_project="$(ask "Enter path to your project")"
fi

PROJECT_DIR="$default_project"
SKILLS_DST="$PROJECT_DIR/.claude/skills"

[[ -d "$PROJECT_DIR" ]] || error "Directory not found: $PROJECT_DIR"

mkdir -p "$SKILLS_DST"
info "Skills will be installed into: $SKILLS_DST"
echo ""

# Select skills to install
echo "Available skills:"
echo ""
declare -a TO_INSTALL=()

for key in $(echo "${!SKILL_NAMES[@]}" | tr ' ' '\n' | sort); do
  name="${SKILL_FILES[$key]}"
  desc="${SKILL_NAMES[$key]}"
  dst="$SKILLS_DST/$name"

  if [[ -f "$dst" ]]; then
    status="${YELLOW}already installed${NC}"
  else
    status="${GREEN}new${NC}"
  fi

  echo -e "  ${CYAN}${key}${NC} — ${desc} (${status})"

  if ask_yn "  Install ${key}?"; then
    TO_INSTALL+=("$key")
  fi
  echo ""
done

# Confirm
if [[ ${#TO_INSTALL[@]} -eq 0 ]]; then
  warn "Nothing selected. Exiting."
  exit 0
fi

echo ""
info "Installing ${#TO_INSTALL[@]} skill(s)..."
echo ""

INSTALLED=()
SKIPPED=()

for key in "${TO_INSTALL[@]}"; do
  src="$SKILLS_SRC/$key/SKILL.md"
  dst="$SKILLS_DST/${SKILL_FILES[$key]}"

  if [[ ! -f "$src" ]]; then
    warn "Source file not found: $src — skipping"
    SKIPPED+=("$key")
    continue
  fi

  if [[ -f "$dst" ]]; then
    if ! ask_yn "  ${SKILL_FILES[$key]} already exists. Overwrite?"; then
      SKIPPED+=("$key")
      continue
    fi
  fi

  cp "$src" "$dst"
  success "Installed: .claude/skills/${SKILL_FILES[$key]}"
  INSTALLED+=("$key")
done

# Summary
echo ""
echo -e "${CYAN}── Summary ────────────────────────────────────${NC}"
[[ ${#INSTALLED[@]} -gt 0 ]] && success "Installed: ${INSTALLED[*]}"
[[ ${#SKIPPED[@]}   -gt 0 ]] && warn    "Skipped:   ${SKIPPED[*]}"
echo ""

if [[ ${#INSTALLED[@]} -gt 0 ]]; then
  echo -e "${YELLOW}Next steps:${NC}"
  echo "  1. Open each installed skill in .claude/skills/ and fill in [НАСТРОИТЬ] sections."
  echo "  2. See docs/customization-guide.md for guidance."
  echo "  3. Invoke a skill in Claude Code:  /test-generation"
  echo ""
fi
