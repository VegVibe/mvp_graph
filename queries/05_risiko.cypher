// =============================================================
// 05_risiko.cypher
// SPØRRING 5: Risikoeksponering — vis alle risikoer som
// påvirker portefølje PF-001, hvilke objekter de rammer,
// og hvilke tiltak som er på plass.
//
// Verdi: Tradisjonelt holdes risiko i regneark per prosjekt.
// I grafen kan vi se risikoer som spenner over flere
// prosjekter, milepæler og fysiske objekter samtidig.
// =============================================================

MATCH (pf:Portefølje {id: 'PF-001'})-[:INNEHOLDER]->(p:Prosjekt)

// Risikoer som direkte påvirker prosjektet
OPTIONAL MATCH (p)<-[:PÅVIRKER]-(r1:Risiko)

// Risikoer som påvirker milepæler i prosjektet
OPTIONAL MATCH (p)-[:HAR_MILEPÆL]->(mp:Milepæl)<-[:PÅVIRKER]-(r2:Risiko)

// Risikoer som påvirker komponenter prosjektet berører
OPTIONAL MATCH (p)-[:BERØRER]->(objekt)<-[:PÅVIRKER]-(r3:Risiko)

WITH pf, p, collect(DISTINCT r1) + collect(DISTINCT r2) + collect(DISTINCT r3) AS alleRisikoer
UNWIND alleRisikoer AS risiko

OPTIONAL MATCH (risiko)<-[:REDUSERER]-(tiltak:Tiltak)
OPTIONAL MATCH (risiko)-[:PÅVIRKER]->(rammet)

RETURN
  pf.navn AS portefølje,
  p.navn AS prosjekt,
  risiko.navn AS risiko,
  risiko.risikoNivå AS nivå,
  risiko.sannsynlighet AS sannsynlighet,
  risiko.konsekvens AS konsekvens,
  collect(DISTINCT labels(rammet)[0] + ': ' + rammet.navn) AS rammedeObjekter,
  collect(DISTINCT tiltak.navn) AS risikoreduserendeTiltak
ORDER BY
  CASE risiko.risikoNivå
    WHEN 'Høy' THEN 1
    WHEN 'Middels' THEN 2
    WHEN 'Lav' THEN 3
    ELSE 4
  END;

// --- Visuell variant: risikograf ---
//
// MATCH (pf:Portefølje {id: 'PF-001'})-[:INNEHOLDER]->(p:Prosjekt)
// MATCH path = (p)-[:HAR_MILEPÆL|BERØRER*0..2]-(objekt)<-[:PÅVIRKER]-(r:Risiko)
// OPTIONAL MATCH tiltakPath = (r)<-[:REDUSERER]-(:Tiltak)
// RETURN path, tiltakPath;
