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
| **Data Lake** | BigQuery | Used for both raw and processed data storage |
| **Data Warehouse** | BigQuery | SQL-based analytics database with partitioning/clustering |
| **Workflow Orchestration** | Kestra on GKE | Containerized workflow orchestration on Kubernetes |
| **Transformations** | dbt | Data transformation and modeling |
| **Dashboard** | Looker Studio | Visualization of weather insights |
| **Languages** | SQL, YAML, Terraform HCL | For transformations, workflows, and infrastructure |

## Project Architecture

![Architecture Diagram](images/architecture_diagram.png)
*[Architecture diagram showing the data flow from source through transformation to visualization]*

The architecture follows these key steps:
1. Infrastructure provisioning with Terraform (GKE, BigQuery, IAM)
2. Extract data from public NOAA dataset in BigQuery using Kestra running on GKE
3. Process and transform data using BigQuery and store in optimized tables
4. Model data using dbt for analytical purposes
5. Visualize insights using Looker Studio dashboards

## Project Components

### 1. Infrastructure (Terraform)

Terraform is used to provision and manage the GCP resources:
- BigQuery datasets (temp_dataset, weather_analysis, weather_dataset)
- Google Kubernetes Engine (GKE) cluster for Kestra
- Service accounts with appropriate IAM permissions

Key Terraform files:
- `main.tf`: Main infrastructure definition including GKE setup
- `variables.tf`: Variable definitions for project ID and region

**Screenshot:**
![Terraform Deployment](images/terraform_deployment.png)
*[Screenshot of successful Terraform deployment]*

### 2. Kubernetes Deployment for Kestra

The project uses a GKE cluster to run Kestra for workflow orchestration:
- Single-node GKE cluster with e2-medium machine type
- Helm chart for Kestra deployment
- LoadBalancer service to expose the Kestra UI

**Screenshot:**
![GKE Cluster](images/gke_cluster.png)
*[Screenshot of GKE cluster running Kestra]*

### 3. Data Pipeline (Kestra)

Kestra orchestrates the workflow that:
1. Extracts data from the public NOAA GSOD dataset in BigQuery
2. Transforms and filters the data to handle invalid entries
3. Loads the processed data into optimized BigQuery tables with appropriate partitioning and clustering

Workflow files:
- `noaa_weather_ingest.yml`: Main workflow definition with three key tasks:
  - Extract: Query public NOAA dataset
  - Transform: Create optimized table with derived fields
  - Cleanup: Remove temporary resources

**Screenshot:**
![Kestra Workflow](images/kestra_workflow.png)
*[Screenshot of the Kestra workflow execution]*

### 4. Data Transformations (dbt)

dbt models transform the already optimized data from Kestra into an analytical layer:
- Staging views that source from the optimized BigQuery table
- Dimension tables for stations with climate zone classification
- Fact tables for daily weather metrics with full analytical capabilities

Model files:
- `models/staging/stg_weather_data.sql`: Initial data staging
- `models/dimensions/dim_stations.sql`: Station information with climate zones
- `models/facts/fact_daily_weather.sql`: Complete fact table with all metrics

**Screenshot:**
![dbt Models](images/dbt_models.png)
*[Screenshot of dbt model lineage graph]*

### 5. Analytics (BigQuery)

Our data pipeline creates several optimized tables in BigQuery:
- `temp_dataset.noaa_weather_raw`: Temporary extraction table
- `weather_analysis.weather_data_optimized`: Kestra-transformed data
- `weather_dataset.dim_stations`: dbt dimension table with climate zones
- `weather_dataset.fact_daily_weather`: dbt fact table with full analytical capabilities

The table structure enables efficient querying with:
- Partitioning by month
- Clustering by station_id
- Derived categorical fields for temperature and precipitation

**Screenshot:**
![BigQuery Tables](images/bigquery_tables.png)
*[Screenshot of BigQuery tables and sample query]*

### 6. Visualization (Looker Studio)

A Looker Studio dashboard with:
- Temperature trends over time by climate zone (line chart)
- Distribution of weather categories by region (pie chart)
- Station map with temperature indicators (geo map)
- Precipitation patterns analysis (bar chart)

**Screenshot:**
![Looker Studio Dashboard](images/looker_dashboard.png)
*[Screenshot of the Looker Studio dashboard]*

## Setup Instructions

### Prerequisites

- GCP account with billing enabled
- Local installation of:
  - Terraform (v1.0.0+)
  - Google Cloud SDK with kubectl
  - Helm (for Kestra deployment)
  - dbt (v1.0.0+)

### Step 1: Deploy Infrastructure with Terraform

```bash
# Clone the repository
git clone https://github.com/yourusername/noaa-weather-pipeline.git
cd noaa-weather-pipeline/terraform

# Initialize Terraform
terraform init

# Deploy the infrastructure
terraform apply -var="project_id=your-project-id" -var="region=us-central1"
```
This creates:

- BigQuery datasets
- GKE cluster
- Service accounts
- Storage buckets

### Step 2: Deploy Kestra on GKE
After Terraform completes, deploy Kestra to the GKE cluster:

```bash
# Get credentials for the GKE cluster
gcloud container clusters get-credentials kestra-cluster --region us-central1 --project your-project-id

# Add the Kestra Helm repository
helm repo add kestra https://kestra-io.github.io/helm-charts
helm repo update

# Install Kestra using Helm
helm install kestra kestra/kestra \
  --set env.config.kestra.storage.type=gcs \
  --set env.config.kestra.storage.gcs.bucket=your-project-id-kestra \
  --set env.config.kestra.variables.gcp.project=your-project-id \
  --set env.config.kestra.variables.gcp.serviceAccount=weather-pipeline-sa@your-project-id.iam.gserviceaccount.com

# Expose the Kestra UI
kubectl expose pod $(kubectl get pods -l "app.kubernetes.io/name=kestra,app.kubernetes.io/component=standalone" -o jsonpath="{.items[0].metadata.name}") --type=LoadBalancer --name=kestra-ui --port=8080

# Get the external IP (this may take a minute)
kubectl get service kestra-ui
```

### Step 3: Import and Run the Kestra Workflow
Once Kestra is running:

1. Access the Kestra UI at the external IP address (http://EXTERNAL_IP:8080)
2. Create a new flow
3. Copy the contents of noaa_weather_ingest.yml (replacing project ID references)
4. Save and execute the workflow

### Step 4: Set Up and Run dbt
After the Kestra workflow successfully creates the optimized weather table:

```bash
# Install dbt with BigQuery adapter
pip install dbt-bigquery

# Initialize a new dbt project
dbt init weather_dbt
cd weather_dbt

# Configure profiles.yml for BigQuery connection
# Copy model files to the correct directories

# Run dbt models
dbt run
```


### Step 5: Create Looker Studio Dashboard

1. Go to Looker Studio
2. Create a new report
3. Connect to your BigQuery table (weather_dataset.fact_daily_weather)
4. Create visualizations:

- Temperature trends line chart
- Weather category distribution
- Station map
- Precipitation analysis

## Implementation Details
GKE Cluster for Kestra
The project uses a GKE cluster specifically configured for running Kestra:

- Single-node e2-medium instance for cost efficiency
- Standard persistent disk instead of SSD to stay within quota limits
- Service account with appropriate permissions for BigQuery and GCS
- Helm chart for simplified Kestra deployment
- LoadBalancer service for easy UI access

## BigQuery Optimization
The data warehouse uses several optimization techniques:

- Partitioning by month to improve query performance on time-based analysis
- Clustering by station_id for efficient filtering by location
- Categorical fields to simplify analysis of weather patterns
- Climate zone derivation for regional analysis

## dbt Data Modeling
The dbt implementation follows a layered approach:

- Staging layer: Clean and prepare data from the source
- Dimension layer: Create climate zone classifications for stations
- Fact layer: Combine all metrics with dimensions for analysis

## Project Results
The project successfully processes and analyzes NOAA weather data from 2020-2022, providing insights through:
Data Volume and Processing

- Processed over 44 million weather records from thousands of stations worldwide
- Organized data by climate zones and time periods for efficient querying
- Reduced query costs through appropriate partitioning and clustering

## Key Insights

- Identified significant temperature variations across climate zones
- Analyzed precipitation patterns and their seasonal distribution
- Created categorized weather metrics for simplified analysis

## Visualization Highlights

- Temperature trends over time by climate zone
- Distribution of precipitation categories
- Weather station distribution map

## Lessons Learned

- Successfully implemented a complete cloud-based data engineering pipeline
- Deployed and managed containerized workflow orchestration on Kubernetes
- Optimized BigQuery tables for efficient analysis
- Created a multi-layered transformation approach with both Kestra and dbt
- Developed effective visualizations that communicate key insights

## Future Enhancements

- Add real-time weather data streaming using Pub/Sub and Dataflow
- Implement machine learning models for weather prediction
- Expand analysis to include more weather metrics
- Incorporate other datasets (e.g., climate change indicators)

## References

- NOAA Global Summary of Day (GSOD) Dataset
- BigQuery Documentation
- Kestra Documentation
- dbt Documentation
- GKE Documentation