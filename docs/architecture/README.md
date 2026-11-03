# ORBIT OS architecture

ORBIT OS is a modular monolith: applications run as independent processes while
shared contracts and infrastructure remain in workspace packages.

Local service ports: API `3000`, web `5173`, PostgreSQL `5432`, Redis `6379`,
NATS `4222`, Temporal `7233`, Temporal UI `8080`, and MinIO `9000`/`9001`.
