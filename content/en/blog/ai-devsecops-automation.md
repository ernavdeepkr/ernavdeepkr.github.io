---
author: Navdeep Kaur
title: "Generative AI & Agentic AI in DevOps: Automating PagerDuty Incidents & Beyond"
date: 2024-03-30
description: "Explore generative AI and agentic AI applications in DevOps. Learn how to automate incident response with PagerDuty, leverage AI for code generation, and build intelligent automation systems."
keywords: ["ai", "devops", "automation", "incident-response", "pagerduty", "machine-learning"]
tags: ["ai", "devops", "automation", "incident-response", "pagerduty"]
categories: ["DevOps", "AI"]
thumbnail: "/images/thumbnails/ai-devops-automation.svg"
---

## Introduction

AI is transforming DevOps. At IBM, I explored generative AI and agentic AI applications for incident response, infrastructure automation, and code generation. This article covers practical approaches to leveraging AI in your DevOps workflows.

## Understanding Generative vs Agentic AI

```
Generative AI:
- Generates content (text, code, images)
- Responds to prompts
- Example: ChatGPT, Claude, GitHub Copilot
- Use case: Suggest runbooks, generate configs

Agentic AI:
- Makes decisions and takes actions autonomously
- Uses reasoning loops (think → plan → execute → reflect)
- Example: AI agents with tool access
- Use case: Automate incident response, infrastructure provisioning
```

## AI for Incident Response Automation

### PagerDuty Incident Auto-Response with Claude

```python
# pagerduty_ai_responder.py
import anthropic
import pdpyras
import json
from datetime import datetime

class PagerDutyAIResponder:
    def __init__(self, pagerduty_token, anthropic_key):
        self.pagerduty = pdpyras.APISession(pdpyras.PDSession(auth_token=pagerduty_token))
        self.anthropic = anthropic.Anthropic(api_key=anthropic_key)
        self.model = "claude-3-5-sonnet-20241022"
    
    def get_incident_context(self, incident_id):
        """Fetch incident details from PagerDuty"""
        
        response = self.pagerduty.get(f'/incidents/{incident_id}')
        incident = response['incident']
        
        # Get alert details
        alerts_response = self.pagerduty.get(
            f'/log_entries?incident_id={incident_id}&include=channels'
        )
        
        context = {
            'title': incident['title'],
            'status': incident['status'],
            'urgency': incident['urgency'],
            'service': incident['service']['summary'],
            'assigned_to': incident['assignments'][0]['assignee']['summary'] if incident['assignments'] else None,
            'created_at': incident['created_at'],
            'alerts': [alert['body'] for alert in alerts_response['log_entries'][:5]]
        }
        
        return context
    
    def analyze_and_suggest_actions(self, incident_context):
        """Use Claude to analyze incident and suggest actions"""
        
        tools = [
            {
                "name": "create_incident_note",
                "description": "Add a note to the PagerDuty incident",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "content": {"type": "string", "description": "Note content"}
                    },
                    "required": ["content"]
                }
            },
            {
                "name": "trigger_remediation",
                "description": "Trigger automated remediation actions",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "action_type": {"type": "string", "enum": ["restart_service", "scale_up", "rollback", "investigate"]},
                        "parameters": {"type": "object"}
                    },
                    "required": ["action_type"]
                }
            },
            {
                "name": "get_similar_incidents",
                "description": "Find similar past incidents",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "query": {"type": "string"}
                    },
                    "required": ["query"]
                }
            }
        ]
        
        system_prompt = """You are an expert DevOps AI assistant helping to resolve PagerDuty incidents.
        
Your responsibilities:
1. Analyze the incident context
2. Identify the likely root cause
3. Suggest remediation actions
4. Document findings for the incident responder

Always err on the side of caution - if unsure, ask for human approval.
Format your responses clearly with:
- Incident Analysis
- Likely Root Cause
- Suggested Actions (prioritized)
- Risks to Consider"""
        
        user_message = f"""Please analyze this incident and suggest actions:
        
{json.dumps(incident_context, indent=2)}"""
        
        messages = [{"role": "user", "content": user_message}]
        
        # Agentic loop
        while True:
            response = self.anthropic.messages.create(
                model=self.model,
                max_tokens=4096,
                system=system_prompt,
                tools=tools,
                messages=messages
            )
            
            if response.stop_reason == "end_turn":
                # Extract final response
                for block in response.content:
                    if hasattr(block, 'text'):
                        return block.text
                break
            
            # Process tool calls
            tool_calls = [block for block in response.content if block.type == "tool_use"]
            
            if not tool_calls:
                break
            
            # Add assistant response to messages
            messages.append({"role": "assistant", "content": response.content})
            
            # Process each tool call
            tool_results = []
            for tool_call in tool_calls:
                result = self.execute_tool(tool_call.name, tool_call.input)
                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": tool_call.id,
                    "content": json.dumps(result)
                })
            
            # Add tool results back to conversation
            messages.append({"role": "user", "content": tool_results})
        
        return None
    
    def execute_tool(self, tool_name, input_data):
        """Execute tool requested by AI"""
        
        if tool_name == "create_incident_note":
            print(f"📝 Adding note: {input_data['content'][:100]}...")
            return {"status": "success", "note_created": True}
        
        elif tool_name == "trigger_remediation":
            action = input_data['action_type']
            print(f"🔧 Triggering remediation: {action}")
            return {"status": "success", "action": action, "timestamp": datetime.now().isoformat()}
        
        elif tool_name == "get_similar_incidents":
            # Query incident history
            print(f"🔍 Searching for similar incidents: {input_data['query']}")
            return {
                "incidents": [
                    {"id": "P123456", "title": "Database connection pool exhausted", "resolution": "Increased pool size"},
                    {"id": "P123457", "title": "Similar CPU spike", "resolution": "Identified runaway process"}
                ]
            }
        
        return {"error": f"Unknown tool: {tool_name}"}

# Usage
def respond_to_incident(incident_id):
    responder = PagerDutyAIResponder(
        pagerduty_token="YOUR_TOKEN",
        anthropic_key="YOUR_KEY"
    )
    
    context = responder.get_incident_context(incident_id)
    analysis = responder.analyze_and_suggest_actions(context)
    
    print("\n🤖 AI Incident Analysis:")
    print(analysis)
```

## Generative AI for Code & Config Generation

### GitHub Copilot for Ansible Playbooks

```yaml
# Example Copilot suggestion workflow
---
# User writes comment and Copilot generates playbook
# Comment: Create a playbook to deploy a Node.js app to AWS EC2

- name: Deploy Node.js Application to AWS
  hosts: webservers
  become: yes
  vars:
    app_port: 3000
    nodejs_version: "18"
    domain: "myapp.example.com"

  tasks:
  - name: Update system packages
    ansible.builtin.yum:
      name: '*'
      state: latest

  - name: Install Node.js
    ansible.builtin.shell: |
      curl -sL https://rpm.nodesource.com/setup_{{ nodejs_version }}.x | bash -
      yum install -y nodejs

  - name: Create application user
    ansible.builtin.user:
      name: nodeapp
      shell: /bin/bash
      home: /opt/nodeapp

  - name: Clone application repository
    ansible.builtin.git:
      repo: "{{ app_repo }}"
      dest: /opt/nodeapp/app
      version: "{{ app_version }}"
    become_user: nodeapp

  - name: Install dependencies
    ansible.builtin.npm:
      path: /opt/nodeapp/app
    become_user: nodeapp

  - name: Setup systemd service
    ansible.builtin.template:
      src: nodeapp.service.j2
      dest: /etc/systemd/system/nodeapp.service
    notify: restart nodeapp

  - name: Start application
    ansible.builtin.systemd:
      name: nodeapp
      enabled: yes
      state: started

  handlers:
  - name: restart nodeapp
    ansible.builtin.systemd:
      name: nodeapp
      state: restarted
```

### Claude for Terraform Code Generation

```python
# terraform_generator.py
import anthropic

def generate_terraform_code(infrastructure_requirements):
    """Use Claude to generate Terraform code"""
    
    client = anthropic.Anthropic()
    
    prompt = f"""Generate production-ready Terraform code for the following infrastructure:
    
{infrastructure_requirements}

Requirements:
- Include proper state management
- Add input variables with validation
- Include outputs
- Add security best practices (encryption, IAM, security groups)
- Include comments explaining each resource
- Follow Terraform naming conventions

Provide only the Terraform code, properly formatted."""
    
    message = client.messages.create(
        model="claude-3-5-sonnet-20241022",
        max_tokens=4096,
        messages=[
            {
                "role": "user",
                "content": prompt
            }
        ]
    )
    
    return message.content[0].text

# Usage
infra_req = """
- VPC with 3 public subnets and 3 private subnets across 3 availability zones
- RDS PostgreSQL database with Multi-AZ
- ECS cluster with ALB
- CloudWatch monitoring
- VPC endpoints for S3 and DynamoDB
"""

terraform_code = generate_terraform_code(infra_req)
print(terraform_code)
```

## AI-Powered Monitoring & Anomaly Detection

### Anomaly Detection with Isolation Forest

```python
# anomaly_detection.py
import numpy as np
from sklearn.ensemble import IsolationForest
import json

class MetricsAnomalyDetector:
    def __init__(self, contamination=0.1):
        self.model = IsolationForest(contamination=contamination, random_state=42)
        self.trained = False
    
    def train_on_baseline(self, baseline_metrics):
        """Train on normal operating metrics"""
        
        # Convert metrics to features
        features = self._extract_features(baseline_metrics)
        
        self.model.fit(features)
        self.trained = True
        print(f"✅ Model trained on {len(features)} baseline samples")
    
    def detect_anomalies(self, current_metrics):
        """Detect anomalies in current metrics"""
        
        if not self.trained:
            return None
        
        features = self._extract_features([current_metrics])
        predictions = self.model.predict(features)
        anomaly_scores = self.model.score_samples(features)
        
        is_anomaly = predictions[0] == -1
        
        return {
            'is_anomaly': is_anomaly,
            'anomaly_score': anomaly_scores[0],
            'alert_severity': self._calculate_severity(anomaly_scores[0])
        }
    
    def _extract_features(self, metrics_list):
        """Extract ML features from metrics"""
        
        features = []
        for metrics in metrics_list:
            feature_vector = [
                metrics.get('cpu_usage', 0),
                metrics.get('memory_usage', 0),
                metrics.get('disk_io_read', 0),
                metrics.get('disk_io_write', 0),
                metrics.get('network_in', 0),
                metrics.get('network_out', 0),
                metrics.get('request_rate', 0),
                metrics.get('error_rate', 0),
                metrics.get('response_time_p95', 0),
            ]
            features.append(feature_vector)
        
        return np.array(features)
    
    def _calculate_severity(self, anomaly_score):
        """Map anomaly score to severity level"""
        
        # Lower score = more anomalous
        if anomaly_score < -0.7:
            return "CRITICAL"
        elif anomaly_score < -0.5:
            return "HIGH"
        elif anomaly_score < -0.3:
            return "MEDIUM"
        else:
            return "LOW"

# Usage
detector = MetricsAnomalyDetector()

# Train on baseline
baseline_metrics = [
    {'cpu_usage': 45, 'memory_usage': 60, 'disk_io_read': 100, 'network_in': 500},
    {'cpu_usage': 48, 'memory_usage': 62, 'disk_io_read': 105, 'network_in': 510},
    {'cpu_usage': 42, 'memory_usage': 58, 'disk_io_read': 95, 'network_in': 490},
]
detector.train_on_baseline(baseline_metrics)

# Detect anomalies
current = {'cpu_usage': 95, 'memory_usage': 89, 'disk_io_read': 500, 'network_in': 2000}
result = detector.detect_anomalies(current)

if result['is_anomaly']:
    print(f"🚨 Anomaly detected! Severity: {result['alert_severity']}")
else:
    print("✅ Metrics normal")
```

## LLM-Powered Documentation & Runbook Generation

### Auto-generate Runbooks from Incidents

```python
# runbook_generator.py
import anthropic

class RunbookGenerator:
    def __init__(self):
        self.client = anthropic.Anthropic()
    
    def generate_runbook(self, incident_data):
        """Generate runbook from past incident"""
        
        prompt = f"""Based on this incident history, generate a clear, actionable runbook:

Incident Title: {incident_data['title']}
Description: {incident_data['description']}
Root Cause: {incident_data['root_cause']}
Resolution Steps: {json.dumps(incident_data['resolution_steps'], indent=2)}
Duration: {incident_data['duration_minutes']} minutes
Impact: {incident_data['impact']}

Generate a runbook with:
1. Incident identification (what to look for)
2. Immediate response steps (triage)
3. Root cause analysis process
4. Resolution steps (prioritized)
5. Prevention measures
6. Escalation criteria
7. Post-incident actions

Format as markdown with clear sections."""
        
        message = self.client.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=2000,
            messages=[
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        )
        
        return message.content[0].text

# Usage
incident = {
    'title': 'Database Connection Pool Exhaustion',
    'description': 'Application unable to connect to database, 500 errors',
    'root_cause': 'Connection leak in new code deployment',
    'resolution_steps': [
        'Identified connection leak in user service',
        'Rolled back deployment',
        'Restarted application servers',
        'Verified database connections returned to normal'
    ],
    'duration_minutes': 35,
    'impact': '15 minutes of service degradation'
}

generator = RunbookGenerator()
runbook = generator.generate_runbook(incident)
print(runbook)
```

## Building AI-Powered Automation Agents

### Agent Architecture

```python
# ai_agent_framework.py
from typing import Any, Dict, List
import anthropic

class DevOpsAgent:
    """Autonomous agent for DevOps tasks"""
    
    def __init__(self):
        self.client = anthropic.Anthropic()
        self.tools = self._initialize_tools()
        self.memory = []
    
    def _initialize_tools(self):
        """Define available tools for the agent"""
        
        return [
            {
                "name": "check_service_status",
                "description": "Check if a service is running",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "service_name": {"type": "string"}
                    }
                }
            },
            {
                "name": "restart_service",
                "description": "Restart a service",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "service_name": {"type": "string"}
                    }
                }
            },
            {
                "name": "scale_deployment",
                "description": "Scale a Kubernetes deployment",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "deployment_name": {"type": "string"},
                        "replicas": {"type": "integer"}
                    }
                }
            },
            {
                "name": "query_logs",
                "description": "Query application logs",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "service": {"type": "string"},
                        "time_range": {"type": "string"},
                        "filter": {"type": "string"}
                    }
                }
            }
        ]
    
    def run_task(self, task_description: str) -> str:
        """Run an autonomous task"""
        
        messages = [
            {
                "role": "user",
                "content": task_description
            }
        ]
        
        system_prompt = """You are an autonomous DevOps agent. Your job is to:
1. Analyze the task
2. Use available tools to accomplish it
3. Make decisions autonomously (but safely)
4. Report results

Always consider safety and never make risky changes without confirmation."""
        
        while True:
            response = self.client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=4096,
                system=system_prompt,
                tools=self.tools,
                messages=messages
            )
            
            # Check if task complete
            if response.stop_reason == "end_turn":
                # Extract final response
                for block in response.content:
                    if hasattr(block, 'text'):
                        return block.text
                break
            
            # Process tool calls
            tool_calls = [block for block in response.content if block.type == "tool_use"]
            
            if not tool_calls:
                break
            
            # Add assistant message
            messages.append({"role": "assistant", "content": response.content})
            
            # Execute tools and gather results
            tool_results = []
            for tool_call in tool_calls:
                result = self._execute_tool(tool_call.name, tool_call.input)
                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": tool_call.id,
                    "content": json.dumps(result)
                })
            
            # Add results back to conversation
            messages.append({"role": "user", "content": tool_results})
        
        return "Task completed"
    
    def _execute_tool(self, tool_name: str, inputs: Dict[str, Any]) -> Dict:
        """Execute requested tool (mock implementation)"""
        
        if tool_name == "check_service_status":
            return {"status": "running", "uptime": "24h"}
        elif tool_name == "query_logs":
            return {"logs": ["INFO: Request processed", "DEBUG: Cache hit"]}
        else:
            return {"result": "Tool executed successfully"}

# Usage
agent = DevOpsAgent()
result = agent.run_task("Check if the API service is running and restart if needed")
print(result)
```

## Best Practices for AI in DevOps

### 1. Human-in-the-Loop Decision Making

```python
def critical_action_requires_approval(action_type, severity):
    """Require human approval for critical actions"""
    
    critical_actions = [
        'delete_database',
        'scale_down_all_instances',
        'modify_security_group',
        'rollback_production'
    ]
    
    if action_type in critical_actions or severity == 'CRITICAL':
        return True
    
    return False
```

### 2. Monitoring AI Decision Quality

```python
# Track AI decision outcomes for continuous improvement
ai_decision_tracker = {
    'total_decisions': 1000,
    'correct_decisions': 950,
    'false_positives': 30,
    'false_negatives': 20,
    'accuracy': 0.95,
    'trends': 'Improving with more training data'
}
```

### 3. Security Considerations

- Never expose secrets to AI models
- Validate all AI-generated code before deployment
- Rate-limit AI API calls
- Audit all AI-driven actions
- Maintain human oversight of critical systems

## Conclusion

Generative AI and agentic AI are transforming DevOps. By combining AI-assisted coding, autonomous incident response, and intelligent monitoring, you can reduce MTTR, improve system reliability, and free your team to focus on strategic work.

The future is collaborative: humans making strategic decisions, AI handling tactical execution.

---

**How are you exploring AI in your DevOps practice? Share your experiments in the comments!**
