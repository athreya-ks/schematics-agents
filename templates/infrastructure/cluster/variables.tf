###############################################################################
# IBM Confidential
# OCO Source Materials
# IBM Cloud Schematics
# (C) Copyright IBM Corp. 2022 All Rights Reserved.
# The source code for this program is not  published or otherwise divested of
# its trade secrets, irrespective of what has been deposited with
# the U.S. Copyright Office.
###############################################################################

##############################################################################
# Account variables
##############################################################################

variable "create_cluster" {
  description = "Enable this to provision VPC cluster."
  type        = bool
}

variable "prefix" {
  description = "A unique identifier need to provision resources. Must begin with a letter"
  type        = string
  default     = "agent-stage"

  validation {
    error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "region" {
  description = "IBM Cloud region where all resources will be deployed"
  type        = string
}

variable "resource_group_id" {
  description = "ID of resource group where all infrastructure will be provisioned"
  type        = string
}

##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable "vpc_id" {
  description = "ID of VPC where cluster is to be created"
  type        = string
}

variable "subnets" {
  description = "A map containing cluster subnet IDs and subnet zones"
  type = list(object({
    id   = string
    zone = string
    cidr = string
    name = string
  }))
}

##############################################################################


##############################################################################
# Cluster Variables
##############################################################################

variable "machine_type" {
  description = "The flavor of VPC worker node to use for your cluster. Use `ibmcloud ks flavors` to find flavors for a region."
  type        = string
  default     = "bx2.4x16"
}

variable "workers_per_zone" {
  description = "Number of workers to provision in each subnet"
  type        = number
  default     = 1

  # validation {
  #     error_message = "Each zone must contain at least 2 workers."
  #     condition     = var.workers_per_zone >= 2
  # }
}

variable "kube_version" {
  description = "Specify the Kubernetes version, including the major.minor version. To see available versions, run `ibmcloud ks versions`."
  type        = string
  default     = "4.9.21_openshift"

  # validation {
  #     error_message = "To create a ROKS cluster, the kube version must include `openshift`."
  #     condition     = can(regex(".*openshift", var.kube_version))
  # }
}

variable "wait_till" {
  description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`"
  type        = string
  default     = "IngressReady"

  validation {
    error_message = "`wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, or `IngressReady`."
    condition = contains([
      "MasterNodeReady",
      "OneWorkerNodeReady",
      "IngressReady"
    ], var.wait_till)
  }
}

variable "tags" {
  description = "A list of tags to add to the cluster"
  type        = list(string)
  default     = ["agent-stage:agent"]

  # validation {
  #   error_message = "Tags must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$`."
  #   condition = length([
  #     for name in var.tags :
  #     false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", name))
  #   ]) == 0
  # }
}

variable "worker_pools" {
  description = "List of maps describing worker pools"

  type = list(object({
    name             = string
    machine_type     = string
    workers_per_zone = number
  }))

  default = []

  validation {
    error_message = "Worker pool names must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$`."
    condition = length([
      for pool in var.worker_pools :
      false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", pool.name))
    ]) == 0
  }

  validation {
    error_message = "Worker pools cannot have duplicate names."
    condition = length(distinct([
      for pool in var.worker_pools :
      pool.name
    ])) == length(var.worker_pools)
  }

  validation {
    error_message = "Worker pools must have at least two workers per zone."
    condition = length([
      for pool in var.worker_pools :
      false if pool.workers_per_zone < 2
    ]) == 0
  }

}

##############################################################################
