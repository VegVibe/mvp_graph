// =============================================================
// questions.js
// Forhåndsdefinerte spørsmål gruppert per tema.
// Hver spørring har enten "graph" (visuell) eller "table" som
// foretrukket visning.
// =============================================================

const QUESTIONS = [
  {
    group: "Sporbarhet",
    items: [
      {
        id: "spor-opp",
        title: "Hva støtter denne komponenten?",
        desc: "Spor effektbryter Q1 helt opp til strategisk mål",
        view: "graph",
        cypher: `
          MATCH path = (k:Komponent {id: 'KOMP-TROL-Q1'})
            <-[:BERØRER]-(:Prosjekt)
            <-[:INNEHOLDER]-(:Portefølje)
            -[:STØTTER]->(:StrategiskMål)
          RETURN path
        `
      },
      {
        id: "spor-ned",
        title: "Hva blir berørt av strategien?",
        desc: "Alle objekter som er knyttet til strategisk mål",
        view: "graph",
        cypher: `
          MATCH path = (sm:StrategiskMål {id: 'SM-001'})
            <-[:STØTTER]-(:Portefølje)
            -[:INNEHOLDER]->(:Prosjekt)
            -[:BERØRER]->(o)
          RETURN path
        `
      },
      {
        id: "stasjon-trolla",
        title: "Hva henger sammen med Trolla?",
        desc: "Stasjonen og alle dens komponenter, prosjekter, dokumenter og roller",
        view: "graph",
        cypher: `
          MATCH path = (s:Stasjon {id: 'STA-TROL'})-[*1..2]-(annet)
          RETURN path LIMIT 100
        `
      }
    ]
  },
  {
    group: "Prosjekter og leveranser",
    items: [
      {
        id: "prosjekt-oversikt",
        title: "Oversikt over alle prosjekter",
        desc: "Status, budsjett og tidsrom",
        view: "table",
        cypher: `
          MATCH (pf:Portefølje)-[:INNEHOLDER]->(p:Prosjekt)
          OPTIONAL MATCH (p)-[:EIES_AV]->(rolle:Rolle)
          RETURN
            p.navn AS Prosjekt,
            pf.navn AS Portefølje,
            p.status AS Status,
            p.fase AS Fase,
            p.startDato AS Start,
            p.planlagtSluttDato AS Slutt,
            p.budsjett AS Budsjett,
            rolle.innehaver AS Eier
          ORDER BY p.startDato
        `
      },
      {
        id: "prosjekt-detaljer",
        title: "Detaljer for ett prosjekt",
        desc: "Hele strukturen for Oppgradering Trolla",
        view: "graph",
        cypher: `
          MATCH path = (p:Prosjekt {id: 'PRJ-001'})
            -[:INNEHOLDER|HAR_MILEPÆL|LEVERER*0..3]->(n)
          RETURN path
        `
      },
      {
        id: "milepaeler",
        title: "Alle milepæler",
        desc: "Sortert etter dato og kritikalitet",
        view: "table",
        cypher: `
          MATCH (p:Prosjekt)-[:HAR_MILEPÆL]->(mp:Milepæl)
          RETURN
            mp.navn AS Milepæl,
            p.navn AS Prosjekt,
            mp.planlagtDato AS Planlagt,
            mp.status AS Status,
            mp.type AS Type,
            mp.kritisk AS Kritisk
          ORDER BY mp.planlagtDato
        `
      },
      {
        id: "avhengigheter",
        title: "Hvilke prosjekter er avhengige av hverandre?",
        desc: "Direkte og indirekte avhengigheter",
        view: "graph",
        cypher: `
          MATCH path = (p:Prosjekt)-[:ER_AVHENGIG_AV]->(:Prosjekt)
          RETURN path
          UNION
          MATCH path = (mp1:Milepæl)-[:ER_AVHENGIG_AV]->(mp2:Milepæl)
          MATCH (p1:Prosjekt)-[:HAR_MILEPÆL]->(mp1)
          MATCH (p2:Prosjekt)-[:HAR_MILEPÆL]->(mp2)
          RETURN path
        `
      }
    ]
  },
  {
    group: "Anlegg",
    items: [
      {
        id: "stasjon-hierarki",
        title: "Stasjonshierarki",
        desc: "Stasjon → felt → komponenter med RDS",
        view: "graph",
        cypher: `
          MATCH path = (s:Stasjon {id: 'STA-TROL'})
            -[:INNEHOLDER*0..2]->(n)
            -[:HAR_RDS]->(rds:RDSReferanse)
          RETURN path
        `
      },
      {
        id: "tilstand",
        title: "Komponenter i dårlig tilstand",
        desc: "Sortert etter kritikalitet",
        view: "table",
        cypher: `
          MATCH (k:Komponent)
          WHERE k.tekniskTilstand IN ['Dårlig', 'Redusert']
          OPTIONAL MATCH (k)<-[:INNEHOLDER]-(felt:Felt)<-[:INNEHOLDER]-(s:Stasjon)
          OPTIONAL MATCH (k)-[:HAR_RDS]->(rds:RDSReferanse)
          OPTIONAL MATCH (k)<-[:BERØRER]-(p:Prosjekt)
          RETURN
            k.navn AS Komponent,
            k.type AS Type,
            k.tekniskTilstand AS Tilstand,
            k.kritikalitet AS Kritikalitet,
            k.byggeår AS Byggeår,
            s.navn AS Stasjon,
            rds.referanse AS RDS,
            collect(DISTINCT p.navn) AS BerørtAvProsjekter
          ORDER BY
            CASE k.kritikalitet WHEN 'Høy' THEN 1 WHEN 'Middels' THEN 2 ELSE 3 END,
            k.tekniskTilstand
        `
      },
      {
        id: "rds-oversikt",
        title: "Alle RDS-referanser",
        desc: "Hierarkisk oversikt",
        view: "table",
        cypher: `
          MATCH (n)-[:HAR_RDS]->(rds:RDSReferanse)
          RETURN
            rds.referanse AS RDS,
            rds.aspekt AS Aspekt,
            labels(n)[0] AS Objekttype,
            n.navn AS Objekt
          ORDER BY rds.referanse
        `
      }
    ]
  },
  {
    group: "Konsekvens og risiko",
    items: [
      {
        id: "konsekvens-prj1",
        title: "Hva hvis PRJ-001 forsinkes?",
        desc: "Avhengighetskjede oppstrøms",
        view: "graph",
        cypher: `
          MATCH path = (start:Prosjekt {id: 'PRJ-001'})
            <-[:ER_AVHENGIG_AV*1..3]-(berørt)
          RETURN path
          UNION
          MATCH path = (start:Prosjekt {id: 'PRJ-001'})
            -[:HAR_MILEPÆL]->(:Milepæl)
            <-[:ER_AVHENGIG_AV*1..3]-(berørt)
          RETURN path
        `
      },
      {
        id: "risiko-tabell",
        title: "Alle risikoer",
        desc: "Med hva de påvirker og hvilke tiltak",
        view: "table",
        cypher: `
          MATCH (r:Risiko)
          OPTIONAL MATCH (r)-[:PÅVIRKER]->(rammet)
          OPTIONAL MATCH (r)<-[:REDUSERER]-(t:Tiltak)
          RETURN
            r.navn AS Risiko,
            r.risikoNivå AS Nivå,
            r.sannsynlighet AS Sannsynlighet,
            r.konsekvens AS Konsekvens,
            collect(DISTINCT labels(rammet)[0] + ': ' + rammet.navn) AS Rammede,
            collect(DISTINCT t.navn) AS Tiltak
          ORDER BY
            CASE r.risikoNivå WHEN 'Høy' THEN 1 WHEN 'Middels' THEN 2 ELSE 3 END
        `
      },
      {
        id: "risiko-graf",
        title: "Risikobilde — visuelt",
        desc: "Risikoer, hva de rammer, og tiltak",
        view: "graph",
        cypher: `
          MATCH path = (r:Risiko)-[:PÅVIRKER]->(rammet)
          OPTIONAL MATCH tiltakPath = (r)<-[:REDUSERER]-(:Tiltak)
          RETURN path, tiltakPath
        `
      }
    ]
  },
  {
    group: "Eierskap og roller",
    items: [
      {
        id: "eierskap-trolla",
        title: "Hvem er ansvarlige for Trolla?",
        desc: "Alle roller knyttet til stasjonen",
        view: "table",
        cypher: `
          MATCH (s:Stasjon {id: 'STA-TROL'})
          OPTIONAL MATCH (s)-[rel:EIES_AV|DRIFTES_AV]->(direkteRolle:Rolle)
          WITH s, collect(DISTINCT {type: type(rel), rolle: direkteRolle.navn, person: direkteRolle.innehaver}) AS direkte
          OPTIONAL MATCH (s)<-[:BERØRER]-(p:Prosjekt)-[:EIES_AV]->(prosjektRolle:Rolle)
          WITH s, direkte, collect(DISTINCT {type: 'PROSJEKTEIER (' + p.navn + ')', rolle: prosjektRolle.navn, person: prosjektRolle.innehaver}) AS via_prosjekt
          OPTIONAL MATCH (s)<-[:BESKRIVER]-(d:Dokument)-[:EIES_AV]->(dokRolle:Rolle)
          WITH s, direkte + via_prosjekt + collect(DISTINCT {type: 'DOKUMENTEIER (' + d.navn + ')', rolle: dokRolle.navn, person: dokRolle.innehaver}) AS alle
          UNWIND alle AS row
          WITH row WHERE row.rolle IS NOT NULL
          RETURN row.type AS Ansvarstype, row.rolle AS Rolle, row.person AS Person
        `
      },
      {
        id: "org-hierarki",
        title: "Organisasjonshierarki",
        desc: "Enheter og roller",
        view: "graph",
        cypher: `
          MATCH path = (oe:Organisasjonsenhet)-[:INNEHOLDER*0..3]->(barn:Organisasjonsenhet)
          OPTIONAL MATCH rollePath = (barn)<-[:TILHØRER]-(:Rolle)
          RETURN path, rollePath
        `
      }
    ]
  },
  {
    group: "Krav og dokumenter",
    items: [
      {
        id: "krav-status",
        title: "Krav og verifikasjonsstatus",
        desc: "Hvilke objekter oppfyller hvilke krav",
        view: "table",
        cypher: `
          MATCH (krav:Krav)<-[oppf:OPPFYLLER]-(obj)
          RETURN
            krav.navn AS Krav,
            krav.type AS Kravtype,
            krav.kritikalitet AS Kritikalitet,
            labels(obj)[0] AS Objekttype,
            obj.navn AS Objekt,
            oppf.verifikasjonsStatus AS Verifikasjonsstatus
          ORDER BY krav.kritikalitet DESC, krav.navn
        `
      },
      {
        id: "dokumenter",
        title: "Dokumenter med eier",
        desc: "Status, versjon og eier",
        view: "table",
        cypher: `
          MATCH (d:Dokument)
          OPTIONAL MATCH (d)-[:EIES_AV]->(eier:Rolle)
          OPTIONAL MATCH (d)-[:BESKRIVER]->(beskriver)
          RETURN
            d.navn AS Dokument,
            d.type AS Type,
            d.versjon AS Versjon,
            d.status AS Status,
            d.format AS Format,
            eier.innehaver AS Eier,
            collect(DISTINCT labels(beskriver)[0] + ': ' + beskriver.navn) AS Beskriver
          ORDER BY d.type, d.navn
        `
      }
    ]
  }
];
