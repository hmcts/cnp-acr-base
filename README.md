# acr-base-importer
Pipelines to automatically import updates to base images and scan them for vulnerabilities

# ACR Cache
The pipeline will also create ACR Caches into hmctspublic registry.

To create a new ACR cache on a repository you need to amend the acr-repositories.yaml file, to add the required details of the new cache. You need to add the following block of code, replacing the values of the parameters with the one you need creating. The below is just an example of an existing ACR Cache
 
 ```
  jenkins: # this can be the same as the name of the repository
    ruleName: Jenkins # the name of the cache rule
    repoName: hmcts/jenkins # the name of the repository
    destinationRepo: jenkins # destination repository as it appears in the ACR Cache
    tagVersion: "75c3e8818c" # The version of the image you need to pull into the Cache; before the image can be used in the cache it needs to be pulled into it by the pipeline
```

The pipeline will also pull the docker image with the tag specified above into the cache.