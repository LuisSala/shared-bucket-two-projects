# Shared GCS Bucket Between 2 Projects

This Terraform example creates 2 projects, A & B. 
Project A contains a VM with the default SA attached 
and Project B contains the bucket that will be accessed 
by the VM on Project A. Within project B, we bind 
the `role/storage.objectUser` role to the service account 
from Project A.