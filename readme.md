# Automation Performance Dashboard

Welcome to the Automation Performance Dashboard project! This project aims to provide real-time insights and analytics on automation performance using AWS services such as Glue, Redshift, S3, and QuickSight.

## Table of Contents

1. [Introduction](#introduction)
2. [Architecture Overview](#architecture-overview)
3. [Prerequisites](#prerequisites)
4. [Getting Started](#getting-started)
5. [Project Structure](#project-structure)
6. [Deployment](#deployment)
7. [Usage](#usage)
8. [Contributing](#contributing)
9. [License](#license)

## Introduction

This project implements a data pipeline to automate the extraction, transformation, loading, and visualization of automation performance metrics. Leveraging AWS services, the project provides an end-to-end solution for analyzing and visualizing data, allowing stakeholders to gain insights into the effectiveness of automation processes.

## Architecture Overview

The architecture of the Automation Performance Dashboard project involves the following components:

- **AWS Glue**: Handles data cataloging, ETL processes, and job orchestration.
- **Amazon S3**: Stores raw and processed data files.
- **Amazon Redshift**: Acts as the data warehouse for storing transformed data.

For a detailed overview of the architecture, refer to the [Architecture and System Design](#architecture-and-system-design) section of the project documentation.

## Prerequisites

Before running the project, ensure you have the following prerequisites installed:

- Terraform
- AWS CLI
- Python
- Access to an AWS account with appropriate permissions to create and manage resources


## Getting Started

To get started with the project, follow these steps:

1. Clone the repository to your local machine.
2. Configure AWS CLI with your AWS account credentials.
3. Initialize Terraform in the project directory.
4. Modify the Terraform configuration files as needed.
5. Deploy the infrastructure using Terraform.
6. Run the ETL processes using AWS Glue or custom scripts.


## Project Structure

The project directory structure is organized as follows:
```
bash

/automation-performance-dashboard
    /terraform
        # Terraform configuration files for infrastructure setup
    /scripts
        /etl
            # Custom ETL scripts for data processing
    /docs
        README.md              # Project documentation
        setup_instructions.md  # Setup and run instructions
        presentation.pdf      # Project presentation slides

```

## Deployment

To deploy the project infrastructure, follow these steps:

1. Navigate to the `/terraform` directory.
2. Initialize Terraform with `terraform init`.
3. Review the Terraform execution plan with `terraform plan`.
4. Apply the changes to create the infrastructure with `terraform apply`.
5. Monitor the deployment progress and confirm any prompts.


## Usage

Once the infrastructure is deployed, you can start using the Automation Performance Dashboard:

1. Run the ETL processes to extract, transform, and load data into Amazon Redshift.
2. Configure Redshift connection to your data vizualization tool.
3. Access the dashboards to visualize automation performance metrics.


## License

This project is licensed under the [MIT License](LICENSE).
