# Guía de Pruebas (Testing Guide)

Sigue estos pasos para verificar que cada componente del stack está funcionando correctamente.

## 1. Verificación de Infraestructura (Terraform + GKE)
Después de ejecutar `./setup.sh`:
- **Comando:** `kubectl get nodes`
  - *Resultado esperado:* Deberías ver 2 nodos en estado `Ready`.
- **Comando:** `gcloud container clusters list`
  - *Resultado esperado:* El cluster `senior-devops-cluster` debe aparecer en estado `RUNNING`.

## 2. Verificación de Seguridad (Workload Identity)
- **Comando:** `kubectl get sa`
  - *Resultado esperado:* Deberías ver las ServiceAccounts de Kubernetes creadas por Flux y por el sistema.
- **Validación:** Revisa en la consola de Google Cloud (IAM > Workload Identity Federation) que el pool `github-pool` existe y tiene el proveedor configurado.

## 3. Probar el CI/CD (GitHub Actions)
1. Haz un pequeño cambio en `src/index.html` (ej: cambia el color de fondo o el texto).
2. Haz push a tu rama `main`:
   ```bash
   git add .
   git commit -m "Test CI/CD pipeline"
   git push origin main
   ```
3. Ve a la pestaña **Actions** en GitHub.
4. *Resultado esperado:* El workflow debe ejecutarse, construir la imagen y subirla al Artifact Registry sin pedirte contraseñas (usando WIF).

## 4. Probar el GitOps (Flux CD)
Una vez que el CI/CD haya terminado y el manifiesto `deployment.yaml` se haya actualizado con el nuevo tag de imagen:
- **Comando:** `flux get kustomizations`
  - *Resultado esperado:* `READY` en `True` y el status `Applied revision: main/...`.
- **Comando:** `kubectl get pods -l app=nginx-webpage`
  - *Resultado esperado:* Los pods deben estar en `Running` y con un tiempo de vida (AGE) reciente (indicando que se reiniciaron para usar la nueva imagen).

## 5. Ver el Sitio en Vivo
- **Comando:** `kubectl get svc nginx-service`
  - *Resultado esperado:* Copia la `EXTERNAL-IP`.
- **Acción:** Pega la IP en tu navegador.
  - *Resultado esperado:* Verás tu página estática con los cambios que hiciste.

## 6. Probar el Auto-escalado (HPA)
Si quieres ver el HPA en acción, puedes estresar el pod:
- **Comando:** 
  ```bash
  kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://nginx-service; done"
  ```
- **Acción:** En otra terminal corre `kubectl get hpa nginx-hpa -w`.
  - *Resultado esperado:* Verás como el número de replicas sube de 2 a más a medida que aumenta la carga.
