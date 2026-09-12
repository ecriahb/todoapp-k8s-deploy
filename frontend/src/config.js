// Runtime API routes are exposed through the frontend nginx reverse proxy.
// This keeps backend services private inside the AKS cluster.
const config = {
  GET_TASKS_API_BASE_URL: process.env.REACT_APP_GET_TASKS_API_BASE_URL || '/api/incidents/list',
  DELETE_TASK_API_BASE_URL: process.env.REACT_APP_DELETE_TASK_API_BASE_URL || '/api/incidents/resolve',
  CREATE_TASK_API_BASE_URL: process.env.REACT_APP_CREATE_TASK_API_BASE_URL || '/api/incidents/create',
};

export default config;
