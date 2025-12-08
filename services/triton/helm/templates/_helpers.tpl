{{/*
Return the chart name
*/}}
{{- define "triton.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the fully qualified name
*/}}
{{- define "triton.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "triton.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end -}}
