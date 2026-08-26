# Nginx Demonstration Workload

## Objective

The `nginx-demo` namespace provides a controlled set of Kubernetes resources
for the backup and restore demonstration.

```text
nginx-demo namespace
|-- ConfigMap: nginx-content
|-- Deployment: nginx (2 replicas)
|-- Pods: nginx
`-- Service: nginx (ClusterIP)
```

The ConfigMap supplies a custom HTML page mounted into the Nginx containers.
Restoring the ConfigMap and its content therefore demonstrates more than simply
recreating a generic Deployment.

## Manifest

All resources are defined declaratively in `manifests/nginx-demo.yaml`.

The Deployment includes:

- two replicas;
- CPU and memory requests and limits;
- readiness and liveness probes;
- an unprivileged Nginx image with all additional Linux capabilities removed;
- a read-only ConfigMap volume mount;
- stable application labels used by the Service selector.

The Service uses `ClusterIP` because public exposure is not required to
validate Velero backup and restore.

## Deployment and verification

```bash
kubectl apply -f manifests/nginx-demo.yaml
kubectl rollout status deployment/nginx -n nginx-demo
kubectl get deployment,pods,service,configmap -n nginx-demo
```

The workload is ready for backup only when:

- the Deployment reports both replicas available;
- both pods are `Running` and `Ready`;
- the Service has a ClusterIP;
- the `nginx-content` ConfigMap exists;
- an in-cluster request returns the custom page.

## Validated result

The Deployment completed successfully with two available replicas. Both pods
were `Running` and `Ready`, the ClusterIP Service resolved inside the cluster,
and an HTTP request returned the custom heading from `nginx-content`.

The initial standard Nginx image required a filesystem ownership operation
that conflicted with the restricted container capabilities. It was replaced by
the official unprivileged Nginx image on port 8080, preserving the security
controls without granting additional capabilities.

## Backup scope

The upcoming Velero backup targets the complete `nginx-demo` namespace. The
namespace will then be deleted and restored from Azure Blob Storage.
