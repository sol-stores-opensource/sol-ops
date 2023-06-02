# Solana Spaces terraform ops

There are two separate terraform plans, due to the way some initial infrastructure needs to
be applied first, and present before other parts are applied.

### gce

Base level terraform for the required Google Cloud APIs, GKE Autopilot cluster, common
service accounts, and the VPC.

### k8s

This terraform typically applies to the GKE Autopilot cluster.  It includes additional
service accounts, setup for CloudSQL, and a PostgreSQL db.

### GKE Autopilot notes

- CPU resources must use increments of 0.25 CPUs, or 250 mCPU. Autopilot automatically adjusts your requests to round up to the nearest 250m. For example, if you request 800m CPU, Autopilot adjusts the request to 1000m (1 vCPU).
- The CPU:memory ratio must be within the allowed range for the selected compute class.
- The ephemeral storage limit, which must be within 10 MiB and 10 GiB for all compute classes.

```
CPU:memory ratio (vCPU:GiB)     Minimum     Maximum
Between 1:1 and 1:6.5           0.25 vCPU   28 vCPU
                                0.5 GiB     80 GiB
```                                

## Running

Run gce first, and from time to time as needed.  Then run k8s second.  k8s is the one we will
typically be working on.

    cd gce
    ./run.sh apply

    cd ..

    cd k8s
    ./run.sh apply

The script `run.sh` is a helper establishing needed environment variables and common commands.
