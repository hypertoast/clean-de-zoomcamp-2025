provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a GCS bucket for temporary storage
resource "google_storage_bucket" "data_lake" {
  name          = "${var.project_id}-datalake"
  location      = var.region
  force_destroy = true
}

# Create a GCS bucket for Kestra storage
resource "google_storage_bucket" "kestra_storage" {
  name          = "${var.project_id}-kestra"
  location      = var.region
  force_destroy = true
}

# Create BigQuery datasets
resource "google_bigquery_dataset" "weather_dataset" {
  dataset_id    = "weather_analysis"
  friendly_name = "Weather Analysis Dataset"
  description   = "Dataset for NOAA weather data analysis"
  location      = "US"
}

resource "google_bigquery_dataset" "temp_dataset" {
  dataset_id    = "temp_dataset"
  friendly_name = "Temporary Dataset"
  description   = "Temporary dataset for workflow processing"
  location      = "US"
}

# Create a service account for the pipeline
resource "google_service_account" "pipeline_service_account" {
  account_id   = "weather-pipeline-sa"
  display_name = "Weather Pipeline Service Account"
}

# Grant the service account access to BigQuery
resource "google_project_iam_binding" "bigquery_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  members = [
    "serviceAccount:${google_service_account.pipeline_service_account.email}",
  ]
}

# Grant the service account access to GCS
resource "google_project_iam_binding" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.pipeline_service_account.email}",
  ]
}

# Create a smaller GKE cluster for Kestra
resource "google_container_cluster" "kestra_cluster" {
  name     = "kestra-cluster"
  location = var.region
  
  # Use a smaller cluster with fewer nodes
  initial_node_count = 1
  
  # Specify a smaller machine type and standard persistent disk
  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 50
    disk_type    = "pd-standard" # Use standard disk instead of SSD
    
    # Use the pipeline service account for the nodes
    service_account = google_service_account.pipeline_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# Upload the Kestra workflow to GCS
resource "google_storage_bucket_object" "kestra_workflow" {
  name    = "workflows/noaa_weather_ingest.yml"
  bucket  = google_storage_bucket.kestra_storage.name
  content = <<EOF
id: noaa_weather_ingest
namespace: weather
description: |
  Extracts NOAA GSOD data from the public BigQuery dataset, 
  processes it, and loads it into our optimized table structure

tasks:
  # Task 1: Extract data from public NOAA dataset
  - id: extract_data
    type: io.kestra.plugin.gcp.bigquery.Query
    sql: |
      SELECT 
        PARSE_DATE('%Y%m%d', CONCAT(year, mo, da)) as date,
        stn as station_id,
        name as station_name,
        lat as latitude,
        lon as longitude,
        temp as avg_temperature,
        max as max_temperature,
        min as min_temperature,
        prcp as precipitation,
        wdsp as wind_speed,
        visib as visibility
      FROM `bigquery-public-data.noaa_gsod.gsod*` g
      JOIN `bigquery-public-data.noaa_gsod.stations` s
      ON g.stn = s.usaf AND g.wban = s.wban
      WHERE 
        _TABLE_SUFFIX BETWEEN '2020' AND '2022'
        AND prcp != 99.99  -- Filter out invalid precipitation data
        AND temp != 9999.9 -- Filter out invalid temperature data
        AND g.stn IS NOT NULL
    destinationTable: "{{gcp.project}}.temp_dataset.noaa_weather_raw"
    serviceAccount: "{{gcp.serviceAccount}}"

  # Task 2: Transform data and save to final table
  - id: transform_data
    type: io.kestra.plugin.gcp.bigquery.Query
    sql: |
      CREATE OR REPLACE TABLE `{{gcp.project}}.weather_analysis.weather_data_optimized`
      PARTITION BY DATE_TRUNC(date, MONTH)
      CLUSTER BY station_id, latitude, longitude
      AS
      SELECT
        date,
        station_id,
        station_name,
        latitude,
        longitude,
        ROUND(avg_temperature, 2) as avg_temperature,
        ROUND(max_temperature, 2) as max_temperature,
        ROUND(min_temperature, 2) as min_temperature,
        ROUND(precipitation, 2) as precipitation,
        ROUND(wind_speed, 2) as wind_speed,
        ROUND(visibility, 2) as visibility,
        CASE
          WHEN precipitation > 0.5 THEN 'Heavy Rain'
          WHEN precipitation > 0.1 THEN 'Light Rain'
          WHEN precipitation > 0 THEN 'Drizzle'
          ELSE 'No Rain'
        END as precipitation_category,
        CASE
          WHEN avg_temperature > 30 THEN 'Very Hot'
          WHEN avg_temperature > 25 THEN 'Hot'
          WHEN avg_temperature > 15 THEN 'Warm'
          WHEN avg_temperature > 5 THEN 'Cool'
          WHEN avg_temperature > -5 THEN 'Cold'
          ELSE 'Very Cold'
        END as temperature_category
      FROM `{{gcp.project}}.temp_dataset.noaa_weather_raw`
    serviceAccount: "{{gcp.serviceAccount}}"

  # Task 3: Clean up temporary table
  - id: cleanup
    type: io.kestra.plugin.gcp.bigquery.Delete
    table: "{{gcp.project}}.temp_dataset.noaa_weather_raw"
    serviceAccount: "{{gcp.serviceAccount}}"
EOF
}

# Output variables for easy access
output "gcs_bucket" {
  value = google_storage_bucket.data_lake.name
}

output "kestra_storage_bucket" {
  value = google_storage_bucket.kestra_storage.name
}

output "service_account" {
  value = google_service_account.pipeline_service_account.email
}

output "gke_cluster" {
  value = google_container_cluster.kestra_cluster.name
}

output "gke_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.kestra_cluster.name} --region ${var.region} --project ${var.project_id}"
}

output "kestra_install_commands" {
  value = <<EOT
# Get cluster credentials
gcloud container clusters get-credentials ${google_container_cluster.kestra_cluster.name} --region ${var.region} --project ${var.project_id}

# Install Kestra using Helm
helm repo add kestra https://kestra-io.github.io/helm-charts
helm repo update
helm install kestra kestra/kestra \
  --set env.config.kestra.storage.type=gcs \
  --set env.config.kestra.storage.gcs.bucket=${google_storage_bucket.kestra_storage.name} \
  --set env.config.kestra.variables.gcp.project=${var.project_id} \
  --set env.config.kestra.variables.gcp.serviceAccount=${google_service_account.pipeline_service_account.email}

# Create a service to access the UI
kubectl expose deployment kestra --type=LoadBalancer --name=kestra-ui --port=8080

# Get the external IP (this may take a minute)
kubectl get service kestra-ui

# Wait until you see an external IP, then import the workflow
export KESTRA_URL=$(kubectl get service kestra-ui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):8080
curl -X POST "http://$KESTRA_URL/api/v1/flows/import" -H "Content-Type: application/yaml" --data-binary @<(gsutil cat gs://${google_storage_bucket.kestra_storage.name}/workflows/noaa_weather_ingest.yml)

# Execute the workflow
curl -X POST "http://$KESTRA_URL/api/v1/executions" -H "Content-Type: application/json" -d '{"namespace":"weather","flowId":"noaa_weather_ingest"}'
EOT
}