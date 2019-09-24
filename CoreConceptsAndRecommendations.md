## Core Concepts and Recommendations

Before jumping into configuration and other changes, you will need to make to Octopus Deploy, take a step back, and answer this fundamental question.  Why do you want to leverage IaC?  Do you want to be able to auto-scale production to handle additional traffic?  Do you want to deploy the latest code to a DR site in the event your primary data center goes offline?  Do you want to provide each of your developers with a testing sandbox?  When should a teardown event occur on the infrastructure?  Who should be the one who triggers it? 

### Long Living Resources

In most IaC demos the entire infrastructure, from the SQL Server to the network, to the Web Server get created on the fly.  In the real world, having your entire infrastructure spun up and torn down is not feasible.  For example, if you were using a cloud provider such as Azure or AWS, you might have a virtual network configured with a point to point VPN.  A point to point VPN allows you to configure all your testing servers to have no public IP addresses, but you could still access them.  In our experience, tearing down a VPN connection like that is risky (dropping the VPN means you cannot connect to those test VMs anymore), and error-prone.  Firewalls have to be configured just so.  

Besides, it is unlikely you will want to spin up and down database servers on the fly, especially when it is in a production environment.  We have seen several companies who eventually get to this, but it is not something did day one.  

The point is, you will have long living resources.  We recommend identifying those resources and isolating them from your IaC when possible.  For example, in Azure, you can have virtual networks in one resource group and create a separate resource group as part of your IaC deployments.  When you want to delete all the IaC resources, you delete the IaC resource group you created as part of your deployment.

### Databases

Databases were mentioned in the earlier section, but we wanted to address them again.  When working through your scenarios, consider where that data is coming from.  If you are building testing sandboxes for feature branches, how will the database be populated?  Backup and restore?  Using a third-party tool such as SQL Clone?  Seed scripts?  What about using IaC for disaster recovery?  Will you configure high availability in SQL Server and use a virtual IP address?  We can't answer those questions for you as we don't know your configuration and requirements.  We wanted to bring them up now so you can think about them now rather than running into them later.  

### Bootstrap VMs

If you opt to leverage VMs instead of PaaS services such as Azure Web Apps or Kubernetes clusters, then you should automate the install of the tentacle using a bootstrap script.  That script should also install any additional applications.  Please take a look at our other documentation on how to [automate the tentacle installation](https://octopus.com/docs/infrastructure/deployment-targets/windows-targets/automating-tentacle-installation).  

When using Windows VMs, we recommend leveraging [Chocolatey](https://chocolatey.org/).  .NET has NuGet packages, Chocolatey is NuGet packages, but for Windows, not .NET.  We also recommend leveraging [Deployment Imaging Servicing and Management](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism---deployment-image-servicing-and-management-technical-reference-for-windows), otherwise known as DISM for Windows.  With Chocolatey and DISM, you should be able to configure Windows automatically to your liking.

Your Linux Distro of choice should already have a package manager built in.  You will need to refer to the documentation on your Linux Distro to get those specific commands.  If you wish to use a tentacle on Linux, please refer to our documentation on how to [bootstrap the Linux tentacle](https://octopus.com/docs/infrastructure/deployment-targets/linux/tentacle).

This repository includes a [sample bootstrap script which you can use](arm/bootstrap/BootstrapTentacleandRunChoco.ps1).