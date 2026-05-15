{{- define "patchmon.name" -}}
patchmon
{{- end -}}

{{- define "patchmon.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "patchmon.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "patchmon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "patchmon.labels" -}}
helm.sh/chart: {{ include "patchmon.chart" . }}
{{ include "patchmon.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "patchmon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "patchmon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "patchmon.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "patchmon.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Validate that only one exposure method is enabled */}}
{{- define "patchmon.exposure.validate" -}}
{{- if and .Values.gatewayAPI.enabled .Values.ingress.enabled -}}
  {{- fail "Only one exposure method can be enabled: set either gatewayAPI.enabled or ingress.enabled, not both" -}}
{{- end -}}
{{- end -}}

{{- define "patchmon.db.external.validate" -}}
{{- if eq .Values.database.mode "external" -}}
  {{- $hasUriVal := and .Values.external.postgres.uri (ne .Values.external.postgres.uri "") -}}
  {{- $hasUriSecret := and .Values.external.postgres.uriFromSecret.name (ne .Values.external.postgres.uriFromSecret.name "") -}}
  {{- if not (or $hasUriVal $hasUriSecret) -}}
    {{- if or (eq .Values.external.postgres.host "") (eq .Values.external.postgres.database "") (eq .Values.external.postgres.username "") -}}
      {{- fail "external.postgres: set uri/uriFromSecret OR provide host/database/username (+ password or passwordFromSecret)" -}}
    {{- end -}}
    {{- $hasPwVal := and .Values.external.postgres.password (ne .Values.external.postgres.password "") -}}
    {{- $hasPwSecret := and .Values.external.postgres.passwordFromSecret.name (ne .Values.external.postgres.passwordFromSecret.name "") -}}
    {{- if not (or $hasPwVal $hasPwSecret) -}}
      {{- fail "external.postgres: password is required when uri is not set (use passwordFromSecret preferred)" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "patchmon.redis.host" -}}
{{- if and .Values.patchmon.redis.host (ne .Values.patchmon.redis.host "") -}}
{{ .Values.patchmon.redis.host }}
{{- else if .Values.valkey.enabled -}}
{{ printf "%s-valkey" .Release.Name }}
{{- else -}}
""
{{- end -}}
{{- end -}}

{{- define "patchmon.redis.port" -}}
{{- if and .Values.patchmon.redis.port (ne (.Values.patchmon.redis.port | toString) "") -}}
{{ .Values.patchmon.redis.port }}
{{- else -}}
{{ .Values.valkey.service.port }}
{{- end -}}
{{- end -}}

{{- define "patchmon.postgres.passwordSecretName" -}}
{{- if .Values.postgres.auth.existingSecret -}}
{{ .Values.postgres.auth.existingSecret }}
{{- else -}}
{{ include "patchmon.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "patchmon.postgres.passwordSecretKey" -}}
{{- if .Values.postgres.auth.existingSecret -}}
{{ default "password" .Values.postgres.auth.existingSecretPasswordKey }}
{{- else -}}
POSTGRES_PASSWORD
{{- end -}}
{{- end -}}
