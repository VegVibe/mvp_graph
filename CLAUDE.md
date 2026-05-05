# CLAUDE.md — Statnett Kunnskapsgraf MVP

Dette dokumentet er for Claude Code når den jobber med dette prosjektet. Les hele før du gjør endringer.

## Hva dette prosjektet er

En MVP for en kunnskapsgraf som modellerer Statnetts virksomhet på tvers av strategi, prosjektgjennomføring, fysiske anlegg, krav, organisasjon og risiko. Bygget med syntetiske, men realistiske data for å vurdere modelleringen før vi tar det videre til produksjon.

## Modelleringsprinsipper

Disse er ikke til forhandling i MVP-en:

1. **Ontologi og instansdata holdes strengt adskilt.** Ontologi i `ontology/`, instansdata i `data/`.
2. **Alle fysiske objekter skal ha en RDS-referanse.** Modellert som egen node, ikke bare som property.
3. **Alle objekter skal ha en eier.** Eieren er en `Rolle` som er bemannet av en `Person` (i MVP forenklet til navn på rollen).
4. **Sporbarhet skal alltid være mulig** fra strategisk mål helt ned til fysisk komponent. Hvis du legger til noe som bryter denne kjeden, dokumenter hvorfor.
5. **Tid representeres som properties** i MVP (start, slutt, status). Ingen temporal graf.
6. **Geografi representeres som koordinater (lat/lon)** som properties. Ingen geo-spesifikke noder.

## Navnekonvensjoner

- **Node-labels:** PascalCase, norsk i entall — `Stasjon`, `Prosjekt`, `Krav`, `RDSReferanse`
- **Relasjonstyper:** SCREAMING_SNAKE_CASE, norsk, beskrivende verb — `INNEHOLDER`, `ER_AVHENGIG_AV`, `EIES_AV`, `OPPFYLLER`
- **Properties:** camelCase, norsk — `navn`, `startDato`, `kritikalitet`, `rdsReferanse`
- **Filnavn:** snake_case med nummerprefiks for kjøreorden — `02_strategi_portefolje.cypher`

Hvorfor norsk? Fordi domeneeksperter skal kunne lese spørringene direkte, og fordi engelsk-norsk-blanding gir verre resultater enn rent norsk.

## Strukturelle valg

### Graph database vs. RDF

Vi bruker Neo4j (property graph) i MVP. Begrunnelse: raskere å komme i gang, bedre visualisering, enklere for de som skal vurdere modellen. Hvis vi tar dette videre til produksjon, vurderes RDF/OWL for semantisk presisjon — særlig der CIM-integrasjon er sentralt. Se `docs/adr/001-neo4j-vs-rdf.md`.

### RDS-modellering

RDS-referanser er egne noder fordi:
- Samme komponent kan ha flere RDS-aspekter (funksjon, lokasjon, produkt)
- RDS-strukturen er hierarkisk og kan spørres på
- Aspekter og klasser kan endres uten å endre komponenten

Forenkling i MVP: vi modellerer kun funksjonsaspektet (`=`). Lokasjons- (`+`) og produktaspekter (`-`) legges til senere.

### Prosjekthierarki

`Portefølje → Prosjekt → Delprosjekt → Arbeidspakke → Leveranse` er en `INNEHOLDER`-kjede. `Milepæl` henger på `Prosjekt` og kan referere til en `Leveranse` via `MARKERER`.

### Krav

Krav er sin egen entitet, ikke en property på objekter. Et krav kan `STILLES_TIL` flere objekter, og objekter kan `OPPFYLLER` flere krav. Verifikasjonsstatus modelleres som property på `OPPFYLLER`-relasjonen.

## Når du legger til noder

1. Sjekk om noden allerede finnes i ontologien
2. Følg navnekonvensjonene
3. Legg til en `id`-property (string, unik innen labelen)
4. Legg til en `navn`-property (lesbar tekst)
5. Knytt den til riktig sted i hierarkiet
6. Hvis det er et fysisk objekt: legg til RDS-referanse
7. Hvis det er noe som har eier: legg til `EIES_AV`-relasjon

## Når du legger til relasjoner

- Gi relasjonen en retning som leses naturlig: `Prosjekt -[:LEVERER]-> Leveranse`, ikke omvendt
- Bruk verb i relasjonstypen, ikke substantiv (`ER_AVHENGIG_AV`, ikke `AVHENGIGHET`)
- Properties på relasjoner er greit for ting som beskriver selve relasjonen (f.eks. `verifikasjonsStatus` på `OPPFYLLER`)

## Validering

Etter endringer i data eller ontologi, kjør disse sjekkene som Cypher-spørringer:

```cypher
// Alle fysiske komponenter må ha RDS-referanse
MATCH (k:Komponent) WHERE NOT (k)-[:HAR_RDS]->() RETURN k;

// Alle prosjekter må ha en eier
MATCH (p:Prosjekt) WHERE NOT (p)-[:EIES_AV]->() RETURN p;

// Sporbarhet: alle prosjekter skal kunne spores til et strategisk mål
MATCH (p:Prosjekt)
WHERE NOT (p)<-[:INNEHOLDER*]-(:Portefølje)-[:STØTTER]->(:StrategiskMål)
RETURN p;
```

Disse skal returnere tomme resultater. Hvis ikke, er modellen brutt.

## Når du blir bedt om å utvide modellen

Spør først:
1. Hvilket brukstilfelle skal dette løse?
2. Eksisterer det allerede en lignende node-type vi kan bruke?
3. Hvor i lagdelingen hører dette hjemme (strategi, prosjekt, anlegg, tverrgående, drift)?

Bygg deretter ut i denne rekkefølgen:
1. Definer node-typen i `ontology/`
2. Legg til constraints/indexer
3. Legg til instansdata i `data/`
4. Skriv minst én spørring som bruker den nye node-typen

## Hva du IKKE skal gjøre

- Ikke bland inn ekte data fra Statnett. Alt er syntetisk.
- Ikke modeller sanntidsdata, sensorer eller tidsserier i MVP.
- Ikke bygg webfrontend — Neo4j Browser er tilstrekkelig.
- Ikke endre passordet i `docker-compose.yml` uten å oppdatere `README.md`.
- Ikke legg til avhengigheter (Python-pakker, npm) uten å diskutere det først.

## Filer du bør lese før større endringer

- `README.md` — overordnet beskrivelse
- `docs/modell.md` — forklaring av modelleringsvalg
- `docs/adr/` — beslutninger som er tatt
- `ontology/01_constraints.cypher` — strukturen på modellen
