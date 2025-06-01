#!/bin/sh
# Patch CSI sidecar deployments with nodeSelector and tolerations

# Save patched objects
yq eval-all '
  select(.kind == "Deployment" and (
    .metadata.name == "csi-attacher" or
    .metadata.name == "csi-provisioner" or
    .metadata.name == "csi-resizer" or
    .metadata.name == "csi-snapshotter"
  ))
  | .spec.template.spec.nodeSelector = {"node-role.kubernetes.io/control-plane": "true"}
  | .spec.template.spec.tolerations = [
      {"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"},
      {"key":"node-role.kubernetes.io/master","operator":"Exists","effect":"NoSchedule"},
      {"key":"CriticalAddonsOnly","operator":"Exists","effect":"NoSchedule"}
    ]
' - > /tmp/longhorn-patched.yaml

# Keep the rest of the unpatched documents
yq eval-all '
  select(.kind != "Deployment" or (
    .metadata.name != "csi-attacher" and
    .metadata.name != "csi-provisioner" and
    .metadata.name != "csi-resizer" and
    .metadata.name != "csi-snapshotter"
  ))
' - /tmp/longhorn-patched.yaml
