// Runtime API routes are exposed through the frontend nginx reverse proxy.
// This keeps backend services private inside the AKS cluster.
const config = {
  INCIDENT_LIST_API_BASE_URL: process.env.REACT_APP_INCIDENT_LIST_API_BASE_URL || '/api/incidents/list',
  INCIDENT_RESOLVE_API_BASE_URL: process.env.REACT_APP_INCIDENT_RESOLVE_API_BASE_URL || '/api/incidents/resolve',
  INCIDENT_CREATE_API_BASE_URL: process.env.REACT_APP_INCIDENT_CREATE_API_BASE_URL || '/api/incidents/create',
};

export default config;
