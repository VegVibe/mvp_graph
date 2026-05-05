// =============================================================
// 01_sporbarhet_opp.cypher
// SPØRRING 1: Sporbarhet OPPOVER
//
// Spørsmål: Hvilket strategisk mål bidrar effektbryter Q1
// (i Trolla stasjon) til? Vis hele kjeden.
//
// Verdi: Demonstrerer at en hvilken som helst fysisk
// komponent kan spores helt opp til strategisk nivå.
// =============================================================

MATCH path = (k:Komponent {id: 'KOMP-TROL-Q1'})
  <-[:BERØRER]-(prosjekt:Prosjekt)
  <-[:INNEHOLDER]-(portefølje:Portefølje)
  -[:STØTTER]->(mål:StrategiskMål)
RETURN path;

// --- Variant: tabellform med hele kjeden ---
//
// MATCH (k:Komponent {id: 'KOMP-TROL-Q1'})<-[:BERØRER]-(p:Prosjekt)
// MATCH (p)<-[:INNEHOLDER]-(pf:Portefølje)-[:STØTTER]->(sm:StrategiskMål)
// OPTIONAL MATCH (k)-[:HAR_RDS]->(rds:RDSReferanse)
// OPTIONAL MATCH (k)<-[:INNEHOLDER]-(felt:Felt)<-[:INNEHOLDER]-(stasjon:Stasjon)
// RETURN
//   k.navn AS komponent,
//   rds.referanse AS rdsReferanse,
//   stasjon.navn AS stasjon,
//   felt.navn AS felt,
//   p.navn AS prosjekt,
//   pf.navn AS portefølje,
//   sm.navn AS strategiskMål;
