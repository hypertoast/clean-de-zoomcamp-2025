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

**Terraform apply output (snippet):**

```bash
[calvin@devsjc terraform]$ export PROJECT_ID=de-zoomcamp-p3-gsod

[calvin@devsjc terraform]$ terraform apply -var="project_id=de-zoomcamp-p3-gsod" -var="region=us-central1"
google_service_account.pipeline_service_account: Creating...
google_bigquery_dataset.temp_dataset: Creating...
google_storage_bucket.data_lake: Creating...
google_bigquery_dataset.weather_dataset: Creating...
google_storage_bucket.kestra_storage: Creating...
google_bigquery_dataset.weather_dataset: Creation complete after 0s [id=projects/de-zoomcamp-p3-gsod/datasets/weather_analysis]
google_bigquery_dataset.temp_dataset: Creation complete after 0s [id=projects/de-zoomcamp-p3-gsod/datasets/temp_dataset]
google_storage_bucket.kestra_storage: Creation complete after 1s [id=de-zoomcamp-p3-gsod-kestra]
google_storage_bucket_object.kestra_workflow: Creating...
google_storage_bucket.data_lake: Creation complete after 1s [id=de-zoomcamp-p3-gsod-datalake]
google_storage_bucket_object.kestra_workflow: Creation complete after 0s [id=de-zoomcamp-p3-gsod-kestra-workflows/noaa_weather_ingest.yml]
google_service_account.pipeline_service_account: Still creating... [10s elapsed]
google_service_account.pipeline_service_account: Creation complete after 12s [id=projects/de-zoomcamp-p3-gsod/serviceAccounts/weather-pipeline-sa@de-zoomcamp-p3-gsod.iam.gserviceaccount.com]
google_project_iam_binding.storage_admin: Creating...
google_project_iam_binding.bigquery_admin: Creating...
google_container_cluster.kestra_cluster: Creating...
google_project_iam_binding.bigquery_admin: Creation complete after 8s [id=de-zoomcamp-p3-gsod/roles/bigquery.admin]
google_project_iam_binding.storage_admin: Creation complete after 8s [id=de-zoomcamp-p3-gsod/roles/storage.admin]
google_container_cluster.kestra_cluster: Still creating... [10s elapsed]
google_container_cluster.kestra_cluster: Still creating... [20s elapsed]
google_container_cluster.kestra_cluster: Still creating... [30s elapsed]
google_container_cluster.kestra_cluster: Still creating... [40s elapsed]
google_container_cluster.kestra_cluster: Still creating... [50s elapsed]
google_container_cluster.kestra_cluster: Still creating... [1m0s elapsed]
google_container_cluster.kestra_cluster: Still creating... [1m10s elapsed]
google_container_cluster.kestra_cluster: Still creating... [1m20s elapsed]
google_container_cluster.kestra_cluster: Still creating... [1m30s elapsed]
google_container_cluster.kestra_cluster: Still creating... [1m40s elapsed]
google_container_cluster.kestra_cluster: Still creating... [1m50s elapsed]
google_container_cluster.kestra_cluster: Still creating... [2m0s elapsed]
google_container_cluster.kestra_cluster: Still creating... [2m10s elapsed]
google_container_cluster.kestra_cluster: Still creating... [2m20s elapsed]
google_container_cluster.kestra_cluster: Still creating... [2m30s elapsed]
google_container_cluster.kestra_cluster: Still creating... [2m40s elapsed]
google_container_cluster.kestra_cluster: Still creating... [2m50s elapsed]
google_container_cluster.kestra_cluster: Still creating... [3m0s elapsed]
google_container_cluster.kestra_cluster: Still creating... [3m10s elapsed]
google_container_cluster.kestra_cluster: Still creating... [3m20s elapsed]
google_container_cluster.kestra_cluster: Still creating... [3m30s elapsed]
google_container_cluster.kestra_cluster: Still creating... [3m40s elapsed]
google_container_cluster.kestra_cluster: Still creating... [3m50s elapsed]
google_container_cluster.kestra_cluster: Still creating... [4m0s elapsed]
google_container_cluster.kestra_cluster: Still creating... [4m10s elapsed]
google_container_cluster.kestra_cluster: Still creating... [4m20s elapsed]
google_container_cluster.kestra_cluster: Still creating... [4m30s elapsed]
google_container_cluster.kestra_cluster: Still creating... [4m40s elapsed]
google_container_cluster.kestra_cluster: Still creating... [4m50s elapsed]
google_container_cluster.kestra_cluster: Still creating... [5m0s elapsed]
google_container_cluster.kestra_cluster: Still creating... [5m10s elapsed]
google_container_cluster.kestra_cluster: Still creating... [5m20s elapsed]
google_container_cluster.kestra_cluster: Still creating... [5m30s elapsed]
google_container_cluster.kestra_cluster: Creation complete after 5m31s [id=projects/de-zoomcamp-p3-gsod/locations/us-central1/clusters/kestra-cluster]

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

gcs_bucket = "de-zoomcamp-p3-gsod-datalake"
gke_cluster = "kestra-cluster"
gke_command = "gcloud container clusters get-credentials kestra-cluster --region us-central1 --project de-zoomcamp-p3-gsod"
kestra_install_commands = <<EOT
# Get cluster credentials
gcloud container clusters get-credentials kestra-cluster --region us-central1 --project de-zoomcamp-p3-gsod

# Install Kestra using Helm
helm repo add kestra https://kestra-io.github.io/helm-charts
helm repo update
helm install kestra kestra/kestra \
  --set env.config.kestra.storage.type=gcs \
  --set env.config.kestra.storage.gcs.bucket=de-zoomcamp-p3-gsod-kestra \
  --set env.config.kestra.variables.gcp.project=de-zoomcamp-p3-gsod \
  --set env.config.kestra.variables.gcp.serviceAccount=weather-pipeline-sa@de-zoomcamp-p3-gsod.iam.gserviceaccount.com


NAME: kestra
LAST DEPLOYED: Sun Apr 27 22:21:39 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=kestra,app.kubernetes.io/instance=kestra,app.kubernetes.io/component=standalone" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward --namespace default $POD_NAME 8080:8080
  

# Create a service to access the UI
kubectl expose deployment kestra --type=LoadBalancer --name=kestra-ui --port=8080

# Get the external IP (this may take a minute)
kubectl get service kestra-ui

# Wait until you see an external IP, then import the workflow
export KESTRA_URL=$(kubectl get service kestra-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):8080
curl -X POST "http://$KESTRA_URL/api/v1/flows/import" -H "Content-Type: application/yaml" --data-binary @<(gsutil cat gs://de-zoomcamp-p3-gsod-kestra/workflows/noaa_weather_ingest.yml)

# Execute the workflow
curl -X POST "http://$KESTRA_URL/api/v1/executions" -H "Content-Type: application/json" -d '{"namespace":"weather","flowId":"noaa_weather_ingest"}'

EOT
kestra_storage_bucket = "de-zoomcamp-p3-gsod-kestra"
service_account = "weather-pipeline-sa@de-zoomcamp-p3-gsod.iam.gserviceaccount.com"
```

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