#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/OWNER/marcdown.git"
TARGET="$HOME/.claude"
SRC="$TARGET/Marcdown"

# Framework items to symlink into ~/.claude/
DIRS=(agents commands references templates)
FILES=(CLAUDE.md CHEATSHEET.md CHEATSHEET.pdf)

echo "Installing Marcdown into $TARGET ..."

mkdir -p "$TARGET"

if [ -d "$SRC/.git" ]; then
  echo "Updating existing install..."
  git -C "$SRC" pull --ff-only
else
  rm -rf "$SRC"
  git clone "$REPO" "$SRC"
fi

for d in "${DIRS[@]}"; do
  if [ -L "$TARGET/$d" ]; then
    rm "$TARGET/$d"
  elif [ -e "$TARGET/$d" ]; then
    echo "  SKIP $d/ (exists and is not a symlink)"
    continue
  fi
  ln -s "$SRC/$d" "$TARGET/$d"
  echo "  -> $d/"
done

for f in "${FILES[@]}"; do
  if [ -L "$TARGET/$f" ]; then
    rm "$TARGET/$f"
  elif [ -e "$TARGET/$f" ]; then
    echo "  SKIP $f (exists and is not a symlink)"
    continue
  fi
  ln -s "$SRC/$f" "$TARGET/$f"
  echo "  -> $f"
done

echo "Done. Update anytime with: cd $SRC && git pull"
