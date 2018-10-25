## Running Litmus on Kubernetes Local Persistent Volumes
--------------------------------------------------------

### Litmus  

The primary objective of Litmus is to ensure a consistent and reliable behavior of workloads running in Kubernetes. Litmus strives 
to detect real-world issues which escape during unit and integration tests. The Litmus e2e attempts to gather as many "use-cases" 
from users, while providing them with an easy way to define their "tests" : In [English](Refer:). The tests are generic in nature and are expected to run on different storage backends, by selecting appropriate
flags in the litmus test job.

Litmus contains certian "pre-built" test (kubernetes) jobs that perform certain standard tests, such as running benchmarking tools 
against a storage backend. This demo illustrates one such test where a sample TPC-C benchmark is run against Local Volumes.


Presentation: https://docs.google.com/presentation/d/1x8x6YoRfSeqkzEgZSB7FFVnQqK8cbr9E8hF77IueL34/edit?usp=sharing

