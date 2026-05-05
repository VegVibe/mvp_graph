// =============================================================
// 06_validering.cypher
// BONUS: Modellvalidering
//
// Disse spørringene skal alle returnere TOMME resultater hvis
// modellen er konsistent. Hvis noen returnerer noder, har vi
// brutt et modelleringsprinsipp.
//
// Kjør disse rutinemessig etter endringer.
// =============================================================

// 1. Alle komponenter skal ha en RDS-referanse
MATCH (k:Komponent) WHERE NOT (k)-[:HAR_RDS]->()
RETURN 'Mangler RDS' AS problem, k.id AS id, k.navn AS navn;

// 2. Alle prosjekter skal ha en eier
MATCH (p:Prosjekt) WHERE NOT (p)-[:EIES_AV]->()
RETURN 'Mangler prosjekteier' AS problem, p.id AS id, p.navn AS navn;

// 3. Alle stasjoner skal ha en eier og driftsansvarlig
MATCH (s:Stasjon) WHERE NOT (s)-[:EIES_AV]->() OR NOT (s)-[:DRIFTES_AV]->()
RETURN 'Mangler eier eller driftsansvarlig' AS problem, s.id AS id, s.navn AS navn;

// 4. Sporbarhet: alle prosjekter skal kunne spores til strategisk mål
MATCH (p:Prosjekt)
WHERE NOT EXISTS {
  MATCH (p)<-[:INNEHOLDER]-(:Portefølje)-[:STØTTER]->(:StrategiskMål)
}
RETURN 'Brutt sporbarhet til strategisk mål' AS problem, p.id AS id, p.navn AS navn;

// 5. Alle leveranser skal være levert av et prosjekt
MATCH (lv:Leveranse) WHERE NOT (lv)<-[:LEVERER]-(:Prosjekt)
RETURN 'Leveranse uten prosjekt' AS problem, lv.id AS id, lv.navn AS navn;

// 6. Alle krav skal stilles til minst ett objekt
MATCH (krav:Krav) WHERE NOT ()-[:OPPFYLLER]->(krav)
RETURN 'Krav uten objekter' AS problem, krav.id AS id, krav.navn AS navn;

// 7. Sjekk for dupliserte RDS-referanser (skal være håndtert av constraint, men dobbeltsjekk)
MATCH (r:RDSReferanse)
WITH r.referanse AS ref, collect(r) AS refs
WHERE size(refs) > 1
RETURN 'Duplisert RDS' AS problem, ref;

// --- Statistikk: oversikt over modellen ---

MATCH (n)
RETURN labels(n)[0] AS type, count(*) AS antall
ORDER BY antall DESC;

// MATCH ()-[r]->()
// RETURN type(r) AS relasjon, count(*) AS antall
// ORDER BY antall DESC;
