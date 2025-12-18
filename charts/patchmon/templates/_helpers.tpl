{{- define "patchmon.name" -}}
patchmon
{{- end -}}

{{- define "patchmon.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "patchmon.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "patchmon.labels" -}}
app.kubernetes.io/name: {{ include "patchmon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "patchmon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "patchmon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
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
{{- if .Values.redis.host -}}
{{ .Values.redis.host }}
{{- else if .Values.valkey.enabled -}}
{{ printf "%s-valkey" .Release.Name }}
{{- else -}}
""
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
{{- /* Always use the chart secret key name */ -}}
POSTGRES_PASSWORD
{{- end -}}
{{- end -}}
