# Todo Application — Microservices Deployment on Kubernetes

A DevOps project that packages a Todo application into frontend and backend services, containerizes them with Docker, deploys them to Kubernetes, and automates build/deployment workflows with GitHub Actions.

## Project architecture

```text
User
 ↓
Frontend
 ↓
Kubernetes / Ingress
 ↓
Backend Microservices
 ├─ Add Task
 ├─ Get Tasks
 └─ Delete Task
```

The repository contains separate backend services for Todo operations, Kubernetes manifests for workloads/services, Dockerfiles, frontend code, and GitHub Actions workflows.

## Repository highlights

```text
.github/workflows/
    CI/CD workflows

backend/
    AddTaskTodoMicroservice/
    GetTasksTodoMicroservice/
    DeleteTaskTodoMicroservice/

frontend/
    UI application and container configuration
```

## DevOps concepts demonstrated

- Microservices-based application structure
- Docker image creation
- Kubernetes Deployments and Services
- Kubernetes Ingress
- Frontend and backend deployment
- GitHub Actions CI/CD
- Separate pipelines for application components
- Terraform deployment workflow present in `.github/workflows`
- Basic code-quality configuration such as SonarQube project settings

## Prerequisites

Depending on which parts you want to run:

- Docker
- Kubernetes cluster
- `kubectl`
- GitHub repository with required Actions secrets
- Terraform/Azure tooling for infrastructure workflow, where applicable

Verify Kubernetes access:

```bash
kubectl cluster-info
kubectl get nodes
```

## Kubernetes deployment pattern

Each backend service contains its own manifests. Typical flow:

```bash
kubectl apply -f backend/AddTaskTodoMicroservice/manifests/
kubectl apply -f backend/GetTasksTodoMicroservice/manifests/
kubectl apply -f backend/DeleteTaskTodoMicroservice/manifests/
```

Then verify:

```bash
kubectl get deployments
kubectl get pods
kubectl get svc
kubectl get ingress
```

Exact deployment order and external dependencies should be reviewed from the corresponding manifests and workflows before execution.

## CI/CD flow

```text
Code Change
   ↓
GitHub Actions
   ↓
Build / Validate
   ↓
Container Image
   ↓
Kubernetes Deployment
```

The repository contains dedicated workflows for frontend and backend components so services can be built/deployed independently.

## Production considerations

Before treating this as a production deployment, add or validate:

- Kubernetes Secrets / external secret management
- Image version pinning instead of mutable tags
- Readiness and liveness probes
- CPU/memory requests and limits
- Network policies
- TLS for Ingress
- Deployment rollback strategy
- Vulnerability scanning
- Centralized logging and monitoring
- Environment separation
- GitHub Actions least-privilege permissions

## Purpose

This repository demonstrates an end-to-end DevOps learning project: application code → Docker → CI/CD → Kubernetes deployment using independently deployable frontend and Todo backend services.