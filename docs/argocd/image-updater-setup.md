# Image Updater Setup


Instead of using CLI helm commands, to setup the image updater, we will use a more repeatable IAC solution.


We will use terraform to install the image updater. (same as we did for argocd)


An ssh key is required for the image updater to work. We will also give it write access to the git repo as we will want to experiement with both git write back methods. This allows the image updater to update the git infra repo with the new image tags.


!!! tip "Delete the key after experiementation is done"
    Since this is a public repo, the key should be deleted after experiementation is done.


Whether we are using private or public docker repos it is the same process. But we will need to provide the image updater with the credentials to access the private repo. 


