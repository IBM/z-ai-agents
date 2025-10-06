{{/* templates/_helpers.tpl */}}

{{- define "wxa4z.annotations" -}}
productID: "26a8719e17cd45daa94f2312d450fd6a"
productName: "IBM watsonx Assistant for Z"
productMetric: "RESOURCE_UNIT"
productChargedContainers: "All"
{{- end }}

{{- define "wxa4z.precheck" -}}
  {{- $bad := list -}}
  {{- range $dep := .Chart.Dependencies }}
    {{- $key  := default $dep.Name $dep.Alias -}}        {{/* alias wins if set */}}
    {{- $vals := index $.Values $key | default dict -}}
    {{- $enabled   := (index $vals "enabled" | default false) -}}
    {{- $hasAccept := hasKey $vals "acceptLicense" -}}

    {{/* Enforce only if the key exists and is explicitly false */}}
    {{- if and $enabled $hasAccept (not (index $vals "acceptLicense")) -}}
      {{- $bad = append $bad $key -}}
    {{- end -}}
  {{- end -}}

  {{- if gt (len $bad) 0 -}}
    {{- $compLines := list -}}
    {{- $valLines  := list -}}
    {{- range $bad }}
      {{- $compLines = append $compLines (printf "  - %s" .) -}}
      {{- $valLines  = append $valLines  (printf "     %s:\n       acceptLicense: true" .) -}}
    {{- end -}}

    {{- $message := printf `
ERROR [EULA_NOT_ACCEPTED]: Installation blocked by license requirements

Chart: %s v%s
Release: %s (namespace: %s)

The following components are enabled but their licenses have not been accepted (acceptLicense=false):
%s

Resolution:
  1) Review and accept the license terms for each component listed above.
  2) Re-run Helm with the following:
     - values.yaml (Recommended):
%s

Alternatively, to disable a component:
  --set <component>.enabled=false

If this issue persists, contact support and include this full message.
` .Chart.Name .Chart.Version .Release.Name .Release.Namespace (join "\n" $compLines) (join "\n" $valLines) -}}

    {{- fail $message -}}
  {{- end -}}
{{- end -}}
