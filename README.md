
## Sample

```yaml
deploys:
  - name: dummy-app
    image:
      repository: nginx
      pullPolicy: IfNotPresent
      tag: "latest"

    replicaCount: 1 # Optional | default: 1

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

    service:
      ports:
        - port: 80
          protocol: TCP
          name: http

    ingress:
      admin: false
      host: poc.dummy.com
      paths:
        - path: /
          type: Prefix
          port: http
```
