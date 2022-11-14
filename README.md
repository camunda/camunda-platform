# Camunda Platform 8

This repository contains links to Camunda Platform 8 resources, the offical release artifacts and a [docker-compose.yaml](docker-compose.yaml) file for local development. For production setups we recommend to use our [helm charts](https://docs.camunda.io/docs/self-managed/platform-deployment/kubernetes-helm/).

- [Documentation](https://docs.camunda.io)
- [Camunda Platform SaaS](https://camunda.io)
- [Getting Started Guide](https://github.com/camunda/camunda-platform-get-started)
- [Releases](https://github.com/camunda/camunda-platform/releases)
- [Helm Charts](https://helm.camunda.io/)
- [Zeebe Workflow Engine](https://github.com/camunda/zeebe)
- [Contact](https://docs.camunda.io/contact/)

## Using docker-compose

> :information_source: The docker-compose file in this repository uses the latest [compose specification](https://docs.docker.com/compose/compose-file/), which was introduced with docker-compose version 1.27.0+. Please make sure to use an up-to-date docker-compose version.

> :information_source: The Docker required is 20.10.16+

To stand-up a complete Camunda Platform 8 Self-Managed environment locally the [docker-compose.yaml](docker-compose.yaml) file in this repository can be used.

The full enviornment contains these components:
- Zeebe
- Operate
- Tasklist
- Connectors
- Optimize
- Identity
- Elasticsearch
- KeyCloak

Clone this repo and issue the following command to start your environment:

```
docker-compose up -d
```

Wait a few minutes for the environment to start up and settle down. Monitor the logs, especially the Keycloak container log, to ensure the components have started.

Now you can navigate to the different web apps and log in with the user `demo` and password `demo`:
- Operate: [http://localhost:8081](http://localhost:8081)
- Tasklist: [http://localhost:8082](http://localhost:8082)
- Optimize: [http://localhost:8083](http://localhost:8083)
- Identity: [http://localhost:8084](http://localhost:8084)
- Elasticsearch: [http://localhost:9200](http://localhost:9200)

KeyCloak is used to manage users. Here you can log in with the user `admin` and password `admin`
- KeyCloak: [http://localhost:18080/auth/](http://localhost:18080/auth/)

The workflow engine Zeebe is available using gRPC at `localhost:26500`.

To tear down the whole environment run the following command

```
docker-compose down -v
```

If Optimize, Identity, and Keycloak are not needed you can use the [docker-compose-core.yaml](docker-compose-core.yaml) instead which does not include these components:

```
docker-compose -f docker-compose-core.yaml up -d
```

Zeebe, Operate, Tasklist, along with Optimize require a separate network from Identity as you'll see in the docker-compose file.

In addition to the local environment setup with docker-compose, you can download the [Camunda Desktop Modeler](https://camunda.com/download/modeler/) to locally model BPMN diagrams for execution and directly deploy them to your local environment.

Feedback and updates are welcome!

## Connectors

Both docker-compose files contain our [out-of-the-box Connectors](https://docs.camunda.io/docs/components/integration-framework/connectors/out-of-the-box-connectors/available-connectors-overview/).

Refer to the [Connector installation guide](https://docs.camunda.io/docs/self-managed/connectors-deployment/install-and-start/) for details on how to provide the related Connector templates for modeling.

To inject secrets into the Connector runtime they can be added to the
[`connector-secrets.txt`](connector-secrets.txt) file inside the repository in the format `NAME=VALUE`
per line. The secrets will then be available in the Connector runtime with the
format `secrets.NAME`.

To add custom Connectors either create a new docker image bundling them as
described [here](https://github.com/camunda-community-hub/spring-zeebe/tree/master/connector-runtime#via-docker).

Alternatively, you can mount new Connector JARs as volumes into the `/opt/app` folder by adding this to the docker-compose file. Keep in mind that the Connector JARs need to bring along all necessary dependencies inside the JAR.

## Kibana

A `kibana` profile is available in the provided docker compose files to support inspection and exploration of the Camunda Platform 8 data in Elasticsearch.
It can be enabled by adding `--profile kibana` to your docker compose command.
In addition to the other components, this profile spins up [Kibana](https://www.elastic.co/kibana/).
Kibana can be used to explore the records exported by Zeebe into Elasticsearch, or to discover the data in Elasticsearch used by the other components (e.g. Operate).

You can navigate to the Kibana web app and start exploring the data without login credentials:

- Kibana: [http://localhost:5601](http://localhost:5601)

> **Note**
> You need to configure the index patterns in Kibana before you can explore the data.
> - Go to `Management > Stack Management > Kibana > Index Patterns`.
> - Create a new index pattern. For example, `zeebe-record-*` matches the exported records.
>   - If you don't see any indexes then make sure to export some data first (e.g. deploy a process). The indexes of the records are created when the first record of this type is exported.
> - Go to `Analytics > Discover` and select the index pattern.

## Web Modeler Self-Managed Beta Release

> :warning: Web Modeler Self-Managed is currently offered as a [beta release](https://docs.camunda.io/docs/next/reference/early-access#beta) with limited availability for enterprise customers only. It is not recommended for production use, and there is no maintenance service guaranteed. Special [terms & conditions](https://camunda.com/legal/terms/camunda-platform/camunda-platform-8-self-managed/) apply. However, we encourage you to provide feedback via your designated support channel or the [Camunda Forum](https://forum.camunda.io/).

The Docker images for Web Modeler Beta are available in a private registry. Enterprise customers either already have credentials to this registry, or they can request access to this registry through their CSM contact at Camunda.

To run Camunda Platform with Web Modeler Self-Managed clone this repo and issue the following commands:

```
$ docker login registry.camunda.cloud
Username: your_username
Password: ******
Login Succeeded
$ docker-compose -f docker-compose.yaml -f docker-compose-web-modeler-beta.yaml up -d
```

To tear down the whole environment run the following command

```
$ docker-compose -f docker-compose.yaml -f docker-compose-web-modeler-beta.yaml down -v
```

If you want to delete everything (including any data you created).
Alternatively, if you want to keep the data run:

```
$ docker-compose -f docker-compose.yaml -f docker-compose-web-modeler-beta.yaml down
```

### Web Modeler
Now you can access Web Modeler Self-Managed and log in with the user `demo` and password `demo` at [http://localhost:8070](http://localhost:8070).

Once you are ready to deploy or execute processes use these settings to deploy to the local Zeebe instance:
* Authentication: None
* URL: `zeebe:26500`

### Emails
The setup includes [MailHog](https://github.com/mailhog/MailHog) as a test SMTP server. It captures all emails sent by Web Modeler, but does not forward them to the actual recipients. 

You can access emails in MailHog's Web UI at [http://localhost:8075](http://localhost:8075).

# Camunda Platform 7

- [Documentation](https://docs.camunda.org/)
- [GitHub](https://github.com/camunda/camunda-bpm-platform)
