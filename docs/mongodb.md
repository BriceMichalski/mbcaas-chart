# MONGO CHART

## Global cluster config

```yaml
cluster:
  name: mongodb-cluster     # Cluster Name
  version: 7.0.11           # Mongo Version
  members: 1                # NUmber of Mongo Node
```

## Storage size

```yaml
storage:
  data: 10G
  logs: 2G
```

## Mongod resources
```yaml
resources:
  limits:
    cpu: "0.2"
    memory: 250M
  requests:
    cpu: "0.2"
    memory: 200M
```

## User Settings

```yaml
# Root user (required)
adminUser: root
adminPassword: azertyuiop

# Additional User
users:
- name: admin
  password: azertyuiop
  roles:
  - db: admin
    name: clusterAdmin
```

## Mongo UI ( Mongo-express )

```yaml
gui:
  enabled: true
  host: mongo.exemple.org
  basicAuth:
    user: foo
    password: bar

```