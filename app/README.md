# 2bcloud Assignment Web Application

A simple Python web application built with Flask for the 2bcloud assignment.

## Features

- Hello World endpoint at `/`
- Health check endpoint at `/healthz`
- Containerized with Docker
- Ready for deployment to Kubernetes

## Development

### Prerequisites
- Python 3.9+
- pip
- Docker (for containerization)

### Local Setup

1. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: .\venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the application:
   ```bash
   flask run --host=0.0.0.0 --port=5000
   ```

4. Access the application at http://localhost:5000

### Building the Docker Image

```bash
docker build -t 2bcloud-app .
docker run -p 5000:5000 2bcloud-app
```

### Endpoints

- `GET /` - Returns a welcome message
- `GET /healthz` - Health check endpoint that returns service status

## Deployment

The application is ready to be deployed to Kubernetes. See the root README for deployment instructions.
