# MBCaaS Chart

## Sample

```yaml
deploys:
  - name: dummy-app
    image:
      repository: nginx
      pullPolicy: IfNotPresent
      tag: "latest"

    serviceAccount:
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
