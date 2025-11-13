---
author: Navdeep Kaur
title: "Kubernetes & OpenShift: Production Deployment Strategies for Enterprise Applications"
date: 2024-07-30
description: "Master Kubernetes and OpenShift deployment patterns for enterprise applications. Learn scaling, high availability, GitOps, and disaster recovery."
keywords: ["kubernetes", "openshift", "deployment", "containers", "orchestration", "devops"]
tags: ["kubernetes", "openshift", "devops", "docker", "enterprise"]
categories: ["DevOps", "Kubernetes"]
thumbnail: "/images/thumbnails/kubernetes-deployment.svg"
---

## Introduction

Kubernetes has become the de facto standard for container orchestration. But moving from development to production requires more than just running `kubectl apply`.

In this article, I'll share enterprise deployment strategies for Kubernetes and OpenShift based on production experience at IBM.

## Core Concepts

### Kubernetes Architecture
```
┌─────────────────────────────────────────┐
│          Control Plane                   │
│  (API Server, Scheduler, Etcd, etc.)    │
└────────────┬────────────────────────────┘
             │
     ┌───────┴────────────┬────────────┐
     │                    │            │
┌────▼───┐          ┌────▼───┐   ┌───▼───┐
│ Worker │          │ Worker │   │Worker  │
│ Node 1 │          │ Node 2 │   │ Node 3 │
│        │          │        │   │        │
│ Pods   │          │ Pods   │   │ Pods   │
└────────┘          └────────┘   └────────┘
```

## Production Deployment Patterns

### 1. Canary Deployments

```yaml
# Canary deployment using Flagger
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: my-app
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  service:
    name: my-app
    port: 80
  analysis:
    interval: 1m
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    metrics:
    - name: request-success-rate
      thresholdRange:
        min: 99
      interval: 1m
    - name: request-duration
      thresholdRange:
        max: 500
      interval: 1m
  skipAnalysis: false
  webhooks:
    - name: smoke-tests
      url: http://flagger-loadtester/
      timeout: 30s
      metadata:
        type: smoke
        cmd: "curl -sd 'test' http://my-app-canary/api/test | grep token"
```

### 2. Blue-Green Deployments

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app
spec:
  selector:
    app: my-app
    version: blue  # Initially points to blue
  ports:
    - port: 80
      targetPort: 8080
  type: LoadBalancer
---
# Blue deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
      version: blue
  template:
    metadata:
      labels:
        app: my-app
        version: blue
    spec:
      containers:
      - name: my-app
        image: my-app:v1.0
        ports:
        - containerPort: 8080
---
# Green deployment (new version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
      version: green
  template:
    metadata:
      labels:
        app: my-app
        version: green
    spec:
      containers:
      - name: my-app
        image: my-app:v2.0
        ports:
        - containerPort: 8080
```

## High Availability Setup

### 1. Pod Disruption Budgets

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: my-app
  unhealthyPodEvictionPolicy: AlwaysAllow
```

### 2. Affinity Rules for Distribution

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - my-app
            topologyKey: kubernetes.io/hostname
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: node-type
                operator: In
                values:
                - compute-optimized
      containers:
      - name: my-app
        image: my-app:v1.0
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

## GitOps for Deployment

### Flux CD Configuration

```yaml
# kustomization.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
---
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: my-app-repo
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/myorg/my-app-config.git
  ref:
    branch: main
  secretRef:
    name: github-credentials
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: my-app-production
  namespace: flux-system
spec:
  interval: 5m
  path: ./kustomize/production
  prune: true
  wait: true
  sourceRef:
    kind: GitRepository
    name: my-app-repo
  validation: server
  healthChecks:
  - apiVersion: apps/v1
    kind: Deployment
    name: my-app
    namespace: production
```

## Secrets Management

### Using Sealed Secrets

```bash
# Create a secret
echo -n mypassword | kubectl create secret generic my-secret \
  --dry-run=client \
  --from-file=password=/dev/stdin \
  -o yaml > secret.yaml

# Seal it
kubeseal -f secret.yaml -w sealed-secret.yaml

# Apply sealed secret
kubectl apply -f sealed-secret.yaml
```

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: my-app-secrets
  namespace: production
spec:
  encryptedData:
    database-password: AgCvC8F2... # Encrypted data
  template:
    metadata:
      name: my-app-secrets
      namespace: production
    type: Opaque
```

## Monitoring & Logging

### Prometheus ServiceMonitor

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app
  namespace: production
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: metrics
    interval: 30s
```

### Logging with Fluent Bit

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
data:
  fluent-bit.conf: |
    [INPUT]
        name              tail
        path              /var/log/containers/*.log
        parser            docker
        tag               kube.*
        refresh_interval  5
    
    [FILTER]
        name    kubernetes
        match   kube.*
    
    [OUTPUT]
        name   stdout
        match  *
```

## Disaster Recovery

### Velero Backup Configuration

```yaml
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: my-app-daily-backup
spec:
  storageLocation: aws-s3
  volumeSnapshotLocation: aws-ebs
  includedNamespaces:
  - production
  ttl: 720h
  schedule: "0 2 * * *"  # Daily at 2 AM
```

## Best Practices

### 1. Resource Requests & Limits
Always set resource requests and limits to enable proper scheduling and prevent resource starvation.

### 2. Readiness & Liveness Probes
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 20

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
```

### 3. Network Policies
Implement network policies to restrict traffic between pods:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-app
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api-gateway
```

## Conclusion

Kubernetes and OpenShift offer powerful deployment strategies for enterprise applications. By leveraging canary deployments, high availability patterns, and GitOps workflows, you can achieve reliable, scalable production environments.

---

**What's your favorite Kubernetes deployment pattern? Share in the comments!**
