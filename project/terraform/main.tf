terraform {
  required_version = ">= 1.0"
  backend "local" {}  # Can change from "local" to "gcs" (for google) or "s3" (for aws), if you would like to preserve your tf-state online
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project
  region = var.region
  // credentials = file(var.credentials)  # Use this if you do not want to set env-var GOOGLE_APPLICATION_CREDENTIALS
}

# Data Lake Bucket
resource "google_storage_bucket" "data-lake-bucket" {
  name          = "${local.data_lake_bucket}_${var.project}" # Concatenating DL bucket & Project name for unique naming
  location      = var.region

  # Optional, but recommended settings:
  storage_class = var.storage_class
  uniform_bucket_level_access = true

  versioning {
    enabled     = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30  // days
    }
  }

  force_destroy = true
}

// In-Progress
//
//# DWH
//resource "google_bigquery_dataset" "dataset" {
//  dataset_id = var.BQ_DATASET
//}
//
//# May not be needed if covered by DBT
//resource "google_bigquery_table" "table" {
//  dataset_id = google_bigquery_dataset.dw.dataset_id
//  table_id   = var.TABLE_NAME[count.index]
//  count      = length(var.TABLE_NAME)
//
//  external_data_configuration {
//    autodetect    = true
//    source_format = "CSV"
//    source_uris = [
//      "gs://${var.BUCKET_NAME}/dw/${var.TABLE_NAME[count.index]}/*.csv"
//    ]
//  }
//}
