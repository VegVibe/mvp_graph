#!/bin/bash
# =============================================================
# load-all.sh
# Laster all ontologi og data inn i Neo4j i riktig rekkefølge.
# =============================================================

set -e

CONTAINER=statnett-kg-neo4j
USER=neo4j
PASS=mvp-passord-123

# Sjekk at Neo4j kjører
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "❌ Neo4j-containeren '${CONTAINER}' kjører ikke."
  echo "   Start den med: docker compose up -d"
  exit 1
fi

# Vent til Neo4j er klar
echo "⏳ Venter på at Neo4j er klar..."
for i in {1..30}; do
  if docker exec "$CONTAINER" cypher-shell -u "$USER" -p "$PASS" "RETURN 1" > /dev/null 2>&1; then
    echo "✅ Neo4j er klar"
    break
  fi
  sleep 2
done

run_cypher() {
  local file=$1
  local label=$2
  echo ""
  echo "▶️  $label"
  docker exec -i "$CONTAINER" cypher-shell -u "$USER" -p "$PASS" --format plain < "$file"
}

# Last i riktig rekkefølge
run_cypher ontology/01_constraints.cypher       "Constraints og indekser"
run_cypher data/02_strategi_portefolje.cypher   "Strategi og portefølje"
run_cypher data/03_anlegg.cypher                "Fysisk anlegg og RDS"
run_cypher data/04_prosjektstruktur.cypher      "Prosjektstruktur"
run_cypher data/05_tverrgaende.cypher           "Krav, dokumenter, roller, risiko"

echo ""
echo "✅ Ferdig!"
echo ""
echo "Neo4j Browser: http://localhost:7474"
echo "Brukernavn:    $USER"
echo "Passord:       $PASS"
echo ""
echo "Prøv f.eks.:"
echo "  MATCH (n) RETURN n LIMIT 100"
