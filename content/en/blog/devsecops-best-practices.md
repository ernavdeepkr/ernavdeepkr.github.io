---
author: Navdeep Kaur
title: "DevSecOps Best Practices: Embedding Security in Your CI/CD Pipeline"
date: 2024-07-05
description: "Learn how to embed security practices throughout your CI/CD pipeline. Covers vulnerability scanning, compliance automation, secrets management, and incident response."
keywords: ["devsecops", "security", "ci/cd", "vulnerability", "compliance", "devops"]
tags: ["devsecops", "security", "ci-cd", "compliance", "automation"]
categories: ["DevOps", "Security"]
thumbnail: "/images/thumbnails/devsecops-security.svg"
---

## Introduction

Security can't be an afterthought in modern development. At IBM, I led the implementation of DevSecOps practices across 54+ repositories using Tekton pipelines. This article shares practical strategies for embedding security throughout your CI/CD pipeline.

## The DevSecOps Mindset

DevSecOps shifts security left by integrating security checks early in the development lifecycle:

```
Traditional Pipeline:
Dev → Build → Test → Deploy → Security Review (Too Late!)

DevSecOps Pipeline:
Secure Code ← Dev → Security Tests → Build → Security Scanning → Deploy → Monitor
```

## Secret Management

### 1. Preventing Secrets in Git

```bash
#!/bin/bash
# .git/hooks/pre-commit - Prevent secrets in commits

FILES=$(git diff --cached --name-only)
SECRET_PATTERNS=(
  "AKIA[0-9A-Z]{16}"  # AWS Access Key
  "aws_secret_access_key"
  "password.*[:=]"
  "api[_-]?key"
  "BEGIN RSA PRIVATE KEY"
)

for file in $FILES; do
  for pattern in "${SECRET_PATTERNS[@]}"; do
    if git show ":$file" | grep -E "$pattern" > /dev/null; then
      echo "❌ Potential secret found in $file: $pattern"
      exit 1
    fi
  done
done
exit 0
```

### 2. HashiCorp Vault Integration

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
---
apiVersion: v1
kind: Secret
metadata:
  name: vault-token
type: kubernetes.io/service-account-token
---
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: fetch-secrets-from-vault
spec:
  params:
  - name: VAULT_ADDR
  - name: SECRET_PATH
  steps:
  - name: get-secrets
    image: vault:latest
    env:
    - name: VAULT_TOKEN
      valueFrom:
        secretKeyRef:
          name: vault-token
          key: token
    script: |
      #!/bin/sh
      set -e
      VAULT_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
      
      # Authenticate with Kubernetes auth method
      LOGIN_RESPONSE=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "{\"jwt\": \"$VAULT_TOKEN\", \"role\": \"my-app\"}" \
        $(params.VAULT_ADDR)/v1/auth/kubernetes/login)
      
      CLIENT_TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.auth.client_token')
      
      # Fetch secrets
      curl -s -H "X-Vault-Token: $CLIENT_TOKEN" \
        $(params.VAULT_ADDR)/v1/$(params.SECRET_PATH) | jq -r '.data.data'
```

## Dependency Scanning

### SBOM (Software Bill of Materials) Generation

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: generate-sbom
spec:
  params:
  - name: IMAGE
    description: Container image to scan
  steps:
  - name: syft-sbom
    image: anchore/syft:latest
    script: |
      #!/bin/sh
      syft $(params.IMAGE) -o json > sbom.json
      syft $(params.IMAGE) -o cyclonedx > sbom.xml
      
      # Check for critical vulnerabilities in SBOM
      syft $(params.IMAGE) -o json | \
        jq '.artifacts[] | select(.vulnerabilities[].severity == "CRITICAL")'
  - name: upload-sbom
    image: curlimages/curl:latest
    script: |
      #!/bin/sh
      curl -X POST https://sbom-registry/api/upload \
        -F "sbom=@sbom.json" \
        -H "Authorization: Bearer $SBOM_TOKEN"
```

### Dependency Check with Grype

```bash
#!/bin/bash
# scan-dependencies.sh

CONTAINER_IMAGE=$1
MAX_CRITICAL=0

# Scan with grype
grype "$CONTAINER_IMAGE" -o json > grype-report.json

# Extract vulnerability counts
CRITICAL=$(jq '[.matches[] | select(.vulnerability.severity == "Critical")] | length' grype-report.json)
HIGH=$(jq '[.matches[] | select(.vulnerability.severity == "High")] | length' grype-report.json)
MEDIUM=$(jq '[.matches[] | select(.vulnerability.severity == "Medium")] | length' grype-report.json)

echo "📊 Vulnerability Summary"
echo "Critical: $CRITICAL"
echo "High: $HIGH"
echo "Medium: $MEDIUM"

if [ "$CRITICAL" -gt "$MAX_CRITICAL" ]; then
  echo "❌ Critical vulnerabilities found!"
  exit 1
fi

echo "✅ Dependency scan passed"
```

## Container Security Scanning

### Trivy for Image Scanning

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: scan-container-image
spec:
  params:
  - name: IMAGE
  steps:
  - name: trivy-scan
    image: aquasec/trivy:latest
    script: |
      #!/bin/sh
      set -e
      
      # Full scan with output
      trivy image --severity HIGH,CRITICAL \
        --exit-code 0 \
        --format json \
        --output trivy-report.json \
        $(params.IMAGE)
      
      # Check for critical issues
      CRITICAL_COUNT=$(jq '[.Results[].Misconfigurations[] | select(.Severity == "CRITICAL")] | length' trivy-report.json)
      
      if [ "$CRITICAL_COUNT" -gt 0 ]; then
        echo "❌ $CRITICAL_COUNT critical issues found"
        jq '.Results[].Misconfigurations[] | select(.Severity == "CRITICAL")' trivy-report.json
        exit 1
      fi
      
      echo "✅ Container image passed security scan"
```

## Static Application Security Testing (SAST)

### SonarQube Integration

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: sonarqube-sast
spec:
  params:
  - name: SONAR_HOST_URL
  - name: SONAR_TOKEN
  - name: PROJECT_KEY
  steps:
  - name: run-sonar-scan
    image: sonarsource/sonar-scanner-cli:latest
    script: |
      #!/bin/bash
      sonar-scanner \
        -Dsonar.projectKey=$(params.PROJECT_KEY) \
        -Dsonar.sources=. \
        -Dsonar.host.url=$(params.SONAR_HOST_URL) \
        -Dsonar.login=$(params.SONAR_TOKEN) \
        -Dsonar.qualitygate.wait=true \
        -Dsonar.exclusions='**/test/**,**/vendor/**'
```

### Python SAST with Bandit

```python
# bandit_security_check.py
import subprocess
import json
import sys

def scan_python_code(source_path):
    """Run Bandit security scanner on Python code"""
    
    result = subprocess.run(
        ['bandit', '-r', source_path, '-f', 'json', '-o', 'bandit-report.json'],
        capture_output=True,
        text=True
    )
    
    with open('bandit-report.json', 'r') as f:
        report = json.load(f)
    
    # Fail on HIGH severity issues
    high_issues = [
        issue for issue in report['results']
        if issue['severity'] == 'HIGH'
    ]
    
    if high_issues:
        print(f"❌ Found {len(high_issues)} HIGH severity security issues:")
        for issue in high_issues:
            print(f"  - {issue['issue_text']} in {issue['filename']}:{issue['line_number']}")
        return False
    
    print(f"✅ Bandit scan passed. Low: {len([i for i in report['results'] if i['severity'] == 'LOW'])}")
    return True

if __name__ == '__main__':
    success = scan_python_code('src/')
    sys.exit(0 if success else 1)
```

## Infrastructure as Code (IaC) Security

### Terraform Security with Checkov

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: checkov-iac-scan
spec:
  params:
  - name: TERRAFORM_DIR
  steps:
  - name: checkov-scan
    image: bridgecrewio/checkov:latest
    script: |
      #!/bin/sh
      checkov \
        --directory $(params.TERRAFORM_DIR) \
        --framework terraform \
        --check CKV_AWS_1,CKV_AWS_6,CKV_AWS_7 \
        --output json \
        --output-file checkov-report.json
```

## Container Image Signing & Verification

### Cosign for Image Signing

```bash
#!/bin/bash
# sign-container-image.sh

REGISTRY=$1
IMAGE=$2
COSIGN_KEY=$3

# Generate keys if not exist
if [ ! -f "$COSIGN_KEY.pub" ]; then
  cosign generate-key-pair
fi

# Sign the image
cosign sign --key "$COSIGN_KEY" "$REGISTRY/$IMAGE"

# Verify signature
cosign verify --key "$COSIGN_KEY.pub" "$REGISTRY/$IMAGE"

echo "✅ Image signed and verified: $REGISTRY/$IMAGE"
```

## Compliance as Code

### Auditree Integration for Compliance

```python
# evidence_fetchers/security_compliance.py
from auditree.framework.evidence_fetcher import EvidenceFetcher
from auditree.utils.exception import AuditreeException

class SecurityComplianceFetcher(EvidenceFetcher):
    """Fetch security compliance evidence"""
    
    def fetch_evidence(self):
        """Gather security compliance data"""
        
        # Check container image scanning
        scan_results = self._fetch_image_scans()
        self.store_fetched_evidences(scan_results)
        
        # Check secrets management
        vault_audit = self._check_vault_compliance()
        self.store_fetched_evidences(vault_audit)
        
        # Verify SSL/TLS certificates
        cert_validation = self._validate_certificates()
        self.store_fetched_evidences(cert_validation)
    
    def _fetch_image_scans(self):
        """Fetch container image vulnerability scans"""
        try:
            import grype
            scans = grype.scan_registry()
            return {'scans': scans, 'timestamp': self.get_timestamp()}
        except Exception as e:
            raise AuditreeException(f"Failed to fetch scans: {str(e)}")
    
    def _check_vault_compliance(self):
        """Check Vault secret rotation compliance"""
        import hvac
        client = hvac.Client(url=self.config['vault_url'])
        
        audit_log = client.sys.read_audit_log()
        
        # Check for secrets older than 90 days
        old_secrets = [s for s in audit_log if self._is_old_secret(s)]
        
        return {
            'old_secrets': len(old_secrets),
            'compliant': len(old_secrets) == 0
        }
    
    def _validate_certificates(self):
        """Validate SSL/TLS certificates"""
        import ssl
        import socket
        from datetime import datetime, timedelta
        
        domain = self.config['primary_domain']
        context = ssl.create_default_context()
        
        with socket.create_connection((domain, 443)) as sock:
            with context.wrap_socket(sock, server_hostname=domain) as ssock:
                cert = ssock.getpeercert()
                expiry = datetime.strptime(
                    cert['notAfter'], '%b %d %H:%M:%S %Y %Z'
                )
                
                days_remaining = (expiry - datetime.now()).days
                
                return {
                    'domain': domain,
                    'expires_in_days': days_remaining,
                    'compliant': days_remaining > 30
                }
```

## Runtime Security Monitoring

### Falco Rules for Anomaly Detection

```yaml
# falco-rules.yaml
- rule: Unauthorized Process Execution
  desc: Detect unauthorized processes in containers
  condition: >
    spawned_process and container and
    not proc.name in (allowed_processes) and
    user.uid > 0
  output: >
    Unauthorized process execution detected
    (user=%user.name process=%proc.name container=%container.id)
  priority: WARNING
  tags: [container_runtime, process]

- rule: Suspicious Network Activity
  desc: Detect suspicious outbound connections
  condition: >
    outbound and container and
    not fd.sip in (trusted_ips)
  output: >
    Suspicious network activity
    (container=%container.id destination=%fd.sip)
  priority: ERROR
  tags: [network, container_runtime]
```

## Incident Response Automation

### PagerDuty Integration for Security Alerts

```python
# security_incident_handler.py
import pdpyras
import json

class SecurityIncidentHandler:
    def __init__(self, pagerduty_token):
        self.client = pdpyras.APISession(pdpyras.PDSession(auth_token=pagerduty_token))
    
    def create_security_incident(self, severity, title, details):
        """Create PagerDuty incident for security events"""
        
        # Determine urgency from severity
        urgency_map = {
            'CRITICAL': 'high',
            'HIGH': 'high',
            'MEDIUM': 'low'
        }
        
        incident = {
            'type': 'incident',
            'title': f"[{severity}] {title}",
            'service': {'id': self.config['service_id'], 'type': 'service_reference'},
            'urgency': urgency_map.get(severity, 'low'),
            'body': {
                'type': 'incident_body',
                'details': json.dumps(details, indent=2)
            }
        }
        
        response = self.client.post('/incidents', json=incident)
        print(f"✅ Incident created: {response['id']}")
        return response
    
    def auto_remediate(self, incident_type):
        """Automatically remediate common security issues"""
        
        if incident_type == 'exposed_secrets':
            self._rotate_secrets()
            self._invalidate_tokens()
        elif incident_type == 'vulnerable_image':
            self._quarantine_container()
            self._trigger_rebuild()
```

## Best Practices Summary

1. **Secrets Management**: Never commit secrets; use Vault or similar
2. **Shift Left**: Catch vulnerabilities early in the pipeline
3. **Automate Everything**: Use tools like Trivy, SonarQube, Checkov
4. **Monitor Continuously**: Runtime security with Falco
5. **Audit Compliance**: Document and automate compliance checks
6. **Incident Response**: Integrate with PagerDuty for rapid response

## Conclusion

DevSecOps isn't a one-time implementation but an ongoing process. By embedding security checks throughout your CI/CD pipeline and automating compliance, you significantly reduce security risks while maintaining development velocity.

---

**How do you approach DevSecOps in your organization? Share your strategies in the comments below!**
