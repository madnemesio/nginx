# Guía de Secretos y Autenticación (Senior DevOps)

Para un proyecto profesional, evitamos descargar archivos JSON de llaves de Google Cloud. En su lugar, usamos **Workload Identity Federation (WIF)**.

## 1. Configurar WIF en Google Cloud

Ejecuta estos comandos en tu terminal (o añádelos a un script de Terraform) para permitir que GitHub hable con GCP sin llaves:

```bash
# 1. Crear el Pool de Identidad
gcloud iam workload-identity-pools create "github-pool" \
    --project="${PROJECT_ID}" --location="global" \
    --display-name="GitHub Pool"

# 2. Crear el Proveedor dentro del Pool
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
    --project="${PROJECT_ID}" --location="global" \
    --workload-identity-pool="github-pool" \
    --display-name="GitHub Provider" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
    --issuer-uri="https://token.actions.githubusercontent.com"

# 3. Permitir que tu cuenta de servicio sea usada por el repositorio
gcloud iam service-accounts add-iam-policy-binding "tu-service-account@${PROJECT_ID}.iam.gserviceaccount.com" \
    --project="${PROJECT_ID}" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')/locations/global/workloadIdentityPools/github-pool/attribute.repository/tu-usuario/tu-repo"
```

## 2. Configurar Secrets en GitHub

Ve a tu repositorio en GitHub: **Settings > Secrets and variables > Actions > New repository secret**.

Añade los siguientes secretos:

| Nombre | Valor Ejemplo | Descripción |
| :--- | :--- | :--- |
| `GCP_PROJECT_ID` | `mi-proyecto-123` | ID de tu proyecto en Google Cloud. |
| `WIF_PROVIDER` | `projects/12345/locations/global/workloadIdentityPools/github-pool/providers/github-provider` | El nombre completo generado en el paso 1.2. |
| `WIF_SERVICE_ACCOUNT` | `github-actions@proyecto.iam.gserviceaccount.com` | La cuenta de servicio con permisos de Docker Push. |
| `GITHUB_TOKEN` | `ghp_xxxxxxxxxxxx` | (Solo para Flux) Tu Personal Access Token. |

## 3. Seguridad de Flux CD

Flux gestiona sus propios secretos dentro del cluster. Cuando corres `flux bootstrap`, Flux crea un SSH Key o usa un Token para escribir en tu repo. **Nunca** compartas el archivo `flux-system/gotk-patches.yaml` si contiene información sensible (aunque por defecto Flux usa Deploy Keys de SSH que son más seguras).

---

### Beneficio Senior:
Al usar WIF, si alguien hackea tu GitHub, **no hay llaves JSON que robar**. El acceso solo funciona desde los servidores de GitHub y expira automáticamente cada hora.
