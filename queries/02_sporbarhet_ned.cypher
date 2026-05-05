// =============================================================
// 02_sporbarhet_ned.cypher
// SPØRRING 2: Sporbarhet NEDOVER
//
// Spørsmål: Hvilke fysiske komponenter blir påvirket av det
// strategiske målet "Øke overføringskapasitet i Midt-Norge"?
//
// Verdi: Når ledelsen lurer på "hva får vi konkret igjen for
// denne strategien?", kan vi vise alle anleggsobjekter som
// faktisk blir endret.
// =============================================================

MATCH path = (sm:StrategiskMål {id: 'SM-001'})
  <-[:STØTTER]-(pf:Portefølje)
  -[:INNEHOLDER]->(p:Prosjekt)
  -[:BERØRER]->(objekt)
RETURN path;

// --- Variant: gruppert per prosjekt med antall berørte objekter ---
//
// MATCH (sm:StrategiskMål {id: 'SM-001'})<-[:STØTTER]-(pf:Portefølje)
//       -[:INNEHOLDER]->(p:Prosjekt)-[:BERØRER]->(objekt)
// RETURN
//   p.navn AS prosjekt,
//   labels(objekt)[0] AS objekttype,
//   count(objekt) AS antall,
//   collect(objekt.navn)[0..5] AS eksempler
// ORDER BY p.navn, objekttype;
