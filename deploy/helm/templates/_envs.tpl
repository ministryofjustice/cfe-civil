{{/* vim: set filetype=mustache: */}}
{{/*
Environment variables for web and worker containers
*/}}
{{- define "app.envs" }}
env:
  {{ if .Values.postgresql.enabled }}
  - name: POSTGRES_USER
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: postgresqlUsername
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: postgresqlPassword
  - name: POSTGRES_HOST
    value: {{ printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" }}
  - name: POSTGRES_DATABASE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: postgresqlDatabase
  {{ else }}
  - name: POSTGRES_USER
    valueFrom:
      secretKeyRef:
        name: rds-postgresql-instance-output
        key: database_username
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: rds-postgresql-instance-output
        key: database_password
  - name: POSTGRES_HOST
    valueFrom:
      secretKeyRef:
        name: rds-postgresql-instance-output
        key: rds_instance_address
  - name: POSTGRES_DATABASE
    valueFrom:
      secretKeyRef:
        name: rds-postgresql-instance-output
        key: database_name
  {{ end }}
  - name: SECRET_KEY_BASE
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: secretKeyBase
  - name: SENTRY_DSN
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: sentryDsn
  - name: RAILS_ENV
    value: production
  - name: RAILS_LOG_TO_STDOUT
    value: 'true'
  - name: USE_TEST_THRESHOLD_DATA
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: useTestThresholdData
  - name: HOST
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: deployHost
  - name: LEGAL_FRAMEWORK_API_HOST
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: legalFrameworkApiHost
  - name: SENTRY
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: sentryEnabled
  - name: NOTIFICATIONS_API_KEY
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: notificationsApiKey
  - name: NOTIFICATIONS_ERROR_MESSAGE_TEMPLATE_ID
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: notificationsErrorMessageTemplateId
  - name: NOTIFICATIONS_RECIPIENT
    valueFrom:
      secretKeyRef:
        name: {{ template "app.fullname" . }}
        key: notificationsRecipient
{{- end }}
