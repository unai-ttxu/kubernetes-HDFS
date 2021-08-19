{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "hdfs-config-k8s.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hdfs-config-k8s.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hdfs-config-k8s.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the kerberos principal suffix for core HDFS services
*/}}
{{- define "hdfs-principal" -}}
{{- printf "hdfs/_HOST@%s" .Values.kerberos.realm -}}
{{- end -}}

{{/*
Create the kerberos principal for HTTP services
*/}}
{{- define "http-principal" -}}
{{- printf "HTTP/_HOST@%s" .Values.kerberos.realm -}}
{{- end -}}

{{/*
Create the keytabs principals list.
*/}}
{{- define "hdfs-keytabs-principals" -}}
{{- $principalList := list }}
{{- $namenodeName := include "hdfs-k8s.namenode.fullname" . -}}
{{- $replicas := 2 -}}
{{- range $i, $e := until $replicas }}
  {{- define "namenodePrincipal" -}}
    {{- printf "hdfs/%s-%s" .$namenodeName $i -}}
  {{- end -}}
  {{- $principalList = append $principalList .namenodePrincipal }}
{{- end -}}
{{- $journalnodeName := include "hdfs-k8s.journalnode.fullname" . -}}
{{- $replicas := .Values.global.journalnodeQuorumSize | int -}}
{{- range $i, $e := until $replicas }}
  {{- define "journalnodePrincipal" -}}
    {{- printf "hdfs/%s-%s" .$journalnodeName $i -}}
  {{- end -}}
  {{- $principalList = append $principalList .journalnodePrincipal }}
{{- end -}}
{{- $datanodeName := include "hdfs-k8s.datanode.fullname" . -}}
{{- $replicas := .Values.global.datanodeQuorumSize | int -}}
{{- range $i, $e := until $replicas }}
  {{- define "datanodePrincipal" -}}
    {{- printf "hdfs/%s-%s" .$datanodeName $i -}}
  {{- end -}}
  {{- $principalList = append $principalList .datanodePrincipal }}
{{- end -}}
{{- end -}}


{{/*
Create the datanode data dir list.  The below uses two loops to make sure the
last item does not have comma. It uses index 0 for the last item since that is
the only special index that helm template gives us.
*/}}
{{- define "datanode-data-dirs" -}}
{{- range $index, $path := .Values.global.dataNodeHostPath -}}
  {{- if ne $index 0 -}}
    /hadoop/dfs/data/{{ $index }},
  {{- end -}}
{{- end -}}
{{- range $index, $path := .Values.global.dataNodeHostPath -}}
  {{- if eq $index 0 -}}
    /hadoop/dfs/data/{{ $index }}
  {{- end -}}
{{- end -}}
{{- end -}}
