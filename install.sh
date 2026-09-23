#!/usr/bin/env bash
# Установка навыков Акметрон в Claude Code.
#
#   ./install.sh                          все навыки в ~/.claude/skills
#   ./install.sh meeting-protocol         только один
#   ./install.sh --project /path/to/repo  в .claude/skills проекта
#   ./install.sh --list                   что есть в наборе

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
DEST="$HOME/.claude/skills"
WANTED=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      [[ -n "${2:-}" ]] || { echo "После --project нужен путь к проекту." >&2; exit 1; }
      DEST="$2/.claude/skills"; shift 2 ;;
    --list)
      for d in "$SRC"/*/; do basename "$d"; done; exit 0 ;;
    -h|--help)
      sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)
      echo "Неизвестный ключ: $1" >&2; exit 1 ;;
    *)
      WANTED+=("$1"); shift ;;
  esac
done

if [[ ${#WANTED[@]} -eq 0 ]]; then
  for d in "$SRC"/*/; do WANTED+=("$(basename "$d")"); done
fi

mkdir -p "$DEST"
installed=0

for name in "${WANTED[@]}"; do
  if [[ ! -d "$SRC/$name" ]]; then
    echo "  пропуск: навыка «$name» нет в наборе" >&2
    continue
  fi
  if [[ -e "$DEST/$name" ]]; then
    backup="$DEST/$name.bak.$(date +%Y%m%d%H%M%S)"
    mv "$DEST/$name" "$backup"
    echo "  прежняя версия сохранена: $backup"
  fi
  cp -R "$SRC/$name" "$DEST/$name"
  files=$(find "$DEST/$name" -type f | wc -l | tr -d ' ')
  echo "  установлен: $name ($files файлов)"
  installed=$((installed + 1))
done

echo
echo "Готово: $installed навыков в $DEST"
echo "Перезапустите Claude Code, чтобы они появились в списке."
