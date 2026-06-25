# Task API — DevOps Take-Home Test

## Quick Start

cp .env.example .env
docker compose up -d

## Services

Task API   : http://localhost:8000
Prometheus : http://localhost:9090
Grafana    : http://localhost:3000 (admin/admin)

## CI/CD

Push ke GitHub, pipeline otomatis: lint > test > build & scan > deploy.

## Terraform

cd terraform
terraform init
terraform plan
terraform apply

## Tests

pip install -r requirements.txt pytest requests
BASE_URL=http://localhost:8000 pytest tests/test_api.py -v
