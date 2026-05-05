# GUI for Statnett Kunnskapsgraf

En enkel webbasert utforsker som lar deg klikke gjennom forhåndsdefinerte spørsmål og se grafen visuelt — uten å lære Cypher.

## Hva du får

- **Forhåndsdefinerte spørsmål** gruppert per tema (Sporbarhet, Prosjekter, Anlegg, Risiko, Eierskap, Krav)
- **Visuell graf** med farger per node-type, klikk for detaljer
- **Tabellvisning** for spørsmål med strukturerte data
- **Egen Cypher-spørring** for de som vil utforske selv
- **Detaljpanel** når du klikker på en node — viser alle properties

## Forutsetninger

- Neo4j må kjøre (`docker compose up -d` fra rotmappen)
- Data må være lastet inn (`./load-all.sh` fra rotmappen)
- Python 3 (forhåndsinstallert på Mac/Linux, finnes også for Windows)

## Komme i gang

Fra rotmappen:

```bash
./start-gui.sh
```

GUI-en åpnes automatisk på <http://localhost:8080>.

## Hvis automatisk start ikke fungerer

**Manuelt med Python:**
```bash
cd gui
python3 -m http.server 8080
```
Åpne deretter <http://localhost:8080> i nettleseren.

**Med Node.js (hvis du har det):**
```bash
cd gui
npx serve -p 8080
```

**Direkte i nettleseren (Chrome/Edge):**
Du kan i prinsippet åpne `gui/index.html` direkte, men WebSocket-tilkoblingen til Neo4j kan blokkeres av nettleserens sikkerhetsregler. HTTP-server er sikrest.

## Hva GUI-en kobler til

GUI-en bruker den offisielle Neo4j JavaScript-driveren og kobler direkte til Neo4j via Bolt-protokollen på `bolt://localhost:7687`. Tilkoblingsdetaljene står øverst i `app.js`:

```javascript
const NEO4J_URI = "bolt://localhost:7687";
const NEO4J_USER = "neo4j";
const NEO4J_PASSWORD = "mvp-passord-123";
```

Hvis du endrer passordet i `docker-compose.yml`, må du også endre det her.

## Hvordan utvide GUI-en

### Legg til et nytt spørsmål

Åpne `gui/questions.js`. Hvert spørsmål har formen:

```javascript
{
  id: "min-id",
  title: "Spørsmål til brukeren",
  desc: "Kort beskrivelse",
  view: "graph",  // eller "table"
  cypher: `MATCH (n) RETURN n LIMIT 25`
}
```

Legg det til i en eksisterende gruppe eller lag en ny. Lagre og last siden på nytt — ingen byggesteg.

### Endre fargene per node-type

Åpne `gui/app.js`, finn `COLORS`-objektet øverst, og endre verdiene.

### Endre andre ting

Filene er små og kommenterte. Det er meningen at du skal kunne be Claude Code om endringer:

> "Legg til et nytt spørsmål under Anlegg som viser alle stasjoner med byggeår og spenningsnivå"
>
> "Endre fargen på Risiko-noder til oransje"
>
> "Legg til en knapp som eksporterer tabellresultatet til CSV"

## Begrensninger (med vilje)

GUI-en er **ikke produksjonskvalitet**. Disse tingene er bevisst utelatt:

- Ingen pålogging — passordet ligger i klartekst i `app.js`
- Ingen autorisasjon — alle som har tilgang til siden kan kjøre alle spørringer (også slette data)
- Ingen ytelsesoptimalisering — kjører bra på MVP-datasett, vil bli treigt på 100k+ noder
- Ingen mobile/touch-tilpasning
- Ingen eksport eller deling av visninger
- Ingen historikk
- Ingen redigering av data — kun visning

Dette er en **vurderings-MVP**, ikke et verktøy for daglig bruk.

## Vanlige problemer

**"Ikke tilkoblet — sjekk at Neo4j kjører"** i statuslinjen
→ Neo4j-containeren kjører ikke. Kjør `docker compose up -d` fra rotmappen.

**Tilkoblingen henger eller feiler i nettleseren**
→ Sjekk at port 7687 er åpen. På noen Windows-maskiner blokkerer Windows Defender Bolt-protokollen. Bytt til `neo4j://localhost:7687` eller `bolt+s://` i `app.js` hvis du har TLS satt opp.

**Tom graf returneres**
→ Du har ikke lastet inn data. Kjør `./load-all.sh` fra rotmappen.

**Spørringen kjører, men noder vises ikke**
→ Sjekk at spørringen returnerer `path`, noder, eller relasjoner. Spørringer som kun returnerer scalarer (tall, strenger) vises som tabell.
