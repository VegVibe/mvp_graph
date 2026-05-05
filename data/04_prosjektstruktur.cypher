// =============================================================
// 04_prosjektstruktur.cypher
// Bryter ned hvert prosjekt i delprosjekter, arbeidspakker,
// leveranser og milepæler. Skaper sporbarhet og avhengigheter.
// =============================================================

// =============================================================
// PROSJEKT 1: Oppgradering Trolla stasjon (PRJ-001)
// =============================================================

// --- Delprosjekter ---
CREATE (dp1a:Delprosjekt {
  id: 'DP-001-A',
  navn: 'Trolla — Primærutstyr',
  startDato: date('2025-03-01'),
  planlagtSluttDato: date('2027-06-30'),
  status: 'Gjennomføring'
});

CREATE (dp1b:Delprosjekt {
  id: 'DP-001-B',
  navn: 'Trolla — Kontrollanlegg',
  startDato: date('2025-09-01'),
  planlagtSluttDato: date('2027-09-30'),
  status: 'Planlegging'
});

CREATE (dp1c:Delprosjekt {
  id: 'DP-001-C',
  navn: 'Trolla — Bygg og infrastruktur',
  startDato: date('2025-03-01'),
  planlagtSluttDato: date('2026-12-31'),
  status: 'Gjennomføring'
});

// --- Arbeidspakker for delprosjekt 1A ---
CREATE (ap1:Arbeidspakke {
  id: 'AP-001-A-01',
  navn: 'Demontering eksisterende T1 og Q1',
  status: 'Ikke startet',
  estimertVarighetUker: 8
});

CREATE (ap2:Arbeidspakke {
  id: 'AP-001-A-02',
  navn: 'Installasjon ny transformator T1',
  status: 'Ikke startet',
  estimertVarighetUker: 16
});

CREATE (ap3:Arbeidspakke {
  id: 'AP-001-A-03',
  navn: 'Installasjon ny effektbryter Q1',
  status: 'Ikke startet',
  estimertVarighetUker: 6
});

// --- Arbeidspakker for delprosjekt 1B ---
CREATE (ap4:Arbeidspakke {
  id: 'AP-001-B-01',
  navn: 'Modernisering kontrollanlegg',
  status: 'Planlegging',
  estimertVarighetUker: 24
});

// --- Arbeidspakker for delprosjekt 1C ---
CREATE (ap5:Arbeidspakke {
  id: 'AP-001-C-01',
  navn: 'Oppgradering bygningsmasse',
  status: 'Gjennomføring',
  estimertVarighetUker: 32
});

// --- Leveranser ---
CREATE (lv1:Leveranse {
  id: 'LV-001-01',
  navn: 'Ny T1 idriftsatt',
  type: 'Driftssatt anlegg',
  planlagtDato: date('2026-09-30'),
  status: 'Ikke startet'
});

CREATE (lv2:Leveranse {
  id: 'LV-001-02',
  navn: 'Modernisert kontrollanlegg overlevert',
  type: 'Driftssatt anlegg',
  planlagtDato: date('2027-09-30'),
  status: 'Ikke startet'
});

CREATE (lv3:Leveranse {
  id: 'LV-001-03',
  navn: 'FDV-dokumentasjon Trolla',
  type: 'Dokumentasjon',
  planlagtDato: date('2027-12-15'),
  status: 'Ikke startet'
});

// --- Milepæler ---
CREATE (mp1:Milepæl {
  id: 'MP-001-01',
  navn: 'BP3 — Beslutningspunkt gjennomføring',
  planlagtDato: date('2025-02-15'),
  status: 'Passert',
  type: 'Beslutningspunkt'
});

CREATE (mp2:Milepæl {
  id: 'MP-001-02',
  navn: 'Idriftsettelse T1',
  planlagtDato: date('2026-09-30'),
  status: 'Planlagt',
  type: 'Driftssettelse',
  kritisk: true
});

CREATE (mp3:Milepæl {
  id: 'MP-001-03',
  navn: 'Stasjon klar for 420 kV drift',
  planlagtDato: date('2027-12-31'),
  status: 'Planlagt',
  type: 'Sluttleveranse',
  kritisk: true
});

// --- Relasjoner for prosjekt 1 ---

MATCH (p:Prosjekt {id: 'PRJ-001'}), (dp:Delprosjekt)
WHERE dp.id IN ['DP-001-A', 'DP-001-B', 'DP-001-C']
CREATE (p)-[:INNEHOLDER]->(dp);

MATCH (dp:Delprosjekt {id: 'DP-001-A'}), (ap:Arbeidspakke)
WHERE ap.id IN ['AP-001-A-01', 'AP-001-A-02', 'AP-001-A-03']
CREATE (dp)-[:INNEHOLDER]->(ap);

MATCH (dp:Delprosjekt {id: 'DP-001-B'}), (ap:Arbeidspakke {id: 'AP-001-B-01'})
CREATE (dp)-[:INNEHOLDER]->(ap);

MATCH (dp:Delprosjekt {id: 'DP-001-C'}), (ap:Arbeidspakke {id: 'AP-001-C-01'})
CREATE (dp)-[:INNEHOLDER]->(ap);

// Arbeidspakke-avhengighet: kan ikke installere før demontering
MATCH (ap2:Arbeidspakke {id: 'AP-001-A-02'}), (ap1:Arbeidspakke {id: 'AP-001-A-01'})
CREATE (ap2)-[:ER_AVHENGIG_AV]->(ap1);

MATCH (ap3:Arbeidspakke {id: 'AP-001-A-03'}), (ap1:Arbeidspakke {id: 'AP-001-A-01'})
CREATE (ap3)-[:ER_AVHENGIG_AV]->(ap1);

// Arbeidspakker leverer leveranser
MATCH (ap:Arbeidspakke), (lv:Leveranse {id: 'LV-001-01'})
WHERE ap.id IN ['AP-001-A-01', 'AP-001-A-02', 'AP-001-A-03']
CREATE (ap)-[:BIDRAR_TIL]->(lv);

MATCH (ap:Arbeidspakke {id: 'AP-001-B-01'}), (lv:Leveranse {id: 'LV-001-02'})
CREATE (ap)-[:BIDRAR_TIL]->(lv);

// Prosjektet leverer leveransene
MATCH (p:Prosjekt {id: 'PRJ-001'}), (lv:Leveranse)
WHERE lv.id IN ['LV-001-01', 'LV-001-02', 'LV-001-03']
CREATE (p)-[:LEVERER]->(lv);

// Milepæler markerer leveranser
MATCH (mp:Milepæl {id: 'MP-001-02'}), (lv:Leveranse {id: 'LV-001-01'})
CREATE (mp)-[:MARKERER]->(lv);

MATCH (mp:Milepæl {id: 'MP-001-03'}), (lv:Leveranse {id: 'LV-001-02'})
CREATE (mp)-[:MARKERER]->(lv);

// Prosjekt har milepæler
MATCH (p:Prosjekt {id: 'PRJ-001'}), (mp:Milepæl)
WHERE mp.id IN ['MP-001-01', 'MP-001-02', 'MP-001-03']
CREATE (p)-[:HAR_MILEPÆL]->(mp);

// =============================================================
// PROSJEKT 2: Ny ledning Trolla–Klæbu (PRJ-002)
// =============================================================

CREATE (dp2a:Delprosjekt {
  id: 'DP-002-A',
  navn: 'Konsesjon og grunnerverv',
  startDato: date('2026-01-01'),
  planlagtSluttDato: date('2026-12-31'),
  status: 'Planlegging'
});

CREATE (dp2b:Delprosjekt {
  id: 'DP-002-B',
  navn: 'Bygging av ledning',
  startDato: date('2027-01-01'),
  planlagtSluttDato: date('2028-03-31'),
  status: 'Ikke startet'
});

CREATE (dp2c:Delprosjekt {
  id: 'DP-002-C',
  navn: 'Tilkobling og idriftsettelse',
  startDato: date('2028-04-01'),
  planlagtSluttDato: date('2028-06-30'),
  status: 'Ikke startet'
});

CREATE (ap6:Arbeidspakke {
  id: 'AP-002-A-01',
  navn: 'Konsesjonssøknad NVE',
  status: 'Pågående',
  estimertVarighetUker: 20
});

CREATE (ap7:Arbeidspakke {
  id: 'AP-002-B-01',
  navn: 'Mast- og fundamentarbeid',
  status: 'Ikke startet',
  estimertVarighetUker: 40
});

CREATE (ap8:Arbeidspakke {
  id: 'AP-002-B-02',
  navn: 'Linestrenging',
  status: 'Ikke startet',
  estimertVarighetUker: 16
});

CREATE (ap9:Arbeidspakke {
  id: 'AP-002-C-01',
  navn: 'Tilkobling og spenningssetting',
  status: 'Ikke startet',
  estimertVarighetUker: 8
});

CREATE (lv4:Leveranse {
  id: 'LV-002-01',
  navn: 'Konsesjon innvilget',
  type: 'Myndighetsgodkjenning',
  planlagtDato: date('2026-12-31'),
  status: 'Ikke startet'
});

CREATE (lv5:Leveranse {
  id: 'LV-002-02',
  navn: 'Ledning idriftsatt',
  type: 'Driftssatt anlegg',
  planlagtDato: date('2028-06-30'),
  status: 'Ikke startet'
});

CREATE (mp4:Milepæl {
  id: 'MP-002-01',
  navn: 'Konsesjonsvedtak fra NVE',
  planlagtDato: date('2026-12-31'),
  status: 'Planlagt',
  type: 'Myndighetsgodkjenning',
  kritisk: true
});

CREATE (mp5:Milepæl {
  id: 'MP-002-02',
  navn: 'Idriftsettelse ledning',
  planlagtDato: date('2028-06-30'),
  status: 'Planlagt',
  type: 'Driftssettelse',
  kritisk: true
});

// --- Relasjoner prosjekt 2 ---

MATCH (p:Prosjekt {id: 'PRJ-002'}), (dp:Delprosjekt)
WHERE dp.id IN ['DP-002-A', 'DP-002-B', 'DP-002-C']
CREATE (p)-[:INNEHOLDER]->(dp);

MATCH (dp:Delprosjekt {id: 'DP-002-A'}), (ap:Arbeidspakke {id: 'AP-002-A-01'})
CREATE (dp)-[:INNEHOLDER]->(ap);

MATCH (dp:Delprosjekt {id: 'DP-002-B'}), (ap:Arbeidspakke)
WHERE ap.id IN ['AP-002-B-01', 'AP-002-B-02']
CREATE (dp)-[:INNEHOLDER]->(ap);

MATCH (dp:Delprosjekt {id: 'DP-002-C'}), (ap:Arbeidspakke {id: 'AP-002-C-01'})
CREATE (dp)-[:INNEHOLDER]->(ap);

// Avhengighetskjede innen prosjekt 2
MATCH (apB1:Arbeidspakke {id: 'AP-002-B-01'}), (apA:Arbeidspakke {id: 'AP-002-A-01'})
CREATE (apB1)-[:ER_AVHENGIG_AV]->(apA);

MATCH (apB2:Arbeidspakke {id: 'AP-002-B-02'}), (apB1:Arbeidspakke {id: 'AP-002-B-01'})
CREATE (apB2)-[:ER_AVHENGIG_AV]->(apB1);

MATCH (apC:Arbeidspakke {id: 'AP-002-C-01'}), (apB2:Arbeidspakke {id: 'AP-002-B-02'})
CREATE (apC)-[:ER_AVHENGIG_AV]->(apB2);

MATCH (ap:Arbeidspakke {id: 'AP-002-A-01'}), (lv:Leveranse {id: 'LV-002-01'})
CREATE (ap)-[:BIDRAR_TIL]->(lv);

MATCH (ap:Arbeidspakke), (lv:Leveranse {id: 'LV-002-02'})
WHERE ap.id IN ['AP-002-B-01', 'AP-002-B-02', 'AP-002-C-01']
CREATE (ap)-[:BIDRAR_TIL]->(lv);

MATCH (p:Prosjekt {id: 'PRJ-002'}), (lv:Leveranse)
WHERE lv.id IN ['LV-002-01', 'LV-002-02']
CREATE (p)-[:LEVERER]->(lv);

MATCH (mp:Milepæl {id: 'MP-002-01'}), (lv:Leveranse {id: 'LV-002-01'})
CREATE (mp)-[:MARKERER]->(lv);

MATCH (mp:Milepæl {id: 'MP-002-02'}), (lv:Leveranse {id: 'LV-002-02'})
CREATE (mp)-[:MARKERER]->(lv);

MATCH (p:Prosjekt {id: 'PRJ-002'}), (mp:Milepæl)
WHERE mp.id IN ['MP-002-01', 'MP-002-02']
CREATE (p)-[:HAR_MILEPÆL]->(mp);

// --- Tverrprosjekt-avhengighet: PRJ-002 må ha 420 kV i Trolla ---
// Idriftsettelse av ledning er avhengig av at Trolla er klar for 420 kV
MATCH (mp5:Milepæl {id: 'MP-002-02'}), (mp3:Milepæl {id: 'MP-001-03'})
CREATE (mp5)-[:ER_AVHENGIG_AV {type: 'Teknisk forutsetning'}]->(mp3);

RETURN "Prosjektstruktur opprettet" AS status;
