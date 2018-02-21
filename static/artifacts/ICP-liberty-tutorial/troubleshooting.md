# Troubleshooting

In this section, we will explain common processes for the tutorial such as logging into ICP as well as solution to known potential issues.

* [Open the terminal](#opent-the-terminal)
* [Log into ICP](#log-into-icp)
* [Configure the Kubernetes CLI](#configure-the-kubernetes-cli)
* [Restart Environment](#restart-environment)

### Open the terminal

In order to **open the terminal** to be able to interact through command line with the operating system,

1. Click on the terminal's launcher in the dock that can be found on the left hand side of the screen:

   ![Trouble 6](/static/imgs/trouble/trouble6.png)

If what you want is to **open a new terminal window**,

1. Right click on the terminal's launcher in the dock and select New Terminal:

   ![Trouble 7](/static/imgs/trouble/trouble7.png)

For either of the previous two options, your terminal window will open at `/home/skytap` or `~`

   ![Trouble 8](/static/imgs/trouble/trouble8.png)  

### Log into ICP

In order to log into the IBM Cloud Private,

1. Open Mozilla Firefox and point it to the **IBM Cloud Private** console:

   https://10.0.0.1:8443/console or click on the ICP console bookmark:

   ![Trouble 3](/static/imgs/trouble/trouble3.png)

2. If you are still not logged in, you will get redirected to the login page:

   ![Trouble 1](/static/imgs/trouble/trouble1.png)

   Credentials should be already typed in but, just in case, they are `Username: admin and Password: admin`

3. Once you are authenticated you should finally get to the IBM Cloud Private console:

   ![Trouble 2](/static/imgs/trouble/trouble2.png)

### Configure the Kubernetes CLI

In order to configure the [Kubernetes CLI](https://kubernetes.io/docs/reference/kubectl/overview/) to work with your IBM Cloud Private cluster,

1. [Log into IBM Cloud Private](#log-into-icp).

2. In the ICP console, click on the **admin** avatar in the upper right and then select **Configure client**.

   ![Trouble 4](/static/imgs/trouble/trouble4.png)

3. Copy the contents of the dialog box.

   ![Trouble 5](/static/imgs/trouble/trouble5.png)

4. [Open a terminal window](#open-the-terminal)

5. Paste the previously copied text into the terminal window. This will configure the CLI to talk to the ICP instance via the Kubernetes CLI tool, **kubectl**. You should see the following on your terminal:

   ![Trouble 9](/static/imgs/trouble/trouble9.png)

6. The above set of commands sets the kubernetes CLI to work on the **default namespace**. However, we want to work on the **purplecompute namespace**. Best practices when working on potentially shared environments such as ICP, dictate to use namespaces to allow isolation of resources from others (resources, developers, admins, teams, etc).

   In order to get the Kubernetes CLI to work with the purplecompute namespace, run

   ```
   kubectl config set-context bluedemocluster.icp-context --user=admin --namespace=purplecompute
   ```

   ![Trouble 10](/static/imgs/trouble/trouble10.png)

### Restart environment

**IBM Cloud Private** is a multi-node cloud environment with a boot, master, worker, and proxy nodes all forming a cluster. Where most customers (if not all) will be having the aforementioned nodes hosted on different virtual machines for a much better performance, they can still be deployed on a single host for development and testing purposes or, like in this case, for a tutorial/education purposes.

As you can imagine, having a Kubernetes based cloud environment all running on a single host is a very demanding task. Also, Skytap is a shared, multi-tenant cloud resources provider. As a result, **our Skytap environment, where this tutorial is carried out, might suffer from resource contention**.

More precisely, we have seen that the environment **becomes somewhat unusable** when the following command `ll -rt /sys/fs/cgroup/blkio/system.slice | grep run | wc -l` returns a number bigger than **1000**:

   ![Trouble 11](/static/imgs/trouble/trouble11.png)

At this point, we **strongly recommend** to restart the environment by clicking on the system menu button at the top right corner of your screen on the Ubuntu menu bar and select shut down.

   ![Trouble 12](/static/imgs/trouble/trouble12.png)

Then, select restart.

   ![Trouble 13](/static/imgs/trouble/trouble13.png)

Once the environment is back up, please **allow around 5-10 min** for the environment to start up, synchronise, etc all the IBM Cloud Private pieces.
