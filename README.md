# MBCaaS Helm Charts Repository

## Installation 

```bash
$ helm repo add mbcaas https://charts.mbcaas.com/
$ helm repo update
```

## Usage

Search charts name & versions
```bash
$ helm search repo mbcaas
```

Install one chart
```bash
$ helm install my-release mbcaas/<chart>
```

## Chart List

| Chart Name | Usage | Documentation |
|------------|-------|---------------|
|  Applications   |   Deploy custom application to mbcaas       | [application.md](./docs/application.md)       |
|  Kafka          |   Deploy Kafka broker to mbcaas             | [kafka.md](./docs/kafka.md)       |
|  Mongodb        |   Deploy Mongodb to mbcaas                  | [mongodb.md](./docs/mongodb.md)       |

> For more information you can browse https://github.com/BriceMichalski/mbcaas-chart