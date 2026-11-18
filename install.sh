#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/MarcKr3/Marcdown.git"
TARGET="$HOME/.claude"
MANIFEST="$TARGET/.marcdown-manifest"

# Framework items to install
DIRS=(agents bin commands references templates skills)
ROOT_FILES=(CLAUDE.md)

# --- Uninstall mode ---
if [[ "${1:-}" == "--uninstall" ]]; then
  if [[ ! -f "$MANIFEST" ]]; then
    echo "No Marcdown installation found (missing manifest)."
    echo "If you installed manually, remove these from $TARGET:"
    echo "  agents/ bin/ commands/ references/ templates/ skills/ste-writing/ CLAUDE.md"
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

# Source: the folder of this script when it holds the framework (an unpacked zip),
# else a fresh clone of the repository.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd -P || true)"
if [[ -n "$HERE" && -f "$HERE/CLAUDE.md" && -d "$HERE/agents" && "$HERE" != "$(cd "$TARGET" 2>/dev/null && pwd -P || true)" ]]; then
  SRC="$HERE"
  echo "Installing Marcdown from $SRC..."
else
  TMPDIR="$(mktemp -d)"
  trap 'rm -rf "$TMPDIR"' EXIT
  echo "Downloading Marcdown..."
  git clone --depth 1 --quiet "$REPO" "$TMPDIR/marcdown"
  SRC="$TMPDIR/marcdown"
fi

mkdir -p "$TARGET"

# Fresh manifest
> "$MANIFEST"

# Copy directories
for d in "${DIRS[@]}"; do
  if [[ -d "$SRC/$d" ]]; then
    (cd "$SRC" && find "$d" -type f) | while IFS= read -r rel; do
      mkdir -p "$(dirname "$TARGET/$rel")"
      cp "$SRC/$rel" "$TARGET/$rel"
      echo "$rel" >> "$MANIFEST"
      echo "  + $rel"
    done
  fi
done

# Copy root files
for f in "${ROOT_FILES[@]}"; do
  if [[ -f "$SRC/$f" ]]; then
    cp "$SRC/$f" "$TARGET/$f"
    echo "$f" >> "$MANIFEST"
    echo "  + $f"
  fi
done

chmod +x "$TARGET"/bin/* 2>/dev/null || true

COUNT=$(wc -l < "$MANIFEST" | tr -d ' ')
echo ""
echo "Installed $COUNT files into $TARGET."
echo ""
echo "Board:     in each project, run ~/.claude/bin/board setup (one time for each computer)"
echo "Update:    re-run this script"
echo "Uninstall: bash <(curl -fsSL https://raw.githubusercontent.com/MarcKr3/Marcdown/main/install.sh) --uninstall"
