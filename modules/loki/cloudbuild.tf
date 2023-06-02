resource "google_cloudbuild_trigger" "trigger" {
  name = "deploy-${var.name}"

  github {
    owner = "REPLACE-YOUR-GITHUB-OWNER"
    name  = "REPLACE-YOUR-GITHUB-NAME"

    push {
      branch = "^release-${var.app_env}$"
    }
  }

  substitutions = {
    _CLUSTER        = var.gke_cluster_name
    _COMPUTE_REGION = var.region
    _SERVICE_NAME   = var.name
    _NAMESPACE      = var.k8s_namespace
  }

  build {

    # Build docker container
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "--build-arg", "APP_REVISION=$SHORT_SHA", "--build-arg", "STAGING=${var.app_env == "staging" ? "1" : "0"}", "-t", "gcr.io/$PROJECT_ID/$${_SERVICE_NAME}:$SHORT_SHA", "."]
    }

    # Push docker image
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "gcr.io/$PROJECT_ID/$${_SERVICE_NAME}:$SHORT_SHA"]
    }

    # Set image for deployment
    step {
      name = "gcr.io/cloud-builders/kubectl"
      args = ["set", "image", "deployment/$${_SERVICE_NAME}", "$${_SERVICE_NAME}=gcr.io/$PROJECT_ID/$${_SERVICE_NAME}:$SHORT_SHA", "-n=$${_NAMESPACE}"]
      env = [
        "CLOUDSDK_COMPUTE_REGION=$${_COMPUTE_REGION}",
        "CLOUDSDK_CONTAINER_CLUSTER=$${_CLUSTER}",
        "CLOUDSDK_CORE_PROJECT=$PROJECT_ID"
      ]
    }

    # # Wait for rollout
    # step {
    #   name = "gcr.io/cloud-builders/kubectl"
    #   args = ["rollout", "status", "-w", "deployment/$${_SERVICE_NAME}"]
    #   env = [
    #     "CLOUDSDK_COMPUTE_REGION=$${_COMPUTE_REGION}",
    #     "CLOUDSDK_CONTAINER_CLUSTER=$${_CLUSTER}",
    #     "CLOUDSDK_CORE_PROJECT=$PROJECT_ID"
    #   ]
    # }

    images = [
      "gcr.io/$PROJECT_ID/$${_SERVICE_NAME}:$SHORT_SHA"
    ]

    timeout = "1800s"

    options {
      machine_type = "N1_HIGHCPU_8"
    }

  }
}
