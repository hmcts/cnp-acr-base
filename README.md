# acr-base-importer
Pipelines to automatically import updates to base images and scan them for vulnerabilities

# ACR Cache Rules
The pipeline will also create and add ACR Cache Rules into hmctspublic registry.

To create a new ACR cache rule on a repository you need to amend the [yaml file](acr-repositories.yaml), to add the required details of the new cache rule. You need to add the following block of code, replacing the values of the parameters with the one you need creating. The below is just an example of an existing ACR Cache rule:
 
 ```
  jenkins: # this can be the same as the name of the repository
    ruleName: Jenkins # the name of the cache rule
    repoName: hmcts/jenkins # the name of the repository the image is stored in
    destinationRepo: jenkins # destination repository as it will appear in Azure hmctspublic ACR, which the cache rule will be associated to. This will make part of the URL used to fetch the cached image.
    tagVersion: "75c3e8818c" # The version of the image you need to pull into the Cache; before the image can be used in the cache it needs to be pulled into it by the pipeline
```

The pipeline will also pull the docker image with the tag specified above into the cache.