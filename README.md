# Grafana SLO Testing
Main goal of this repo is to explore how Grafana SLO works

## Components
This consists of TODO parts

- test-server
- test-client
- Grafana Agent
- Prometheus (optional)
- Grafana SLO configuration

## Test Server
It has 3 endpoints,
- `/`: sends 200
- `/err`: sends 500
- `/variable`: depending on request argument, responds 200, 500, or 200 with random latency (arguments: `type: ok`, `type: ko`, `type: late-ok`)

## Test Client
Used [`oha`](https://github.com/hatoo/oha) to generate synthetic traffic:
```bash
oha -z 600min -q 200 http://127.0.0.1:51234
oha -z 180sec -q 20 "http://127.0.0.1:51234/variable?type=ko"
```

## Grafana Agent configuration
This agent is very similar to Prometheus agent, it allows you collect more than metrics but also logging and tracing data (I believe its also used for profiling data). To demonstrate Grafana SLO I have only added fetching metrics from `http://app:51234/metrics` and remote write to Self hosted Mimir.

For this demo, I have chosen to test [Grafana Agent's Flow mode](https://grafana.com/docs/agent/latest/flow/) which uses "river" files, yet another xyz. Basically a river file consists of components. Components that can be defined are documented in [Flow mode Reference page](https://grafana.com/docs/agent/latest/flow/reference/components/) (For example [`prometheus.scrape`](https://grafana.com/docs/agent/latest/flow/reference/components/prometheus.scrape/)).

> One problem I had with Grafana Agent is, it's quirky when it comes to hostname resolution that should have come from compose, it did not accept `http://app:51234/metrics`. Probably it could work if I would have created a separate network with Compose, but I just used forwarded port from my localhost IP instead.

## Prometheus configuration
For isolation aspects, I have decided to run prometheus in a separate host, in this case it will be a Raspberry Pi, its hostname is `rpi`. Hostname of the server that will run `test-server` is `nobara`.

Example prometheus configuration:
```yaml
global:
  scrape_interval: 10s
scrape_configs:
  - job_name: 'app'
    scrape_interval: 10s
    metrics_path: '/metrics'
    static_configs:
      - targets: ['nobara:51234'] # This part may need to changed

# To sync data to Grafana Mimir
remote_write:
  - url: https://prometheus-prod-24-prod-eu-west-2.grafana.net/api/prom/push
    basic_auth:
      username: 123456
      password: glc_XXXXXXXXXXXXXXXXXXXXXx
```

For replication of this test-setup, you can use Docker Compose configuration in `prometheus` directory. Don't forget to change `targets`.

As Grafana SLO only supports Mimir as of now, there are two alternatives to follow with Grafana Cloud, either:
- Have a prometheus server running that scrapes metrics from your application, then have it remote write to Mimir instance in Grafana Cloud
- Have Grafana agent and Mimir running on your setup, let Grafana agent scrape and remote write to self-hosted Mimir and add this Mimir as a data source to Grafana Cloud.

To demonstrate both, I have also created a Mimir setup which is defined in `docker-compose.yaml`.

> Note: If you try adding a prometheus server instead of Mimir, you get the following error on Grafana:
    ```
    SLO failed validation: datasource is not a Mimir - Grafana SLO currently only works with Mimir datasources with the Ruler API enabled. please refer to the docs here: https://grafana.com/docs/grafana-cloud/alerting-and-irm/slo/set-up/terraform/#provision-slo-resources and try using a DestinationDatasourceUID of: grafanacloud-prom
    ```

```bash
# Sample for availability with Prometheus
100 * (1 - (sum(rate(app_request_count_total{job="app", http_status=~"(5..|429)"}[1m])) / sum(rate(app_request_count_total{job="app"}[1m]))))
```

## First Impressions
Positive side:
- Grafana SLO allows you to generate SLI/SLOs within its web UI very easily. Specify success metric, total metric, window, SLO and that gets you:
  - Prometheus recording rules (5m, 30m, 1h, 2h, 6h, 1d, 3d)
  - Alerting for Burn Rate (warn, crit for burn rate high and very high)
- Automatically generates Dashboard to see:
  - If Alerts are firing, Burn Rate alerts
  - SLI graph
- Terraform provisioning for SLOs (and everything) and its fast, very fast.


On the not so positive side (Or I haven't figured out yet)
- Could not find a way to control remote_write frequency (on prometheus or in mimir)
- Changes are reflected to SLI/SLO board quite late (~5 mins)
- Self hosting Mimir looks quite complicated. Thankfully I found a demo container that runs it minimally, enough for demonstration.

## How to get it working
You need:
- Grafana server that has SLO plugin (Grafana Cloud offers 2 weeks of trial as of writing)
- Machine capable of running few containers
- Docker Compose

### To get test stack running:
1. Edit `targets` in `config/grafana-agent/config.river` to ensure grafana agent can reach out to test-server. You can verify after running compose and checking [Grafana Agent UI](http://localhost:51235/component/prometheus.scrape.app)
2. Run compose by: `docker compose run`

### To provision Grafana resources via Terraform:
First, create `.env` file
```bash
cd grafana-terraform
cp .env.example .env
```
and replace variables with what is needed.

I have generated `GRAFANA_AUTH_TOKEN` by going to `https://<username>.grafana.net/org/serviceaccounts`, created Service Account with Admin role and added **Service account token**.

for running terraform, I have done:
```bash
terraform init
terraform plan  -var-file=".env"
terraform apply -var-file=".env"
```


## References
- [Exposing Python Metrics with Prometheus](https://medium.com/@letathenasleep/exposing-python-metrics-with-prometheus-c5c837c21e4d)
- [Get started with Grafana Mimir](https://grafana.com/docs/mimir/latest/get-started/#configure-prometheus-to-write-to-grafana-mimir)

