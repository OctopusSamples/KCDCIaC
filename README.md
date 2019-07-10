# KCDC IaC Sample Scripts
Sample project containing all the scripts used in the IaC demo for KCDC.

## Slide Deck
You can find the slide deck from the presentation here: https://docs.google.com/presentation/d/1mzFTchnTQvGyaGc7iOH643CIleEHZH-efJ4u8d3sGWQ/edit?usp=sharing

## Introduction

Infrastructure as Code (IaC) allows you to define your infrastructure using a common language, such as JSON or YAML, and store it in a file. That file can be included as part of your deployment.  In this section, we will walk you through some core concepts of IaC.  Later we will discuss how to configure Octopus Deploy to leverage infrastructure as code.  In later sections, we will go through some common real-world scenarios.

To take full advantage of infrastructure as code, we recommend you are running the latest Long Term Support (LTS) version of Octopus Deploy.  

## Background

Imagine you have been working on a new feature in your application for a few weeks, and it is now time to get some feedback.  The code isn't finished; it is in a state where you can get some feedback to determine if you are on the right track.  Where do you deploy that code?  You don't want to deploy on top of your current install on your testing servers.  That could break all the testing.  You also don't want to have people connect to your machine.  The people whom you want to get feedback from are not in the office today, and you want to keep working on the code.  When your co-workers are ready to give you feedback, and they connect to your machine, the code could be in a broken state.  In an ideal world, you would spin up some new infrastructure, deploy to new infrastructure to get feedback.  Once everyone is done testing the new feature, that infrastructure is deleted.

So you go to operations to ask them to create a new virtual machine (VM).  They hand you a form to fill out.  That form has several fields to fill out.   Windows or Linux, RAM and CPU, testing or production, and what applications need to be installed on the machine, to name a few.  You dutifully fill it out and hand it back to them.  Due to a variety of reasons, it takes almost a week to get the new VM.  Other priorities took precedence, and your request was pushed to the back of the list.  

It took a long time to get those VMs.  As a developer, you are reluctant to give them up.  Operations are also reluctant to destroy them because you might come back in a few weeks after it is destroyed and ask for a new VM.  So the VM lives on for a long time.  Now you have to worry about keeping that server up to date.  

### Cattle Not Pets

The VM in the above example essentially became a pet.  You have to care for it because it is going to live for a long time.  What we want to do is treat the VM like a rancher treats cattle.  Compared to a pet, cows live for a short amount of time and are replaced quickly.  A cow is sold to market, a new cow comes and takes its place.  We want to treat our infrastructure the same way.  Treating your VM as cattle and not a pet is accomplished by leveraging Infrastructure as Code.

### Tooling

How you leverage IaC depends on where you host your code.  If you are hosting your code using a cloud provider, such as Azure, AWS, or Google Cloud, then they provide a rich API and tooling for you.  If you are hosting on-premise, then chances are your operations team has migrated as many physical servers over to hypervisors.  In that case, you will have to refer to the documentation of your company's hypervisor(s) of choice.

## Further Reading

This repository is here to provide you a written version of the presentation at KCDC.  It has been broken out into multiple documents to help with your reading.

1. [Core Concepts and Recommendations](CoreConceptsAndRecommendations.md)
2. [General Octopus Deploy Configuration](ConfigureOctopusDeploy.md)


