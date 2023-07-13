{{/*
Expand the name of the chart.
*/}}
{{- define "mbcaas.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mbcaas.fullname" -}}
{{- if .appName }}
{{- .appName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mbcaas.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mbcaas.labels" -}}
{{- $root := .root -}}
{{- $appName := .appName -}}
helm.sh/chart: mbcaas-chart
{{ include "mbcaas.selectorLabels" (dict "root" $root "appName" $appName ) }}
app.kubernetes.io/managed-by: {{ $root.Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mbcaas.selectorLabels" -}}
{{- $root := .root -}}
{{- $appName := .appName -}}
app.kubernetes.io/name: {{ $appName }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mbcaas.serviceAccountName" -}}
{{- $appName := .appName -}}
{{- $sa := .serviceAccount -}}
{{- if (default $sa.name false) }}
    {{- $sa.name }}
{{- else }}
    {{- if (default $sa.create false) }}
        {{- (default $sa.name (printf "%s-%s" $appName "sa" | trunc 63 | trimSuffix "-")) }}
    {{- else }}
        {{- "default" }}
    {{- end }}
{{- end }}
{{- end }}
