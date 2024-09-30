| Infra | Source |
|-|-|
| [![Landingzone - Deploy FrontendApi FunctionApp](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/landingzone-frontendapi.yml/badge.svg)](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/landingzone-frontendapi.yml) | [![Landingzone - Azure Infrastructure Deployment](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/landingzone.yml/badge.svg)](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/landingzone.yml) |
| [![Spoke - Frontend - Azure Infrastructure Deployment](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-frontend-infra.yml/badge.svg)](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-frontend-infra.yml) | [![Spoke - Frontend - Deploy Frontend WebApp](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-frontend-webapp.yml/badge.svg)](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-frontend-webapp.yml) |
| [![Spoke - Orders - Azure Infrastructure Deployment](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-orders.yml/badge.svg)](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-orders.yml) | [![Spoke - Orders - Deploy Orders FunctionApp](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-orders-functionapp.yml/badge.svg)](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-orders-functionapp.yml) |
| [![Spoke - Payments - Azure Infrastructure Deployment](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-payments-infra.yml/badge.svg)](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-payments-infra.yml) | [![Spoke - Payments - Deploy Payments FunctionApp](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-payments-functionapp.yml/badge.svg)](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-payments-functionapp.yml) |
| [![Spoke - Products - Azure Infrastructure Deployment](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-products-infra.yml/badge.svg)](https://github.com/jacobduijzer/HopocalypseNow/actions/workflows/spoke-products-infra.yml) | |

# Hopocalypse Now: Brews for the End Times

<img src="docs/assets/logo.png" width="200" align="left"/> This repository is used for a presentation to explain the basics of Team Topologies by using an online beer web shop as an example. It will start with a platform team, creating all services needed for value-stream teams to deploy services.

This documentation describes the flow and how to deploy the various parts. there are a few requirements to be able to deploy this application yourself.

<br clear="left"/>

## Prerequisites

* Access to Azure
* Azure CLI + Bicep

## The Application Context

The context diagram of this application looks like this:

![Context](docs/diagrams/context/context.png)

## The Platform Team

The Platform Team is one of the first teams that starts. They want to provide a platform where Stream-Aligned Teams (and other teams) can easily onboard, making use of all the services they provide. the Platform Team is the hub in the so-called 'Hub and Spoke Model'. The first service they are going to provision is a GraphQL Api, which other teams can use to get products, add orders, basically all operations go via this API.

![Platform Team](docs/assets/img/platform-01.png)

### Deploy the hub

1. Run landingzone action (duration aprox. 6:08)
2. Run Landingzone - Deploy FrontendApi FunctionApp (duration aprox: 1:40)

### The current design

![Platform Context Diagram - Platform](docs/assets/img/context-platform-only.png)

## Products Team (Stream-Aligned Team)

Now that the platform is ready, teams can actually start working. The Products Team of Value Stream, together with the Platform Team start working on getting a product database.

In the diagram, we see 2 new team types: a value-stream team and an enabling team. The enabling team helps the value-stream team with anything they can to make sure they are not blocked. For example: they help them with a new technique, GraphQl.

![Products Team](docs/assets/img/products-01.png)

### Deployments for the Products Team

1. Spoke - Products - Azure Infrastructure Deployment (duration approx 3:32)
2. Spoke - Products - Deploy Products Function App (duration approx 2:20)

### The current design

![Platform Context Diagram - Platform + Products](docs/assets/img/context-platform-products.png)

## Marketing Team (Stream-Aligned Team)

Not that there are products available, the Marketing Team wants to start as soon as possible. So, together with the Products Stream-Aligned Team, they work together on making product information available.

With the help of the Enabling Team, the Platform Team, together with the Products Team, developed an API, which they made available via the X-as-a-Service Principle.

![Marketing Team 1](docs/assets/img/marketing-01.png)

After working together (in collaboration mode) for a short amount of time, the Products Team developed a service to make product information available for the Marketing Team.

![Marketing Team 2](docs/assets/img/marketing-02.png)

### Deployments for the Marketing Team

1. Spoke - Frontend - Azure Infrastructure Deployment (duration approx 3:21)
2. Spoke - Frontend - Deploy Frontend WebApp (duration approx )

### The current design

![Platform Context Diagram - Platform + Products](docs/assets/img/context-platform-products-marketing.png)

## Orders Team (Stream-Aligned Team)

It is nice to have a web shop, but it's not really a shop when ordering is not possible. So, the organization keeps pushing forward. First, the Marketing Team and the Orders Team work together, working to make it possible to place orders. Also, the Enabling Team comes to the rescue again, helping the Orders Team work with an Azure Service Bus.

![Orders  1](docs/assets/img/orders-01.png)

After some hard work, they can all work together again, by using X-as-a-Service, which is the preferred way of working together.

![Orders Team 2](docs/assets/img/orders-02.png)

### Deployments for the Orders Team

1. 

## Payments Team (Stream-Aligned Team)

![Payments Team 1](docs/assets/img/payments-01.png)

![Payments Team 2](docs/assets/img/payments-02.png)

## Tasted-based Predictions Team (Complicated Subsystem Team)

![Tasted Based Predictions Team 1](docs/assets/img/tasted-based-predictions-01.png)

![Tasted Based Predictions Team 1](docs/assets/img/tasted-based-predictions-02.png)

## The current situation

Except the Complicated Subsystems team implementation. Too complex for this example.

![Organization](docs/diagrams/organization/Container%20Diagram.png)

## Resources

* [Team Topologies Website](https://teamtopologies.com/)
* [Team Topologies Shapes](https://github.com/TeamTopologies/Team-Shape-Templates)
* [C4 model website](https://c4model.com/)
* [C4 model + PlantUML](https://github.com/plantuml-stdlib/C4-PlantUML)
* [PlantUML + Azure](https://github.com/plantuml-stdlib/Azure-PlantUML)
* [Hub & Spoke Topology](https://www.cbtnuggets.com/blog/technology/networking/what-is-hub-and-spoke-topology)