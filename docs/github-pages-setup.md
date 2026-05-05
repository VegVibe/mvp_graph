# GitHub Pages Deployment Guide

Denne guide forklarer hvordan du deployer Statnett Kunnskapsgraf GUI-en til GitHub Pages.

## Automatisk Deployment

Når du pusher endringer til `main`- eller `master`-branchen, kjører GitHub Actions automatisk og deployer GUI-filene til GitHub Pages.

### Krav

1. **GitHub-konto** med et offentlig (eller privat med Pages aktivert) repository
2. **Git** installert lokalt
3. **Neo4j-instans** som er tilgjengelig på internett (eller lokalt for testing)

### Oppsett

#### 1. Aktiver GitHub Pages i repoet ditt

1. Gå til repository-innstillinger: **Settings** → **Pages**
2. Under "Build and deployment", velg **Source**: `Deploy from a branch`
3. Velg branch: `gh-pages` og mappe: `/ (root)`
4. Klikk "Save"

GitHub Actions vil automatisk opprette `gh-pages`-branchen første gang workflowet kjører.

#### 2. Konfigurer Neo4j-forbindelsen

GUI-en trenger forbindelsesdetaljer til en Neo4j-instans. Du har flere alternativer:

**Alternativ A: URL-parametre (enklest for testing)**

Legg til parametre i URL-en når du besøker GitHub Pages-siden:

```
https://brukernavn.github.io/statnett-kg-mvp/
?neo4j_uri=bolt://your-neo4j-server.com:7687
&neo4j_user=neo4j
&neo4j_password=your-password
```

Browser-cache lagrer disse verdiene i `localStorage`, så du trenger bare å gjøre det én gang.

**Alternativ B: Environment-variabler (for produksjon)**

For å unngå å eksponere passord i URL-en:

1. Opprett en GitHub Secret: **Settings** → **Secrets and variables** → **Actions** → **New repository secret**
2. Opprett `NEO4J_URI`, `NEO4J_USER`, `NEO4J_PASSWORD`
3. Modifiser `.github/workflows/deploy.yml` (se eksempel nedenfor)

**Eksempel på oppdatert workflow med secrets:**

Opprett en `gui/config.js`-fil:

```javascript
// gui/config.js
window.NEO4J_CONFIG = {
  uri: localStorage.getItem('neo4j_uri') || '{{ NEO4J_URI }}',
  user: localStorage.getItem('neo4j_user') || '{{ NEO4J_USER }}',
  password: localStorage.getItem('neo4j_password') || '{{ NEO4J_PASSWORD }}'
};
```

Oppdater `index.html` for å inkludere denne før `app.js`:

```html
<script src="config.js"></script>
<script src="app.js"></script>
```

Oppdater `.github/workflows/deploy.yml`:

```yaml
      - name: Substitute environment variables in config
        run: |
          sed -i "s|{{ NEO4J_URI }}|${{ secrets.NEO4J_URI }}|g" gui/config.js
          sed -i "s|{{ NEO4J_USER }}|${{ secrets.NEO4J_USER }}|g" gui/config.js
          sed -i "s|{{ NEO4J_PASSWORD }}|${{ secrets.NEO4J_PASSWORD }}|g" gui/config.js
```

Oppdater `gui/app.js` for å bruke `window.NEO4J_CONFIG`:

```javascript
const NEO4J_URI = window.NEO4J_CONFIG?.uri || getConfig("neo4j_uri", "bolt://localhost:7687");
const NEO4J_USER = window.NEO4J_CONFIG?.user || getConfig("neo4j_user", "neo4j");
const NEO4J_PASSWORD = window.NEO4J_CONFIG?.password || getConfig("neo4j_password", "mvp-passord-123");
```

---

## Håndbok for brukere

### Første gang du besøker GUI-en

1. **Lagre Neo4j-forbindelsen**

   Hvis du har en Neo4j-server tilgjengelig, besøk:
   ```
   https://brukernavn.github.io/statnett-kg-mvp/?neo4j_uri=bolt://your-server:7687&neo4j_user=neo4j&neo4j_password=passord
   ```

   Browser-appen lagrer disse verdiene lokalt.

2. **Kjør spørringene**

   Klikk på spørsmålene i menyen. Hvis tilkoblingen er OK, vil resultatene vises som en interaktiv graf.

### Feiltips

| Problem | Løsning |
|---------|--------|
| "Ikke tilkoblet" | Sjekk at Neo4j-serveren kjører og er tilgjengelig fra ditt nettverk. Bekreft URI, brukernavn og passord. |
| CORS-feil | Neo4j må tillate forespørsler fra GitHub Pages-domenet. Sjekk Neo4j `bolt.listen_address` og firewall-innstillinger. |
| Resultatene er tomme | Sjekk at data er lastet inn i Neo4j (`load-all.sh` eller manuell import). |

---

## Testing lokalt

1. Start Neo4j og last inn data (se `README.md`)
2. Start GUI lokalt:
   ```bash
   ./start-gui.sh
   ```
3. Åpne <http://localhost:8080>
4. Gjør endringer og test

---

## Continuous Deployment-arbeidsflyt

1. **Utvikle lokalt** → Test med `./start-gui.sh`
2. **Git commit og push** til `main` eller `master`
3. **GitHub Actions kjører** `.github/workflows/deploy.yml`
4. **GUI deployed til GitHub Pages** automatisk

Sjekk **Actions**-fanen i ditt GitHub-repository for status.

---

## Avansert

### Egendefinert domene

Hvis du ønsker å serve GUI-en på ditt eget domene:

1. I **Settings** → **Pages**, under "Custom domain", skriv inn ditt domene
2. Konfigurer DNS-records (se GitHub Pages dokumentasjon)
3. GitHub deployer automatisk med HTTPS

### Build-trinn (hvis du legger til kompleksitet senere)

Hvis du senere legger til f.eks. TypeScript, bundlers eller build-trinn:

1. Legg til build-kommando i workflow:
   ```yaml
   - name: Build GUI
     run: npm run build
   ```
2. Endre `path: 'gui/'` til `path: 'dist/'` eller der build-outputen genereres

---

## Lenker

- [GitHub Pages dokumentasjon](https://docs.github.com/en/pages)
- [GitHub Actions dokumentasjon](https://docs.github.com/en/actions)
- [Neo4j JavaScript Driver](https://neo4j.com/docs/javascript-manual/current/)
