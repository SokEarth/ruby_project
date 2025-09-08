# salsify_project

## Instructions that allow us to run your code
To deploy app from a github pipeline
1. Clone this repo
2. Create a .github/workflow/gifmachine.yaml file on github
3. Copy pipeline code from the .github/workflow/gifmachine.yaml on this repo
4. Commit the project and the workflow will run automatically
5. It will deploy infrastructure on AWS and install two helm packages in the kubernetes cluster: External secret store and argocd.
6. Create project on ArgoCD with url to the helm repo in this 
7. In the end check the URL of the loadbalancer deployed by argocd

## A description of your solution noting interesting choices you made and why you made them
1. I decided to use gitops to implement continuous deployment
  
## A list of resources you consulted to accomplish the exercise
1. https://docs.aws.amazon.com/
2. https://registry.terraform.io/providers/hashicorp/aws/latest/docs
3. https://argo-cd.readthedocs.io/en/stable/
4. https://helm.sh/docs/

## Feedback on the exercise and some information about how long you spent on it
I spent five days on the project
