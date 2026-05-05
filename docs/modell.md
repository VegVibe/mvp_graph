# Modellforklaring

Dette dokumentet forklarer modelleringsvalgene som er gjort i MVP-en, slik at noen kan vurdere dem og foreslå endringer før vi tar dette videre til produksjon.

## Lagdelt struktur

Modellen er organisert i fem lag som hver har sin egen logikk og som knyttes sammen med tverrgående relasjoner:

**Strategi-lag** — `StrategiskMål`, `Styringsparameter`, `Portefølje`, `Beslutning`. Definerer *hvorfor* vi gjør noe.

**Prosjekt-lag** — `Prosjekt`, `Delprosjekt`, `Arbeidspakke`, `Leveranse`, `Milepæl`. Definerer *hva* vi gjør og *når*.

**Anlegg-lag** — `Stasjon`, `Ledning`, `Felt`, `Komponent` (med spesialiseringer som `Transformator`, `Bryter`, `Vern`), `Kontrollanlegg`. Definerer den fysiske virkeligheten.

**Tverrgående lag** — `Krav`, `Dokument`, `Risiko`, `Tiltak`, `Endringsinitiativ`. Binder ting sammen og dokumenterer.

**Organisasjons-lag** — `Organisasjonsenhet`, `Rolle`. Definerer *hvem* som er ansvarlig.

## Sentrale designvalg

### RDS-referanser som egne noder

Vi modellerer RDS-referanser som egne noder, ikke som properties på objektene. Dette gjør at:
- Samme objekt kan ha flere aspekter (i MVP kun funksjon, men senere også lokasjon og produkt)
- Vi kan spørre på RDS-strukturen direkte
- Endring i RDS-systemet ikke krever endring i objektmodellen

Forenkling i MVP: kun funksjonsaspekt (`=`). Lokasjon (`+`) og produkt (`-`) legges til senere.

### Sporbarhet via `BERØRER`

Koblingen mellom prosjekt og anleggsobjekt er en `BERØRER`-relasjon med property `type` (Utskifting, Nybygg, Tilkobling). Dette er den viktigste enkeltrelasjonen i modellen — det er den som gjør det mulig å spore fra strategi helt ned til komponent.

### Krav som egne entiteter

Krav er ikke properties på objekter. Et krav `STILLES_TIL` flere objekter, og objekter `OPPFYLLER` flere krav. Verifikasjonsstatus ligger som property på `OPPFYLLER`-relasjonen, ikke på kravet selv. Dette gjør at samme krav kan være verifisert på én stasjon men ikke på en annen.

### Eierskap via roller, ikke personer

I MVP er rollens innehaver bare et navn på rollen (f.eks. "Stasjonsmester Trolla"). I produksjon vil vi sannsynligvis legge til en `Person`-node som er knyttet via en `BEMANNER`-relasjon med tidsperioder, slik at vi kan se historisk hvem som var ansvarlig når.

### Avhengigheter på flere nivåer

Avhengigheter er modellert både mellom prosjekter (`Prosjekt -[:ER_AVHENGIG_AV]-> Prosjekt`), mellom milepæler på tvers av prosjekter, og mellom arbeidspakker innen et prosjekt. Dette gjør konsekvensanalyse mer presis — vi kan svare på om en arbeidspakke-forsinkelse virkelig påvirker ledningsprosjektet, eller om bufferen i milepælene tåler det.

## Hva som er forenklet i MVP

Dette er bevisste forenklinger som bør utbedres i produksjonsversjon:

| Område | Forenkling i MVP | Hva som trengs i produksjon |
|---|---|---|
| Tid | Datoer som properties | Temporal modell for endring over tid |
| Geografi | Bare lat/lon | Geo-spesifikke noder, traséer, polygoner |
| Personer | Bare navn på rolleinnehaver | Person-noder med bemanning over tid |
| RDS | Kun funksjonsaspekt | Funksjon, lokasjon, produkt — alle aspekter |
| CIM-justering | Egendefinerte navn | Justert mot CIM-vokabular der relevant |
| Dokumentversjoner | Property på dokument | Versjon som egen entitet med endringslogg |
| Eksterne aktører | Ikke modellert | NVE, kommuner, grunneiere, kunder |
| Drift | Ikke modellert | Arbeidsordre, feil, tilstand, sensorer |

## Hva som er tatt med selv om det er enkelt

Disse områdene er med fordi de demonstrerer prinsipper som er viktige for vurderingen, selv om implementasjonen er minimal:

- **Endringsinitiativ** — for å vise at strukturelle endringer (som RDS-PP) kan modelleres som egne entiteter
- **Tiltak knyttet til risiko** — for å vise at risikoreduksjon kan spores
- **Beslutninger** — for å vise at modellen kan inkludere governance-historikk

## Hva som åpner seg når dette skaleres

Den virkelige verdien av en kunnskapsgraf kommer når:

1. Den knyttes til **masterdata** for anlegg, slik at den blir den autoritative oversikten over koblinger på tvers
2. Den får **automatisk oppdatering** fra prosjektstyringssystem, dokumentstyringssystem og anleggsregister
3. Den brukes som **integrasjonslag** mellom systemer — i stedet for at hver applikasjon må vite om alle andre, kan de gå via grafen
4. **Domeneeksperter** kan stille spørsmål direkte mot grafen via et naturlig språk-grensesnitt

Punkt 4 er der LLM-er kommer inn — Cypher er enkelt nok til at en god LLM kan generere det fra norske spørsmål, og grafen gir en strukturert kontekst som er mye mer pålitelig enn ren tekstsøk.
