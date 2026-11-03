# System context

Users interact with the React web application and API. The API and worker use
shared packages and connect to PostgreSQL, Redis, NATS, Temporal, and MinIO.
The AI runtime is an independently runnable process and does not require an LLM
credential for startup.
