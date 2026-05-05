// =============================================================
// 04_eierskap.cypher
// SPØRRING 4: Hvem er ansvarlige for alt knyttet til
// Trolla stasjon?
//
// Verdi: Demonstrerer hvordan grafen kan svare på et spørsmål
// som i dag krever sammenstilling fra HR-system, anleggsregister,
// dokumentasjonssystem og prosjektstyringsverktøy.
// =============================================================

MATCH (s:Stasjon {id: 'STA-TROL'})

// Direkte eierskap til stasjonen
OPTIONAL MATCH (s)-[:EIES_AV]->(anleggseier:Rolle)
OPTIONAL MATCH (s)-[:DRIFTES_AV]->(driftsansvarlig:Rolle)

// Prosjekteiere for prosjekter som berører stasjonen
OPTIONAL MATCH (s)<-[:BERØRER]-(prosjekt:Prosjekt)-[:EIES_AV]->(prosjekteier:Rolle)

// Porteføljeeier for porteføljen som inneholder disse prosjektene
OPTIONAL MATCH (prosjekt)<-[:INNEHOLDER]-(pf:Portefølje)-[:EIES_AV]->(porteføljeeier:Rolle)

// Dokumenteiere for dokumenter som beskriver stasjonen
OPTIONAL MATCH (s)<-[:BESKRIVER]-(dok:Dokument)-[:EIES_AV]->(dokeier:Rolle)

RETURN
  s.navn AS stasjon,
  collect(DISTINCT {rolle: anleggseier.navn, person: anleggseier.innehaver}) AS anleggseiere,
  collect(DISTINCT {rolle: driftsansvarlig.navn, person: driftsansvarlig.innehaver}) AS driftsansvarlige,
  collect(DISTINCT {rolle: prosjekteier.navn, person: prosjekteier.innehaver, prosjekt: prosjekt.navn}) AS prosjekteiere,
  collect(DISTINCT {rolle: porteføljeeier.navn, person: porteføljeeier.innehaver, portefølje: pf.navn}) AS porteføljeeiere,
  collect(DISTINCT {rolle: dokeier.navn, person: dokeier.innehaver, dokument: dok.navn}) AS dokumenteiere;

// --- Visuell variant ---
//
// MATCH (s:Stasjon {id: 'STA-TROL'})
// MATCH path = (s)-[:EIES_AV|DRIFTES_AV|BERØRER|INNEHOLDER|BESKRIVER*1..3]-(rolle:Rolle)
// RETURN path;
