# About Database Connection App

This is assignment 2 of Databases System Course - HCMUT

# Prerequisites

1. Install `nodemon` globally

```bash
npm install -g nodemon
```

2. Install dependencies

```bash
npm install
```

# Start the server

1. Start `MySQL` and `Adminer` instances

```bash
docker-compose up
```

2. Start the server

```bash
npm start
```

# Connect to MySQL db using Adminer

1. Go to `http://localhost:8080/`

2. Use the following credentials to login

- Server: `host.docker.internal`
- Username: `root`
- Password: `rootuserpw`
- Database: `fabric`
