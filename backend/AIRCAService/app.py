import os
from datetime import datetime, timezone
from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

def classify(text):
    t = text.lower()
    if any(x in t for x in ["oomkilled", "out of memory", "oom", "memory limit"]):
        return ("Memory pressure / OOMKill is the most likely root cause.",
                ["Inspect container memory usage and limits.", "Check recent memory-related changes.", "Increase memory only after validating workload requirements."], 92)
    if any(x in t for x in ["imagepullbackoff", "errimagepull", "image pull", "manifest unknown"]):
        return ("Container image retrieval or registry authentication failure.",
                ["Verify image name and tag.", "Validate ACR permissions/workload identity.", "Check imagePullSecrets if used."], 91)
    if any(x in t for x in ["crashloopbackoff", "back-off restarting"]):
        return ("Container is repeatedly failing during startup.",
                ["Inspect previous container logs.", "Check startup command, environment variables and secrets.", "Review liveness/readiness probes and recent deployments."], 89)
    if any(x in t for x in ["5xx", "502", "503", "504", "gateway"]):
        return ("Likely upstream application or ingress/backend health failure.",
                ["Inspect ingress/controller events.", "Check backend pod readiness and service endpoints.", "Review application logs around the incident time."], 84)
    if any(x in t for x in ["pending", "unschedulable", "insufficient cpu", "insufficient memory"]):
        return ("Pod scheduling/resource-capacity issue.",
                ["Check node capacity and allocatable resources.", "Inspect pod requests/limits and scheduling events.", "Check taints, tolerations and node selectors."], 86)
    return ("Insufficient evidence for a high-confidence root cause.",
            ["Collect pod logs and previous container logs.", "Inspect Kubernetes events and deployment history.", "Correlate application, ingress and infrastructure telemetry."], 62)

def get_k8s_context(namespace, pod):
    try:
        from kubernetes import client, config
        try:
            config.load_incluster_config()
        except Exception:
            config.load_kube_config()
        v1 = client.CoreV1Api()
        result = {}
        if pod:
            p = v1.read_namespaced_pod(pod, namespace)
            result["podStatus"] = p.status.to_dict() if p.status else {}
            try:
                result["logs"] = v1.read_namespaced_pod_log(pod, namespace, tail_lines=120, timestamps=True)
            except Exception:
                result["logs"] = ""
            ev = v1.list_namespaced_event(namespace, field_selector=f"involvedObject.name={pod}")
        else:
            ev = v1.list_namespaced_event(namespace)
        result["events"] = [{"reason": e.reason, "message": e.message, "type": e.type} for e in ev.items[-20:]]
        return result
    except Exception as e:
        return {"collectionError": str(e)}

@app.get("/health")
def health():
    return jsonify({"status":"healthy","service":"ai-rca","timestamp":datetime.now(timezone.utc).isoformat()})

@app.post("/analyze")
def analyze():
    body = request.get_json(silent=True) or {}
    incident = body.get("incident", body)
    namespace = body.get("namespace") or incident.get("namespace") or os.getenv("DEFAULT_NAMESPACE", "default")
    pod = body.get("pod") or incident.get("pod")
    context = get_k8s_context(namespace, pod) if os.getenv("K8S_CONTEXT_ENABLED", "true").lower() == "true" else {}
    raw = " ".join(str(incident.get(k, "")) for k in ["title","Title","description","Description","service","Service","severity","Severity"])
    raw += " " + str(context)
    root, actions, confidence = classify(raw)
    return jsonify({
        "rootCause": root,
        "confidence": confidence,
        "evidence": {"incident": incident, "kubernetes": context},
        "recommendedActions": actions,
        "mode": "read-only",
        "generatedAt": datetime.now(timezone.utc).isoformat()
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8080")))
