# FastAPI Docker Calculator

A simple RESTful calculator API built with **FastAPI** and **Docker** to demonstrate application containerization and basic cloud-native principles.

This project was created as part of learning **Docker, application packaging, and DevOps fundamentals**.

---

## 🚀 Features

- REST API built using FastAPI
- Health check endpoint for service validation
- Basic calculator operations:
  - Add
  - Subtract
  - Multiply
  - Divide
- Dockerized for consistent and portable runtime
- Ready to be deployed to Kubernetes or cloud environments

---

## 🧱 Tech Stack

- **Python**
- **FastAPI**
- **Uvicorn**
- **Docker**

---

## 📡 API Endpoints

### Health Check

**GET** `/health`

Response:
```json
{
  "status": "ok"
}
```
## Calculator

**POST** /calculate

Request Body:
```
{
  "a": 10,
  "b": 5,
  "operation": "add"
}
```

Response:
```
{
  "result": 15
}
```

## Supported operations:

 -- add
 -- subtract
 -- multiply
 -- divide

## 🐳 Run Locally with Docker

### Build the Docker Image
docker build -t fastapi-docker-calculator:1.0 .

### Run the Container
docker run -p 8000:8000 fastapi-docker-calculator:1.0

### Access the Application

API Docs (Swagger UI):
http://localhost:8000/docs
Health Check:
http://localhost:8000/health

## 📂 Project Structure
.
├── Dockerfile
├── main.py
├── requirements.txt
├── README.md
└── .gitignore

## 🎯 Learning Objectives

 -- This project helped reinforce understanding of:
 -- Containerizing Python applications using Docker
 -- Writing clean and efficient Dockerfiles
 -- Image vs container lifecycle
 -- Running and validating services inside containers
 -- Preparing applications for cloud and Kubernetes deployment

## 🔮 Next Steps

 -- Push Docker image to a container registry (ECR)
 -- Deploy the application using Kubernetes
 -- Add CI/CD pipeline for automated builds and deployments

## 👤 Author

### Venkatraman
### Aspiring Cloud / DevOps Engineer
