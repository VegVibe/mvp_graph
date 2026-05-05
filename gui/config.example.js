// gui/config.example.js
// 
// Kopier denne filen til config.js og fyll inn dine Neo4j-detaljer.
// Eller bruk URL-parametre direkte:
//   ?neo4j_uri=bolt://example.com:7687&neo4j_user=neo4j&neo4j_password=passord
//

window.NEO4J_CONFIG = {
  // URI til Neo4j-serveren
  // Lokalt: bolt://localhost:7687
  // Ekstern: bolt://your-server.example.com:7687
  uri: 'bolt://localhost:7687',
  
  // Brukernavn
  user: 'neo4j',
  
  // Passord
  password: 'mvp-passord-123'
};
