# API Testing Guide

## 🌐 Testing URLs

This guide provides all the URLs you need to test the Sample API both locally and after deployment to Azure APIM.

---

## 📍 Local Testing URLs

When running the API locally using `dotnet run`, use these URLs:

### Base URLs
- **HTTP**: `http://localhost:5000`
- **HTTPS**: `https://localhost:5001`
- **Swagger UI**: `http://localhost:5000/swagger` (Interactive API documentation)

### API Endpoints

#### 1. Health Check
```
GET http://localhost:5000/api/health
```

#### 2. Get All Users
```
GET http://localhost:5000/api/users
```

#### 3. Get User by ID
```
GET http://localhost:5000/api/users/{id}
```
Example: `http://localhost:5000/api/users/1`

#### 4. Create New User
```
POST http://localhost:5000/api/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com"
}
```

#### 5. Update User
```
PUT http://localhost:5000/api/users/{id}
Content-Type: application/json

{
  "name": "John Updated",
  "email": "john.updated@example.com"
}
```

#### 6. Delete User
```
DELETE http://localhost:5000/api/users/{id}
```

---

## ☁️ Azure APIM URLs (After Deployment)

After deploying to Azure APIM, replace the placeholders with your actual values:

### Base URL Pattern
```
https://{your-apim-service-name}.azure-api.net/{api-path}
```

**Example with actual values:**
```
https://my-apim-service.azure-api.net/sample-api
```

### Full Endpoint URLs (APIM)

#### 1. Health Check
```
GET https://{your-apim-service-name}.azure-api.net/sample-api/api/health
```

#### 2. Get All Users
```
GET https://{your-apim-service-name}.azure-api.net/sample-api/api/users
```

#### 3. Get User by ID
```
GET https://{your-apim-service-name}.azure-api.net/sample-api/api/users/{id}
```

#### 4. Create New User
```
POST https://{your-apim-service-name}.azure-api.net/sample-api/api/users
Content-Type: application/json

{
  "name": "Jane Smith",
  "email": "jane@example.com"
}
```

#### 5. Update User
```
PUT https://{your-apim-service-name}.azure-api.net/sample-api/api/users/{id}
Content-Type: application/json

{
  "name": "Jane Updated",
  "email": "jane.updated@example.com"
}
```

#### 6. Delete User
```
DELETE https://{your-apim-service-name}.azure-api.net/sample-api/api/users/{id}
```

---

## 🧪 Quick Testing with cURL

### Local Testing

```bash
# 1. Health Check
curl http://localhost:5000/api/health

# 2. Get all users
curl http://localhost:5000/api/users

# 3. Get user by ID
curl http://localhost:5000/api/users/1

# 4. Create a new user
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice Smith","email":"alice@example.com"}'

# 5. Update a user
curl -X PUT http://localhost:5000/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice Updated","email":"alice.updated@example.com"}'

# 6. Delete a user
curl -X DELETE http://localhost:5000/api/users/1
```

### APIM Testing (Replace {your-apim-service-name})

```bash
# Set your APIM base URL
APIM_BASE="https://{your-apim-service-name}.azure-api.net/sample-api"

# 1. Health Check
curl $APIM_BASE/api/health

# 2. Get all users
curl $APIM_BASE/api/users

# 3. Get user by ID
curl $APIM_BASE/api/users/1

# 4. Create a new user
curl -X POST $APIM_BASE/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Bob Johnson","email":"bob@example.com"}'

# 5. Update a user
curl -X PUT $APIM_BASE/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Bob Updated","email":"bob.updated@example.com"}'

# 6. Delete a user
curl -X DELETE $APIM_BASE/api/users/1
```

---

## 📮 Postman Collection

You can import this into Postman for easy testing:

```json
{
  "info": {
    "name": "Sample API - Local & APIM",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "local_base_url",
      "value": "http://localhost:5000",
      "type": "string"
    },
    {
      "key": "apim_base_url",
      "value": "https://{your-apim-service-name}.azure-api.net/sample-api",
      "type": "string"
    }
  ],
  "item": [
    {
      "name": "Local - Health Check",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{local_base_url}}/api/health",
          "host": ["{{local_base_url}}"],
          "path": ["api", "health"]
        }
      }
    },
    {
      "name": "Local - Get All Users",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{local_base_url}}/api/users",
          "host": ["{{local_base_url}}"],
          "path": ["api", "users"]
        }
      }
    },
    {
      "name": "Local - Get User by ID",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{local_base_url}}/api/users/1",
          "host": ["{{local_base_url}}"],
          "path": ["api", "users", "1"]
        }
      }
    },
    {
      "name": "Local - Create User",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"name\": \"Test User\",\n  \"email\": \"test@example.com\"\n}"
        },
        "url": {
          "raw": "{{local_base_url}}/api/users",
          "host": ["{{local_base_url}}"],
          "path": ["api", "users"]
        }
      }
    },
    {
      "name": "Local - Update User",
      "request": {
        "method": "PUT",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"name\": \"Updated User\",\n  \"email\": \"updated@example.com\"\n}"
        },
        "url": {
          "raw": "{{local_base_url}}/api/users/1",
          "host": ["{{local_base_url}}"],
          "path": ["api", "users", "1"]
        }
      }
    },
    {
      "name": "Local - Delete User",
      "request": {
        "method": "DELETE",
        "header": [],
        "url": {
          "raw": "{{local_base_url}}/api/users/1",
          "host": ["{{local_base_url}}"],
          "path": ["api", "users", "1"]
        }
      }
    },
    {
      "name": "APIM - Health Check",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{apim_base_url}}/api/health",
          "host": ["{{apim_base_url}}"],
          "path": ["api", "health"]
        }
      }
    },
    {
      "name": "APIM - Get All Users",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{apim_base_url}}/api/users",
          "host": ["{{apim_base_url}}"],
          "path": ["api", "users"]
        }
      }
    }
  ]
}
```

---

## 🔍 How to Find Your APIM Service Name

If you've already deployed to APIM, you can find your service name:

### Option 1: Azure Portal
1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **API Management services**
3. Find your APIM service
4. The **Gateway URL** will be shown as: `https://{your-service-name}.azure-api.net`

### Option 2: Azure CLI
```bash
# List all APIM services in your subscription
az apim list --output table

# Get specific APIM service details
az apim show \
  --name {your-apim-service-name} \
  --resource-group {your-resource-group} \
  --query gatewayUrl \
  --output tsv
```

### Option 3: Check GitHub Secrets
Your APIM service name is stored in the GitHub secret: `APIM_SERVICE_NAME`

---

## 📊 Expected Responses

### Health Check Response
```json
{
  "status": "healthy",
  "timestamp": "2026-02-04T05:27:00.000Z",
  "service": "Sample API"
}
```

### Get All Users Response
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  {
    "id": 2,
    "name": "Jane Smith",
    "email": "jane@example.com"
  },
  {
    "id": 3,
    "name": "Bob Johnson",
    "email": "bob@example.com"
  }
]
```

### Get User by ID Response
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com"
}
```

### Create User Response (201 Created)
```json
{
  "id": 4,
  "name": "Alice Smith",
  "email": "alice@example.com"
}
```

### Update User Response
```json
{
  "id": 1,
  "name": "John Updated",
  "email": "john.updated@example.com"
}
```

### Delete User Response
```json
{
  "message": "User 1 deleted successfully"
}
```

### Error Response (404 Not Found)
```json
{
  "error": "User not found"
}
```

### Error Response (400 Bad Request)
```json
{
  "error": "Name is required"
}
```
or
```json
{
  "error": "Invalid email format"
}
```

---

## 🚀 Quick Start

### Test Locally (3 steps)

1. **Start the API**
   ```bash
   cd /path/to/hackathon
   dotnet run
   ```

2. **Open Swagger UI in browser**
   ```
   http://localhost:5000/swagger
   ```

3. **Test with curl**
   ```bash
   curl http://localhost:5000/api/health
   ```

### Test on APIM (After Deployment)

1. **Get your APIM URL from Azure Portal**
   
2. **Test the health endpoint**
   ```bash
   curl https://{your-apim-service}.azure-api.net/sample-api/api/health
   ```

3. **If it works, test other endpoints!**

---

## 🐛 Troubleshooting

### Local Testing Issues

**Problem**: Connection refused on localhost:5000
- **Solution**: Make sure the API is running with `dotnet run`
- Check if port 5000 is already in use

**Problem**: HTTPS certificate errors on localhost:5001
- **Solution**: Trust the development certificate:
  ```bash
  dotnet dev-certs https --trust
  ```

### APIM Testing Issues

**Problem**: 404 Not Found on APIM URL
- **Solution**: 
  - Verify the API has been deployed to APIM
  - Check the GitHub Actions workflow succeeded
  - Verify your APIM service name is correct

**Problem**: 401 Unauthorized
- **Solution**: If your APIM requires subscriptions:
  - Get a subscription key from Azure Portal
  - Add header: `Ocp-Apim-Subscription-Key: {your-key}`

**Problem**: CORS errors in browser
- **Solution**: CORS is configured for production origins in appsettings.json
  - Update `AllowedOrigins` in appsettings.json for your domain

---

## 📝 Notes

- **Local URLs** are for development and testing on your machine
- **APIM URLs** are for production use after deployment
- Replace `{your-apim-service-name}` with your actual APIM service name
- Default API path is `sample-api` (can be changed in GitHub secrets)
- All endpoints return JSON responses
- POST and PUT requests require `Content-Type: application/json` header

---

## 📚 Related Documentation

- [README.md](README.md) - Complete project documentation
- [SETUP-GUIDE.md](SETUP-GUIDE.md) - Azure and GitHub setup
- [QUICKSTART.md](QUICKSTART.md) - Quick reference guide
- [swagger.yaml](swagger.yaml) - OpenAPI specification

---

**Need Help?** Check the [SETUP-GUIDE.md](SETUP-GUIDE.md) for detailed troubleshooting or the [README.md](README.md) for complete documentation.
