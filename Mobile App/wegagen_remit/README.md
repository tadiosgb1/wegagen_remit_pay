# wegagen_remit

A new Flutter project.

## Configure the API base URL

Set `BASE_URL` in the `.env` file in the project root to the backend address
reachable from your device. Include any required base path. The app reads that
single value for API requests, connectivity checks, and payment endpoints.

The app loads `.env` at startup and reports an error if `BASE_URL` is missing
or empty.
