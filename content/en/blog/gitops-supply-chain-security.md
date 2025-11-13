---
author: Navdeep Kaur
title: "GitOps Security & Supply Chain Security: SLSA Framework Integration"
date: 2025-09-20
description: "Secure your GitOps pipelines and implement SLSA framework for supply chain security. Learn provenance, artifact signing, and automated compliance."
keywords: ["gitops", "security", "supply-chain", "slsa", "compliance", "devsecops"]
tags: ["security", "devops", "gitops", "compliance", "supply-chain"]
categories: ["DevOps", "Security"]
thumbnail: "/images/thumbnails/gitops-supply-chain-security.svg"
---

## Introduction

GitOps has revolutionized deployment workflows, but with great power comes great responsibility. Supply chain security—ensuring every artifact is verified, signed, and traceable—is now critical.

The SLSA (Supply-chain Levels for Software Artifacts) framework provides a structured approach. This article explores implementing GitOps security with SLSA integration.

## The Supply Chain Attack Surface

### Attack Vectors in Modern CI/CD

```
Source Code
    ↓ (git injection)
Git Repository
    ↓ (unauthorized access)
CI/CD Pipeline
    ↓ (pipeline tampering)
Artifact Registry
    ↓ (image poisoning)
Kubernetes Cluster
    ↓ (runtime compromise)
Production Environment
```

## SLSA Framework Overview

### SLSA Levels (0-4)

| Level | Requirements | Verification |
|-------|---|---|
| **Level 0** | No security practices | None |
| **Level 1** | Automated build, source control, CI/CD | Build provenance |
| **Level 2** | Hosted build service, version control | Signed provenance |
| **Level 3** | Isolated build, access control | Hardened provenance |
| **Level 4** | Hermetic builds, offline signing | Full audit trail |

## Implementing SLSA with GitOps

### 1. Build Provenance Generation

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: generate-slsa-provenance
spec:
  params:
    - name: image
      type: string
    - name: commit-sha
      type: string
    - name: build-timestamp
      type: string
  steps:
    - name: generate-provenance
      image: python:3.11
      script: |
        #!/usr/bin/env python3
        import json
        import hashlib
        from datetime import datetime
        import os
        
        # Generate SLSA v1.0 provenance
        provenance = {
          "buildType": "https://tekton.dev/v1beta1/PipelineRun",
          "builder": {
            "id": "https://tekton.example.com/v1beta1/builder"
          },
          "metadata": {
            "invocationId": os.getenv('TEKTON_BUILD_ID'),
            "startedOn": "$(params.build-timestamp)",
            "finishedOn": datetime.now().isoformat()
          },
          "materials": [
            {
              "uri": "git+https://github.com/myorg/myapp.git",
              "digest": {
                "sha256": "$(params.commit-sha)"
              }
            }
          ],
          "recipe": {
            "type": "https://tekton.dev/v1beta1/PipelineRun",
            "definedInMaterial": 0,
            "entryPoint": "release.yaml",
            "arguments": {
              "image": "$(params.image)"
            }
          }
        }
        
        with open('provenance.json', 'w') as f:
          json.dump(provenance, f, indent=2)
        
        # Calculate digest
        with open('provenance.json', 'rb') as f:
          digest = hashlib.sha256(f.read()).hexdigest()
        print(f"Provenance digest: {digest}")
    
    - name: upload-provenance
      image: curlimages/curl:latest
      script: |
        #!/bin/sh
        curl -X POST https://artifact-registry/provenance \
          -H "Authorization: Bearer $REGISTRY_TOKEN" \
          -F "provenance=@provenance.json" \
          -F "image=$(params.image)"
```

### 2. Artifact Signing with Cosign

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: sign-artifact-with-cosign
spec:
  params:
    - name: image
      type: string
    - name: slsa-provenance
      type: string
  steps:
    - name: sign-image
      image: gcr.io/projectsigstore/cosign:latest
      env:
        - name: COSIGN_EXPERIMENTAL
          value: "true"
        - name: COSIGN_REPOSITORY
          value: "gcr.io/myproject/signatures"
      script: |
        #!/bin/sh
        # Sign container image
        cosign sign --key cosign.key $(params.image)
        
        # Attach SLSA provenance
        cosign attach attestation \
          --attestation $(params.slsa-provenance) \
          $(params.image)
        
        # Attach SBOM
        cosign attach sbom \
          --sbom sbom.spdx \
          $(params.image)
```

### 3. Verification Before Deployment

```python
# Verify artifacts before GitOps sync
import subprocess
import json
import sys

class SlsaArtifactVerifier:
    def __init__(self, image: str, public_key: str):
        self.image = image
        self.public_key = public_key
    
    def verify_signature(self) -> bool:
        """Verify artifact signature with Cosign"""
        result = subprocess.run([
            'cosign', 'verify',
            '--key', self.public_key,
            self.image
        ], capture_output=True)
        
        return result.returncode == 0
    
    def verify_provenance(self) -> Dict:
        """Verify SLSA provenance"""
        result = subprocess.run([
            'cosign', 'verify-attestation',
            '--certificate-identity', 'https://github.com/myorg/myapp/.github/workflows/release.yaml',
            '--certificate-oidc-issuer', 'https://token.actions.githubusercontent.com',
            self.image
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            return {'valid': False, 'error': result.stderr}
        
        attestations = json.loads(result.stdout)
        return {
            'valid': True,
            'attestations': attestations,
            'verified': True
        }
    
    def verify_sbom(self) -> Dict:
        """Verify Software Bill of Materials"""
        result = subprocess.run([
            'cosign', 'download', 'sbom',
            self.image
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            sbom = json.loads(result.stdout)
            return {
                'valid': True,
                'sbom': sbom,
                'components': len(sbom.get('components', []))
            }
        return {'valid': False}
    
    def verify_all(self) -> bool:
        """Complete verification workflow"""
        checks = {
            'signature': self.verify_signature(),
            'provenance': self.verify_provenance()['valid'],
            'sbom': self.verify_sbom()['valid']
        }
        
        if not all(checks.values()):
            print(f"Verification failed: {checks}")
            return False
        
        print(f"✅ All verifications passed for {self.image}")
        return True

# Usage in GitOps controller
verifier = SlsaArtifactVerifier(
    image='gcr.io/myproject/myapp:v1.2.3',
    public_key='cosign.pub'
)

if verifier.verify_all():
    # Safe to deploy
    apply_gitops_sync()
else:
    # Block deployment
    raise Exception("Artifact verification failed - deployment blocked")
```

### 4. GitOps Integrity with Flux CD

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: infrastructure
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/myorg/infrastructure.git
  ref:
    branch: main
  # GPG signature verification
  verify:
    mode: all
    secretRef:
      name: git-signing-keys
---
apiVersion: v1
kind: Secret
metadata:
  name: git-signing-keys
  namespace: flux-system
type: Opaque
data:
  identity: |
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    mQENBF...
    -----END PGP PUBLIC KEY BLOCK-----
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: infrastructure
  namespace: flux-system
spec:
  interval: 5m
  path: ./kustomize/production
  sourceRef:
    kind: GitRepository
    name: infrastructure
  validation: server
  # Policy for deployments
  postBuild:
    substitute:
      environment: production
    substituteFrom:
      - kind: ConfigMap
        name: cluster-config
```

## End-to-End GitOps Security Flow

```
1. Developer commits code (signed commit)
   ↓
2. GitHub webhook triggers pipeline
   ↓
3. Tekton builds image in isolated container
   ↓
4. Generate SLSA provenance
   ↓
5. Sign image with Cosign
   ↓
6. Attach attestations & SBOM
   ↓
7. Push to artifact registry
   ↓
8. GitOps controller detects new image
   ↓
9. Verify signature & provenance
   ↓
10. Verify policies (Kyverno/OPA)
   ↓
11. Deploy to cluster
```

## Policy Enforcement with Kyverno

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-images
spec:
  validationFailureAction: enforce
  webhookTimeoutSeconds: 30
  rules:
  - name: verify-signature
    match:
      resources:
        kinds:
        - Pod
    verifyImages:
    - imageReferences:
      - "gcr.io/myproject/*"
      attestors:
      - name: check-signature
        entries:
        - keys:
            publicKeys: |
              -----BEGIN PUBLIC KEY-----
              MFkwEwYH...
              -----END PUBLIC KEY-----
            signatureAlgorithm: sha256
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-provenance
spec:
  validationFailureAction: enforce
  rules:
  - name: require-slsa-provenance
    match:
      resources:
        kinds:
        - Pod
    verifyImages:
    - imageReferences:
      - "gcr.io/myproject/*"
      attestors:
      - name: check-provenance
        attestationFormat: "CycloneDX"
        conditions:
        - all:
          - key: "{{ attestation.predicate.buildType }}"
            operator: Equals
            value: "https://tekton.dev/v1beta1/PipelineRun"
```

## Best Practices

1. **Sign Commits**: Enforce GPG-signed commits
2. **Hermetic Builds**: Use isolated build environments
3. **Attestation**: Generate and verify attestations
4. **Audit Logging**: Log all deployment approvals
5. **Key Management**: Use secure key storage (Vault, Cloud KMS)

## Challenges & Solutions

| Challenge | Solution |
|-----------|----------|
| Key rotation complexity | Automate with cert-manager |
| Verification performance | Cache verification results |
| Legacy systems | Gradual rollout with exemptions |
| Compliance requirements | Map to specific SLSA levels |

## Conclusion

Supply chain security is not optional—it's essential. By implementing SLSA framework with GitOps, you ensure every artifact is verified, traceable, and secure.

---

**How are you securing your supply chain? Share your SLSA implementation in the comments!**
