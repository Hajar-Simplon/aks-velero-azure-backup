# Screenshot Evidence

Only retain screenshots that prove the brief's required outcomes. Never include
credentials, tokens, account keys, SAS URLs, or unrelated troubleshooting.

## Retained evidence

| File | Requirement proved |
|---|---|
| `04-velero-running-bsl-available.png` | Velero pod is `Running` and the Azure BackupStorageLocation is `Available` in `ReadWrite` mode. |
| `06-backup-completed.png` | `nginx-backup` completed with 54/54 items and no errors or warnings. |
| `07-azure-blob-backup-objects.png` | Backup objects exist under the `backups/nginx-backup/` Azure Blob prefix. |
| `09-restore-completed-resources-running.png` | `nginx-restore` is `Completed` and the restored Deployment, Service, ConfigMap, and pods are healthy. |
