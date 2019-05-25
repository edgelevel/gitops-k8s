# gitops-k8s

[![Build Status][travis-image]][travis-url]

[travis-image]: https://travis-ci.org/edgelevel/gitops-k8s.svg?branch=master
[travis-url]: https://travis-ci.org/edgelevel/gitops-k8s

This document aims to provide an opinionated working solution leveraging Kubernetes and proven GitOps techniques to have a resilient, composable and scalable Kubernetes platform.

Nothing outlined below is new or innovative, but it should be at least a good starting point to have a cluster up and running pretty quickly and give you a chance to remain focused and try out new ideas.

Feedback and help are always welcome!

* [Introduction](#introduction)
* [Argo CD](#argo-cd)
* [Applications](#applications)

---

## Introduction

### TL;DR

* Kubernetes is a declarative system
* Git can be used to describe infrastructure and applications
* Git repository is the source of truth and represents a cluster
* GitOps is a way to do Continuous Delivery and operate Kubernetes via Git pull requests
* GitOps empowers developers to do operations
* CI pipelines should only run builds, tests and publish images
* In a pull-based approach, an operator deploys new images from inside of the cluster
* You can only observe the actual state of the cluster and react when it diverges from the desired state

### Imperative vs Declarative

In an *imperative* system, the user knows the desired state, determines the sequence of commands to transition the system to the desired state and supplies a representation of the commands to the system.

By contrast, in a *declarative* system, the user knows the desired state, supplies a representation of the desired state to the system, then the system reads the current state and determines the sequence of commands to transition the system to the desired state.

Declarative systems have the distinct advantage of being able to react to unintended state changes without further supervision. In the event of an unintended state change leading to a state drift, the system may autonomously determine and apply the set of mitigating actions leading to a state match. This process is called a **control loop**, a popular choice for the implementation of controllers.

### What is GitOps?

GitOps is the art and science of using Git pull requests to manage infrastructure provisioning and software deployment.

The concept of GitOps originated at Weaveworks, whose developers described how they use Git to create a **single source of truth**. Kubernetes is a **declarative** system and by using declarative tools, the entire set of configuration files can be version controlled in Git.

More generally, GitOps is a way to do Continuous Delivery and operate Kubernetes via Git.

### Push vs Pull

In a *push*-based pipeline, the CI system runs build and tests, followed by a deployment directly to Kubernetes. This is an *anti-pattern*. CI server is not an orchestration tool. You need something that continually attempts to make progress until there are no more diffs because CI fails when it encounters a difference and then you could end up being in a partial and unknown state.

In a *pull*-based pipeline, a Kubernetes **operator** deploys new images from inside of the cluster. The operator notices when a new image has been pushed to the registry. Convergence of the cluster state is then triggered and the new image is pulled from the registry, the manifest is automatically updated and the new image is deployed to the cluster.

A CI pipeline should be used to merge and integrate updates with master, while with GitOps you should rely on Kubernetes or the cluster to internally manage deployments based on those master updates.

You could potentially have multiple cluster pointing to the same GitOps repository, but you won't have a centralized view of them, all the clusters will be independent.

### Observability

Git provides a source of truth for the desired state of the system and *observability* provides a source of truth for the actual state of the running system.

You cannot say what actual state is in the cluster. You can only observe it. This is why diffs are so important.

A system is observable if developers can understand its current state from the outside. Observability is a property of systems like Availability and Scalability. Monitoring, Tracing and Logging are techniques for baseline observations.

Observability is a source of truth for the actual running state of the system right now. You observe the running system in order to understand and control it. Observed state must be compared with the desired state in Git and usually you want to monitor and alert when the system diverge from the desired state.

**Resources**

* [Imperative vs Declarative](https://medium.com/@dominik.tornow/imperative-vs-declarative-8abc7dcae82e)
* [GitOps - Operations by Pull Request](https://www.weave.works/blog/gitops-operations-by-pull-request) (Part 1)
* [The GitOps Pipeline](https://www.weave.works/blog/the-gitops-pipeline) (Part 2)
* [GitOps - Observability](https://www.weave.works/blog/gitops-part-3-observability) (Part 3)
* [GitOps - Application Delivery Compliance and Secure CICD](https://www.weave.works/blog/gitops-compliance-and-secure-cicd) (Part 4)
* [Making the Leap from Continuous Integration to Continuous Delivery](docs/Weaveworks_ContinuousDelivery_wp_2018.pdf) (Whitepaper)
* [What is GitOps really?](https://www.weave.works/blog/what-is-gitops-really)
* [Why is a PULL vs a PUSH pipeline important?](https://www.weave.works/blog/why-is-a-pull-vs-a-push-pipeline-important)
* [Kubernetes anti-patterns: Let's do GitOps, not CIOps!](https://www.weave.works/blog/kubernetes-anti-patterns-let-s-do-gitops-not-ciops)
* [GitOps: High velocity CICD for Kubernetes](https://www.weave.works/blog/gitops-high-velocity-cicd-for-kubernetes)
* [GitOps - What you need to know](https://www.weave.works/technologies/gitops)
* [GitOps for Kubernetes - A DevOps Iteration Focused on Declarative Infrastructure](https://youtu.be/wJleh-6DZJ0)
* [Automating continuous delivery with Kubernetes, Google Cloud and Git](https://vimeo.com/255633066)
* [Continuous Delivery the Hard Way](https://www.weave.works/blog/continuous-delivery-the-hard-way)

---

*TODO update docs below with `seed` Chart and add `bootstrap` Chart example*

## Argo CD

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes. It automates the deployment of the desired application states in the specified target environments. In this project Kubernetes manifests are specified as [helm](https://helm.sh/docs) charts.

You need to embrace failures if you want to have the ability to heal and recover automatically in most of the situations. A useful pattern is to have an `initContainer` to solve dependencies between various resources. For example a Kafka application should check if topics have been properly created (ideally by an operator) before even start.

This guide will explain how to setup in few steps the whole infrastructure on DigitalOcean via GitOps and Argo CD. Note that it's not tightly coupled to any specific vendor and you should be able to easily port it on [EKS](https://aws.amazon.com/eks) or [GKE](https://cloud.google.com/kubernetes-engine) for example.

![architecture](docs/img/architecture.png)

Most of the steps have been kept manual on purpose, but they should be automated in a production enviroment.

### Prerequisites

* Quick install [guide](docs/setup.md)
    * Setup [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl) to run commands against Kubernetes clusters
    * Setup [helm](https://helm.sh/docs/using_helm/#installing-helm) for templating purposes only
    * Setup [argocd](https://argoproj.github.io/argo-cd/getting_started/#2-download-argo-cd-cli) CLI
* Create a Kubernetes cluster on [DigitalOcean](https://www.digitalocean.com/docs/kubernetes)
    * $10/month for Worker Node
    * $10/month for Load Balancer
* Download the cluster configs and test connection
    ```bash
    export KUBECONFIG=~/.kube/<CLUSTER_NAME>-kubeconfig.yaml
    kubectl get nodes
    ```

### Bootstrap

1. *TODO Setup secrets (optional)*
2. Setup Argo CD and all the applications
    * [bootstrap](bootstrap/) (not working)
    * [bootstrap-unofficial](bootstrap-unofficial/)
    * or simply type `make`
3. Access Argo CD
    ```bash
    # username: admin
    # password: (autogenerated) the pod name of the Argo CD API server
    kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2

    # port forward the service
    kubectl port-forward svc/argocd-server -n argocd 8080:443

    # from the UI
    [open|xdg-open] https://localhost:8080
    # from the CLI
    argocd login localhost:8080 --username admin
    ```
    * You might need to *allow invalid certificates for resources loaded from localhost* on Chrome enabling the flag `chrome://flags/#allow-insecure-localhost` to access it
    * *TODO using Ambassador*
4. First time only sync all the `OutOfSync` applications
    * manually
    * *TODO with a cronjob (optional)*
    * verify [guestbook](https://github.com/argoproj/argocd-example-apps/tree/master/guestbook) example
    ```bash
    # port forward the service
    kubectl port-forward service/guestbook-ui -n guestbook 8081:80
    # open browser
    [open|xdg-open] https://localhost:8081
    ```

This is how it should looks like on the UI

![argocd-ui](docs/img/argocd-ui.png)

**Resources**

* [Introducing Argo CD](https://blog.argoproj.io/introducing-argo-cd-declarative-continuous-delivery-for-kubernetes-da2a73a780cd)
* [Argo CD - Declarative Continuous Delivery for Kubernetes](https://argoproj.github.io/argo-cd)

## Applications

Applications in this repository are defined in the parent [applications](https://github.com/edgelevel/gitops-k8s/tree/master/applications/templates) chart folder.  
Applications are logically split into folders which represent Kubernetes namespaces

### kube-system namespace
`kube-system` namespace is reserved for Kubernete system applications

- `metrics server`  
    The metrics server is a Kubernetes cluster add-on which extends the metrics api group.  
    The metrics it collects enables the kubectl commands:
    ```
    kubectl top node
    kubectl top pod --all-namespaces
    ```
    It also enables the Kubernetes resource `HorizontalPodAutoscaler`

- `spotify-docker-gc`  
    The spotify docker gc performs garbage collection in the Kubernetes cluster.  
    Default configuration has the gc running once a day which  
    removes containers that exited more than a hour ago  
    removes images that don't belong to any container  
    removes volumes that are not associated to any remaining container.

### Service mesh

> TODO Ambassador vs Istio

```bash
# retrieve EXTERNAL-IP
kubectl get service ambassador -n ambassador
[open|xdg-open] http://<EXTERNAL-IP>/guestbook/

# debug ambassador
# http://localhost:8877/ambassador/v0/diag
kubectl port-forward ambassador-XXX 8877 -n ambassador
```

**Resources** TODO

```
https://www.getambassador.io
https://istio.io
https://medium.com/namely-labs/a-crash-course-for-running-istio-1c6125930715
```

### Monitoring and Alerting

An Operator is software that encodes this domain knowledge and extends the Kubernetes API through the third party resources mechanism, enabling users to create, configure, and manage applications.

The Prometheus Operator creates, configures, and manages Prometheus monitoring instances.

> TODO Prometheus

**Resources** TODO

```
https://coreos.com/operators/prometheus/docs/latest/user-guides/getting-started.html
https://grafana.com/dashboards
```

### Logging

> TODO Fluent Bit and Elasticsearch

**Resources** TODO

```
https://supergiant.io/blog/exporting-kubernetes-logs-to-elasticsearch-using-fluent-bit
https://itnext.io/logging-best-practices-for-kubernetes-using-elasticsearch-fluent-bit-and-kibana-be9b7398dfee
https://docs.fluentbit.io/manual/installation/kubernetes
https://akomljen.com/get-kubernetes-logs-with-efk-stack-in-5-minutes
https://blog.zufardhiyaulhaq.com/setup-efk-elasticsearch-fluent-bit-kibana-stack-in-kubernetes
https://logz.io/blog/fluentd-vs-fluent-bit

# kubernetes logging
https://platform9.com/blog/logging-monitoring-of-kubernetes-applications-requirements-recommended-toolset
https://platform9.com/blog/kubernetes-logging-and-monitoring-the-elasticsearch-fluentd-and-kibana-efk-stack-part-1-fluentd-architecture-and-configuration
https://platform9.com/blog/kubernetes-logging-and-monitoring-the-elasticsearch-fluentd-and-kibana-efk-stack-part-2-elasticsearch-configuration
https://logz.io/blog/kubernetes-log-analysis
https://itnext.io/logging-best-practices-for-kubernetes-using-elasticsearch-fluent-bit-and-kibana-be9b7398dfee
# tools
http://fluentbit.org
https://github.com/giantswarm/curator
# cerebro
http://www.atechref.com/blog/elk-stack/elk-stack-monitor-elastic-nodes

# grafana logs
https://github.com/grafana/loki
```

## TODO (not in order)

* [ ] argocd: example secrets for private charts
* [ ] argocd: override default `admin.password`
* [ ] argocd: example login with GitHub
* [ ] argocd: explain solution of how to sync automatically first time with cronjob
* [ ] argocd: fix Ambassador routes in LoadBalancer configs
* [ ] argocd: Makefile for bootstrap
* [ ] travis: publish `seed` and remove script from chart
* [ ] [Jaeger](https://www.jaegertracing.io) tracing
* [ ] [kube-monkey](https://github.com/asobti/kube-monkey) or [chaoskube](https://github.com/helm/charts/tree/master/stable/chaoskube)
* [ ] switch cluster via DNS
* [ ] Kafka from public chart + [JMX fix](https://github.com/helm/charts/pull/10799/files)
* [ ] stateless vs stateful: how to restore state if source of truth
* [ ] [external-dns](https://github.com/kubernetes-incubator/external-dns)
* [ ] TODO explain how to use this repo: bootstrap and reuse shared charts
* [ ] Example with multiple providers: DigitalOcean, EKS, GKE
* [ ] Add prometheus adapter for custom metrics that can be used by the [HorizontalPodAutoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale)
* [ ] Verify/fix argocd version `version: 1.0.0-0` with `appVersion`
