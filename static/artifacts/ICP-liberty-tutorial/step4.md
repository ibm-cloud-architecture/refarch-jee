# Step 4. Write Kubernetes YAMLs, including Deployment and Services stanzas

In this step, we are going to write the needed configuration files, deployment files, etc for a container orchestrator such as Kubernetes to get our Liberty app appropriately deployed onto our virtulized infrastructure.

1. [Push image to ICP Image Repository](#push-image-to-icp-image-repository)
    * [Create user and namespace](#create-user-and-namespace)
    * [Re-Tag image](#re-tag-image)
    * [Push image](#push-image)
2. [Generate deployment yaml file](#generate-deployment-yaml-file)

### Push image to ICP Image Repository

IBM Cloud Private (ICP) provides a docker compatible image repository out of the box, which is available on the server `bluedemocluster.icp` port `8500`.

#### Re-Tag image

To be able to push the image we build in the previous step into the ICP Image Repository, we'll need to add an additional tag to the image we built.

From the command line, enter the following command
```
docker tag customer-order-services:liberty bluedemocluster.icp:8500/default/customer-order-services:liberty
```
This extra information in the tag tells docker that this image belongs to the repository `default` on the `bluedemocluster.icp:8500` server which is the repository for the `default` namespace. Namespacing is a concept in Kubernetes that allows isolation of applications and other resources.

#### Push image

To make the image available to use in Kubernetes enter the following commands

1. `docker login bluedemocluster.icp:8500` providing `admin` as the user and `admin` as the password.
2. `docker push bluedemocluster.icp:8500/default/customer-order-services:liberty`

You will now be able to see the image in the ICP Dashboard under `Catalog -> Images`.

When completed, **sign out of the ICP dashboard**.

### Generate deployment yaml file

Our [deployment yaml file](https://github.com/ibm-cloud-architecture/refarch-jee/tree/master/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/deployment.yaml), which specifies how we want our application (i.e. the container) to be deployed, looks like this:

```
apiVersion: v1
kind: Service
metadata:
  name: customerorderservices
  labels:
    app: customerorderservices
spec:
  ports:
    - port: 80
      targetPort: 9080
  selector:
    app: customerorderservices
  type: NodePort

---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: customerorderservices
  name: customerorderservices
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: customerorderservices
    spec:
      containers:
      - image: bluedemocluster.icp:8500/default/customer-order-services:liberty
        name: customerorderservices
        ports:
        - containerPort: 9080
          protocol: TCP
        envFrom:
        - configMapRef:
            name: orderdb
        - configMapRef:
            name: ldap
```

You can see there are two parts in this file, separated by `---`. The three dashes is a yaml construct that allows us to put the content of multiple files in a single file.

Above the dashes is the **Service**, indicated by `kind: Service`. Here we describe how we like the application to be exposed. In our case, we choose to use NodePort, which will expose this service to external traffic. This isn't a secure or recommended way to access your application hosted in a kubernetes-based environment like ICP but for the goal of this tutorial it is acceptable.

The next part is the **deployment** part, indicated by `kind: Deployment`. Here we describe what we want the target state of the application to be. In our example, we instruct a single container to be named `customerorderservices` and created from the image we pushed to our image repository previously.

The envFrom section tells kubernetes to populate the containers environment variables from a ConfigMap, which we will create in Step 5. These variables holds deployment specific information such as database host, port, user and password. This enables us to reuse the same image and deployment manifests in multiple deployment environments such as pre-prod and prod at the same time having their specifics set aside in separate ConfigMap files.
