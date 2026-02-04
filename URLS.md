# 🌐 API Testing URLs - Quick Reference

## Local Development
**Base URL**: `http://localhost:5000`  
**Swagger UI**: `http://localhost:5000/swagger`

| Method | Endpoint | URL |
|--------|----------|-----|
| GET | Health Check | `http://localhost:5000/api/health` |
| GET | All Users | `http://localhost:5000/api/users` |
| GET | User by ID | `http://localhost:5000/api/users/1` |
| POST | Create User | `http://localhost:5000/api/users` |
| PUT | Update User | `http://localhost:5000/api/users/1` |
| DELETE | Delete User | `http://localhost:5000/api/users/1` |

## Azure APIM (Production)
**Base URL**: `https://{your-apim-service}.azure-api.net/sample-api`

| Method | Endpoint | URL |
|--------|----------|-----|
| GET | Health Check | `https://{your-apim-service}.azure-api.net/sample-api/api/health` |
| GET | All Users | `https://{your-apim-service}.azure-api.net/sample-api/api/users` |
| GET | User by ID | `https://{your-apim-service}.azure-api.net/sample-api/api/users/{id}` |
| POST | Create User | `https://{your-apim-service}.azure-api.net/sample-api/api/users` |
| PUT | Update User | `https://{your-apim-service}.azure-api.net/sample-api/api/users/{id}` |
| DELETE | Delete User | `https://{your-apim-service}.azure-api.net/sample-api/api/users/{id}` |

## Quick Test Commands

### Local
```bash
# Start API
dotnet run

# Test (in another terminal)
curl http://localhost:5000/api/health
curl http://localhost:5000/api/users
```

### APIM
```bash
# Replace with your APIM service name
curl https://YOUR-APIM-NAME.azure-api.net/sample-api/api/health
curl https://YOUR-APIM-NAME.azure-api.net/sample-api/api/users
```

---

**📖 Full Documentation**: See [API-TESTING.md](API-TESTING.md) for detailed testing guide with examples and troubleshooting.
