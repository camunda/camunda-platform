# Camunda Platform 8

This repository contains links to Camunda Platform 8 resources, the official release artifacts (binaries), and supporting config files for running Docker Compose as a local development option. 

:warning: **Docker Compose is only recommended for local development.** :warning:

We recommend using [SaaS](https://camunda.com/get-started/) or [Helm/Kubernetes](https://docs.camunda.io/docs/self-managed/setup/overview/) for development.

For more information, check Camunda 8 Self-Managed official [documentation](https://docs.camunda.io/docs/self-managed/about-self-managed/).

For production setups we recommend using [Helm charts](https://docs.camunda.io/docs/self-managed/setup/install/) which can be found at [helm.camunda.io](https://helm.camunda.io/

## Links to additional Camunda Platform 8 repos and assets

- [Documentation](https://docs.camunda.io)
- [Camunda Platform SaaS](https://camunda.io)
- [Getting Started Guide](https://github.com/camunda/camunda-platform-get-started)
- [Releases](https://github.com/camunda/camunda-platform/releases)
- [Helm Charts](https://helm.camunda.io/)
- [Zeebe Workflow Engine](https://github.com/camunda/zeebe)
- [Contact](https://docs.camunda.io/contact/)

## Using docker compose

> :information_source: The docker-compose file in this repository uses the latest [compose specification](https://docs.docker.com/compose/compose-file/), which was introduced with docker compose version 1.27.0+. Please make sure to use an up-to-date docker compose version.

> :information_source: Docker 20.10.16+ is required.

> :information_source: The Web Modeler service names have changed with `8.6.0-alpha2`. Run `docker compose stop modeler-webapp modeler-restapi modeler-websockets` when upgrading from a previous version to stop the old services.

Be sure you are in the correct directory when running all the following commands. Use `cd docker-compose/camunda-8.6` to navigate to the correct directory.

To spin up a complete Camunda Platform 8 Self-Managed environment locally the [docker-compose.yaml](docker-compose.yaml) file in this repository can be used.

The full environment contains these components:
- Zeebe
- Operate
- Tasklist
- Connectors
- Optimize
- Identity
- Elasticsearch
- Keycloak
- PostgreSQL
- Web Modeler (Restapi, Webapp and Websockets)

<a id="start-full-profile"></a>
Clone this repo and issue the following command to start your environment:

```
docker compose --profile full up -d
```

Wait a few minutes for the environment to start up and settle down. Monitor the logs, especially the Keycloak container log, to ensure the components have started.

Now you can navigate to the different web apps and log in with the user `demo` and password `demo`:
- Operate: [http://localhost:8081](http://localhost:8081)
- Tasklist: [http://localhost:8082](http://localhost:8082)
- Optimize: [http://localhost:8083](http://localhost:8083)
- Identity: [http://localhost:8084](http://localhost:8084)
- Elasticsearch: [http://localhost:9200](http://localhost:9200)
- Web Modeler: [http://localhost:8070](http://localhost:8070)

Keycloak is used to manage users. Here you can log in with the user `admin` and password `admin`
- Keycloak: [http://localhost:18080/auth/](http://localhost:18080/auth/)

The workflow engine Zeebe is available using gRPC at `localhost:26500`.

To tear down the whole environment run the following command:

```
docker compose --profile full down -v
```

Zeebe, Operate, Tasklist, Web Modeler along with Optimize require a separate network from Identity as you'll see in the docker-compose file. Web Modeler also requires another separate network.

### Using the basic components

If Optimize, Web Modeler, Identity, and Keycloak are not needed you can use the [docker-compose-core.yaml](docker-compose-core.yaml) instead which does not include these components:

```
docker compose -f docker-compose-core.yaml up -d
```

### Deploying BPMN diagrams

In addition to the local environment setup with docker compose, use the [Camunda Desktop Modeler](#desktop-modeler) to locally model BPMN diagrams for execution and directly deploy them to your local environment.
As an enterprise customer, you can [use Web Modeler](#web-modeler-self-managed).

Feedback and updates are welcome!

## Securing the Zeebe API

By default, the Zeebe gRPC API is publicly accessible without requiring any client credentials for development purposes.

You can however enable authentication of gRPC requests in Zeebe by setting the environment variable `ZEEBE_AUTHENTICATION_MODE` to `identity`, e.g. via running:
```
ZEEBE_AUTHENTICATION_MODE=identity docker compose --profile full up -d
```
or by modifying the default value in the [`.env`](.env) file.

## Connectors

Both docker-compose files contain our [out-of-the-box Connectors](https://docs.camunda.io/docs/components/integration-framework/connectors/out-of-the-box-connectors/available-connectors-overview/).

Refer to the [Connector installation guide](https://docs.camunda.io/docs/self-managed/connectors-deployment/install-and-start/) for details on how to provide the related Connector templates for modeling.

To inject secrets into the Connector runtime they can be added to the
[`connector-secrets.txt`](connector-secrets.txt) file inside the repository in the format `NAME=VALUE`
per line. The secrets will then be available in the Connector runtime with the
format `secrets.NAME`.

To add custom Connectors either create a new docker image bundling them as
described [here](https://github.com/camunda/connectors-bundle/tree/main/runtime).

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

## Desktop Modeler

> :information_source: The Desktop Modeler is [open source, free to use](https://github.com/camunda/camunda-modeler).

[Download the Desktop Modeler](https://camunda.com/download/modeler/) and start modeling BPMN, DMN and Camunda Forms on your local machine.

### Deploy or execute a process

#### Without authentication
Once you are ready to deploy or execute processes use these settings to deploy to the local Zeebe instance:
* Authentication: `None`
* URL: `http://localhost:26500`

#### With Zeebe request authentication
If you enabled [authentication for gRPC requests](#securing-the-zeebe-api) on Zeebe you need to provide client credentials when deploying and executing processes:
* Authentication: `OAuth`
* URL: `http://localhost:26500`
* Client ID: `zeebe`
* Client secret: `zecret`
* OAuth URL: `http://localhost:18080/auth/realms/camunda-platform/protocol/openid-connect/token`
* Audience: `zeebe-api`

## Web Modeler

> [!IMPORTANT]
> Non-production installations of Web Modeler are restricted to five collaborators per project.
> Refer to [the documentation](https://docs.camunda.io/docs/next/reference/licenses/) for more information.

### Standalone setup

Web Modeler can be run standalone with only Identity, Keycloak and Postgres as dependencies by using the Docker Compose `modeling` profile.

Issue the following commands to only start Web Modeler and its dependencies:

```
docker compose --profile modeling up -d
```

To tear down the whole environment run the following command:

```
docker compose --profile modeling down -v
```

> [!WARNING]
> This will also delete any data you created.

Alternatively, if you want to keep the data, run:

```
docker compose --profile modeling down
```

### Login
You can access Web Modeler and log in with the user `demo` and password `demo` at [http://localhost:8070](http://localhost:8070).

### Deploy or execute a process

The local Zeebe instance (that is started when using the Docker Compose [`full` profile](#start-full-profile)) is pre-configured in Web Modeler.

Once you are ready to deploy or execute a process, you can just use this instance without having to enter the cluster endpoint manually.
The correct authentication type is also preset based on the [`ZEEBE_AUTHENTICATION_MODE` environment variable](#securing-the-zeebe-api).

#### Without authentication
No additional input is required.

#### With Zeebe request authentication
If you enabled [authentication for gRPC requests](#securing-the-zeebe-api) on Zeebe, use the following client credentials when deploying and executing processes:
* Client ID: `zeebe`
* Client secret: `zecret`

> [!NOTE]
> The correct OAuth token URL and audience are preset internally.

### Emails
The setup includes [Mailpit](https://github.com/axllent/mailpit) as a test SMTP server. It captures all emails sent by Web Modeler, but does not forward them to the actual recipients. 

You can access emails in Mailpit's Web UI at [http://localhost:8075](http://localhost:8075).

## Troubleshooting

### Submitting Issues
When submitting an issue on this repository, please make sure your issue is related to the docker compose deployment
method of the Camunda Platform. All questions regarding to functionality of the web applications should be instead
posted on the [Camunda Forum](https://forum.camunda.io/). This is the best way for users to query for existing answers
that others have already encountered. We also have a category on that forum specifically for [Deployment Related Topics](https://forum.camunda.io/c/camunda-platform-8-topics/deploying-camunda-platform-8/33).

### Running on arm64 based hardware
When using arm64-based hardware like a M1 or M2 Mac the Keycloak container might not start because Bitnami only
provides amd64-based images for versions <  22. You can build and tag an arm-based
image locally using the following command. After building and tagging the image you can start the environment as
described in [Using docker-compose](#using-docker-compose).

```
$ DOCKER_BUILDKIT=0 docker build -t bitnami/keycloak:19.0.3 "https://github.com/camunda/camunda-platform.git#8.2.15:.keycloak/"
```

## Resource based authorizations

You can control access to specific processes and decision tables in Operate and Tasklist with [resource based authorization](https://docs.camunda.io/docs/self-managed/concepts/access-control/resource-authorizations/).

This feature is disabled by default and can be enabled by setting 
`RESOURCE_AUTHORIZATIONS_ENABLED` to `true`, either via the [`.env`](.env) file or through the command line:

```
RESOURCE_AUTHORIZATIONS_ENABLED=true docker compose --profile full up -d
```

## Multi-Tenancy

You can use [multi-tenancy](https://docs.camunda.io/docs/self-managed/concepts/multi-tenancy/) to achieve tenant-based isolation.

This feature is disabled by default and can be enabled by setting
`MULTI_TENANCY_ENABLED` to `true`, either via the [`.env`](.env) file or through the command line:

```
ZEEBE_AUTHENICATION_MODE=identity MULTI_TENANCY_ENABLED=true docker compose --profile full up -d
```

As seen above the feature also requires you to use `identity` as an authentication provider.

Ensure you [setup tenants in identity](https://docs.camunda.io/docs/self-managed/identity/user-guide/tenants/managing-tenants/) after you started the platform.

## Camunda Platform 7

Looking for information on Camunda Platform 7? Check out the links below:

- [Documentation](https://docs.camunda.org/)
- [GitHub](https://github.com/camunda/camunda-bpm-platform)
