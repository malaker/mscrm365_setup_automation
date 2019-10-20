# Microsoft Dynamics 365 On premise setup automation

Fully automated setup of Microsoft Dynamics 365 on premise v9 for development purposes using vagrant

## Purpose

Preparing setup of dynamics 365 for development purposes

## Hardware requirements

At least 16 GB RAM and at least 70 GB free space for vms.

## Prerequisites

1) Download CRM9.0-Server-ENU-amd64.exe https://www.microsoft.com/en-us/download/details.aspx?id=57478
2) Download SQL Server 2016 Developer

### Vagrant prerequisites

```
vagrant plugin install vagrant-reload
```

Please install reload plugin for vagrant

### Dynamics setup automation

Automation script in order to run a bit faster require to have downloaded :

1. CRM9.0-Server-ENU-amd64.exe => please put with the same name into the same place where vagrant file is
2. SQL Server 2016 Developer.iso => rename to sql.iso and put into the same place where vagrant file is. Please be informed that SQL 2017 Developer probably can be used but Reporting Services has to run on SQL 2016 Server otherwise Crm installed have problem with RS detection. I recommend installing Sql Server 2016. 

In the future it is planned to download them if they don't exist

## Setup overview

### VM OS:
- Windows Server 2016 Evaluation version
- if you have license you can easily activate OS by putting to script proper commands :
The following commands are available for slmgr: 

    - slmgr -dli will display the current activation & licensing information of the device.
    - slmgr -xpr will display the current expiration date of the license installed on the device.
    - slmgr -rilc will re-install the system license files.
    - slmgr -upk will uninstall the product key that is currently being used by the device.
    - slmgr -ipk xxxxx-xxxxx-xxxxx-xxxxx-xxxxx (replace xxxxx with your own product key) will install the product key on the device.
    - slmgr -ato will activate the license that is currently installed on the device.
    - slmgr -rearm will reset the license that is currently installed on the device.

### Dynamics 365 license

Script installs Trial version valid for 90 days however you can provide to configuration file your own key - please put it to crmconfig.xml

### Controller VM

  - Installed Active Directory Controller and DNS
  - Created additional user kb 
  - Added domain vagrant user and kb user to proper AD groups in order to run CRM

### Node1 VM containes:
  - VM joined to an AD domain
  - Chocolatey
  - Installed SQL Server 2016 with Reporting services and other features required by Microsoft Dynamics (can be configure via file)
  - Installed SQL Management Studio via choco
  - IIS role enabled with all other features required by RS and CRM
  - Enabled AD Managment features
  - Installed Dynamics with default organization R1 (can be change via configuration file)
  
## How to run it ?

In the context of folder where vagrant file is run:
 ```
vagrant up controller

vagrant up node1
 ```
And after sometime you should got fresh instance of dynamics crm on premise v9

## How to remove all VMs ?

In the context of folder where vagrant file is run:

 ```
vagrant destroy
 ```

## Script verification

I verified scripts using:

- vagrant version 2.2.5
- virtual box version 6.0.10
