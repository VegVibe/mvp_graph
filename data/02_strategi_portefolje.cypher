// =============================================================
// 02_strategi_portefolje.cypher
// Tenkt scenario: Kapasitetsøkning i Midt-Norge.
// Strategisk mål → Portefølje → Prosjekter (på toppnivå).
// =============================================================

// --- Strategiske mål ---
CREATE (sm1:StrategiskMål {
  id: 'SM-001',
  navn: 'Øke overføringskapasitet i Midt-Norge med 20% innen 2030',
  beskrivelse: 'Strategisk satsning for å støtte ny industri og elektrifisering i regionen.',
  tidshorisont: '2030',
  status: 'Aktiv'
});

// --- Styringsparametere knyttet til målet ---
CREATE (sp1:Styringsparameter {
  id: 'SP-001',
  navn: 'Overføringskapasitet Midt-Norge',
  enhet: 'MW',
  målverdi: 4800,
  baseline: 4000,
  baselineÅr: 2024
});

// --- Portefølje ---
CREATE (pf1:Portefølje {
  id: 'PF-001',
  navn: 'Kapasitetsøkning Midt-Norge',
  beskrivelse: 'Portefølje av prosjekter som samlet skal øke nettkapasitet i regionen.',
  budsjett: 2400000000,
  valuta: 'NOK',
  status: 'Pågående'
});

// --- Prosjekter (toppnivå, detaljer kommer i 04) ---
CREATE (p1:Prosjekt {
  id: 'PRJ-001',
  navn: 'Oppgradering Trolla stasjon',
  beskrivelse: 'Oppgradere Trolla stasjon til 420 kV og bytte aldrende komponenter.',
  startDato: date('2025-03-01'),
  planlagtSluttDato: date('2027-12-31'),
  budsjett: 850000000,
  status: 'Gjennomføring',
  fase: 'Detaljprosjektering'
});

CREATE (p2:Prosjekt {
  id: 'PRJ-002',
  navn: 'Ny ledning Trolla–Klæbu',
  beskrivelse: 'Bygge ny 420 kV ledning mellom Trolla og Klæbu stasjon.',
  startDato: date('2026-01-01'),
  planlagtSluttDato: date('2028-06-30'),
  budsjett: 1450000000,
  status: 'Planlegging',
  fase: 'Konsesjonssøknad'
});

// --- Beslutning som etablerte porteføljen ---
CREATE (b1:Beslutning {
  id: 'BSL-001',
  navn: 'Etablering av portefølje Kapasitetsøkning Midt-Norge',
  besluttetDato: date('2024-09-15'),
  forum: 'Konsernledelse',
  beslutningstype: 'Porteføljeetablering'
});

// --- Relasjoner ---

// Strategi → portefølje
MATCH (pf:Portefølje {id: 'PF-001'}), (sm:StrategiskMål {id: 'SM-001'})
CREATE (pf)-[:STØTTER]->(sm);

// Mål måles via styringsparameter
MATCH (sm:StrategiskMål {id: 'SM-001'}), (sp:Styringsparameter {id: 'SP-001'})
CREATE (sm)-[:MÅLES_VED]->(sp);

// Portefølje inneholder prosjekter
MATCH (pf:Portefølje {id: 'PF-001'}), (p:Prosjekt)
WHERE p.id IN ['PRJ-001', 'PRJ-002']
CREATE (pf)-[:INNEHOLDER]->(p);

// Prosjektavhengighet: ledningsprosjektet er avhengig av stasjonsoppgraderingen
MATCH (p2:Prosjekt {id: 'PRJ-002'}), (p1:Prosjekt {id: 'PRJ-001'})
CREATE (p2)-[:ER_AVHENGIG_AV {
  type: 'Teknisk',
  beskrivelse: 'Ledningen kan ikke settes i drift før Trolla-stasjonen er oppgradert til 420 kV.',
  kritisk: true
}]->(p1);

// Beslutning etablerte porteføljen
MATCH (b:Beslutning {id: 'BSL-001'}), (pf:Portefølje {id: 'PF-001'})
CREATE (b)-[:ETABLERTE]->(pf);

RETURN "Strategi, portefølje og prosjekter opprettet" AS status;
