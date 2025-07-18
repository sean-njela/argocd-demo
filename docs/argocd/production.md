# And then there was Production...

We will use a python script to freeze the environment until we are ready to deploy to production. In the manual version we will need to add an ignore-tags annotation to everuy app we have deployed which is not ideal.

How the script works:

 1. When ready to deploy, `pause` will create a new branch and add ignore annotations to all apps in the environment. Then create a pull request.
 2. Merging this pull request will freeze teh environment.
 3. Then run the script again by stating a source environment and a destination environment to prepare production push. This creates a pullrequest for the production push. 
 4. Merging this pull request will push to production 
 5. Then we run the script to create a pull request to unfreeze the environment.

We seperated the development(kind) terraform config files from the production(EKS) terraform config files. This is to prevent any accidental changes to the production environment.

Create EC repositories in the AWS console.
Replace the `api_url` and `prefix` with those of the ECR repo in the image-updater.yaml file in the values folder of the prod environment. 

---

the first step after provisioning is to give your local kubernetes config access to teh EKS cluster.:

```sh
aws eks update-kubeconfig --name prod-demo --region eu-north-1
```

`<env>-<name> -> prod-demo`

Then run this command in the image updater pod shell:

```sh
 aws ecr --region eu-north-1 get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d
```
If you get any errors restart the pod, and if persistant, double check your configuration.


---

Replace docker hub in the `my-argocd-app3.yaml` file with the ECR repo. 


We do not have annotations or CD in production apps. We always have CDel.

---

## Deploying Docker Images

You will need to provide docker with ECR credentials to be able to push to the ECR. the easiest way is to clisck the repository and click `view push commands`

 1.

 ```sh
 aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 699475925123.dkr.ecr.eu-north-1.amazonaws.com
 ```

 2. 

 ```sh
docker tag devopssean/zta_demo_app:dev 699475925123.dkr.ecr.eu-north-1.amazonaws.com/devopssean/zta_demo_app1:1.5.0
docker push 699475925123.dkr.ecr.eu-north-1.amazonaws.com/devopssean/zta_demo_app1:1.5.0
 ```

```sh
docker tag devopssean/zta_demo_app:dev 699475925123.dkr.ecr.eu-north-1.amazonaws.com/devopssean/zta_demo_app2:2.5.0
docker push 699475925123.dkr.ecr.eu-north-1.amazonaws.com/devopssean/zta_demo_app2:2.5.0
 ```