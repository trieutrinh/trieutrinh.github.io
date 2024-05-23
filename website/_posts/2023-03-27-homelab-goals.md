---
title: My Homelab Plans for 2023
description: In this blog post, I go over the upgrades and changes I have planned for my homelab in the coming year.

categories: ""
tags: Homelab Kubernetes Hardware

# img_path: /assets/img/posts/2023-03-27-homelab-goals/
image:
  path: /assets/img/posts/2023-03-27-homelab-goals/featured.webp
  lqip: ""  # TODO

# This permalink is needed for backwards compatibility 
# due to the migration from my previous Hugo theme.
# The hugo site used this format for the blog post links.
permalink: /posts/:year-:month-:day-:title/

date: 2023-03-27
---

A Homelab is a never-ending project. It is constantly evolving, with new tools, services and technologies always becoming available. As a result, it's essential to have a plan for how to keep your homelab up-to-date and relevant.

My homelab has been a constant work in progress, as I've added new hardware and software over time, in order to satisfy my learning needs and interests. It has always highlighted the technologies and tools I am currently studying or various services that have captured my interest.

Whether you're looking to build a Homelab for personal or professional reasons, it's a great investment in your skills and knowledge. That said, let's dive into my Homelab plans for 2023 and see what the future holds!

## Current Setup

Before we define where we are going, let's take a step back and assess where we're starting. I don't want to spend too much time on this part, as this isn't a 2022 Homelab tour, but I want to give you an idea of where I'm coming from and some context for the changes I will be making this year.

There were 2 main changes, or goals, in 2022:

### Infrastructure as Code

The first one is that I started implementing my Homelab via infrastructure as code. I wrote plenty of Ansible roles to configure my firewall, my Proxmox server and so on, as well as Terraform and Packer scripts to automatically provision new VMs. I got tired of manually configuring and provisioning infrastructure, so I decided to start doing it "properly".

### New Server

The second big change in 2022 was that I purchased my "main" virtualization server, a 10-core 20-thread i9-7900X. This was my first ever system that was technically outside the "consumer" range and more into the workstation segment. It had more threads, RAM, and PCIe lanes than my entire lab prior to that. As such, I decided in 2022 to scale down to a single server and virtualize everything.

## Goals for 2023

### Scaling Out

![Virtualizing VS. Running on bare metal](/assets/img/posts/2023-03-27-homelab-goals/drake-meme.webp)
_Virtualizing VS. Running on bare metal_

The first one of the problems I will be solving this year is separation of concerns. I didn't even finish migrating everything to a single server, and I can already tell that it is not for me.

Having the same server run my router, storage server, and other workloads is too unstable. It means that when I inevitably break something, it takes EVERYTHING down with it. My internet access, my files, my backups, everything. Needless to say, that gets very annoying very quick.

The solution is pretty obvious here. I will be scaling back out and move to dedicated servers. I will be separating my core and non-core infrastructure. By core infrastructure, I mean everything I need to have a minimum viable Homelab. That means the firewall, storage appliance, and the backup server will run on their dedicated machines, separated from the "labbing" infrastructure.

![My OPNsense Box](/assets/img/posts/2023-03-27-homelab-goals/network-server.webp)
_My OPNsense Box_

The server that will be running my firewall is an i5-6500 with 8 gigs of RAM.  It will be running OPNsense on bare-metal. I've been running OPNsense in my lab for a while, and I am simply used to it. I started off with pfSense a while back, but eventually decided to switch over when I virtualized my firewall for the first time, since OPNsense has a plugin for the qemu-guest-agent and pfSense does not.

![My TrueNAS Appliance and its emotional support foam roller](/assets/img/posts/2023-03-27-homelab-goals/storage-server.webp)
_My TrueNAS Appliance and its emotional support foam roller_

My storage appliance is running on an X99 platform, running an Intel Core i7-6850K with 32 gigs of RAM.  For the OS, I am going to go with TrueNAS. I am unsure if I want to go Scale or Core, as I don't intend to run any services on this. It will just handle my storage.

![My 2U backup server](/assets/img/posts/2023-03-27-homelab-goals/backup-server.webp)
_My 2U backup server_

My backup server is an Intel Pentium G6405 with 16 gigs of RAM. This one will also be running TrueNAS, but I think to kill two birds with one stone, I will be alternating. So if I go with core on my storage server, I will use Scale here, and vice-versa. I will configure a replication task between these two in order to make sure that I always have a local backup of my files.

![My Virtualization Server](/assets/img/posts/2023-03-27-homelab-goals/virtualization-server.webp)
_My Virtualization Server_

Lastly, let's discuss about my virtualization platform. I will keep using my Intel i9-7900X with its 96 gigs of RAM for this workload. It's the most powerful server I have in my rack, so it makes sense to dedicate it to virtualization. I've been previously running Proxmox on it, but I have some new plans for it this year!

### Kubernetes

![Kubernetes Certified Nerd](/assets/img/posts/2023-03-27-homelab-goals/kubernetes-certifications.webp)
_Kubernetes Certified Nerd_

Next on the list, we have the buzzword of the year: Kubernetes. Late last year, in December, I set a challenge for myself. I decided to bite the bullet and get all 3 Kubernetes certifications within 3 weeks. Now that I am a Certified Kubernetes Administrator, Application Developer, and Security Specialist, it is time I start my Kubernetes fanboy arc. :nerd:

Since we previously defined what I consider to be core and non-core infrastructure, I want to implement all of my non-core infrastructure on top of Kubernetes. This means that I will not only be using Kubernetes to host the applications I was hosting before in Docker, but I will also be using Kubernetes as my hypervisor!

#### Management Cluster

![3x Pi4 with 2Gb RAM](/assets/img/posts/2023-03-27-homelab-goals/management-cluster.webp)
_3x Pi4 with 2Gb RAM_

For my management cluster, I will be install K3S on three Raspberry Pi 4 boards with 2Gb of RAM. This cluster will only be running Rancher, in order to manage the other Kubernetes cluster running in my infrastructure.

#### Application Cluster

For the main application cluster, I want to try out Talos Linux, as I've been reading more and more about it lately and it sounds like an interesting project. I will be implementing a mixed-architecture cluster, so I will be using both arm nodes, via Raspberry Pis and other single board computers, as well as x86 nodes, via mini PCs.

I have my eyes on some TinyMinyMicro PCs from the local second hand market. I want to get three of these and make them pull double duty, acting both as managers and as workers. The way I will be implementing that is that I will install Proxmox on them and deploy 2 VMs on each. One of the VMs will be a manager node inside the Kubernetes cluster, and the other one will be a worker node.

![A couple Odroid boards and a Pi4 4Gb dedicated to running workloads](/assets/img/posts/2023-03-27-homelab-goals/main-cluster-workers.webp)
_A couple Odroid boards and a Pi4 4Gb dedicated to running workloads_

In order to spice things up and add more architectures into the cluster, I will be using some single board computers. I will be adding a Raspberry Pi 4 board, with 4Gb RAM, an Odroid N2+ and an Odroid C4 to the mix.

![A couple of Odroid HC1 boards for Longhorn](/assets/img/posts/2023-03-27-homelab-goals/main-cluster-storage.webp)
_A couple of Odroid HC1 boards for Longhorn_

Additionally, I have two Odroid HC1 boards, which are pretty neat, because they also have a SATA connector on them. I will be dedicating these to Longhorn in order to distribute highly available storage inside my cluster.

#### Virtualization Cluster

Finally, we have the virtualization cluster. This cluster will be a single-node cluster, running only on my i9-7900X system.

I am unsure if I will go with a pre-packaged solution, like Rancher Harvester, or if I will try to roll my own by running KubeVirt directly on top of Kubernetes. I played around a bit with Harvester and found some issues, mostly in the PCIe passthrough department, which is quite a deal-breaker for me. Hopefully, they manage to fix these issues by the time I get to implementing this cluster, as I am not really looking forward to reinventing the wheel.

### Automation

![Infrastructure-as-Code Tools](/assets/img/posts/2023-03-27-homelab-goals/infrastructure-as-code-tools.webp)
_Infrastructure-as-Code Tools_

Up next, we have automation. This year, I want to double down on the Infrastructure-as-Code side of things. This means getting more experience with tools I already know and enjoy, like Ansible, Packer, and Terraform, as well as learning some new tools. Primarily, I have either Flux or ArgoCD on my radar. A somewhat predictable choice since I am mainly going with Kubernetes in my lab. I will be exploring GitOps this year!

I also want to get more familiar with either Jenkins or GitLab-CI to automate the infrastructure hosted outside of Kubernetes. I am unsure what architecture and design I want to implement on this side for the automation, but I will think of something until we get there! I am tempted to go for GitLab-CI as I am using it on most of my other projects and I plan to deploy some runners in my infrastructure anyway.

### Observability

![Monitoring Tools](/assets/img/posts/2023-03-27-homelab-goals/monitoring-tools.webp)
_Monitoring Tools_

Lastly, there is something my lab has been gravely missing for the longest time: observability. I had no monitoring solution deployed, no centralized logging... nothing. This is going to change! I want to learn more about tools like Prometheus, Grafana, and Loki, so what better way to do that than to implement them in my infrastructure?

I am not 100% sold on this particular application stack, but rather on the concept. The tools I end up using may change, but the bottom line is that I will be setting up monitoring, logging, and hopefully alerting as well!

## Conclusion

And these are my main goals for 2023. Looking back on the journey of 2022 and thinking about my plans for this year, this year sounds like the best one yet. The upgrades and projects I have planned excite me, and I can't wait to get started!

I didn't go into too much detail here, as this post is long enough. Still, I will be making dedicated posts on each of the projects we discussed today in the future. So if any of this sounds interesting to you, subscribe to my mailing list to be notified when I next publish something. I will be documenting the entire process and taking you along with me!

What are your plans for 2023? What tools and technologies do you want to tinker with and learn more about? What are some technologies you might stop using, and why? Let me know in the comment section below.

---

{% include embed/youtube.html id='Uxj-GJCH5TU' %}
📹 [Watch Video](https://www.youtube.com/watch?v=Uxj-GJCH5TU)
