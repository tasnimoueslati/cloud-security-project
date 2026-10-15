#!/usr/bin/env bash
# Simulation controlee : uniquement contre MON cluster de test
HOST="app.20.74.94.241.nip.io"
NS="production"
SA="system:serviceaccount:production:developer-sa"
log() { echo "[$(date -u +%H:%M:%S) UTC] $*"; }

log "ETAPE 1 - Rafale de 150 requetes HTTP invalides vers mon Ingress"
for i in $(seq 1 150); do
  curl -sk -o /dev/null "https://$HOST/admin-$i"
done

log "ETAPE 2 - Operations non autorisees sur l'API Kubernetes (developer-sa)"
for i in $(seq 1 5); do
  kubectl delete deployment web -n "$NS" --as="$SA" 2>&1 | tail -n 1
  kubectl create deployment unauthorized-test --image=nginx -n "$NS" --as="$SA" 2>&1 | tail -n 1
done

log "ETAPE 3 - Mouvement lateral bloque (intruder vers db)"
kubectl exec -n "$NS" intruder -- curl -s -m 3 http://db > /dev/null
echo "code de sortie : $? (28 = connexion bloquee)"

log "FIN"
