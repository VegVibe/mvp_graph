// =============================================================
// 05_tverrgaende.cypher
// Krav, dokumenter, organisasjon, roller, risiko, endring.
// Dette laget binder modellen sammen og gir mest verdi.
// =============================================================

// --- Organisasjonsenheter ---
CREATE (oeKonsern:Organisasjonsenhet {
  id: 'ORG-001',
  navn: 'Statnett SF',
  type: 'Selskap',
  nivå: 1
});

CREATE (oeNettutvikling:Organisasjonsenhet {
  id: 'ORG-002',
  navn: 'Nettutvikling',
  type: 'Forretningsområde',
  nivå: 2
});

CREATE (oeDrift:Organisasjonsenhet {
  id: 'ORG-003',
  navn: 'Drift og marked',
  type: 'Forretningsområde',
  nivå: 2
});

CREATE (oeProsjekt:Organisasjonsenhet {
  id: 'ORG-004',
  navn: 'Prosjekt Midt-Norge',
  type: 'Avdeling',
  nivå: 3
});

CREATE (oeStasjonsdrift:Organisasjonsenhet {
  id: 'ORG-005',
  navn: 'Stasjonsdrift Midt-Norge',
  type: 'Seksjon',
  nivå: 3
});

// Hierarki
MATCH (mor:Organisasjonsenhet {id: 'ORG-001'}), (barn:Organisasjonsenhet)
WHERE barn.id IN ['ORG-002', 'ORG-003']
CREATE (mor)-[:INNEHOLDER]->(barn);

MATCH (mor:Organisasjonsenhet {id: 'ORG-002'}), (barn:Organisasjonsenhet {id: 'ORG-004'})
CREATE (mor)-[:INNEHOLDER]->(barn);

MATCH (mor:Organisasjonsenhet {id: 'ORG-003'}), (barn:Organisasjonsenhet {id: 'ORG-005'})
CREATE (mor)-[:INNEHOLDER]->(barn);

// --- Roller ---
CREATE (rolle1:Rolle {
  id: 'ROLLE-001',
  navn: 'Porteføljeeier',
  rolletype: 'Styringsrolle',
  innehaver: 'Direktør Nettutvikling'
});

CREATE (rolle2:Rolle {
  id: 'ROLLE-002',
  navn: 'Prosjekteier PRJ-001',
  rolletype: 'Prosjekteier',
  innehaver: 'Avdelingsleder Prosjekt Midt-Norge'
});

CREATE (rolle3:Rolle {
  id: 'ROLLE-003',
  navn: 'Prosjekteier PRJ-002',
  rolletype: 'Prosjekteier',
  innehaver: 'Avdelingsleder Prosjekt Midt-Norge'
});

CREATE (rolle4:Rolle {
  id: 'ROLLE-004',
  navn: 'Driftsansvarlig Trolla',
  rolletype: 'Driftsansvarlig',
  innehaver: 'Stasjonsmester Trolla'
});

CREATE (rolle5:Rolle {
  id: 'ROLLE-005',
  navn: 'Anleggseier Trolla',
  rolletype: 'Anleggseier',
  innehaver: 'Seksjonsleder Stasjonsdrift Midt-Norge'
});

CREATE (rolle6:Rolle {
  id: 'ROLLE-006',
  navn: 'Dokumenteier — Tegningsarkiv Trolla',
  rolletype: 'Dokumenteier',
  innehaver: 'Dokumentkontroller Nettutvikling'
});

// Roller hører hjemme i en enhet
MATCH (r:Rolle {id: 'ROLLE-001'}), (e:Organisasjonsenhet {id: 'ORG-002'})
CREATE (r)-[:TILHØRER]->(e);

MATCH (r:Rolle), (e:Organisasjonsenhet {id: 'ORG-004'})
WHERE r.id IN ['ROLLE-002', 'ROLLE-003']
CREATE (r)-[:TILHØRER]->(e);

MATCH (r:Rolle), (e:Organisasjonsenhet {id: 'ORG-005'})
WHERE r.id IN ['ROLLE-004', 'ROLLE-005']
CREATE (r)-[:TILHØRER]->(e);

MATCH (r:Rolle {id: 'ROLLE-006'}), (e:Organisasjonsenhet {id: 'ORG-002'})
CREATE (r)-[:TILHØRER]->(e);

// Eierskap
MATCH (pf:Portefølje {id: 'PF-001'}), (r:Rolle {id: 'ROLLE-001'})
CREATE (pf)-[:EIES_AV]->(r);

MATCH (p:Prosjekt {id: 'PRJ-001'}), (r:Rolle {id: 'ROLLE-002'})
CREATE (p)-[:EIES_AV]->(r);

MATCH (p:Prosjekt {id: 'PRJ-002'}), (r:Rolle {id: 'ROLLE-003'})
CREATE (p)-[:EIES_AV]->(r);

MATCH (s:Stasjon {id: 'STA-TROL'}), (r:Rolle {id: 'ROLLE-004'})
CREATE (s)-[:DRIFTES_AV]->(r);

MATCH (s:Stasjon {id: 'STA-TROL'}), (r:Rolle {id: 'ROLLE-005'})
CREATE (s)-[:EIES_AV]->(r);

// --- Krav ---
CREATE (krav1:Krav {
  id: 'KRAV-001',
  navn: 'Kapasitet 420 kV i Midt-Norge',
  beskrivelse: 'Stasjonen skal være dimensjonert for 420 kV drift med minimum 1500 MVA overføringskapasitet.',
  type: 'Strategisk',
  kritikalitet: 'Høy',
  kilde: 'Statnetts nettutviklingsplan 2024'
});

CREATE (krav2:Krav {
  id: 'KRAV-002',
  navn: 'Forskrift om systemansvar (FoS)',
  beskrivelse: 'Stasjon og ledning skal oppfylle krav i Forskrift om systemansvar i kraftsystemet.',
  type: 'Regulatorisk',
  kritikalitet: 'Høy',
  kilde: 'NVE FOR-2002-05-07-448'
});

CREATE (krav3:Krav {
  id: 'KRAV-003',
  navn: 'IEC 61850 for kontrollanlegg',
  beskrivelse: 'Kontrollanlegg skal følge IEC 61850 for kommunikasjon og dataformater.',
  type: 'Teknisk',
  kritikalitet: 'Middels',
  kilde: 'Statnett teknisk spesifikasjon TS-CTRL-001'
});

CREATE (krav4:Krav {
  id: 'KRAV-004',
  navn: 'RDS-PP referansebetegnelser',
  beskrivelse: 'Alle anleggsobjekter skal merkes etter RDS-PP / IEC 81346 standardene.',
  type: 'Teknisk',
  kritikalitet: 'Middels',
  kilde: 'Statnett merkestandard MS-001'
});

// Krav stilles til objekter
MATCH (krav:Krav {id: 'KRAV-001'}), (sm:StrategiskMål {id: 'SM-001'})
CREATE (krav)-[:UTLEDET_FRA]->(sm);

MATCH (krav:Krav {id: 'KRAV-001'}), (s:Stasjon {id: 'STA-TROL'})
CREATE (s)-[:OPPFYLLER {verifikasjonsStatus: 'Under arbeid', verifisertAv: null}]->(krav);

MATCH (krav:Krav {id: 'KRAV-002'}), (s:Stasjon)
WHERE s.id IN ['STA-TROL', 'STA-KLAE']
CREATE (s)-[:OPPFYLLER {verifikasjonsStatus: 'Verifisert', verifisertAv: 'Driftsleder'}]->(krav);

MATCH (krav:Krav {id: 'KRAV-002'}), (l:Ledning {id: 'LED-TROL-KLAE'})
CREATE (l)-[:OPPFYLLER {verifikasjonsStatus: 'Ikke startet', verifisertAv: null}]->(krav);

MATCH (krav:Krav {id: 'KRAV-003'}), (ka:Kontrollanlegg {id: 'KA-TROL'})
CREATE (ka)-[:OPPFYLLER {verifikasjonsStatus: 'Planlagt', verifisertAv: null}]->(krav);

MATCH (krav:Krav {id: 'KRAV-004'}), (k:Komponent)
CREATE (k)-[:OPPFYLLER {verifikasjonsStatus: 'Verifisert', verifisertAv: 'Anleggsregister'}]->(krav);

// Prosjekter realiserer krav
MATCH (p:Prosjekt {id: 'PRJ-001'}), (krav:Krav {id: 'KRAV-001'})
CREATE (p)-[:REALISERER]->(krav);

MATCH (p:Prosjekt {id: 'PRJ-001'}), (krav:Krav {id: 'KRAV-003'})
CREATE (p)-[:REALISERER]->(krav);

// --- Dokumenter ---
CREATE (dok1:Dokument {
  id: 'DOK-001',
  navn: 'Kravspesifikasjon — Oppgradering Trolla',
  type: 'Kravdokument',
  versjon: '2.1',
  status: 'Godkjent',
  godkjentDato: date('2024-12-10'),
  format: 'PDF'
});

CREATE (dok2:Dokument {
  id: 'DOK-002',
  navn: 'Enlinjeskjema Trolla — fremtidig',
  type: 'Tegning',
  versjon: '1.3',
  status: 'Under revisjon',
  format: 'DWG'
});

CREATE (dok3:Dokument {
  id: 'DOK-003',
  navn: 'Konsesjonssøknad ledning Trolla–Klæbu',
  type: 'Konsesjonssøknad',
  versjon: '1.0',
  status: 'Innsendt',
  innsendtDato: date('2026-04-15'),
  format: 'PDF'
});

CREATE (dok4:Dokument {
  id: 'DOK-004',
  navn: 'Risikoanalyse PRJ-001',
  type: 'Risikoanalyse',
  versjon: '1.2',
  status: 'Godkjent',
  godkjentDato: date('2025-01-20'),
  format: 'PDF'
});

// Dokumenter beskriver objekter
MATCH (dok:Dokument {id: 'DOK-001'}), (p:Prosjekt {id: 'PRJ-001'})
CREATE (dok)-[:BESKRIVER]->(p);

MATCH (dok:Dokument {id: 'DOK-001'}), (krav:Krav)
WHERE krav.id IN ['KRAV-001', 'KRAV-003']
CREATE (dok)-[:DEFINERER]->(krav);

MATCH (dok:Dokument {id: 'DOK-002'}), (s:Stasjon {id: 'STA-TROL'})
CREATE (dok)-[:BESKRIVER]->(s);

MATCH (dok:Dokument {id: 'DOK-003'}), (p:Prosjekt {id: 'PRJ-002'})
CREATE (dok)-[:BESKRIVER]->(p);

MATCH (dok:Dokument {id: 'DOK-004'}), (p:Prosjekt {id: 'PRJ-001'})
CREATE (dok)-[:BESKRIVER]->(p);

// Dokumenter har eier
MATCH (dok:Dokument), (r:Rolle {id: 'ROLLE-006'})
CREATE (dok)-[:EIES_AV]->(r);

// --- Risiko ---
CREATE (r1:Risiko {
  id: 'RISK-001',
  navn: 'Forsinket konsesjon fra NVE',
  beskrivelse: 'Risiko for at NVE-konsesjon for ny ledning forsinkes på grunn av høringsprosess eller miljøhensyn.',
  sannsynlighet: 'Middels',
  konsekvens: 'Stor',
  risikoNivå: 'Høy',
  status: 'Aktiv'
});

CREATE (r2:Risiko {
  id: 'RISK-002',
  navn: 'Havari på T1 før utskifting',
  beskrivelse: 'Eksisterende transformator T1 er i redusert tilstand og kan svikte før planlagt utskifting i 2026.',
  sannsynlighet: 'Middels',
  konsekvens: 'Stor',
  risikoNivå: 'Høy',
  status: 'Aktiv'
});

// Risikoreduserende tiltak
CREATE (tiltak1:Tiltak {
  id: 'TIL-001',
  navn: 'Tidlig dialog med NVE',
  beskrivelse: 'Forhåndsmøter med NVE for å avklare krav og prosess.',
  type: 'Risikoreduserende',
  status: 'Pågående'
});

CREATE (tiltak2:Tiltak {
  id: 'TIL-002',
  navn: 'Forsterket tilstandsovervåking T1',
  beskrivelse: 'Online DGA og temperaturovervåking på T1 frem til utskifting.',
  type: 'Risikoreduserende',
  status: 'Implementert'
});

// Risikoer påvirker objekter
MATCH (r:Risiko {id: 'RISK-001'}), (p:Prosjekt {id: 'PRJ-002'})
CREATE (r)-[:PÅVIRKER]->(p);

MATCH (r:Risiko {id: 'RISK-001'}), (mp:Milepæl {id: 'MP-002-01'})
CREATE (r)-[:PÅVIRKER]->(mp);

MATCH (r:Risiko {id: 'RISK-002'}), (k:Komponent {id: 'KOMP-TROL-T1'})
CREATE (r)-[:PÅVIRKER]->(k);

MATCH (r:Risiko {id: 'RISK-002'}), (s:Stasjon {id: 'STA-TROL'})
CREATE (r)-[:PÅVIRKER]->(s);

MATCH (r:Risiko {id: 'RISK-002'}), (p:Prosjekt {id: 'PRJ-001'})
CREATE (r)-[:PÅVIRKER]->(p);

// Tiltak adresserer risiko
MATCH (t:Tiltak {id: 'TIL-001'}), (r:Risiko {id: 'RISK-001'})
CREATE (t)-[:REDUSERER]->(r);

MATCH (t:Tiltak {id: 'TIL-002'}), (r:Risiko {id: 'RISK-002'})
CREATE (t)-[:REDUSERER]->(r);

// --- Endringsinitiativ ---
CREATE (e1:Endringsinitiativ {
  id: 'END-001',
  navn: 'Innføring av RDS-PP merkestandard',
  beskrivelse: 'Tverrgående initiativ for å innføre RDS-PP merking på alle nye og oppgraderte anlegg.',
  status: 'Pågående',
  startDato: date('2024-01-01'),
  planlagtSluttDato: date('2027-12-31')
});

MATCH (e:Endringsinitiativ {id: 'END-001'}), (krav:Krav {id: 'KRAV-004'})
CREATE (e)-[:DEFINERER]->(krav);

MATCH (e:Endringsinitiativ {id: 'END-001'}), (p:Prosjekt)
WHERE p.id IN ['PRJ-001', 'PRJ-002']
CREATE (e)-[:BERØRER]->(p);

RETURN "Tverrgående lag (krav, dokumenter, roller, risiko, endring) opprettet" AS status;
