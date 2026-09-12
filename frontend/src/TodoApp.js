import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Button, TextField, Container, Typography, Grid, Card, CardContent, IconButton, Box, MenuItem, Chip, Divider, Alert } from '@mui/material';
import { Delete, Refresh, Analytics, AddAlert } from '@mui/icons-material';
import config from './config';

const AI_RCA_API = process.env.REACT_APP_AI_RCA_API_URL || '/ai-rca/analyze';
const GET_API = config.GET_TASKS_API_BASE_URL;
const DELETE_API = config.DELETE_TASK_API_BASE_URL;
const CREATE_API = config.CREATE_TASK_API_BASE_URL;

function TodoApp() {
  const [incidents, setIncidents] = useState([]);
  const [analysis, setAnalysis] = useState({});
  const [analyzing, setAnalyzing] = useState(null);
  const [incident, setIncident] = useState({ title:'', description:'', severity:'MEDIUM', service:'AKS', environment:'production' });

  const analyzeIncident = async (item) => {
    setAnalyzing(item.ID);
    try {
      if (!AI_RCA_API) throw new Error('AI RCA URL is not configured');
      const r = await axios.post(AI_RCA_API, { incident:item });
      setAnalysis(a => ({...a, [item.ID]:r.data}));
    } catch (e) {
      setAnalysis(a => ({...a, [item.ID]:{rootCause:'AI RCA service unavailable.', confidence:0, recommendedActions:['Verify REACT_APP_AI_RCA_API_URL and AI RCA service health.','Collect pod logs and Kubernetes events, then retry.'], mode:'unavailable'}}));
    } finally { setAnalyzing(null); }
  };

  const fetchIncidents = async () => {
    try { const response=await axios.get(`${GET_API}/tasks`); setIncidents(response.data); }
    catch (error) { console.error('Error fetching incidents',error); }
  };
  const createIncident = async () => {
    if (!incident.title.trim()) return;
    try { await axios.post(`${CREATE_API}/tasks`,incident); await fetchIncidents(); setIncident({title:'',description:'',severity:'MEDIUM',service:'AKS',environment:'production'}); }
    catch (error) { console.error('Error creating incident',error); }
  };
  const resolveIncident = async (id) => {
    try { await axios.delete(`${DELETE_API}/tasks/${id}`); fetchIncidents(); }
    catch (error) { console.error('Error resolving incident',error); }
  };
  useEffect(()=>{fetchIncidents();},[]);
  const high=incidents.filter(i=>(i.Severity||i.severity)==='HIGH').length;
  const medium=incidents.filter(i=>(i.Severity||i.severity)==='MEDIUM').length;

  return <Box className="cloudops"><Container maxWidth="lg" sx={{py:4}}>
    <Box className="hero"><Box><Typography variant="h3" fontWeight={800}>☁️ CloudOps Command Center</Typography><Typography variant="subtitle1">AKS Production • Incident Management • AI-assisted RCA</Typography></Box><Button variant="outlined" startIcon={<Refresh/>} onClick={fetchIncidents}>Refresh</Button></Box>
    <Grid container spacing={2} sx={{my:2}}>
      <Grid item xs={12} sm={4}><Card className="stat"><CardContent><Typography>🟢 Environment</Typography><Typography variant="h5">HEALTHY</Typography><Typography variant="body2">Production / AKS</Typography></CardContent></Card></Grid>
      <Grid item xs={12} sm={4}><Card className="stat"><CardContent><Typography>🔴 High Severity</Typography><Typography variant="h5">{high}</Typography><Typography variant="body2">Requires attention</Typography></CardContent></Card></Grid>
      <Grid item xs={12} sm={4}><Card className="stat"><CardContent><Typography>🟡 Medium Severity</Typography><Typography variant="h5">{medium}</Typography><Typography variant="body2">Active incidents</Typography></CardContent></Card></Grid>
    </Grid>
    <Card className="panel"><CardContent><Typography variant="h5" fontWeight={700} gutterBottom><AddAlert/> Create Incident</Typography>
      <Grid container spacing={2}>
        <Grid item xs={12} md={6}><TextField fullWidth label="Incident title" value={incident.title} onChange={e=>setIncident({...incident,title:e.target.value})}/></Grid>
        <Grid item xs={12} md={2}><TextField select fullWidth label="Severity" value={incident.severity} onChange={e=>setIncident({...incident,severity:e.target.value})}>{['LOW','MEDIUM','HIGH','CRITICAL'].map(v=><MenuItem key={v} value={v}>{v}</MenuItem>)}</TextField></Grid>
        <Grid item xs={12} md={2}><TextField select fullWidth label="Service" value={incident.service} onChange={e=>setIncident({...incident,service:e.target.value})}>{['AKS','API','Frontend','Database','Ingress'].map(v=><MenuItem key={v} value={v}>{v}</MenuItem>)}</TextField></Grid>
        <Grid item xs={12} md={2}><TextField select fullWidth label="Environment" value={incident.environment} onChange={e=>setIncident({...incident,environment:e.target.value})}>{['production','staging','development'].map(v=><MenuItem key={v} value={v}>{v}</MenuItem>)}</TextField></Grid>
        <Grid item xs={12}><TextField fullWidth multiline rows={3} label="Description / symptoms" value={incident.description} onChange={e=>setIncident({...incident,description:e.target.value})}/></Grid>
        <Grid item xs={12}><Button variant="contained" size="large" startIcon={<AddAlert/>} onClick={createIncident}>Create Incident</Button></Grid>
      </Grid></CardContent></Card>
    <Box sx={{mt:4,mb:2}}><Typography variant="h5" fontWeight={700}>Active Incidents</Typography></Box>
    {incidents.length===0 && <Card className="panel"><CardContent><Typography>No active incidents. 🎉</Typography></CardContent></Card>}
    {incidents.map(item=>{const severity=item.Severity||item.severity||'MEDIUM'; const service=item.Service||item.service||'AKS'; const environment=item.Environment||item.environment||'production'; const result=analysis[item.ID]; return <Card key={item.ID} className="incident"><CardContent>
      <Box display="flex" justifyContent="space-between" gap={2} alignItems="flex-start"><Box flex={1}><Typography variant="h6" fontWeight={700}>{item.Title||item.title}</Typography><Typography variant="body2" sx={{my:1}}>{item.Description||item.description}</Typography><Chip label={severity} size="small" className={`severity ${severity.toLowerCase()}`}/><Chip label={service} size="small" sx={{ml:1}}/><Chip label={environment} size="small" sx={{ml:1}} variant="outlined"/></Box>
      <Box><Button size="small" startIcon={<Analytics/>} onClick={()=>analyzeIncident(item)} disabled={analyzing===item.ID}>{analyzing===item.ID?'Analyzing…':'Analyze with AI'}</Button><IconButton color="success" onClick={()=>resolveIncident(item.ID)} title="Resolve incident"><Delete/></IconButton></Box></Box>
      {result && <Box sx={{mt:2,p:2,borderRadius:2,bgcolor:'action.hover'}}><Typography variant="subtitle1" fontWeight={700}>🤖 AI RCA Result {result.confidence!==undefined && `• ${result.confidence}% confidence`}</Typography><Typography sx={{mt:1}}><b>Root cause:</b> {result.rootCause}</Typography>{result.recommendedActions?.length>0 && <><Typography sx={{mt:1}}><b>Recommended actions:</b></Typography><ul>{result.recommendedActions.map((x,i)=><li key={i}>{x}</li>)}</ul></>}{result.evidence?.kubernetes?.events?.length>0 && <Typography variant="body2"><b>Kubernetes evidence:</b> {result.evidence.kubernetes.events.length} event(s) collected.</Typography>}<Typography variant="caption">Mode: {result.mode||'read-only'}</Typography></Box>}
    </CardContent></Card>})}
  </Container></Box>;
}
export default TodoApp;
