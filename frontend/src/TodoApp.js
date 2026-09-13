import React, { useEffect, useMemo, useState } from 'react';
import axios from 'axios';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  Container,
  Divider,
  Grid,
  IconButton,
  MenuItem,
  Stack,
  TextField,
  Typography,
} from '@mui/material';
import {
  AddAlert,
  Analytics,
  CheckCircle,
  CloudQueue,
  Delete,
  FiberManualRecord,
  Refresh,
  Shield,
  Speed,
  Storage,
} from '@mui/icons-material';
import config from './config';

const AI_RCA_API = process.env.REACT_APP_AI_RCA_API_URL || '/ai-rca/analyze';
const GET_API = config.INCIDENT_LIST_API_BASE_URL;
const DELETE_API = config.INCIDENT_RESOLVE_API_BASE_URL;
const CREATE_API = config.INCIDENT_CREATE_API_BASE_URL;

const initialIncident = {
  title: '',
  description: '',
  severity: 'MEDIUM',
  service: 'AKS',
  environment: 'production',
};

function TodoApp() {
  const [incidents, setIncidents] = useState([]);
  const [analysis, setAnalysis] = useState({});
  const [analyzing, setAnalyzing] = useState(null);
  const [incident, setIncident] = useState(initialIncident);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const analyzeIncident = async (item) => {
    setAnalyzing(item.ID);
    try {
      const r = await axios.post(AI_RCA_API, { incident: item });
      setAnalysis((a) => ({ ...a, [item.ID]: r.data }));
    } catch (e) {
      setAnalysis((a) => ({
        ...a,
        [item.ID]: {
          rootCause: 'AI RCA service unavailable.',
          confidence: 0,
          recommendedActions: [
            'Verify the AI RCA service health and API URL.',
            'Collect pod logs and Kubernetes events, then retry.',
          ],
          mode: 'unavailable',
        },
      }));
    } finally {
      setAnalyzing(null);
    }
  };

  const fetchIncidents = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${GET_API}/tasks`);
      setIncidents(response.data);
      setMessage('');
    } catch (error) {
      console.error('Error fetching incidents', error);
      setMessage('Unable to load active incidents.');
    } finally {
      setLoading(false);
    }
  };

  const createIncident = async () => {
    if (!incident.title.trim()) {
      setMessage('Please enter an incident title.');
      return;
    }
    try {
      setLoading(true);
      await axios.post(`${CREATE_API}/tasks`, incident);
      await fetchIncidents();
      setIncident(initialIncident);
      setMessage('Incident created successfully.');
    } catch (error) {
      console.error('Error creating incident', error);
      setMessage('Unable to create the incident.');
    } finally {
      setLoading(false);
    }
  };

  const resolveIncident = async (id) => {
    try {
      await axios.delete(`${DELETE_API}/tasks/${id}`);
      await fetchIncidents();
      setMessage('Incident resolved.');
    } catch (error) {
      console.error('Error resolving incident', error);
      setMessage('Unable to resolve the incident.');
    }
  };

  useEffect(() => {
    fetchIncidents();
  }, []);

  const high = incidents.filter((i) => (i.Severity || i.severity) === 'HIGH').length;
  const critical = incidents.filter((i) => (i.Severity || i.severity) === 'CRITICAL').length;
  const medium = incidents.filter((i) => (i.Severity || i.severity) === 'MEDIUM').length;
  const activeCount = incidents.length;
  const criticalOrHigh = high + critical;

  const healthLabel = useMemo(() => (criticalOrHigh > 0 ? 'ATTENTION' : 'HEALTHY'), [criticalOrHigh]);

  const updateField = (field) => (e) => setIncident((current) => ({ ...current, [field]: e.target.value }));

  return (
    <Box className="cloudops">
      <Container maxWidth="xl" sx={{ py: { xs: 2, md: 4 } }}>
        <Card className="hero-card">
          <CardContent sx={{ p: { xs: 2.5, md: 3.5 }, '&:last-child': { pb: { xs: 2.5, md: 3.5 } } }}>
            <Stack direction={{ xs: 'column', md: 'row' }} justifyContent="space-between" alignItems={{ xs: 'flex-start', md: 'center' }} gap={3}>
              <Stack direction="row" spacing={2} alignItems="center">
                <Box className="brand-mark"><CloudQueue fontSize="large" /></Box>
                <Box>
                  <Typography className="eyebrow">CLOUDOPS • LIVE OPERATIONS</Typography>
                  <Typography variant="h3" className="hero-title">Command Center</Typography>
                  <Typography className="hero-subtitle">AKS production observability · Incident management · AI-assisted RCA</Typography>
                </Box>
              </Stack>
              <Stack direction="row" spacing={1.25} alignItems="center">
                <Chip icon={<FiberManualRecord sx={{ fontSize: '11px !important' }} />} label="LIVE" className="live-chip" />
                <Button className="refresh-button" variant="outlined" startIcon={<Refresh />} onClick={fetchIncidents} disabled={loading}>Refresh</Button>
              </Stack>
            </Stack>
          </CardContent>
        </Card>

        {message && <Alert className="dashboard-alert" severity={message.includes('success') || message === 'Incident resolved.' ? 'success' : 'info'} onClose={() => setMessage('')}>{message}</Alert>}

        <Grid container spacing={2.2} sx={{ mt: 0.4 }}>
          <Grid item xs={12} md={6} lg={3}>
            <Card className="metric-card metric-health"><CardContent>
              <Stack direction="row" justifyContent="space-between"><Box className="metric-icon"><CheckCircle /></Box><Chip label="PRODUCTION" size="small" variant="outlined" /></Stack>
              <Typography className="metric-label">Environment health</Typography>
              <Typography className="metric-value">{healthLabel}</Typography>
              <Typography className="metric-note">AKS cluster · Central India</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={12} md={6} lg={3}>
            <Card className="metric-card metric-danger"><CardContent>
              <Stack direction="row" justifyContent="space-between"><Box className="metric-icon"><Shield /></Box><Typography className="metric-kicker">Needs attention</Typography></Stack>
              <Typography className="metric-label">High / critical</Typography>
              <Typography className="metric-value">{criticalOrHigh}</Typography>
              <Typography className="metric-note">{critical} critical · {high} high</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={12} md={6} lg={3}>
            <Card className="metric-card metric-warning"><CardContent>
              <Stack direction="row" justifyContent="space-between"><Box className="metric-icon"><Speed /></Box><Typography className="metric-kicker">Active queue</Typography></Stack>
              <Typography className="metric-label">Medium severity</Typography>
              <Typography className="metric-value">{medium}</Typography>
              <Typography className="metric-note">Incidents requiring triage</Typography>
            </CardContent></Card>
          </Grid>
          <Grid item xs={12} md={6} lg={3}>
            <Card className="metric-card metric-blue"><CardContent>
              <Stack direction="row" justifyContent="space-between"><Box className="metric-icon"><Storage /></Box><Typography className="metric-kicker">Open now</Typography></Stack>
              <Typography className="metric-label">Active incidents</Typography>
              <Typography className="metric-value">{activeCount}</Typography>
              <Typography className="metric-note">Across all monitored services</Typography>
            </CardContent></Card>
          </Grid>
        </Grid>

        <Grid container spacing={2.2} sx={{ mt: 0.2 }}>
          <Grid item xs={12}>
            <Card className="create-card">
              <CardContent sx={{ p: { xs: 2.5, md: 3.5 }, '&:last-child': { pb: { xs: 2.5, md: 3.5 } } }}>
                <Stack direction={{ xs: 'column', md: 'row' }} justifyContent="space-between" gap={2} mb={2.5}>
                  <Box>
                    <Stack direction="row" spacing={1.2} alignItems="center"><Box className="section-icon"><AddAlert /></Box><Typography variant="h5" className="section-title">Create incident</Typography></Stack>
                    <Typography className="section-subtitle">Capture the signal, scope and symptoms so responders can move faster.</Typography>
                  </Box>
                  <Chip label="Incident intake" className="soft-chip" />
                </Stack>
                <Divider sx={{ mb: 2.5, borderColor: 'rgba(255,255,255,0.08)' }} />
                <Grid container spacing={2}>
                  <Grid item xs={12} md={6}><TextField fullWidth label="Incident title" placeholder="e.g. API latency spike in production" value={incident.title} onChange={updateField('title')} /></Grid>
                  <Grid item xs={12} sm={4} md={2}><TextField select fullWidth label="Severity" value={incident.severity} onChange={updateField('severity')}>{['LOW','MEDIUM','HIGH','CRITICAL'].map((v) => <MenuItem key={v} value={v}>{v}</MenuItem>)}</TextField></Grid>
                  <Grid item xs={12} sm={4} md={2}><TextField select fullWidth label="Service" value={incident.service} onChange={updateField('service')}>{['AKS','API','Frontend','Database','Ingress'].map((v) => <MenuItem key={v} value={v}>{v}</MenuItem>)}</TextField></Grid>
                  <Grid item xs={12} sm={4} md={2}><TextField select fullWidth label="Environment" value={incident.environment} onChange={updateField('environment')}>{['production','staging','development'].map((v) => <MenuItem key={v} value={v}>{v}</MenuItem>)}</TextField></Grid>
                  <Grid item xs={12}><TextField fullWidth multiline minRows={4} label="Description / symptoms" placeholder="What changed? What are users or workloads experiencing?" value={incident.description} onChange={updateField('description')} /></Grid>
                  <Grid item xs={12}><Button className="primary-action" variant="contained" size="large" startIcon={<AddAlert />} onClick={createIncident} disabled={loading}>{loading ? 'Creating…' : 'Create Incident'}</Button></Grid>
                </Grid>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        <Stack direction="row" justifyContent="space-between" alignItems="end" sx={{ mt: 4, mb: 1.5 }}>
          <Box><Typography className="section-title" variant="h5">Active incidents</Typography><Typography className="section-subtitle">Prioritized workload for the operations team.</Typography></Box>
          <Chip label={`${activeCount} open`} className="count-chip" />
        </Stack>

        {incidents.length === 0 && <Card className="empty-card"><CardContent><Typography variant="h6">No active incidents</Typography><Typography className="section-subtitle">Your production queue is clear. Nice work.</Typography></CardContent></Card>}

        <Stack spacing={1.5}>
          {incidents.map((item) => {
            const severity = item.Severity || item.severity || 'MEDIUM';
            const service = item.Service || item.service || 'AKS';
            const environment = item.Environment || item.environment || 'production';
            const result = analysis[item.ID];
            return (
              <Card key={item.ID} className="incident-card">
                <CardContent sx={{ p: { xs: 2.2, md: 2.6 }, '&:last-child': { pb: { xs: 2.2, md: 2.6 } } }}>
                  <Stack direction={{ xs: 'column', lg: 'row' }} justifyContent="space-between" gap={2}>
                    <Stack spacing={1.1} flex={1}>
                      <Stack direction="row" spacing={1} alignItems="center" flexWrap="wrap"><Chip label={severity} size="small" className={`severity ${severity.toLowerCase()}`} /><Chip label={service} size="small" className="service-chip" /><Chip label={environment} size="small" className="env-chip" variant="outlined" /></Stack>
                      <Typography variant="h6" className="incident-title">{item.Title || item.title}</Typography>
                      <Typography className="incident-description">{item.Description || item.description || 'No symptom description provided.'}</Typography>
                    </Stack>
                    <Stack direction="row" spacing={1} alignItems="center" justifyContent="flex-end"><Button className="ai-button" size="small" startIcon={<Analytics />} onClick={() => analyzeIncident(item)} disabled={analyzing === item.ID}>{analyzing === item.ID ? 'Analyzing…' : 'Analyze with AI'}</Button><IconButton className="resolve-button" onClick={() => resolveIncident(item.ID)} title="Resolve incident"><Delete /></IconButton></Stack>
                  </Stack>
                  {result && <Box className="rca-panel">
                    <Stack direction={{ xs: 'column', md: 'row' }} justifyContent="space-between" gap={1}><Typography className="rca-heading">AI RCA result</Typography>{result.confidence !== undefined && <Chip label={`${result.confidence}% confidence`} size="small" className="confidence-chip" />}</Stack>
                    <Typography sx={{ mt: 1.2 }}><b>Root cause:</b> {result.rootCause}</Typography>
                    {result.recommendedActions?.length > 0 && <><Typography sx={{ mt: 1.2 }}><b>Recommended actions</b></Typography><Box component="ul" sx={{ mt: 0.4, mb: 0, pl: 2.5 }}>{result.recommendedActions.map((x, i) => <li key={i}>{x}</li>)}</Box></>}
                    {result.evidence?.kubernetes?.events?.length > 0 && <Typography variant="body2" sx={{ mt: 1 }}><b>Kubernetes evidence:</b> {result.evidence.kubernetes.events.length} event(s) collected.</Typography>}
                    <Typography variant="caption" sx={{ display: 'block', mt: 1.2, opacity: .65 }}>Mode: {result.mode || 'read-only'}</Typography>
                  </Box>}
                </CardContent>
              </Card>
            );
          })}
        </Stack>
      </Container>
    </Box>
  );
}

export default TodoApp;
