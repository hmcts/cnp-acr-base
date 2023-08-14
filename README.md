# acr-base-importer
Pipelines to automatically import updates to base images and scan them for vulnerabilities
## Supported Upstream Image Repositories

Below is a table of upstream image repositories that will have supported cache rules in hmctspublic. No image tags are added by default, but will be added on the first running instance of `docker pull hmctspublic.azurecr.io/${destinationRepo}:image-tag`, where destinationRepo is the [mapped repository in our ACR for the upstream repository](acr-respositories.yaml), any upstream image tag is available.


| **Upstream Repository Name**  | **HMCTS Repository Name** |
| -------- | ------- |
| `bitnami/postgresql`  | `hmctspublic.azurecr.io/imported/bitnami/postgresql`    |


### ACR Cache Rules
The pipeline will also add ACR Cache Rules into hmctspublic registry.

To create a new ACR cache rule on a repository you need to amend the [yaml file](acr-repositories.yaml), to add the required details of the new cache rule. You need to add the following block of code, replacing the values of the parameters with the one you need creating. The below is just an example of an existing ACR Cache rule
 
 ```
  jenkins: # this can be the same as the name of the repository
    ruleName: Jenkins # the name of the cache rule
    repoName: hmcts/jenkins # the name of the repository the image is currently stored in
    destinationRepo: jenkins # destination repository as it appears in the ACR Cache, will not be visibile until first instance of docker pull command
 ```