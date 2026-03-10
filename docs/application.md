
# APPLICATION CHART

## Sample

mbcaas-chart usage sample

- [Regcreds](#regcreds)
- [Secrets](#secrets)
- [ConfigMap](#configmap)
- [Volumes](#pvc)
- [Deployment](#deployment)
  - [Probes](#probes)
- [CronJob](#cronjob)

## Change:

<details markdown="1">
<summary><strong>0.16.0</strong></summary>

- Add `startupProbe` support (alongside existing `liveness` and `readiness`)
- Add `PodDisruptionBudget` support (`pdb.minAvailable` / `pdb.maxUnavailable`)
- Fix `RollingUpdate` strategy — `maxSurge` and `maxUnavailable` now properly rendered
- Documentation added in `values.yaml` and `docs/application.md`

</details>

<details markdown="1">
<summary><strong>0.14.0</strong></summary>

- Secret now accept annotations
- **!! Breaking !!** Deployment ingress now defined as array.

use:

```yaml
deploys:
  # ...
  ingress:
  - host: poc.dummy.com
    paths:
      - path: /
        type: Prefix
        port: http
```

instead of:

```yaml
deploys:
  # ...
  ingress:
    host: poc.dummy.com
    paths:
      - path: /
        type: Prefix
        port: http
```

</details>

## Regcreds

Allow you to pull image from private registry

```yaml
regcreds:
  ghcr-personnal-token:
    registry: ghcr.io
    username: JohnDoe
    password: ghp_wqcFqdjnYV6AYuqiAtLZ0V6MOqoPY0pn8gs
```

## Secrets

Allow you to define secret value, can be use in env vars

```yaml
secrets:
  api-creds:
    annotations:
      replicator.v1.mittwald.de/replication-allowed: "true"
    stringData:
      auth_user: AdminJohnDoe
      auth_password: 6EQUJ5wow!
```

## ConfigMap

Allow you to define image extarnal file and mount it on runtine

```yaml
cms:
  apps-files:
    application.yaml: |
      application:
        title: Dummy App
        version: ${APP_VERSION}

      server:
        port: ${APP_PORT}

      management:
        endpoints:
          web:
            exposure:
              include: health,info,prometheus

      api:
        uri: ${API_BASE_URI}
        auth:
          user: ${API_BASIC_AUTH_USER}
          password: ${API_BASIC_AUTH_USER}
```

## pvc

```yaml
pvc:
  backup-store:
    size: 50Gi
    accessMode: ReadWriteOnce
    storageClass: hdd-file
```

## Deployment

Allow you to define and configure workload

```yaml
deploys:
  - name: dummy-app
    imagePullSecrets: ghcr-personnal-token
    strategy: RollingUpdate # Optional | default: 'Recreate' | Can be 'Recreate' or 'RollingUpdate'. nb: RollingUpdate may not be possible if namespace quota do not permit to create a new pod
    maxSurge: 1             # Optional | default: 25% | RollingUpdate only - extra pods created during rollout (int or percentage)
    maxUnavailable: 0       # Optional | default: 25% | RollingUpdate only - max pods unavailable during rollout (int or percentage)
    image:
      repository: ghcr.io/johndoe/johndoe/dummy-app
      pullPolicy: IfNotPresent
      tag: 1.0.0

    replicaCount: 1 # Optional | default: 1

    enableServiceLinks: false # Optional | default: true - Disable Kubernetes service environment variable injection into the pod

    # Container command
    cmd:
      shell: "/bin/bash"
      exec: "tail -f"

    # Container args to pass to entrypoint
    args: run

    # Resource allocated to dummy-app
    resources:   # Optional
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 100m
        memory: 128Mi

    serviceAccount:   # Optional
      create: true
      name: dummy-sa

    # Environment variable
    env:
      fromValue:
        APP_VERSION: 1.0.0
        APP_PORT: 8080
        API_BASE_URI: https://api.foo.com/
      fromSecret:
        API_BASIC_AUTH_USER:
          secret: api-creds
          key: auth_user
        API_BASIC_AUTH_PWD:
          secret: api-creds
          key: auth_password

    # Volumes
    volumes:
  
      # In this sample, the 'apps-files' ConfigMap contains one file called 'application.yaml'.
      # By mounting this config map into '/app/config', container contains at runtime a file '/app/config/application.yaml'
      configMap:
        - name: apps-files
          mount: /app/config/

      # use persistent volume claim define in pvc section
      persistentVolumeClaim:
        - name: backup-store
          mount: /data/backup

    # Workload port exposition, internal to cluster 
    service:
      ports:
        - port: 80
          protocol: TCP
          name: http

    # PodDisruptionBudget - protects pods during voluntary disruptions (node drain, maintenance)
    pdb:                    # Optional
      minAvailable: 1       # Min pods that must remain available (int or percentage e.g. "50%")
      # maxUnavailable: 1   # OR max pods that can be unavailable - mutually exclusive with minAvailable

    # Health probes (Optional)
    # startup: checked at boot until success, then disabled. Blocks liveness/readiness during init.
    # liveness: restarts the container if it fails continuously.
    # readiness: removes the pod from Service endpoints if it fails.
    probe:
      startup:
        httpGet:
          path: /health
          port: 8080
        failureThreshold: 30  # 30 * periodSeconds = max boot time before considered failed
        periodSeconds: 10
      liveness:
        httpGet:
          path: /health
          port: 8080
        initialDelaySeconds: 10
        periodSeconds: 10
        failureThreshold: 3
      readiness:
        httpGet:
          path: /ready
          port: 8080
        initialDelaySeconds: 5
        periodSeconds: 5
        failureThreshold: 3

    # Service www exposition
    ingress:
      - host: poc.dummy.com
        paths:
          - path: /
            type: Prefix
            port: http
```


## Probes

| Probe | Rôle | Comportement en cas d'échec |
|-------|------|-----------------------------|
| `startup` | Attend que l'app soit prête au démarrage. Bloque liveness et readiness le temps qu'elle réussisse. | Tue le container si `failureThreshold` est dépassé |
| `liveness` | Vérifie que l'app tourne correctement. | Redémarre le container |
| `readiness` | Vérifie que l'app peut recevoir du trafic. | Retire le pod des endpoints du Service |

Chaque probe accepte la syntaxe Kubernetes standard : `httpGet`, `tcpSocket`, `exec`, ainsi que les champs `initialDelaySeconds`, `periodSeconds`, `timeoutSeconds`, `failureThreshold`, `successThreshold`.

```yaml
deploys:
  - name: dummy-app
    # ...
    probe:
      startup:
        httpGet:
          path: /health
          port: 8080
        failureThreshold: 30   # 30 * 10s = 5 min max pour démarrer
        periodSeconds: 10
      liveness:
        httpGet:
          path: /health
          port: 8080
        initialDelaySeconds: 10
        periodSeconds: 10
        failureThreshold: 3
      readiness:
        httpGet:
          path: /ready
          port: 8080
        initialDelaySeconds: 5
        periodSeconds: 5
        failureThreshold: 3
```

## Cronjob

```yaml
cronjobs:
  - name: influx-backup
    cron: "* * * * *" # Cron got job trigger
    enableServiceLinks: false # Optional | default: true
    image:
      repository: alpine
      pullPolicy: IfNotPresent
      tag: 3.19

    # Override container image command
    cmd: 
      shell: "/bin/ash" # Shell to use (default: /bin/sh)
      exec: | # command block to exec
        apk add coreutils
        wget https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.7.3-linux-amd64.tar.gz
        tar xvzf ./influxdb2-client-2.7.3-linux-amd64.tar.gz
        mkdir -p /data/`date -d yesterday +%Y`/`date -d yesterday +%m-%B`
        ./influx backup ...  >> /data/`date -d yesterday +%Y`/`date -d yesterday +%m-%B`/`date -d yesterday +%d-%A`.csv

    # Volumes (same as deployment part)
    volumes:
      persistentVolumeClaim:
        - name: influx-backup-data
          mount: /data
```

## Job

```yaml
jobs:
  - name: init-db
    image:
      repository: alpine
      pullPolicy: IfNotPresent
      tag: 3.19

    backoffLimit: 2        # 2 retries
    enableServiceLinks: false # Optional | default: true

    # Override container image command
    cmd: 
      shell: "/bin/ash" # Shell to use (default: /bin/sh)
      exec: | # command block to exec
        mongo my-db-address:27017 /data/init-database.js


    # Volumes (same as deployment part)
    volumes:
      persistentVolumeClaim:
        - name: mongo-scripts-js
          mount: /data
   
```
