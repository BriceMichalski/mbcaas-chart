# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Lint a chart
helm lint charts/application
helm lint charts/kafka
helm lint charts/mongodb

# Render templates locally (dry-run)
helm template my-release charts/application -f charts/application/values.yaml

# Test template rendering with custom values
helm template my-release charts/application --set "deploys[0].name=test"

# Package a chart
helm package charts/application
```

## Architecture

This is a Helm charts monorepo providing three charts for the MBCaaS platform:

- **`charts/application`** — Generic multi-workload chart. The main chart. See [docs/application.md](docs/application.md).
- **`charts/kafka`** — Wraps Strimzi CRDs (`KafkaNodePool`, `Kafka`, `KafkaTopic`) for KRaft-mode Kafka clusters.
- **`charts/mongodb`** — Wraps MongoDB Community Operator CRDs for MongoDB replica sets with optional GUI.

### Application chart structure

The `application` chart follows a **list-based multi-resource** pattern: each top-level key accepts a list or map of items, and the chart iterates over them to produce multiple Kubernetes resources in a single release.

Top-level values keys:
- `default` — shared defaults (resources, replicaCount, strategy, probe) inherited by all workloads
- `deploys[]` — list of Deployments (each also renders Service, Ingress, ServiceAccount, PDB inline)
- `cronjobs[]` — list of CronJobs
- `jobs[]` — list of one-shot Jobs
- `secrets{}` — map of Kubernetes Secrets
- `cms{}` — map of ConfigMaps
- `pvc{}` — map of PersistentVolumeClaims
- `regcreds{}` — map of registry pull secret credentials

### Template helpers

`templates/_helpers.tpl` defines named templates used across all workload types:
- `mbcaas.pod` — renders a container spec (image, env, resources, probes, volumeMounts, ports)
- `mbcaas.volumes` — renders the pod-level `volumes:` block for configMap and PVC mounts
- `mbcaas.labels` / `mbcaas.selectorLabels` — standard label sets
- `mbcaas.serviceAccountName` — resolves SA name or falls back to `default`

Workload templates (deployment, cronjob, job) build a `$mainPod` dict and delegate container rendering to `mbcaas.pod`. The `deployment.yaml` also inlines calls to `mbcaas.service`, `mbcaas.ingress`, `mbcaas.poddisruptionbudget`, and `mbcaas.serviceaccount` within the same range loop, separated by `---`.

### Key conventions

- Ingress uses **Traefik** entrypoints (`web` / `websecure`) and **cert-manager** cluster issuers for TLS.
- Env vars are split into `fromValue` (plain) and `fromSecret` (secretKeyRef) maps under each workload's `env:`.
- Volume mounts reference ConfigMap or PVC names that must be defined in `cms`/`pvc` sections of the same release.
- `enableServiceLinks` is opt-in per workload (not set = Kubernetes default `true`).
- `ingress` on a Deployment is an **array** (breaking change from 0.14.0).
- `pdb` supports either `minAvailable` or `maxUnavailable` (mutually exclusive).
