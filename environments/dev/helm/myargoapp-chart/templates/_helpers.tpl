{{- define "myapp.fullname" -}}
{{ printf "%s-%s" .Release.Name }}
{{- end -}}
