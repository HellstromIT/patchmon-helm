# PatchMon Helm Chart

This Helm chart deploys the PatchMon application (Backend + Frontend) with optional PostgreSQL and Valkey dependencies.

## Features

- **Full Stack Deployment**: Deploys both frontend and backend services.
- **Database Options**: Can run with an internal PostgreSQL (StatefulSet) or connect to an external PostgreSQL instance.
- **Caching**: Includes Valkey (Redis compatible) as a subchart.
- **Exposure**: Supports Kubernetes Gateway API and standard Ingress.
- **Authentication**: Built-in OIDC (Keycloak) integration.
- **Security**: Configurable SecurityContexts, ServiceAccounts, and standard Kubernetes security practices.

## Installation

```bash
helm repo add patchmon https://patchmon.github.io/charts
helm install my-patchmon patchmon/patchmon
```

## Configuration

The following table lists the configurable parameters of the PatchMon chart and their default values.

### General

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount.backend` | Number of backend replicas | `1` |
| `replicaCount.frontend` | Number of frontend replicas | `1` |
| `image.backend.repository` | Backend image repository | `ghcr.io/patchmon/patchmon-backend` |
| `image.frontend.repository` | Frontend image repository | `ghcr.io/patchmon/patchmon-frontend` |
| `serviceAccount.create` | Create a ServiceAccount | `true` |
| `pdb.create` | Create a PodDisruptionBudget | `false` |

### Networking

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.backend.port` | Backend service port | `3001` |
| `service.frontend.port` | Frontend service port | `3000` |
| `gatewayAPI.enabled` | Enable Gateway API resources | `true` |
| `ingress.enabled` | Enable Ingress resources | `false` |

### Database (PostgreSQL)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `database.mode` | Database mode (`internal` or `external`) | `internal` |
| `postgres.image` | Internal Postgres image | `postgres:16-alpine` |
| `external.postgres.uri` | External Postgres connection URI | `""` |
| `external.postgres.host` | External Postgres host | `""` |

### Authentication (OIDC)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `patchmon.oidc.enabled` | Enable OIDC authentication | `false` |
| `patchmon.oidc.issuerUrl` | OIDC Issuer URL | `""` |
| `patchmon.oidc.clientId` | OIDC Client ID | `"patchmon"` |

### Resources & Security

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources` | CPU/Memory requests and limits | `{}` |
| `securityContext` | Container security context | `{...}` |
| `podSecurityContext` | Pod security context | `{...}` |

## Usage Examples

### Using an External Database

```yaml
database:
  mode: external
external:
  postgres:
    host: "my-postgres-host"
    username: "patchmon"
    password: "securepassword"
    database: "patchmon_db"
```

### Enabling OIDC

```yaml
patchmon:
  oidc:
    enabled: true
    issuerUrl: "https://keycloak.example.com/realms/myrealm"
    clientId: "patchmon-client"
    clientSecret: "my-secret"
```