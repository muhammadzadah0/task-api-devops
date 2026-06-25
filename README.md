# Task API — DevOps Take-Home Test

## Quick Start

cp .env.example .env
docker compose up -d

## Services

| Service    | URL                     | Login             |
|------------|-------------------------|-------------------|
| Task API   | http://localhost:8000   | —                 |
| Prometheus | http://localhost:9090   | —                 |
| Grafana    | http://localhost:3000   | admin / admin     |

## Project Structure

.github/workflows/ci.yml      # CI/CD pipeline
app.py                         # Flask API + Prometheus metrics
docker-compose.yml             # Local orchestration
Dockerfile                     # Multi-stage build
.env.example                   # Environment template
.gitignore
requirements.txt               # Python dependencies
prometheus/                    # Prometheus config + alert rules
grafana/                       # Grafana auto-provisioning
k8s/                           # Kubernetes manifests
helm/task-api/                 # Helm chart
terraform/                     # IaC (Terraform + Docker provider)
sealed-secrets/                # Secret management
scripts/                       # Backup & restore DB, load test
tests/test_api.py              # Automated tests
.pre-commit-config.yaml        # Pre-commit hooks
SOLUTION.html                  # Full solution document

## CI/CD Pipeline

Trigger: Push / Pull Request ke branch main

| Stage | Tools | Deskripsi |
|-------|-------|-----------|
| 1. Lint | flake8, hadolint | Kualitas kode Python & Dockerfile |
| 2. Test | pytest + PostgreSQL | 5 automated test (health, CRUD, metrics) |
| 3. Build & Scan | Docker Buildx, Trivy | Build image, push ke GHCR, scan CVE |
| 4. Deploy | Simulasi | Hanya saat push ke main |

Tagging image: sha-{commit}, {branch}, v{semver}
Secrets: GitHub Secrets

## Infrastructure as Code (Terraform)

cd terraform
terraform init
terraform validate
terraform plan
terraform apply

Stack: network, PostgreSQL, app, Prometheus, Grafana via Docker provider lokal.

## Observability

Metrics: GET /metrics (request rate, latency, error rate)
Prometheus: http://localhost:9090 (scrape tiap 15s, alert rules)
Grafana: http://localhost:3000 (dashboard auto-provisioned, admin/admin)

Alert Rules:
- TaskAPIDown: App tidak merespon > 1 menit (critical)
- HighErrorRate: Error rate > 5% selama 2 menit (warning)

## Automated Tests

pip install pytest requests
BASE_URL=http://localhost:8000 pytest tests/test_api.py -v

5 test: health, create task, list tasks, missing title validation, metrics.

## Bonus Features

K8s manifests: k8s/namespace.yaml + k8s/deployment.yaml + k8s/postgres.yaml
Helm chart: helm/task-api/ (Chart.yaml, values.yaml, bluegreen)
Blue-green: Deploy preview, switch traffic, rollback
SealedSecrets: Secret terenkripsi aman di git
Backup: scripts/backup.sh + cron tiap jam 3 pagi
Load test: K6 (P95 < 500ms, error < 1%)
Horizontal scaling: docker-compose.scale.yml + nginx
Pre-commit: flake8 + hadolint auto check
Dependabot: Auto update pip, docker, actions tiap Senin

## Technical Decisions

| Keputusan | Alasan |
|-----------|--------|
| Multi-stage build | Image ~130MB vs ~1GB |
| Non-root user | Keamanan |
| gunicorn | Production WSGI |
| DB healthcheck | Hindari race condition |
| Prometheus + Grafana | Industry standard |
| Terraform Docker | IaC tanpa cloud |
| Trivy | Fast CVE scan |

## Security Considerations

- No secrets in image
- .env gitignored
- Non-root container
- CVE scanning tiap build
- SealedSecrets for git-safe encryption
- CI secrets via GitHub Secrets
- Firewall UFW (22, 8000, 9090, 3000 only)
