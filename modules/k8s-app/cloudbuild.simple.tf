resource "google_cloudbuild_trigger" "trigger" {
  name = "trigger-${var.name}"

  github {
    owner = var.github_owner
    name  = var.github_name

    push {
      branch = var.github_deploy_branch
    }
  }

  substitutions = {
    _CLUSTER                 = var.gke_cluster_name
    _COMPUTE_REGION          = var.region
    _SERVICE_NAME            = var.name
    _NAMESPACE               = var.name
  }

  build {

    # Build docker container
    step {
      name = "gcr.io/kaniko-project/executor:latest"
      args = ["--dockerfile=Dockerfile", "--cache=true", "--context=.", "--build-arg", "APP_REVISION=$SHORT_SHA", "--destination=gcr.io/$PROJECT_ID/$${_SERVICE_NAME}:$SHORT_SHA"]
    }

    step {
      name       = "gcr.io/cloud-builders/kubectl"
      entrypoint = "bash"
      args = ["-c", <<-EOT
        set -ex
        gcloud container clusters get-credentials --project="$PROJECT_ID" --region="$${_COMPUTE_REGION}" "$${_CLUSTER}" || exit

        kubectl set image deployment/$${_SERVICE_NAME} $${_SERVICE_NAME}=gcr.io/$PROJECT_ID/$${_SERVICE_NAME}:$SHORT_SHA -n=$${_NAMESPACE}

        kubectl rollout status --timeout=20m -w deployment/$${_SERVICE_NAME} --namespace=$${_NAMESPACE}
          
        echo DONE

      EOT
      ]

    }

    timeout = "1800s"

    options {
      machine_type = "N1_HIGHCPU_8"
    }

  }
}
