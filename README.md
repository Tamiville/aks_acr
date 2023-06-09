# Overview
The main purpose of this project is to integrate Datadog monitoring tool with Kubernetes, but before I can start monitoring, I will have to had an infrastructure in place. So I started by deploying an Azure_container_registry(acr).. Created a Kubernetes_Cluster, connected to the kubecluster using a CLI. Created a demo_app, using docker to build/ tag/ and push the demo_app to my Azure_container_registry(acr)
And assign some roles, in other to be able to pull images from acr. After that I created a deployment.yml, service.yml files and deployed the app. This is the end of the first phase.

The second phase of this peroject is to install datadog-agent, So I can monitor K8s-cluster using datadog...


## Step 1:
=========================== @ acr.tf ==========================
Created a resource_group and a container registry


## Step 2:
========================== @ aks.tf ===========================
started by creating a service pincipal.  
When the service principal has been created. go into the portal, type app registration, click on all application tab. there you'll see the name of your sp. Clich on your sp-name. click on API permission/ add a permission./microsoft graph/ Application permissions/ applications/ ApplicationReadWrite.Ownedby/ grant consent  (ssh-keygen -t rsa -b 4096 -f aksclusterkey)


## Step 3:
Use your CLI and connect to your kube-cluster by using the credential of the cluster from the portal eg: Az account set –subscription f783833-++++++-++++++ 
Az aks get-credentials –resource-group eliteclusterdemo. Then you can start with your kube commands, get ns, pods etc.


## Step 4:
============================ demo-app ========================= 
Build a docker app. docker build -f Dockerfile -t helloworldapp .
After creating the image, we will have to tag the image and push it to our acr.( docker tag helloworldapp eliteconregx3twc.azurecr.io/helloworldapp:v1) next is to push. 


## Step 5:
Before you push you'll have to connect to your acr first (az acr login <acr-name> Now you can push)      
docker push eliteconregx3twc.azurecr.io/helloworldapp:v1 (go to ur ACR Repositories and you'll see the image you just pushed)  Copy the name of our image along with the path (eliteconregx3twc.azurecr.io/helloworldapp:v1) and edit the image name in deployment.yml


## Step 6:
And You must assign some roles, for you to be able to pull images from acr
az acr update -n eliteconregx3twc  --anonymous-pull-enabled
az acr update -n eliteconregx3twc --admin-enabled true


## Step 7:
create your deployment but make sure your inside the dir where you have your deployment. in our case its manifest, use this command to create (kubectl apply -f=deployment.yml) or you can delete with (kubectl delete -f=deployment.yml)


## Step 8:
Create service (kubectl apply -f=service.yml)  kubectl get svc = it list the service you just created, with the info of the external ip. you can put that in your browser 51.138.233.137:3000 (:3000 because we expose our app on 3000 in the Dockerfile) 



## : Datadog Installation on ubuntu(server) with Ansible
========================== @ datadogg ===NB: na_4_vm (not k8s)========================= 

Another scenario is when we set-up an infrastructure and spawn-up a linux server. The idea behind this project is similar to my first datadog project. But this time around I want to use datadog to monitor the activities of a linux-server.

After deploying the server, the next target is to install datadog-agent on the server. And I’ll be using ansble to accomplish this task. I started by creating an ansible-role, using the command below:

ansible-galaxy install datadog.datadog

This is like using (ansible-galaxy init nginx) that creates nginx directory and sub-directories in it.
copy the datadog role over to your current directory so you can use it.

cd /home/devopslab/.ansible/roles/
cp -r datadog.datadog/ /mnt/c/Users/apple/Documents/GitHubdev/aks_acr

touch inventory.yml datadog.yml

To deploy the Datadog Agent on hosts, add the Datadog role and your API key to your playbook:
ansible-playbook datadog.yml -i inventory.yml -u adminuser --private-key /home/devopslab/.ssh/ansiblekeylocalexec –vv

at this point, I ssh into my server. To verify is datadog-agent has been installed successfully with the command below:

sudo systemctl status datadog-agent

And it was active and running…

I went to my datadog webpage click on infrastructure/hostmap to check if I can see my server up there.

Troubleshooting: In cases where you cannot find your server on datadog website, but you can see its active (running) when you ssh into your server. 

Best-practice is to stop && start : restart datadog-agent on your server, with the command bellow:

sudo systemctl stop datadog-agent
