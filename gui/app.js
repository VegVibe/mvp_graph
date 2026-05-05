// =============================================================
// app.js
// Kobler til Neo4j via JavaScript-driver, kjører spørringer,
// og viser resultatene som graf eller tabell.
//
// Konfigurering: Bruk URL-parametre for å overstyre Neo4j-innstillinger:
//   ?neo4j_uri=bolt://example.com:7687&neo4j_user=neo4j&neo4j_password=passord
// =============================================================

// Hent konfigurering fra URL-parametre, localStorage, eller bruk defaults
function getConfig(key, defaultValue) {
  const params = new URLSearchParams(window.location.search);
  const urlValue = params.get(key);
  if (urlValue) {
    localStorage.setItem(key, urlValue);
    return urlValue;
  }
  const stored = localStorage.getItem(key);
  if (stored) return stored;
  return defaultValue;
}

const NEO4J_URI = getConfig("neo4j_uri", "bolt://localhost:7687");
const NEO4J_USER = getConfig("neo4j_user", "neo4j");
const NEO4J_PASSWORD = getConfig("neo4j_password", "mvp-passord-123");

// Fargepalett per node-type
const COLORS = {
  StrategiskMål: "#9c27b0",
  Styringsparameter: "#ce93d8",
  Portefølje: "#673ab7",
  Beslutning: "#9575cd",
  Prosjekt: "#1976d2",
  Delprosjekt: "#42a5f5",
  Arbeidspakke: "#90caf9",
  Leveranse: "#26a69a",
  Milepæl: "#26c6da",
  Stasjon: "#388e3c",
  Ledning: "#66bb6a",
  Felt: "#81c784",
  Komponent: "#a5d6a7",
  Transformator: "#a5d6a7",
  Bryter: "#a5d6a7",
  Vern: "#a5d6a7",
  Kontrollanlegg: "#c5e1a5",
  RDSReferanse: "#ffb74d",
  Krav: "#f06292",
  Dokument: "#ffd54f",
  Risiko: "#e53935",
  Tiltak: "#ef9a9a",
  Endringsinitiativ: "#ff8a65",
  Organisasjonsenhet: "#5d4037",
  Rolle: "#8d6e63",
  Kommune: "#bdbdbd",
  PrisOmråde: "#bdbdbd"
};

let driver = null;
let network = null;
let currentQuestion = null;
let currentNodes = new Map();
let currentEdges = [];

// -------------------- Tilkobling --------------------

async function connect() {
  try {
    driver = neo4j.driver(NEO4J_URI, neo4j.auth.basic(NEO4J_USER, NEO4J_PASSWORD));
    await driver.verifyConnectivity();
    setStatus("ok", "Tilkoblet Neo4j");
    return true;
  } catch (err) {
    setStatus("err", "Ikke tilkoblet — sjekk at Neo4j kjører");
    console.error(err);
    return false;
  }
}

function setStatus(state, text) {
  const dot = document.getElementById("status-dot");
  const txt = document.getElementById("status-text");
  dot.classList.remove("ok", "err");
  if (state === "ok") dot.classList.add("ok");
  if (state === "err") dot.classList.add("err");
  txt.textContent = text;
}

// -------------------- Spørringer --------------------

async function runQuery(cypher) {
  const session = driver.session();
  try {
    const result = await session.run(cypher);
    return result;
  } finally {
    await session.close();
  }
}

// -------------------- Graf-visualisering --------------------

function nodeColor(labels) {
  for (const lbl of labels) {
    if (COLORS[lbl]) return COLORS[lbl];
  }
  return "#9e9e9e";
}

function nodeLabel(labels, props) {
  const primary = labels[0];
  const navn = props.navn || props.referanse || props.id || "?";
  return navn.length > 30 ? navn.slice(0, 28) + "…" : navn;
}

function processGraphResult(result) {
  currentNodes = new Map();
  currentEdges = [];

  for (const record of result.records) {
    for (const key of record.keys) {
      const value = record.get(key);
      if (!value) continue;
      collectGraphElements(value);
    }
  }

  return {
    nodes: Array.from(currentNodes.values()),
    edges: currentEdges
  };
}

function collectGraphElements(value) {
  if (Array.isArray(value)) {
    value.forEach(collectGraphElements);
    return;
  }
  if (!value || typeof value !== "object") return;

  // Path-objekt fra Neo4j
  if (value.segments) {
    if (value.start) addNode(value.start);
    for (const seg of value.segments) {
      addNode(seg.start);
      addNode(seg.end);
      addEdge(seg.relationship);
    }
    return;
  }

  // Node
  if (value.labels && value.identity !== undefined) {
    addNode(value);
    return;
  }

  // Relasjon
  if (value.type && value.start !== undefined && value.end !== undefined) {
    addEdge(value);
    return;
  }
}

function addNode(node) {
  const id = node.identity.toString();
  if (currentNodes.has(id)) return;

  const props = {};
  for (const [k, v] of Object.entries(node.properties)) {
    props[k] = serializeValue(v);
  }

  currentNodes.set(id, {
    id: id,
    label: nodeLabel(node.labels, props),
    title: `${node.labels.join(":")}\n${props.navn || props.referanse || ""}`,
    color: { background: nodeColor(node.labels), border: "#1a2332" },
    font: { color: "#fff", size: 12 },
    shape: "dot",
    size: 20,
    _labels: node.labels,
    _props: props
  });
}

function addEdge(rel) {
  currentEdges.push({
    from: rel.start.toString(),
    to: rel.end.toString(),
    label: rel.type,
    arrows: "to",
    font: { size: 10, color: "#666", align: "middle" },
    color: { color: "#999" },
    smooth: { type: "dynamic" }
  });
}

function serializeValue(v) {
  if (v === null || v === undefined) return null;
  if (neo4j.isInt(v)) return v.toNumber();
  if (neo4j.isDate(v) || neo4j.isDateTime(v) || neo4j.isLocalDateTime(v)) return v.toString();
  if (typeof v === "object" && v.year !== undefined) return v.toString();
  return v;
}

function renderGraph(graphData) {
  showView("graph");
  const container = document.getElementById("graph");
  const data = {
    nodes: new vis.DataSet(graphData.nodes),
    edges: new vis.DataSet(graphData.edges)
  };
  const options = {
    physics: {
      enabled: true,
      barnesHut: { gravitationalConstant: -8000, springLength: 140 },
      stabilization: { iterations: 200 }
    },
    interaction: { hover: true }
  };
  if (network) network.destroy();
  network = new vis.Network(container, data, options);

  network.on("click", (params) => {
    if (params.nodes.length > 0) {
      showNodeDetail(params.nodes[0]);
    } else {
      hideDetail();
    }
  });
}

function showNodeDetail(nodeId) {
  const node = currentNodes.get(nodeId);
  if (!node) return;

  const panel = document.getElementById("detail-panel");
  const title = document.getElementById("detail-title");
  const body = document.getElementById("detail-body");

  title.textContent = node._props.navn || node._props.referanse || node._props.id || "Detaljer";

  let html = `<div class="type-badge">${node._labels.join(" · ")}</div>`;
  for (const [k, v] of Object.entries(node._props)) {
    if (v === null || v === undefined || v === "") continue;
    html += `<div class="label">${escapeHtml(k)}</div>`;
    html += `<div class="value">${escapeHtml(String(v))}</div>`;
  }
  body.innerHTML = html;
  panel.classList.add("visible");
}

function hideDetail() {
  document.getElementById("detail-panel").classList.remove("visible");
}

function escapeHtml(s) {
  return s.replace(/[&<>"']/g, (c) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
  }[c]));
}

// -------------------- Tabell-visualisering --------------------

function renderTable(result) {
  showView("table");
  const container = document.getElementById("table-view");

  if (result.records.length === 0) {
    container.innerHTML = '<div class="empty-state"><h3>Ingen resultater</h3><p>Spørringen kjørte, men ga ingen rader.</p></div>';
    return;
  }

  const keys = result.records[0].keys;
  let html = "<table><thead><tr>";
  for (const k of keys) html += `<th>${escapeHtml(k)}</th>`;
  html += "</tr></thead><tbody>";

  for (const record of result.records) {
    html += "<tr>";
    for (const k of keys) {
      const v = record.get(k);
      html += `<td><pre>${escapeHtml(formatCellValue(v))}</pre></td>`;
    }
    html += "</tr>";
  }
  html += "</tbody></table>";
  container.innerHTML = html;
}

function formatCellValue(v) {
  if (v === null || v === undefined) return "";
  if (Array.isArray(v)) return v.map(formatCellValue).filter(x => x).join("\n");
  if (neo4j.isInt(v)) return v.toNumber().toLocaleString("no-NO");
  if (typeof v === "object" && v.year !== undefined) return v.toString();
  if (typeof v === "object" && v.properties) {
    return Object.entries(v.properties).map(([k, val]) => `${k}: ${formatCellValue(val)}`).join("\n");
  }
  if (typeof v === "object") return JSON.stringify(v, null, 2);
  return String(v);
}

// -------------------- View-styring --------------------

function showView(view) {
  document.getElementById("graph").style.display = view === "graph" ? "block" : "none";
  document.getElementById("table-view").style.display = view === "table" ? "block" : "none";
  document.getElementById("cypher-view").style.display = view === "cypher" ? "flex" : "none";
  document.getElementById("empty").style.display = view === "empty" ? "flex" : "none";

  document.getElementById("btn-graph").classList.toggle("active", view === "graph");
  document.getElementById("btn-table").classList.toggle("active", view === "table");

  if (view !== "graph") hideDetail();
}

// -------------------- Spørsmålsmeny --------------------

function buildQuestionList() {
  const container = document.getElementById("question-list");
  let html = "";
  for (const group of QUESTIONS) {
    html += `<div class="question-group" data-group="${escapeHtml(group.group)}"><div class="group-title">${escapeHtml(group.group)}</div>`;
    for (const q of group.items) {
      html += `<div class="question" data-question-id="${q.id}" data-search-text="${escapeHtml((q.title + ' ' + q.desc + ' ' + group.group).toLowerCase())}">
        <span class="q-title">${escapeHtml(q.title)}</span>
        <div class="desc">${escapeHtml(q.desc)}</div>
      </div>`;
    }
    html += "</div>";
  }
  container.innerHTML = html;

  container.querySelectorAll(".question").forEach((el) => {
    el.addEventListener("click", () => selectQuestion(el.dataset.questionId));
  });
}

// -------------------- Søk --------------------

function setupSearch() {
  const input = document.getElementById("search-input");
  const clearBtn = document.getElementById("search-clear");
  const hint = document.getElementById("search-hint");
  const staticActions = document.getElementById("static-actions");

  input.addEventListener("input", (e) => {
    const term = e.target.value.trim().toLowerCase();
    clearBtn.classList.toggle("visible", term.length > 0);
    filterQuestions(term);

    // Skjul "Annet"-seksjonen mens man søker, for å redusere støy
    staticActions.style.display = term.length > 0 ? "none" : "block";
    hint.style.display = term.length > 0 ? "none" : "block";
  });

  // Tøm-knapp
  clearBtn.addEventListener("click", () => {
    input.value = "";
    input.dispatchEvent(new Event("input"));
    input.focus();
  });

  // Tastatursnarveier
  document.addEventListener("keydown", (e) => {
    // Cmd/Ctrl+K eller bare "/" fokuserer søkefeltet
    if ((e.metaKey || e.ctrlKey) && e.key === "k") {
      e.preventDefault();
      input.focus();
      input.select();
    } else if (e.key === "/" && document.activeElement !== input && document.activeElement.tagName !== "TEXTAREA") {
      e.preventDefault();
      input.focus();
    } else if (e.key === "Escape" && document.activeElement === input) {
      input.value = "";
      input.dispatchEvent(new Event("input"));
      input.blur();
    }
  });

  // Hint om snarveier
  hint.innerHTML = 'Prøv "risiko", "trolla", "krav" eller "milepæl" — eller trykk <kbd style="background:#eee;padding:1px 4px;border-radius:3px;font-size:10px;">/</kbd>';
}

function filterQuestions(term) {
  const list = document.getElementById("question-list");

  // Fjern eventuell "ingen treff"-melding fra forrige søk
  const existing = list.querySelector(".no-results");
  if (existing) existing.remove();

  if (!term) {
    // Vis alt og fjern highlights
    list.querySelectorAll(".question").forEach(q => {
      q.classList.remove("hidden");
      const titleEl = q.querySelector(".q-title");
      if (titleEl) titleEl.textContent = titleEl.textContent; // reset highlight
      restoreOriginalText(q);
    });
    list.querySelectorAll(".question-group").forEach(g => g.classList.remove("hidden"));
    return;
  }

  let totalMatches = 0;

  list.querySelectorAll(".question-group").forEach(group => {
    let groupMatches = 0;

    group.querySelectorAll(".question").forEach(q => {
      const searchText = q.dataset.searchText || "";
      const matches = searchText.includes(term);

      q.classList.toggle("hidden", !matches);

      if (matches) {
        groupMatches++;
        totalMatches++;
        highlightMatch(q, term);
      } else {
        restoreOriginalText(q);
      }
    });

    // Skjul hele gruppen hvis ingen treff i den
    group.classList.toggle("hidden", groupMatches === 0);
  });

  if (totalMatches === 0) {
    const msg = document.createElement("div");
    msg.className = "no-results";
    msg.textContent = `Ingen spørsmål matcher "${term}"`;
    list.appendChild(msg);
  }
}

function highlightMatch(questionEl, term) {
  const titleEl = questionEl.querySelector(".q-title");
  const descEl = questionEl.querySelector(".desc");
  if (!titleEl || !descEl) return;

  // Lagre original tekst hvis ikke allerede gjort
  if (!questionEl._originalTitle) {
    questionEl._originalTitle = titleEl.textContent;
    questionEl._originalDesc = descEl.textContent;
  }

  titleEl.innerHTML = highlightText(questionEl._originalTitle, term);
  descEl.innerHTML = highlightText(questionEl._originalDesc, term);
}

function restoreOriginalText(questionEl) {
  if (!questionEl._originalTitle) return;
  const titleEl = questionEl.querySelector(".q-title");
  const descEl = questionEl.querySelector(".desc");
  if (titleEl) titleEl.textContent = questionEl._originalTitle;
  if (descEl) descEl.textContent = questionEl._originalDesc;
}

function highlightText(text, term) {
  if (!term) return escapeHtml(text);
  const lower = text.toLowerCase();
  const idx = lower.indexOf(term);
  if (idx === -1) return escapeHtml(text);

  const before = text.slice(0, idx);
  const match = text.slice(idx, idx + term.length);
  const after = text.slice(idx + term.length);

  return escapeHtml(before) + "<mark>" + escapeHtml(match) + "</mark>" + escapeHtml(after);
}

function findQuestion(id) {
  for (const group of QUESTIONS) {
    for (const q of group.items) {
      if (q.id === id) return q;
    }
  }
  return null;
}

async function selectQuestion(id) {
  const q = findQuestion(id);
  if (!q) return;

  document.querySelectorAll(".question").forEach(el => el.classList.remove("active"));
  document.querySelector(`[data-question-id="${id}"]`)?.classList.add("active");

  document.getElementById("current-title").textContent = q.title;
  currentQuestion = q;

  try {
    const result = await runQuery(q.cypher);
    if (q.view === "graph") {
      const graphData = processGraphResult(result);
      if (graphData.nodes.length === 0) {
        document.getElementById("table-view").innerHTML = '<div class="empty-state"><h3>Ingen graf-data</h3><p>Spørringen returnerte ikke noder eller paths.</p></div>';
        showView("table");
      } else {
        renderGraph(graphData);
      }
    } else {
      renderTable(result);
    }
  } catch (err) {
    console.error(err);
    document.getElementById("table-view").innerHTML = `<div class="error">Feil: ${escapeHtml(err.message)}</div>`;
    showView("table");
  }
}

// -------------------- Custom Cypher --------------------

async function runCustomCypher() {
  const input = document.getElementById("cypher-input").value.trim();
  if (!input) return;
  const resultEl = document.getElementById("cypher-result");
  resultEl.innerHTML = "Kjører...";
  try {
    const result = await runQuery(input);

    // Prøv graf først, fall tilbake til tabell
    const graphData = processGraphResult(result);
    if (graphData.nodes.length > 0) {
      // Vis i hovedvisningen
      document.getElementById("current-title").textContent = "Egen Cypher-spørring";
      renderGraph(graphData);
      resultEl.innerHTML = `<p style="color: #666;">Resultat vist som graf (${graphData.nodes.length} noder, ${graphData.edges.length} relasjoner). Klikk "Tabell" øverst for å se rådata.</p>`;
    } else {
      document.getElementById("current-title").textContent = "Egen Cypher-spørring";
      renderTable(result);
      resultEl.innerHTML = `<p style="color: #666;">Resultat vist som tabell (${result.records.length} rader).</p>`;
    }
  } catch (err) {
    resultEl.innerHTML = `<div class="error">Feil: ${escapeHtml(err.message)}</div>`;
  }
}

// -------------------- Init --------------------

document.addEventListener("DOMContentLoaded", async () => {
  buildQuestionList();
  setupSearch();
  showView("empty");

  document.getElementById("btn-graph").addEventListener("click", () => {
    if (currentNodes.size > 0) showView("graph");
  });
  document.getElementById("btn-table").addEventListener("click", () => {
    if (currentQuestion) {
      runQuery(currentQuestion.cypher).then(renderTable);
    }
  });
  document.getElementById("detail-close").addEventListener("click", hideDetail);

  document.querySelectorAll('[data-action]').forEach(el => {
    el.addEventListener('click', () => {
      const action = el.dataset.action;
      if (action === 'cypher') {
        document.querySelectorAll(".question").forEach(q => q.classList.remove("active"));
        el.classList.add("active");
        document.getElementById("current-title").textContent = "Egen Cypher-spørring";
        showView("cypher");
      } else if (action === 'overview') {
        selectQuestionDirect("Hele grafen", "MATCH path = (n)-[r]->(m) RETURN path LIMIT 200", "graph");
      }
    });
  });

  document.getElementById("run-cypher").addEventListener("click", runCustomCypher);

  await connect();
});

async function selectQuestionDirect(title, cypher, view) {
  document.querySelectorAll(".question").forEach(q => q.classList.remove("active"));
  document.getElementById("current-title").textContent = title;
  try {
    const result = await runQuery(cypher);
    if (view === "graph") {
      renderGraph(processGraphResult(result));
    } else {
      renderTable(result);
    }
  } catch (err) {
    console.error(err);
  }
}
