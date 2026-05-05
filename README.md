# Statnett Kunnskapsgraf — MVP

En tenkt MVP som viser hvordan en kunnskapsgraf kan modellere strategi, prosjekter, fysisk anlegg, krav, roller og risiko i sammenheng. Bygget med syntetiske data, kjører lokalt og helt gratis.

## Hva MVP-en demonstrerer

Et tenkt scenario: To prosjekter i porteføljen "Kapasitetsøkning Midt-Norge" oppgraderer Trolla stasjon og bygger ny ledning til Klæbu. Grafen viser sammenhengen fra strategisk mål helt ned til enkeltkomponenter, og kobler inn krav, dokumenter, roller, risikoer og avhengigheter.

Resultatet er fem spørringer som demonstrerer reell verdi:

1. **Sporbarhet oppover** — fra fysisk komponent til strategisk mål
2. **Sporbarhet nedover** — fra strategisk mål til berørte komponenter
3. **Konsekvensanalyse** — hva påvirkes hvis et prosjekt forsinkes
4. **Eierskap** — hvem er ansvarlig for alt knyttet til en stasjon
5. **Risikoeksponering** — risikoer på tvers av portefølje og anlegg

## Forutsetninger

- Docker Desktop, Rancher Desktop eller Podman Desktop
- En nettleser
- Git (anbefalt)

Ingen lisenser, ingen kontoer, ingen kostnader.

## Komme i gang (10 minutter)

### 1. Start Neo4j

```bash
docker compose up -d
```

Vent 20–30 sekunder. Åpne deretter Neo4j Browser på <http://localhost:7474>.

Logg inn:
- Brukernavn: `neo4j`
- Passord: `mvp-passord-123`

### 2. Last inn ontologi og data

I Neo4j Browser, kjør disse i rekkefølge ved å lime inn innholdet fra hver fil:

1. `ontology/01_constraints.cypher` — unike nøkler og indekser
2. `data/02_strategi_portefolje.cypher` — strategi, portefølje, prosjekter
3. `data/03_anlegg.cypher` — stasjoner, ledning, komponenter, RDS
4. `data/04_prosjektstruktur.cypher` — delprosjekter, arbeidspakker, milepæler
5. `data/05_tverrgaende.cypher` — krav, dokumenter, roller, risiko

Eller alt på én gang fra terminalen:

```bash
./load-all.sh
```

### 3. Kjør spørringene

Du har to valg: Neo4j Browser (innebygd) eller den enkle GUI-en (anbefalt for fagpersoner).

**Alternativ A: Enkel GUI med forhåndsdefinerte spørsmål**

```bash
./start-gui.sh
```

Åpner automatisk <http://localhost:8080>. Klikk gjennom spørsmål i menyen. Se `gui/README.md` for detaljer.

**Alternativ B: Neo4j Browser**

Åpne `queries/`-mappen og kjør hver spørring i Neo4j Browser på <http://localhost:7474>. Hver fil har en kommentar som forklarer hva spørringen viser.

Tips: Klikk på "Graph"-visning øverst til venstre i resultatet for å se relasjonene visuelt.

## Deployment til GitHub Pages

GUI-en kan deployes til GitHub Pages for deling med andre uten å kreve lokal Docker-oppsett.

**Forutsetninger:**
- Git repository på GitHub
- Neo4j-instans som er tilgjengelig fra internett (eller bruk lokalt via tunnel)

**Oppsett:**

1. Push denne repoet til GitHub
2. Gå til repository-innstillinger → **Pages**
3. Velg "Deploy from a branch" og branch `gh-pages`
4. Konfigurer Neo4j-forbindelsen:
   - **Enklest:** Besøk `https://brukernavn.github.io/statnett-kg-mvp/?neo4j_uri=bolt://your-server:7687&neo4j_user=neo4j&neo4j_password=passord`
   - **Sikrare:** Bruk GitHub Secrets (se `docs/github-pages-setup.md`)

GitHub Actions deployer automatisk når du pusher til `main` eller `master`.

Se [GitHub Pages Setup Guide](docs/github-pages-setup.md) for detaljerte instruksjoner.

## Struktur

```
statnett-kg-mvp/
├── docker-compose.yml          # Neo4j-oppsett
├── load-all.sh                 # Laster alt i én kommando
├── start-gui.sh                # Starter den enkle webbaserte GUI-en
├── CLAUDE.md                   # Instruksjoner for Claude Code
├── ontology/
│   └── 01_constraints.cypher   # Unike nøkler og indekser
├── data/
│   ├── 02_strategi_portefolje.cypher
│   ├── 03_anlegg.cypher
│   ├── 04_prosjektstruktur.cypher
│   └── 05_tverrgaende.cypher
├── queries/
│   ├── 01_sporbarhet_opp.cypher
│   ├── 02_sporbarhet_ned.cypher
│   ├── 03_konsekvens.cypher
│   ├── 04_eierskap.cypher
│   ├── 05_risiko.cypher
│   └── 06_validering.cypher
├── gui/
│   ├── index.html              # Webbasert utforsker
│   ├── questions.js            # Forhåndsdefinerte spørsmål
│   ├── app.js                  # Logikk og Neo4j-tilkobling
│   └── README.md               # GUI-dokumentasjon
└── docs/
    ├── modell.md               # Forklaring av modellen
    └── adr/                    # Architecture Decision Records
        └── 001-neo4j-vs-rdf.md
```

## Hva som ikke er med (med vilje)

- Ingen ekte data — alt er oppdiktet, men realistisk strukturert
- Ingen integrasjoner mot kildesystemer
- Ingen sanntidsdata, sensorer eller tidsserier
- Ingen geografisk visualisering
- Ingen BIM-geometri (refereres, ikke modelleres)
- Ingen webfrontend — Neo4j Browser er nok for å vurdere modellen

Disse er bevisst utelatt for å holde MVP-en liten nok til å forstå og endre raskt.

## Neste steg etter MVP

Når du har sett og kjent på modellen, er det disse spørsmålene som bør avklares før produksjonsversjon:

1. Hvilke kildesystemer skal grafen integrere mot, og hvem eier dem?
2. Skal modellen formaliseres som RDF/OWL for semantisk presisjon, eller forbli i property graph?
3. Hvem skal eie og forvalte ontologien?
4. Hvilke 3–5 reelle brukstilfeller gir mest verdi tidlig?
5. Hvilke deler av CIM og RDS-PP skal vi følge strengt vs. tilpasse?

Se `docs/modell.md` for diskusjon av modelleringsvalg som ble gjort i MVP-en.
