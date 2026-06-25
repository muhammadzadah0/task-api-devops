# SealedSecrets — Secret Management

## Cara Kerja
1. Install SealedSecrets controller di cluster:
   kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.26.1/controller.yaml

2. Install kubeseal CLI di lokal:
   wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.26.1/kubeseal-linux-amd64 -O /usr/local/bin/kubeseal
   chmod +x /usr/local/bin/kubeseal

3. Buat SealedSecret dari Secret biasa:
   kubectl create secret generic task-api-secret \
     --namespace task-api \
     --dry-run=client \
     --from-literal=DB_PASSWORD=changeme \
     -o json > secret.json

4. Seal secret (hanya controller yg bisa unseal):
   kubeseal --format=yaml < secret.json > sealed-secrets/task-api-sealed.yaml

5. Hapus secret.json, push sealed-secrets/task-api-sealed.yaml ke git

6. Deploy SealedSecret ke cluster:
   kubectl apply -f sealed-secrets/task-api-sealed.yaml

   Controller akan otomatis membuat Secret asli dari SealedSecret.

## Keuntungan
- Secret terenkripsi bisa di-commit ke git dengan aman
- Hanya SealedSecrets controller di cluster yang bisa mendekripsi
- Aman untuk disimpan di public repository
