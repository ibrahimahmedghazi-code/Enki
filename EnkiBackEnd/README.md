# Enki backend 

In our Enki application, we use a hybrid architecture:

- One for auth using Supabase because of the SSO support.
- The other is a custom FastAPI one using Postgres.

## Using Clean Architecture

We are using Clean Architecture because we found ourselves in need of a way that is fast for development and maintaining the project, with the ability to add features without refactoring all the code.

## But we are using FastAPI

Because of three things:

1. We need something fast to develop and ship.
2. Easy support for HTTP/3 and streaming videos.
3. Python is a scripting language, which means we can use it for server automation.

## What are the downsides of Python?

1. High memory and CPU usage.
2. Too much abstraction.
3. It changes so fast that things might break (we use uv as a package manager to help with version control).

# enki database

## Postgres SQL database

Is one of the famous a free and open-source  database software that wild use in used to store, organize, and retrieve structured data securely.
and it object-relational database management system (ORDBMS)
## Key characteristics 
- Hyrid Querying support for SQL and JSON queries.
- Extensibility user can extend functionality with add-on l9ike postGIS 
- High support from community 
- It have mvcc engine 



## Podman as containers software 

Podman is a daemonless, open-source container engine developed primarily by Red Hat for managing Open Container Initiative.

### what we will do is use a postgres image 

that is the command blow 

```
podman run -d \
  --name my-postgres \
  -e POSTGRES_PASSWORD=your_secure_password \
  -v pg_data:/var/lib/postgresql:Z \
  -p 5432:5432 \
  postgres
```

how to start podman container 

```
podman run "containerID"
```

after creating postgress container access it  and accessing your database

```
podman exec -it my-postgres psql -U postgres -d enki
```

if we need to check tables in Postagres we need to use that command 

```
-- List all user-defined tables in the 'public' schema
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
```

