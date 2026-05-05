#!/bin/bash
# =============================================================
# start-gui.sh
# Starter en enkel HTTP-server for GUI-en.
# =============================================================

set -e

PORT=8080

cd "$(dirname "$0")/gui"

echo "🚀 Starter GUI på http://localhost:${PORT}"
echo ""
echo "Åpner nettleseren automatisk om noen sekunder..."
echo "Trykk Ctrl+C for å stoppe."
echo ""

# Åpne nettleser etter 2 sekunder
(sleep 2 && {
  if command -v open > /dev/null; then
    open "http://localhost:${PORT}"
  elif command -v xdg-open > /dev/null; then
    xdg-open "http://localhost:${PORT}"
  elif command -v start > /dev/null; then
    start "http://localhost:${PORT}"
  fi
}) &

# Start enkel HTTP-server (Python 3 er forhåndsinstallert på Mac/Linux)
if command -v python3 > /dev/null; then
  python3 -m http.server $PORT
elif command -v python > /dev/null; then
  python -m http.server $PORT
else
  echo "❌ Fant ikke Python. Du kan også åpne gui/index.html direkte i nettleseren."
  echo "   (Men da må du kanskje skru av CORS i nettleseren — se README.)"
  exit 1
fi
