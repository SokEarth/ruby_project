# ruby_project

## Instructions to run this code
To deploy app from a github pipeline
1. Clone this repo.
2. Create a .github/workflow/gifmachine.yaml file on github.
3. Copy pipeline code from the .github/workflow/gifmachine.yaml on this repo.
4. Commit the project and the workflow will run automatically and deploy infrastructure on AWS and install two helm packages in the kubernetes cluster: External secret store and argocd.
5. Find the secret manager created by terraform and add:
   a. rack_env: production
   b. gifmachine_password: foo
6. 
7. To get the url to log into argocd, run
   ```
   kubectl get svc -n argocd
   ```
8. To get the credentials to log into argocd, run
   ```
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
   ```
9. Log in and create project on ArgoCD with url to the helm folder in this repo
10. In the end check the URL of the loadbalancer deployed by argocd
   ```
   kubectl get svc -n default
   ```

11. To run the smoke test, add the loadbalancer url to the last step in the workflow document

## A description of your solution noting interesting choices you made and why you made them
1. I decided to use gitops to implement continuous deployment
  
## A list of resources you consulted to accomplish the exercise
1. https://docs.aws.amazon.com/
2. https://registry.terraform.io/providers/hashicorp/aws/latest/docs
3. https://argo-cd.readthedocs.io/en/stable/
4. https://helm.sh/docs/

## Feedback on the exercise and some information about how long you spent on it
I spent five days on the project
