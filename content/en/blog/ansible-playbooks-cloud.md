---
author: Navdeep Kaur
title: "Ansible Playbooks for Cloud Infrastructure: From AWS to IBM Cloud"
date: 2024-06-15
description: "Comprehensive guide to Ansible playbooks for multi-cloud infrastructure management. Learn best practices, role structures, and real-world examples across AWS, Azure, and IBM Cloud."
keywords: ["ansible", "infrastructure", "cloud", "aws", "ibm-cloud", "configuration-management"]
tags: ["ansible", "iac", "aws", "ibm-cloud", "devops"]
categories: ["DevOps", "Infrastructure"]
thumbnail: "/images/thumbnails/ansible-cloud-playbooks.svg"
---

## Introduction

At IBM, I managed infrastructure across AWS, IBM Cloud, and on-premises using Ansible. In this article, I'll share production-proven patterns for managing multi-cloud infrastructure with Ansible playbooks.

## Ansible Fundamentals

### Directory Structure

```
ansible-infrastructure/
├── inventories/
│   ├── production/
│   │   ├── hosts.yaml
│   │   ├── group_vars/
│   │   │   ├── webservers.yaml
│   │   │   ├── databases.yaml
│   │   │   └── all.yaml
│   │   └── host_vars/
│   │       └── web-prod-01.yaml
│   ├── staging/
│   │   └── hosts.yaml
│   └── development/
│       └── hosts.yaml
├── roles/
│   ├── common/
│   │   ├── tasks/
│   │   ├── handlers/
│   │   ├── templates/
│   │   └── vars/
│   ├── webserver/
│   ├── database/
│   └── monitoring/
├── playbooks/
│   ├── site.yaml
│   ├── deploy-app.yaml
│   ├── configure-monitoring.yaml
│   └── disaster-recovery.yaml
├── group_vars/
├── host_vars/
├── templates/
├── files/
└── ansible.cfg
```

### Inventory Configuration

```yaml
# inventories/production/hosts.yaml
---
all:
  vars:
    ansible_user: ec2-user
    ansible_ssh_private_key_file: ~/.ssh/prod-key.pem
    environment: production
    region: us-east-1

  children:
    webservers:
      vars:
        server_type: web
      hosts:
        web-prod-01:
          ansible_host: 10.0.1.10
          app_port: 8080
        web-prod-02:
          ansible_host: 10.0.1.11
          app_port: 8080

    databases:
      vars:
        server_type: db
      hosts:
        db-prod-01:
          ansible_host: 10.0.2.10
          db_type: primary
        db-prod-02:
          ansible_host: 10.0.2.11
          db_type: replica

    cache:
      vars:
        server_type: cache
      hosts:
        cache-prod-01:
          ansible_host: 10.0.3.10
```

## AWS Infrastructure Provisioning

### EC2 Instance Deployment

```yaml
---
- name: Deploy EC2 instances on AWS
  hosts: localhost
  gather_facts: no
  vars:
    aws_region: us-east-1
    instance_type: t3.medium
    ami_id: ami-0c55b159cbfafe1f0  # Amazon Linux 2
    instance_count: 3

  tasks:
  - name: Create security group
    amazon.aws.ec2_security_group:
      name: app-sg
      description: Security group for app servers
      region: "{{ aws_region }}"
      rules:
        - proto: tcp
          ports:
            - 80
            - 443
          cidr_ip: 0.0.0.0/0
        - proto: tcp
          ports:
            - 22
          cidr_ip: 10.0.0.0/8

  - name: Launch EC2 instances
    amazon.aws.ec2_instance:
      key_name: prod-key
      instance_type: "{{ instance_type }}"
      image_id: "{{ ami_id }}"
      region: "{{ aws_region }}"
      security_groups:
        - app-sg
      count: "{{ instance_count }}"
      tags:
        Name: app-server
        Environment: production
      user_data: |
        #!/bin/bash
        yum update -y
        yum install -y python3-pip
    register: ec2_instances

  - name: Add instances to inventory
    ansible.builtin.add_host:
      name: "{{ item.public_ip_address }}"
      groups: webservers
      ansible_user: ec2-user
    loop: "{{ ec2_instances.instances }}"

  - name: Wait for SSH to be ready
    ansible.builtin.wait_for:
      host: "{{ item.public_ip_address }}"
      port: 22
      delay: 10
      timeout: 300
    loop: "{{ ec2_instances.instances }}"
```

### RDS Database Setup

```yaml
---
- name: Setup RDS Database
  hosts: localhost
  gather_facts: no
  vars:
    db_instance_id: myapp-db
    db_allocated_storage: 100
    db_engine: postgres
    db_engine_version: '14.7'

  tasks:
  - name: Create DB subnet group
    amazon.aws.rds_subnet_group:
      name: default-subnet-group
      description: Default subnet group for RDS
      subnets:
        - subnet-12345678
        - subnet-87654321

  - name: Create RDS instance
    amazon.aws.rds_instance:
      identifier: "{{ db_instance_id }}"
      allocated_storage: "{{ db_allocated_storage }}"
      engine: "{{ db_engine }}"
      engine_version: "{{ db_engine_version }}"
      db_instance_class: db.t3.medium
      username: admin
      password: "{{ db_password }}"
      db_subnet_group_name: default-subnet-group
      publicly_accessible: no
      backup_retention_period: 30
      multi_az: yes
      storage_encrypted: yes
      tags:
        Environment: production
    register: rds_instance

  - name: Wait for RDS to be available
    amazon.aws.rds_instance_info:
      db_instance_identifier: "{{ db_instance_id }}"
    register: rds_info
    until: rds_info.instances[0].db_instance_status == 'available'
    retries: 30
    delay: 10
```

## IBM Cloud Infrastructure

### VPC and Compute Setup

```yaml
---
- name: Deploy to IBM Cloud
  hosts: localhost
  gather_facts: no
  vars:
    ibm_cloud_api_key: "{{ lookup('env', 'IBM_CLOUD_API_KEY') }}"
    region: us-south
    vpc_name: production-vpc

  tasks:
  - name: Authenticate with IBM Cloud
    ibm.cloudcollection.ibm_is_vpc:
      state: present
      name: "{{ vpc_name }}"
      resource_group: "{{ resource_group_id }}"
    register: vpc_result

  - name: Create subnet
    ibm.cloudcollection.ibm_is_subnet:
      state: present
      name: "{{ vpc_name }}-subnet"
      vpc: "{{ vpc_result.id }}"
      zone: "{{ region }}-1"
      ipv4_cidr_block: "10.0.1.0/24"

  - name: Create VSI (Virtual Server Instance)
    ibm.cloudcollection.ibm_is_instance:
      state: present
      name: app-server-01
      image: ibm-ubuntu-20-04-minimal-amd64-2
      profile: cx2-2x4
      vpc: "{{ vpc_result.id }}"
      zone: "{{ region }}-1"
      primary_network_interface:
        - subnet: "{{ subnet_id }}"
      tags:
        - production
        - web
    register: vsi_result

  - name: Assign floating IP
    ibm.cloudcollection.ibm_is_floating_ip:
      state: present
      name: app-server-01-fip
      target: "{{ vsi_result.primary_ipv4_address }}"
```

## Configuration Management Roles

### Common Role (Applied to All Servers)

```yaml
# roles/common/tasks/main.yaml
---
- name: Update package cache
  ansible.builtin.yum:
    name: '*'
    state: latest
  when: ansible_os_family == 'RedHat'

- name: Install essential packages
  ansible.builtin.package:
    name:
      - git
      - curl
      - wget
      - htop
      - vim
      - python3
      - python3-pip
    state: present

- name: Configure NTP
  ansible.builtin.lineinfile:
    path: /etc/ntp.conf
    regexp: '^server'
    line: 'server pool.ntp.org iburst'

- name: Enable and start NTP service
  ansible.builtin.systemd:
    name: ntpd
    enabled: yes
    state: started

- name: Configure firewall
  ansible.builtin.firewalld:
    service: "{{ item }}"
    permanent: yes
    state: enabled
  loop:
    - ssh
    - http
    - https

- name: Setup log rotation
  ansible.builtin.template:
    src: logrotate.j2
    dest: /etc/logrotate.d/app
    mode: '0644'

- name: Install CloudWatch agent (AWS)
  ansible.builtin.shell: |
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
    rpm -U ./amazon-cloudwatch-agent.rpm
  when: cloud_provider == 'aws'
```

### Web Server Role

```yaml
# roles/webserver/tasks/main.yaml
---
- name: Install Nginx
  ansible.builtin.package:
    name: nginx
    state: present

- name: Create application directory
  ansible.builtin.file:
    path: /var/www/app
    state: directory
    owner: nginx
    group: nginx
    mode: '0755'

- name: Deploy Nginx configuration
  ansible.builtin.template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
  notify: reload nginx

- name: Deploy application health check script
  ansible.builtin.copy:
    src: health-check.sh
    dest: /usr/local/bin/health-check.sh
    mode: '0755'

- name: Configure Nginx for reverse proxy
  ansible.builtin.template:
    src: app-proxy.conf.j2
    dest: /etc/nginx/conf.d/app-proxy.conf
    owner: root
    group: root
    mode: '0644'
  notify: reload nginx

- name: Enable and start Nginx
  ansible.builtin.systemd:
    name: nginx
    enabled: yes
    state: started

- name: Setup SSL certificates
  block:
    - name: Create certbot renewal script
      ansible.builtin.template:
        src: certbot-renew.sh.j2
        dest: /usr/local/bin/certbot-renew.sh
        mode: '0755'
    
    - name: Add cron job for certificate renewal
      ansible.builtin.cron:
        name: "Certbot renewal"
        minute: "0"
        hour: "3"
        job: "/usr/local/bin/certbot-renew.sh"
```

### Database Role

```yaml
# roles/database/tasks/main.yaml
---
- name: Install PostgreSQL
  ansible.builtin.package:
    name: postgresql-server
    state: present

- name: Initialize PostgreSQL database
  ansible.builtin.shell: |
    /usr/pgsql-14/bin/initdb -D /var/lib/pgsql/14/data
  become: yes
  become_user: postgres
  args:
    creates: /var/lib/pgsql/14/data/PG_VERSION

- name: Start PostgreSQL service
  ansible.builtin.systemd:
    name: postgresql-14
    enabled: yes
    state: started

- name: Configure PostgreSQL for replication
  ansible.builtin.lineinfile:
    path: /var/lib/pgsql/14/data/postgresql.conf
    line: "{{ item }}"
  loop:
    - "wal_level = replica"
    - "max_wal_senders = 10"
    - "wal_keep_size = 1GB"
  notify: restart postgresql

- name: Create backup user
  community.postgresql.postgresql_user:
    name: backup_user
    password: "{{ backup_password }}"
    role_attr_flags: REPLICATION

- name: Setup automated backups
  ansible.builtin.cron:
    name: "PostgreSQL backup"
    minute: "0"
    hour: "2"
    job: "pg_dump -U postgres myapp > /backup/db-$(date +\\%Y\\%m\\%d).sql"
```

## Playbook Examples

### Site-wide Configuration Playbook

```yaml
# playbooks/site.yaml
---
- name: Configure all infrastructure
  hosts: all
  become: yes
  vars_files:
    - "group_vars/{{ environment }}.yaml"

  pre_tasks:
    - name: Display configuration
      ansible.builtin.debug:
        msg: "Configuring {{ inventory_hostname }} in {{ environment }}"

  roles:
    - common
    - role: webserver
      when: inventory_hostname in groups['webservers']
    - role: database
      when: inventory_hostname in groups['databases']
    - role: monitoring
      when: inventory_hostname in groups['monitoring']

  post_tasks:
    - name: Verify services
      ansible.builtin.service_facts:
      register: service_facts

    - name: Report service status
      ansible.builtin.debug:
        msg: "Services: {{ service_facts.ansible_facts.services.keys() | list }}"
```

### Application Deployment Playbook

```yaml
# playbooks/deploy-app.yaml
---
- name: Deploy application
  hosts: webservers
  serial: 1  # Rolling deployment
  vars:
    app_version: "{{ deploy_version }}"
    app_repo: "https://github.com/myorg/myapp.git"

  tasks:
  - name: Clone application repository
    ansible.builtin.git:
      repo: "{{ app_repo }}"
      dest: /var/www/app
      version: "v{{ app_version }}"
    become: yes
    become_user: www-data

  - name: Install Python dependencies
    ansible.builtin.pip:
      requirements: /var/www/app/requirements.txt
      virtualenv: /var/www/app/venv

  - name: Run database migrations
    ansible.builtin.shell: |
      source /var/www/app/venv/bin/activate
      python manage.py migrate
    environment:
      DATABASE_URL: "{{ database_url }}"

  - name: Collect static files
    ansible.builtin.shell: |
      source /var/www/app/venv/bin/activate
      python manage.py collectstatic --noinput

  - name: Restart application service
    ansible.builtin.systemd:
      name: myapp
      state: restarted

  - name: Health check
    ansible.builtin.uri:
      url: "http://localhost:8000/health"
      method: GET
      status_code: 200
    retries: 5
    delay: 10
    register: health_check
```

## Advanced Patterns

### Dynamic Inventory with Tags

```python
# inventory_plugins/cloud_inventory.py
from ansible.plugins.inventory import BaseInventoryPlugin, Composable, Cacheable

class CloudInventoryPlugin(BaseInventoryPlugin, Composable, Cacheable):
    NAME = 'cloud_inventory'
    
    def parse(self, inventory, loader, path, cache=True):
        super().parse(inventory, loader, path, cache)
        
        # Fetch instances from cloud provider
        instances = self.fetch_instances()
        
        for instance in instances:
            self.inventory.add_host(instance['name'])
            self.inventory.set_variable(
                instance['name'],
                'ansible_host',
                instance['private_ip']
            )
            
            # Add to groups based on tags
            for tag in instance.get('tags', []):
                self.inventory.add_group(tag)
                self.inventory.add_child(tag, instance['name'])
    
    def fetch_instances(self):
        # Implementation for fetching from AWS/IBM Cloud
        pass
```

## Best Practices

1. **Version Control**: Keep all playbooks in git
2. **Idempotency**: Ensure playbooks are safe to run multiple times
3. **Testing**: Use Molecule for role testing
4. **Documentation**: Document variables and playbook purpose
5. **Secrets**: Use Ansible Vault for sensitive data
6. **Performance**: Use tags, limits, and serial deployment

## Conclusion

Ansible provides powerful, agentless infrastructure management across multiple cloud providers. By organizing roles, using proper inventory structures, and following best practices, you can manage complex multi-cloud environments reliably.

---

**What patterns do you use in your Ansible automation? Share in the comments!**
