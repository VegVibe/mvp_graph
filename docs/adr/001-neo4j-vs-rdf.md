# ADR-001: Valg av Neo4j (property graph) for MVP

**Status:** Akseptert (gjelder kun for MVP)
**Dato:** 2026-05-04

## Kontekst

Vi skal bygge en kunnskapsgraf for Statnett som modellerer strategi, prosjekter, fysisk anlegg, krav, organisasjon og risiko. Det er to hovedfamilier av teknologier:

1. **Property graph** (Neo4j, Memgraph, Kuzu) — node/edge-modell med properties, spørres med Cypher/GQL
2. **RDF / semantisk web** (GraphDB, Apache Jena, Stardog) — triples, formell ontologi, spørres med SPARQL, validering med SHACL

## Beslutning

For MVP-en bruker vi **Neo4j Community Edition**.

## Begrunnelse

- **Lavere terskel for vurdering** — fagpersoner skal kunne se og forstå modellen visuelt i Neo4j Browser uten å lære RDF-syntaks
- **Raskere å demonstrere verdi** — Cypher er mer kompakt og lettlest enn SPARQL for de fleste spørringene vi trenger
- **Bedre verktøystøtte ut av boksen** — visualisering, autocompletion, generelt utviklermiljø
- **Tilstrekkelig for MVP-formål** — vi trenger ikke formell semantikk eller inferens i denne fasen
- **Gratis for vår bruk** — Community Edition er fri å bruke for intern, ikke-kommersiell bruk

## Konsekvenser

### Positive
- Vi kommer raskt i gang
- Modellen er lett å forklare og demonstrere
- Cypher-spørringer kan generes av LLM-er med høy kvalitet

### Negative
- Vi mister formell semantikk og automatisk inferens
- Integrasjon med CIM (som er formelt definert i OWL) blir manuell mapping
- Når vi senere går til RDF (hvis vi gjør det) må modellen migreres

### Nøytrale
- Beslutningen gjelder kun MVP. Produksjonsversjon vurderes på nytt.

## Vurderte alternativer

### RDF/OWL med GraphDB Free eller Apache Jena Fuseki

**Pro:**
- Formell semantikk
- Direkte gjenbruk av CIM-ontologi
- SHACL for validering
- Standardisert (W3C), bedre for datadeling

**Kontra:**
- Brattere læringskurve
- Svakere visualisering ut av boksen
- SPARQL er mer verbost for typiske traverseringsspørringer
- Krever mer arbeid å sette opp før modellen kan vurderes

### Memgraph Community

**Pro:**
- Cypher-kompatibel, så enkel migrering fra Neo4j
- Raskere på enkelte arbeidsbelastninger
- Ekte open source-lisens

**Kontra:**
- Mindre økosystem og verktøy
- Mindre erfaringsbase i bransjen

## Når dette bør revurderes

Beslutningen bør revurderes hvis ett eller flere av disse blir sant:

1. CIM-integrasjon blir et hovedformål
2. Vi skal dele ontologien med eksterne parter
3. Vi trenger automatisk inferens (f.eks. "alle 420 kV-stasjoner i Midt-Norge inkluderer automatisk Trolla etter oppgradering")
4. Vi skal ha formell verifikasjon av modellkonsistens utover det Cypher kan gi

## Migreringssti hvis vi går til RDF senere

Hovedarbeidet er ikke å konvertere data — det er å justere ontologien mot CIM-vokabular og legge til formell semantikk. Property graph-modellen vår oversettes ganske direkte til RDF:

- Node-labels → `rdf:type`
- Properties → `rdf:Property` med literal-verdier
- Relasjoner → `rdf:Property` med object-verdier

Det vanskeligste er reifikasjon av relasjon-properties (f.eks. `verifikasjonsStatus` på `OPPFYLLER`), men dette er løst med standard mønstre.
