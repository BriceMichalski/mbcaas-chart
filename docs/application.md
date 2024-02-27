
# APPLICATION CHART

## Sample

mbcaas-chart usage sample

- [Regcreds](#regcreds)
- [Secrets](#secrets)
- [ConfigMap](#configmap)
- [Volumes](#pvc)
- [Deployment](#deployment)



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
        port : ${APP_PORT}

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
    startegy: Recreate # Can be 'Recreate' or 'RollingUpdate'. default: 'Recreate'. nb: RollingUpdate may not be possible if namespace quota do not permit to create a new pod
    image:
      repository: ghcr.io/johndoe/johndoe/dummy-app
      pullPolicy: IfNotPresent
      tag: 1.0.0

    replicaCount: 1 # Optional | default: 1

    # Container command
    cmd: 
      - java -jar /srv/dummy-app.jar

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

    # Service www exposition
    ingress:
      tls: selfsigned
      host: poc.dummy.com
      paths:
        - path: /
          type: Prefix
          port: http
```


## Cronjob

```yaml
cronjobs:
  - name: influx-backup
    cron: "* * * * *" # Cron got job trigger
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