# Shared GCS Bucket Between 2 Projects

This Terraform example creates 2 projects, A & B. 
Project A contains a VM with the default SA attached 
and Project B contains the bucket that will be accessed 
by the VM on Project A. Within project B, we bind 
the `role/storage.objectUser` role to the service account 
from Project A.

To test, go into Project A and ssh into instance-1. Then use `gcloud storage cp` to copy a file over to the destination bucket. For example:

```bash
$ touch test.txt
$ gcloud storage cp test.txt gs://my-bucket-name/
$ gcloud storage ls gs://my-bucket-name/
```