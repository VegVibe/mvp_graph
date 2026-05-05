// =============================================================
// 03_konsekvens.cypher
// SPØRRING 3: Konsekvensanalyse — hva påvirkes hvis prosjekt
// PRJ-001 (Oppgradering Trolla) forsinkes?
//
// Verdi: Et klassisk problem i porteføljestyring. Med en graf
// kan vi traversere prosjektavhengigheter og se ringvirkninger
// på milepæler, leveranser og andre prosjekter.
// =============================================================

// Alt som direkte eller indirekte er avhengig av PRJ-001
MATCH (start:Prosjekt {id: 'PRJ-001'})
OPTIONAL MATCH (start)<-[:ER_AVHENGIG_AV]-(avhProsjekt:Prosjekt)
OPTIONAL MATCH (start)-[:HAR_MILEPÆL]->(mp:Milepæl)<-[:ER_AVHENGIG_AV]-(avhMilepæl:Milepæl)<-[:HAR_MILEPÆL]-(annetProsjekt:Prosjekt)
OPTIONAL MATCH (start)-[:LEVERER]->(lv:Leveranse)
RETURN
  start AS forsinketProsjekt,
  collect(DISTINCT avhProsjekt) AS direkteAvhengigeProsjekter,
  collect(DISTINCT mp) AS påvirkedeMilepæler,
  collect(DISTINCT avhMilepæl) AS forskøvneMilepæler,
  collect(DISTINCT annetProsjekt) AS indirekteBerørteProsjekter,
  collect(DISTINCT lv) AS forsinkdeLeveranser;

// --- Visuell variant: hele konsekvensgrafen ---
//
// MATCH path = (start:Prosjekt {id: 'PRJ-001'})
//   <-[:ER_AVHENGIG_AV*1..3]-(berørt)
// RETURN path;
//
// MATCH path = (start:Prosjekt {id: 'PRJ-001'})-[:HAR_MILEPÆL]->(:Milepæl)
//   <-[:ER_AVHENGIG_AV*1..3]-(berørt)
// RETURN path;
