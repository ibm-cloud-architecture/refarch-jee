# Step 5. Deploy the Liberty app on your IBM Cloud Private

In this final step, we are going to deploy our containerized Liberty app to our IBM Cloud Private (ICP) through the Kubernetes command line interface and the ICP Dashboard.

* [Deploy Liberty app from CLI using kubectl](#deploy-liberty-app-from-cli-using-kubectl)
    * [Create ConfigMaps (CLI)](#create-configmaps-cli)
    * [Deploy application (CLI)](#deploy-application-cli)
    * [Validate application (CLI)](#validate-application-cli)
* [Deploy Liberty app using Helm](#deploy-liberty-app-using-helm)

### Deploy Liberty app from CLI using kubectl

First of all, we **must configure the Kubernetes CLI** to work with our ICP cluster. For doing so, follow these [instructions](troubleshooting.md#configure-the-kubernetes-cli).

####  Create ConfigMaps (CLI)

The environment specific runtime variables for the application will be held in ConfigMaps. We use ConfigMaps to hold deployment specific variables so that images and deployment manifests can be independent of individual deployments, making it easy to reuse the majority of assets across different environments such as pre-prod and prod. This information will include connectivity details for the Customer Order Services database and the LDAP server. We will create these ConfigMaps from the properties files located in the our tutorial github repository which has already been cloned to our laptop.

To create the ConfigMaps execute the following on a [terminal window](troubleshooting.md#open-the-terminal):

1. `cd /home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/`
2. `kubectl create configmap ldap --from-env-file=ldap.env`
3. `kubectl create configmap orderdb --from-env-file=orderdb.env`

   ![CLI ConfigMaps](/static/imgs/ICp/configmaps.png)

#### Deploy application (CLI)

In order to deploy our Customer Order Services application through the command line interface using kubectl, you need to execute the following on a [terminal window](troubleshooting.md#open-the-terminal):

`kubectl apply -f deployment.yaml`

![CLI deploy](/static/imgs/ICp/deployCLI.png)

#### Validate application (CLI)

To validate that the application is running properly, we need to grab the external port for the customerorderservices service. We will do so using kubectl. Execute on a [terminal window](troubleshooting.md#open-the-terminal):

```
kubectl get services
```

![CLI service](/static/imgs/ICp/serviceCLI.png)

In our case it is `31304`.

Using a web browser, navigate to the IP address for your ICP cluster appending the path of `CustomerOrderServicesWeb` to the end of it to access the Customer Order Services deployment you just carried out above. The full URL should look like this:

```
http://10.0.0.1:<Node_port>/CustomerOrderServicesWeb/
```

Verify that the page loads properly.

There are some handy kubectl commands to interrogate the application and do debugging you can execute on a [terminal window](troubleshooting.md#open-the-terminal):

1. To get a list of pods: `kubectl get pods`

   ![CLI pods](/static/imgs/ICp/podsCLI.png)

2. To see the container log of a pod: `kubectl logs <pod>`, where `<pod>` is the name of your pod you can grab from previous command.

   ![CLI logs](/static/imgs/ICp/logsCLI.png)

3. To see some information about a given pod: `kubectl describe pod <pod>`, where `<pod>` is the name of your pod you can grab from previous command.

   ![CLI describe](/static/imgs/ICp/describeCLI.png)

### Deploy Liberty app using Helm

We have seen above how we can manually deploy the different pieces our Customer Order Services application deployment needs using the *kubectl* CLI. However, wouldn't it be great to deploy all pieces an application might need at once? We can do so using [Kubernetes Charts](https://github.com/kubernetes/charts) and [Helm](https://github.com/kubernetes/helm).

Helm is a tool that streamlines installing and managing Kubernetes applications. Think of it like apt/yum/homebrew for Kubernetes.

  * Helm has two parts: a client (helm) and a server (tiller)
  * Tiller runs inside of your Kubernetes cluster, and manages releases (installations) of your charts.
  * Helm runs on your laptop, CI/CD, or wherever you want it to run.

Charts are curated application definitions for Kubernetes Helm. A chart is a collection of files that describe a related set of Kubernetes resources. A single chart might be used to deploy something simple, like a memcached pod, or something complex, like a full web app stack with HTTP servers, databases, caches, and so on. Charts contain at least two things:

  * A description of the package (Chart.yaml)
  * One or more templates, which contain Kubernetes manifest files

Charts can be stored on disk, or fetched from remote chart repositories (like Debian or RedHat packages).

In our case, the Customer Order Services Kubernetes chart structure looks like the following:

```bash
├── refarch-jee-customerorder
    ├── chart
        ├── customerorderservices
            ├── templates
            │   ├── configmap.yaml
            │   ├── db2_job.yaml
            │   ├── deployment.yaml
            │   └── service.yaml
            ├── Chart.yaml
            └── values.yaml
```

* **Chart.yaml** defines the chart attributes with regards to name, version, etc.
* **configmap.yaml** defines a configmap where we store the LDAP and DB2 credentials and attributes.
* **db2_job.yaml** defines a job to populate the Customer Order Services database.
* **deployment.yaml** defines the what docker image will get deployed, where it comes from and some other attributes to it.
* **service.yaml** defines the service which will provide access to the several Customer Order Services pods the deployment created.
* **values.yaml** defines the values for the variables the other yaml files within the chart rely on. This is a configuration abstraction that makes the application deployable to different environments by just providing a different set of values.

### Install Helm Chart

In order to deploy the Customer Order Services application using helm, execute the following on a [terminal window](troubleshooting.md#open-the-terminal):

1. Make sure Helm is installed and working by executing `helm version`

   ![Helm 1](/static/imgs/ICp/helm1.png)

2. Install the Customer Order Services application chart by executing

```
helm install --name <release_name> -f <values.yaml> <path_to_chart_directory>
```

where

* **<release_name>** is a unique identifier you should choose to uniquely identify each of the pieces your Customer Order Services kubernetes chart will deploy.
* **<values.yaml>** should be `~/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/values.yaml` in our case. **IMPORTANT:** the values.yaml file provided is tailored for the **default values** used throughout this tutorial. If you decided to used others, you need to modify this values.yaml file accordingly.
* **<path_to_chart_directory>** should be `~/PurpleCompute/git/refarch-jee-customerorder/chart/customerorderservices/` in our case.

The output of this command should be the list of the different kubernetes pieces involved in the deployment of the Customer Order Services application.

   ![Helm 2](/static/imgs/ICp/helm2.png)

Validate the application is running properly by, again, pointing your web browser to your ICP cluster IP address plus your Customer Order Services application's NodePort and context root. That is, your url should look like:

```
http://10.0.0.1:<Node_port>/CustomerOrderServicesWeb/
```

where **NodePort** can be obtained from the information your `helm install` command displayed above.

# Next step

**CONGRATULATIONS!!** you have completed the tutorial.

Click [here](tutorial.md) to go to the tutorial initial page.
