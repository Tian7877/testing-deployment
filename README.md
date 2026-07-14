# DevOps Learning Project

Project latihan untuk belajar **Docker → Kubernetes → Terraform → Jenkins** secara bertahap dan praktik langsung.
Aplikasinya sengaja dibuat sederhana (Flask + 3 endpoint) supaya fokus belajar ada di tooling-nya, bukan di aplikasinya.

```
devops-learning-project/
├── app/                # Source code Flask
├── tests/               # Unit test (pytest)
├── Dockerfile
├── docker-compose.yml
├── k8s/                 # Manifest Kubernetes (cara manual/imperatif)
├── terraform/            # Provisioning ke Kubernetes secara declarative (IaC)
└── Jenkinsfile           # Pipeline CI/CD yang menyatukan semuanya
```

Ikuti tahapan di bawah **berurutan** — jangan loncat ke Jenkins sebelum paham Docker & Kubernetes-nya manual dulu.

---

## Prasyarat

Install di komputer kamu:
- Docker Desktop (atau Docker Engine)
- kubectl
- minikube (atau kind) — cluster Kubernetes lokal
- Terraform (>= 1.5)
- Python 3.12 (opsional, untuk run app tanpa docker)
- Jenkins (bisa dijalankan sebagai container, lihat Tahap 4)

---

## Tahap 1 — Docker (containerize aplikasi)

Build image dan jalankan container:

```bash
cd devops-learning-project
docker build -t devops-learning-project:local .
docker run -p 5000:5000 devops-learning-project:local
```

Cek di browser/terminal:
```bash
curl http://localhost:5000/
curl http://localhost:5000/health
```

Atau lebih cepat pakai docker-compose:
```bash
docker compose up --build
```

**Yang dipelajari:** layering image, `.dockerignore`, healthcheck, best practice `COPY requirements dulu baru source code` supaya cache layer efektif.

---

## Tahap 2 — Kubernetes (deploy manual pakai kubectl)

Nyalakan cluster lokal:
```bash
minikube start
minikube addons enable ingress
minikube addons enable metrics-server
```

Muat image lokal ke minikube (karena minikube punya docker daemon sendiri):
```bash
minikube image load devops-learning-project:local
```

Deploy semua manifest:
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/ingress.yaml
```

Cek status:
```bash
kubectl get all -n devops-learning
kubectl port-forward -n devops-learning svc/devops-app-service 8080:80
curl http://localhost:8080/
```

Coba juga:
```bash
kubectl scale deployment/devops-app -n devops-learning --replicas=4
kubectl logs -n devops-learning -l app=devops-app
kubectl describe hpa devops-app-hpa -n devops-learning
```

**Yang dipelajari:** Deployment vs Pod, Service (ClusterIP), ConfigMap, readiness/liveness probe, HPA, Ingress.

---

## Tahap 3 — Terraform (provisioning declarative, ganti kubectl manual)

Sekarang ulangi deployment Tahap 2, tapi pakai Terraform (bukan `kubectl apply` manual).

```bash
cd terraform
terraform init
terraform plan -var="kube_context=minikube"
terraform apply -var="kube_context=minikube"
```

Verifikasi:
```bash
terraform output
kubectl get all -n devops-learning
```

Ubah jumlah replica lewat variable, lalu apply lagi untuk lihat Terraform mendeteksi *diff*:
```bash
terraform apply -var="kube_context=minikube" -var="replicas=3"
```

Bersihkan semua resource:
```bash
terraform destroy -var="kube_context=minikube"
```

**Yang dipelajari:** state file (`terraform.tfstate`), plan/apply/destroy, variable, output, cara Terraform "mengingat" resource yang sudah dibuat.

> **Lanjutan (opsional):** Di dunia nyata, Terraform biasanya dipakai untuk provisioning **infrastruktur cloud** (VPC, subnet, EKS/GKE cluster, IAM), bukan resource K8s-nya langsung. Kalau kamu sudah nyaman dengan konsep di atas, langkah belajar berikutnya adalah cari contoh `terraform-aws-modules/eks/aws` untuk provisioning cluster AWS EKS sungguhan.

---

## Tahap 4 — Jenkins (otomatisasi semua tahap di atas)

Jalankan Jenkins via Docker (paling gampang untuk belajar):

```bash
docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

Buka `http://localhost:8080`, ikuti setup wizard (ambil initial admin password dari log container).

Install plugin: **Docker Pipeline**, **Kubernetes CLI**, **Terraform**.

Buat kredensial di **Manage Jenkins > Credentials**:
- `dockerhub-credentials` — tipe *Username with password* (akun Docker Hub kamu)
- `kubeconfig-file` — tipe *Secret file*, upload file `~/.kube/config`

Buat pipeline job baru:
1. New Item → Pipeline
2. Pipeline script from SCM → arahkan ke repo Git project ini (push dulu project ini ke GitHub/GitLab)
3. Path: `Jenkinsfile`

Jalankan **Build Now**. Pipeline akan otomatis:
1. Checkout kode
2. Install dependency & jalankan unit test (`pytest`)
3. Build image Docker
4. Push image ke Docker Hub
5. `terraform plan` & `terraform apply` untuk deploy ke Kubernetes
6. Verifikasi rollout selesai

> Sebelum menjalankan, edit `DOCKERHUB_USER` di `Jenkinsfile` sesuai akun Docker Hub kamu, dan pastikan Jenkins container punya akses ke Docker daemon serta ke cluster Kubernetes-mu (untuk minikube lokal, biasanya perlu setup jaringan tambahan — untuk latihan awal boleh juga jalankan agent Jenkins langsung di host, bukan di container).

**Yang dipelajari:** pipeline as code, stage, credential management, integrasi Docker + Terraform + Kubernetes dalam satu alur CI/CD.

---

## Urutan belajar yang disarankan

| Tahap | Fokus | Estimasi waktu |
|---|---|---|
| 1. Docker | build image, run container, layering | 1-2 hari |
| 2. Kubernetes | manifest YAML, kubectl, konsep Pod/Service/Deployment | 3-5 hari |
| 3. Terraform | state, plan/apply, provider kubernetes | 2-3 hari |
| 4. Jenkins | pipeline, integrasi semua tools | 3-5 hari |

Setelah lancar dengan project ini, langkah lanjutan: ganti Docker Hub dengan private registry (ECR/GCR), ganti cluster lokal dengan EKS/GKE real, tambahkan Helm chart untuk manifest Kubernetes, dan tambahkan tahap `terraform plan` sebagai approval gate manual di Jenkins.
