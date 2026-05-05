// =============================================================
// 03_anlegg.cypher
// Fysiske anlegg: to stasjoner, en ledning mellom dem,
// komponenter i Trolla med RDS-referanser.
//
// Forenkling i MVP: kun funksjonsaspekt (=) i RDS.
// Lokasjons- (+) og produktaspekter (-) legges til senere.
// =============================================================

// --- Geografiske områder ---
CREATE (no1:PrisOmråde {
  id: 'NO3',
  navn: 'NO3 Midt-Norge',
  type: 'Prisområde'
});

CREATE (kommTrond:Kommune {
  id: 'KOMM-5001',
  navn: 'Trondheim',
  fylkesnavn: 'Trøndelag'
});

CREATE (kommMelhus:Kommune {
  id: 'KOMM-5028',
  navn: 'Melhus',
  fylkesnavn: 'Trøndelag'
});

// --- Stasjoner ---
CREATE (s1:Stasjon {
  id: 'STA-TROL',
  navn: 'Trolla',
  spenningsnivå: 300,
  planlagtSpenningsnivå: 420,
  byggeår: 1968,
  status: 'I drift',
  latitude: 63.4500,
  longitude: 10.3000,
  kritikalitet: 'Høy'
});

CREATE (s2:Stasjon {
  id: 'STA-KLAE',
  navn: 'Klæbu',
  spenningsnivå: 420,
  byggeår: 1985,
  status: 'I drift',
  latitude: 63.3050,
  longitude: 10.4800,
  kritikalitet: 'Høy'
});

// --- Ledning ---
CREATE (l1:Ledning {
  id: 'LED-TROL-KLAE',
  navn: 'Trolla–Klæbu (planlagt)',
  spenningsnivå: 420,
  lengdeKm: 22.5,
  status: 'Planlagt',
  type: 'Luftledning'
});

// --- Felt i Trolla ---
CREATE (f1:Felt {
  id: 'FELT-TROL-01',
  navn: 'Felt 01 — Innmating Klæbu',
  type: 'Ledningsfelt',
  status: 'Planlagt'
});

CREATE (f2:Felt {
  id: 'FELT-TROL-02',
  navn: 'Felt 02 — Transformator T1',
  type: 'Transformatorfelt',
  status: 'I drift'
});

// --- Kontrollanlegg ---
CREATE (ka1:Kontrollanlegg {
  id: 'KA-TROL',
  navn: 'Kontrollanlegg Trolla',
  status: 'I drift'
});

// --- Komponenter (transformatorer, brytere, vern) ---
// Transformatorer
CREATE (t1:Komponent:Transformator {
  id: 'KOMP-TROL-T1',
  navn: 'Transformator T1',
  type: 'Transformator',
  ytelseMVA: 300,
  primærSpenning: 300,
  sekundærSpenning: 132,
  byggeår: 1972,
  tekniskTilstand: 'Redusert',
  kritikalitet: 'Høy'
});

CREATE (t2:Komponent:Transformator {
  id: 'KOMP-TROL-T2',
  navn: 'Transformator T2',
  type: 'Transformator',
  ytelseMVA: 300,
  primærSpenning: 300,
  sekundærSpenning: 132,
  byggeår: 1989,
  tekniskTilstand: 'God',
  kritikalitet: 'Høy'
});

// Brytere
CREATE (q1:Komponent:Bryter {
  id: 'KOMP-TROL-Q1',
  navn: 'Effektbryter Q1',
  type: 'Effektbryter',
  byggeår: 1972,
  tekniskTilstand: 'Dårlig',
  kritikalitet: 'Høy'
});

CREATE (q2:Komponent:Bryter {
  id: 'KOMP-TROL-Q2',
  navn: 'Effektbryter Q2',
  type: 'Effektbryter',
  byggeår: 2010,
  tekniskTilstand: 'God',
  kritikalitet: 'Middels'
});

CREATE (q3:Komponent:Bryter {
  id: 'KOMP-TROL-Q3',
  navn: 'Skillebryter Q3',
  type: 'Skillebryter',
  byggeår: 2010,
  tekniskTilstand: 'God',
  kritikalitet: 'Middels'
});

CREATE (q4:Komponent:Bryter {
  id: 'KOMP-TROL-Q4',
  navn: 'Jordingsbryter Q4',
  type: 'Jordingsbryter',
  byggeår: 2010,
  tekniskTilstand: 'God',
  kritikalitet: 'Lav'
});

// Vern
CREATE (v1:Komponent:Vern {
  id: 'KOMP-TROL-F1',
  navn: 'Distansevern F1',
  type: 'Distansevern',
  byggeår: 2015,
  tekniskTilstand: 'God',
  kritikalitet: 'Høy'
});

CREATE (v2:Komponent:Vern {
  id: 'KOMP-TROL-F2',
  navn: 'Differensialvern F2',
  type: 'Differensialvern',
  byggeår: 2015,
  tekniskTilstand: 'God',
  kritikalitet: 'Høy'
});

// --- RDS-referanser (funksjonsaspekt) ---
CREATE (rds1:RDSReferanse {referanse: '=AAA01', aspekt: 'Funksjon', beskrivelse: 'Trolla stasjon'});
CREATE (rds2:RDSReferanse {referanse: '=AAA01.A01', aspekt: 'Funksjon', beskrivelse: 'Felt 01 ledningsavgang'});
CREATE (rds3:RDSReferanse {referanse: '=AAA01.A02', aspekt: 'Funksjon', beskrivelse: 'Felt 02 transformatoravgang'});
CREATE (rds4:RDSReferanse {referanse: '=AAA01.A02.T1', aspekt: 'Funksjon', beskrivelse: 'Transformator T1'});
CREATE (rds5:RDSReferanse {referanse: '=AAA01.A02.T2', aspekt: 'Funksjon', beskrivelse: 'Transformator T2'});
CREATE (rds6:RDSReferanse {referanse: '=AAA01.A02.Q1', aspekt: 'Funksjon', beskrivelse: 'Effektbryter Q1'});
CREATE (rds7:RDSReferanse {referanse: '=AAA01.A01.Q2', aspekt: 'Funksjon', beskrivelse: 'Effektbryter Q2'});
CREATE (rds8:RDSReferanse {referanse: '=AAA01.A01.Q3', aspekt: 'Funksjon', beskrivelse: 'Skillebryter Q3'});
CREATE (rds9:RDSReferanse {referanse: '=AAA01.A01.Q4', aspekt: 'Funksjon', beskrivelse: 'Jordingsbryter Q4'});
CREATE (rds10:RDSReferanse {referanse: '=AAA01.A01.F1', aspekt: 'Funksjon', beskrivelse: 'Distansevern F1'});
CREATE (rds11:RDSReferanse {referanse: '=AAA01.A02.F2', aspekt: 'Funksjon', beskrivelse: 'Differensialvern F2'});
CREATE (rds12:RDSReferanse {referanse: '=AAB01', aspekt: 'Funksjon', beskrivelse: 'Klæbu stasjon'});
CREATE (rds13:RDSReferanse {referanse: '=L01', aspekt: 'Funksjon', beskrivelse: 'Ledning Trolla–Klæbu'});

// --- Hierarki: stasjon inneholder felt, felt inneholder komponenter ---

MATCH (s:Stasjon {id: 'STA-TROL'}), (f:Felt) WHERE f.id IN ['FELT-TROL-01', 'FELT-TROL-02']
CREATE (s)-[:INNEHOLDER]->(f);

MATCH (s:Stasjon {id: 'STA-TROL'}), (ka:Kontrollanlegg {id: 'KA-TROL'})
CREATE (s)-[:INNEHOLDER]->(ka);

// Felt 01 (ledningsfelt): Q2, Q3, Q4, F1
MATCH (f:Felt {id: 'FELT-TROL-01'}), (k:Komponent)
WHERE k.id IN ['KOMP-TROL-Q2', 'KOMP-TROL-Q3', 'KOMP-TROL-Q4', 'KOMP-TROL-F1']
CREATE (f)-[:INNEHOLDER]->(k);

// Felt 02 (transformatorfelt): T1, T2, Q1, F2
MATCH (f:Felt {id: 'FELT-TROL-02'}), (k:Komponent)
WHERE k.id IN ['KOMP-TROL-T1', 'KOMP-TROL-T2', 'KOMP-TROL-Q1', 'KOMP-TROL-F2']
CREATE (f)-[:INNEHOLDER]->(k);

// --- Ledningen kobler de to stasjonene ---
MATCH (l:Ledning {id: 'LED-TROL-KLAE'}), (s1:Stasjon {id: 'STA-TROL'}), (s2:Stasjon {id: 'STA-KLAE'})
CREATE (l)-[:ENDEPUNKT]->(s1)
CREATE (l)-[:ENDEPUNKT]->(s2);

// Ledningsfeltet i Trolla håndterer denne ledningen
MATCH (f:Felt {id: 'FELT-TROL-01'}), (l:Ledning {id: 'LED-TROL-KLAE'})
CREATE (f)-[:HÅNDTERER]->(l);

// --- RDS-koblinger ---
MATCH (s:Stasjon {id: 'STA-TROL'}), (r:RDSReferanse {referanse: '=AAA01'}) CREATE (s)-[:HAR_RDS]->(r);
MATCH (s:Stasjon {id: 'STA-KLAE'}), (r:RDSReferanse {referanse: '=AAB01'}) CREATE (s)-[:HAR_RDS]->(r);
MATCH (l:Ledning {id: 'LED-TROL-KLAE'}), (r:RDSReferanse {referanse: '=L01'}) CREATE (l)-[:HAR_RDS]->(r);
MATCH (f:Felt {id: 'FELT-TROL-01'}), (r:RDSReferanse {referanse: '=AAA01.A01'}) CREATE (f)-[:HAR_RDS]->(r);
MATCH (f:Felt {id: 'FELT-TROL-02'}), (r:RDSReferanse {referanse: '=AAA01.A02'}) CREATE (f)-[:HAR_RDS]->(r);
MATCH (k:Komponent {id: 'KOMP-TROL-T1'}), (r:RDSReferanse {referanse: '=AAA01.A02.T1'}) CREATE (k)-[:HAR_RDS]->(r);
MATCH (k:Komponent {id: 'KOMP-TROL-T2'}), (r:RDSReferanse {referanse: '=AAA01.A02.T2'}) CREATE (k)-[:HAR_RDS]->(r);
MATCH (k:Komponent {id: 'KOMP-TROL-Q1'}), (r:RDSReferanse {referanse: '=AAA01.A02.Q1'}) CREATE (k)-[:HAR_RDS]->(r);
MATCH (k:Komponent {id: 'KOMP-TROL-Q2'}), (r:RDSReferanse {referanse: '=AAA01.A01.Q2'}) CREATE (k)-[:HAR_RDS]->(r);
MATCH (k:Komponent {id: 'KOMP-TROL-Q3'}), (r:RDSReferanse {referanse: '=AAA01.A01.Q3'}) CREATE (k)-[:HAR_RDS]->(r);
MATCH (k:Komponent {id: 'KOMP-TROL-Q4'}), (r:RDSReferanse {referanse: '=AAA01.A01.Q4'}) CREATE (k)-[:HAR_RDS]->(r);
MATCH (k:Komponent {id: 'KOMP-TROL-F1'}), (r:RDSReferanse {referanse: '=AAA01.A01.F1'}) CREATE (k)-[:HAR_RDS]->(r);
MATCH (k:Komponent {id: 'KOMP-TROL-F2'}), (r:RDSReferanse {referanse: '=AAA01.A02.F2'}) CREATE (k)-[:HAR_RDS]->(r);

// --- Geografisk plassering ---
MATCH (s:Stasjon {id: 'STA-TROL'}), (k:Kommune {id: 'KOMM-5001'})
CREATE (s)-[:LIGGER_I]->(k);

MATCH (s:Stasjon {id: 'STA-KLAE'}), (k:Kommune {id: 'KOMM-5028'})
CREATE (s)-[:LIGGER_I]->(k);

MATCH (s:Stasjon), (po:PrisOmråde {id: 'NO3'})
CREATE (s)-[:I_PRISOMRÅDE]->(po);

// --- Kobling fra prosjekter til berørte anleggsobjekter ---
// Prosjekt 1 (Oppgradering Trolla) berører Trolla og dens komponenter
MATCH (p:Prosjekt {id: 'PRJ-001'}), (s:Stasjon {id: 'STA-TROL'})
CREATE (p)-[:BERØRER]->(s);

MATCH (p:Prosjekt {id: 'PRJ-001'}), (k:Komponent)
WHERE k.id IN ['KOMP-TROL-T1', 'KOMP-TROL-Q1']
CREATE (p)-[:BERØRER {type: 'Utskifting'}]->(k);

// Prosjekt 2 (Ny ledning) berører ledningen, ledningsfeltet og begge stasjoner
MATCH (p:Prosjekt {id: 'PRJ-002'}), (l:Ledning {id: 'LED-TROL-KLAE'})
CREATE (p)-[:BERØRER {type: 'Nybygg'}]->(l);

MATCH (p:Prosjekt {id: 'PRJ-002'}), (f:Felt {id: 'FELT-TROL-01'})
CREATE (p)-[:BERØRER {type: 'Nybygg'}]->(f);

MATCH (p:Prosjekt {id: 'PRJ-002'}), (s:Stasjon)
WHERE s.id IN ['STA-TROL', 'STA-KLAE']
CREATE (p)-[:BERØRER {type: 'Tilkobling'}]->(s);

RETURN "Anlegg, RDS og prosjekt-til-anlegg-kobling opprettet" AS status;
