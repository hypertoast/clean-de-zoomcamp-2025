# NOAA Weather Data Analysis Pipeline

## Project Overview

**Project Title:** NOAA Weather Data Analysis Pipeline: Understanding Global Weather Patterns

**Objective:** This project builds an end-to-end data pipeline that processes NOAA Global Summary of Day (GSOD) weather data to identify climate patterns, analyze weather anomalies, and visualize weather metrics for better understanding of global weather trends.

## Problem Description

Weather data is critical for understanding climate patterns and their impacts on various aspects of society, from agriculture to transportation. However, raw weather data is often complex, voluminous, and difficult to analyze without proper processing. This project addresses these challenges by:

1. Creating an optimized data structure for efficient queries
2. Providing insights into weather patterns across different climate zones
3. Identifying anomalies and extreme weather events
4. Visualizing temporal trends and categorical distributions of weather data

## Technology Stack

| Component | Technology | Description |
|-----------|------------|-------------|
| **Cloud Platform** | Google Cloud Platform | Managed services for scalable data processing |
| **IaC** | Terraform | Infrastructure as code for GCP resource provisioning |
| **Data Lake** | Google Cloud Storage | Temporary storage for processing |
| **Data Warehouse** | BigQuery | SQL-based analytics database with partitioning/clustering |
| **Workflow Orchestration** | Kestra | Orchestrate the data pipeline workflows |
| **Transformations** | dbt | Data transformation and modeling |
| **Dashboard** | Looker Studio | Visualization of weather insights |
| **Languages** | SQL, YAML | For transformations and workflow definitions |

## Project Components

### 1. Infrastructure (Terraform)

Terraform is used to provision and manage the GCP resources:
- BigQuery datasets and tables
- Cloud Storage bucket
- Service accounts and permissions

Configuration files:
- `main.tf`: Main infrastructure definition
- `variables.tf`: Variable definitions

### 2. Data Pipeline (Kestra)

Kestra orchestrates the workflow that:
1. Extracts data from the public NOAA GSOD dataset in BigQuery
2. Transforms and filters the data to remove invalid entries
3. Loads the processed data into optimized BigQuery tables

Workflow files:
- `noaa_weather_ingest.yml`: Main workflow definition

### 3. Data Transformations (dbt)

dbt models transform the raw weather data into:
- Staging views for initial data cleaning
- Dimension tables for stations and time periods
- Fact tables for daily weather metrics with added analytical fields

Model files:
- `models/staging/stg_weather_data.sql`
- `models/dimensions/dim_stations.sql`
- `models/facts/fact_daily_weather.sql`

### 4. Analytics (BigQuery)

Custom BigQuery queries analyze the weather data for:
- Temperature trends by climate zone
- Distribution of weather categories by station
- Temporal patterns in temperature anomalies
- Correlation between weather metrics

Query files:
- `analysis_queries.sql`

### 5. Visualization (Looker Studio)

A Looker Studio dashboard with:
- Categorical visualization: Distribution of weather conditions by station/climate zone
- Temporal visualization: Temperature trends and anomalies over time
- Interactive filters for date ranges, climate zones, and weather categories

## Setup Instructions

### Prerequisites

- GCP account with billing enabled
- Local installation of:
  - Terraform (v1.0.0+)
  - Kestra (v0.3.0+)
  - dbt (v1.0.0+)
  - Google Cloud SDK

### Deployment Steps

1. **Set up GCP project**
   ```bash
   # Set your GCP project ID
   export PROJECT_ID=your-project-id
   
   # Create a new project (if needed)
   gcloud projects create $PROJECT_ID
   
   # Set as default project
   gcloud config set project $PROJECT_ID
   
   # Enable required APIs
   gcloud services enable bigquery.googleapis.com storage.googleapis.com
   ```

2. **Deploy infrastructure with Terraform**
   ```bash
   cd terraform
   terraform init
   terraform apply -var="project_id=$PROJECT_ID"
   ```

3. **Deploy Kestra workflow**
   ```bash
   # Start Kestra server (local development)
   kestra server local
   
   # Import the workflow
   kestra flow import noaa_weather_ingest.yml
   
   # Execute the workflow
   kestra flow execute weather.noaa_weather_ingest
   ```

4. **Run dbt transformations**
   ```bash
   cd dbt
   dbt deps
   dbt run
   dbt test
   ```

5. **Set up Looker Studio dashboard**
   - Open Looker Studio: https://lookerstudio.google.com/
   - Create a new dashboard
   - Connect to your BigQuery tables
   - Configure visualizations as described in the documentation

## Maintenance and Monitoring

- The Kestra workflow is scheduled to run daily to keep the data up-to-date
- dbt tests verify data quality after each transformation run
- BigQuery query logs help monitor performance and optimize queries

## Future Enhancements

- Add real-time weather data streaming
- Implement machine learning models for weather prediction
- Expand analysis to include more weather metrics
- Incorporate other datasets (e.g., climate change indicators)