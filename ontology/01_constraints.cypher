// =============================================================
// 01_constraints.cypher
// Unike nøkler og indekser for kjerneontologien.
// Kjøres først, før noen data lastes inn.
// =============================================================

// --- Strategi og portefølje ---
CREATE CONSTRAINT strategiskMaal_id IF NOT EXISTS
  FOR (n:StrategiskMål) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT portefolje_id IF NOT EXISTS
  FOR (n:Portefølje) REQUIRE n.id IS UNIQUE;

// --- Prosjektstruktur ---
CREATE CONSTRAINT prosjekt_id IF NOT EXISTS
  FOR (n:Prosjekt) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT delprosjekt_id IF NOT EXISTS
  FOR (n:Delprosjekt) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT arbeidspakke_id IF NOT EXISTS
  FOR (n:Arbeidspakke) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT leveranse_id IF NOT EXISTS
  FOR (n:Leveranse) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT milepael_id IF NOT EXISTS
  FOR (n:Milepæl) REQUIRE n.id IS UNIQUE;

// --- Fysisk anlegg ---
CREATE CONSTRAINT stasjon_id IF NOT EXISTS
  FOR (n:Stasjon) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT ledning_id IF NOT EXISTS
  FOR (n:Ledning) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT felt_id IF NOT EXISTS
  FOR (n:Felt) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT komponent_id IF NOT EXISTS
  FOR (n:Komponent) REQUIRE n.id IS UNIQUE;

// --- RDS ---
CREATE CONSTRAINT rds_referanse IF NOT EXISTS
  FOR (n:RDSReferanse) REQUIRE n.referanse IS UNIQUE;

// --- Tverrgående ---
CREATE CONSTRAINT krav_id IF NOT EXISTS
  FOR (n:Krav) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT dokument_id IF NOT EXISTS
  FOR (n:Dokument) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT risiko_id IF NOT EXISTS
  FOR (n:Risiko) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT endringsinitiativ_id IF NOT EXISTS
  FOR (n:Endringsinitiativ) REQUIRE n.id IS UNIQUE;

// --- Organisasjon ---
CREATE CONSTRAINT enhet_id IF NOT EXISTS
  FOR (n:Organisasjonsenhet) REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT rolle_id IF NOT EXISTS
  FOR (n:Rolle) REQUIRE n.id IS UNIQUE;

// --- Indekser for vanlige søk ---
CREATE INDEX prosjekt_navn IF NOT EXISTS FOR (n:Prosjekt) ON (n.navn);
CREATE INDEX stasjon_navn IF NOT EXISTS FOR (n:Stasjon) ON (n.navn);
CREATE INDEX komponent_type IF NOT EXISTS FOR (n:Komponent) ON (n.type);

RETURN "Constraints og indekser opprettet" AS status;
