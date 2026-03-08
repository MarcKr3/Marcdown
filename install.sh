#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/OWNER/marcdown.git"
TARGET="$HOME/.claude"
MANIFEST="$TARGET/.marcdown-manifest"

# Framework items to install
DIRS=(agents commands references templates)
ROOT_FILES=(CLAUDE.md)

# --- Uninstall mode ---
if [[ "${1:-}" == "--uninstall" ]]; then
  if [[ ! -f "$MANIFEST" ]]; then
    echo "No Marcdown installation found (missing manifest)."
    echo "If you installed manually, remove these from $TARGET:"
    echo "  agents/ commands/ references/ templates/ CLAUDE.md"
    exit 1
  fi

  echo "Uninstalling Marcdown from $TARGET ..."
  echo ""

  while IFS= read -r file; do
    if [[ -f "$TARGET/$file" ]]; then
      rm "$TARGET/$file"
      echo "  removed $file"
    fi
  done < "$MANIFEST"

  # Remove empty directories left behind
  for d in "${DIRS[@]}"; do
    if [[ -d "$TARGET/$d" ]]; then
      find "$TARGET/$d" -type d -empty -delete 2>/dev/null || true
      if [[ -d "$TARGET/$d" ]] && [[ -z "$(ls -A "$TARGET/$d" 2>/dev/null)" ]]; then
        rmdir "$TARGET/$d"
        echo "  removed empty $d/"
      fi
    fi
  done

  rm -f "$MANIFEST"
  echo ""
  echo "Done. Marcdown has been removed. Your ~/.claude/ directory is now vanilla."
  exit 0
fi

# --- Install / Update mode ---

echo "=============================="
echo "  Marcdown Framework Installer"
echo "=============================="
echo ""
echo "This will install Marcdown directly into $TARGET."
echo "Files with identical names WILL be overwritten."
echo ""

# Warn if existing setup detected
if [[ -d "$TARGET" ]] && { [[ -e "$TARGET/CLAUDE.md" ]] || [[ -d "$TARGET/agents" ]] || [[ -d "$TARGET/commands" ]]; }; then
  echo "WARNING: Existing files detected in $TARGET."
  echo "If you have a custom setup, back it up first:"
  echo ""
  echo "  cp -r $TARGET ${TARGET}.backup"
  echo ""
fi

read -p "Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 1
fi

echo ""

# Clone to temp directory
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading Marcdown..."
git clone --depth 1 --quiet "$REPO" "$TMPDIR/marcdown"

mkdir -p "$TARGET"

# Fresh manifest
> "$MANIFEST"

# Copy directories
for d in "${DIRS[@]}"; do
  if [[ -d "$TMPDIR/marcdown/$d" ]]; then
    (cd "$TMPDIR/marcdown" && find "$d" -type f) | while IFS= read -r rel; do
      mkdir -p "$(dirname "$TARGET/$rel")"
      cp "$TMPDIR/marcdown/$rel" "$TARGET/$rel"
      echo "$rel" >> "$MANIFEST"
      echo "  + $rel"
    done
  fi
done

# Copy root files
for f in "${ROOT_FILES[@]}"; do
  if [[ -f "$TMPDIR/marcdown/$f" ]]; then
    cp "$TMPDIR/marcdown/$f" "$TARGET/$f"
    echo "$f" >> "$MANIFEST"
    echo "  + $f"
  fi
done

COUNT=$(wc -l < "$MANIFEST" | tr -d ' ')
echo ""
echo "Installed $COUNT files into $TARGET."
echo ""
echo "Update:    re-run this script"
echo "Uninstall: bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/marcdown/main/install.sh) --uninstall"
