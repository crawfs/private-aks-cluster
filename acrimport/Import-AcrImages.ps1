$RegistryName = "acrjccdevaue"
$SourceRegistry = "k8s.gcr.io"
$ControllerImage = "ingress-nginx/controller"
$ControllerTag = 1.6.4
$PatchImage = "ingress-nginx/kube-webhook-certgen"
$PatchTag = 1.5.1
$DefaultBackendImage = "defaultbackend-amd64"
$DefaultBackendTag = 1.5


az acr import --name $RegistryName --source $SourceRegistry/${ControllerImage}:$ControllerTag --image ${ControllerImage}:$ControllerTag
az acr import --name $RegistryName --source $SourceRegistry/${PatchImage}:$PatchTag --image ${PatchImage}:$PatchTag
az acr import --name $RegistryName --source $SourceRegistry/${DefaultBackendImage}:$DefaultBackendTag --image ${DefaultBackendImage}:$DefaultBackendTag