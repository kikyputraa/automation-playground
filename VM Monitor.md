# Monitoring Setup (Prometheus + Grafana)

Manual installation guide for **Prometheus** and **Grafana** on Ubuntu/Debian.

> You can also use the Ansible playbook: `playbook/systemd/monitor/monitor.yml`

---

## 1. Install Prometheus

```sh
# Download and extract
wget https://github.com/prometheus/prometheus/releases/download/v2.51.2/prometheus-2.51.2.linux-amd64.tar.gz \
  -O /tmp/prometheus.tar.gz
tar -xzf /tmp/prometheus.tar.gz -C /opt/
sudo mv /opt/prometheus-2.51.2.linux-amd64 /opt/prometheus

# Create dedicated user
sudo useradd --no-create-home --shell /sbin/nologin prometheus
sudo chown -R prometheus:prometheus /opt/prometheus

# Create data directory
sudo mkdir -p /data
sudo chown prometheus:prometheus /data
sudo chmod 755 /data
```

### Configure Prometheus

Create `/opt/prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
```

```sh
sudo chown prometheus:prometheus /opt/prometheus/prometheus.yml
```

### Create systemd Service

```sh
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus Monitoring
After=network.target

[Service]
User=prometheus
WorkingDirectory=/opt/prometheus
ExecStart=/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now prometheus
```

---

## 2. Install Grafana

```sh
# Add GPG key and repository
wget -q -O - https://packages.grafana.com/gpg.key | gpg --dearmor \
  | sudo tee /usr/share/keyrings/grafana-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/grafana-keyring.gpg] https://packages.grafana.com/oss/deb stable main" \
  | sudo tee /etc/apt/sources.list.d/grafana.list

# Install
sudo apt update && sudo apt install -y grafana
sudo systemctl enable --now grafana-server
```

---

## 3. Add Dashboard to Grafana (Optional)

```sh
# Create dashboard directory
sudo mkdir -p /var/lib/grafana/dashboards
sudo chown grafana:grafana /var/lib/grafana/dashboards

# Copy dashboard JSON
sudo cp dashboard.json /var/lib/grafana/dashboards/default.json
sudo chown grafana:grafana /var/lib/grafana/dashboards/default.json
```

Create provisioning config at `/etc/grafana/provisioning/dashboards/dashboard.yml`:

```yaml
apiVersion: 1
providers:
  - name: default
    orgId: 1
    folder: ''
    type: file
    options:
      path: /var/lib/grafana/dashboards
```

```sh
sudo systemctl restart grafana-server
```

---

## 4. Open Firewall Ports

```sh
sudo ufw allow 9090/tcp   # Prometheus
sudo ufw allow 3000/tcp   # Grafana
sudo ufw reload
```

---

## 5. Access

| Service | URL | Default Credentials |
|---|---|---|
| Prometheus | http://localhost:9090 | — |
| Grafana | http://localhost:3000 | admin / admin |
