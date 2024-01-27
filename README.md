# Grafana SLO Testing
Main goal of this repo is to explore how Grafana SLO works

## Components
This consists of TODO parts

- test-server
- test-client
- prometheus configuration
- Grafana SLO configuration

## Test Server
It has 3 endpoints,
- `/`: sends 200
- `/err`: sends 500
- `/variable`: depending on request argument, responds 200, 500, or 200 with random latency (arguments: `type: ok`, `type: ko`, `type: late-ok`)

## Test Client
Used [`oha`](https://github.com/hatoo/oha) to generate traffic:
```
oha -z 600min -q 200 http://127.0.0.1:51234
oha -z 100sec -q 10 "http://127.0.0.1:51234/variable?type=ko"
```

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
```

For replication of this test-setup, you can use Docker Compose configuration in `prometheus` directory. Don't forget to change `targets`.

```
# Sample for availability
100 * (1 - (sum(rate(app_request_count_total{job="app", http_status=~"(5..|429)"}[1m])) / sum(rate(app_request_count_total{job="app"}[1m]))))
```

## References
- [Exposing Python Metrics with Prometheus](https://medium.com/@letathenasleep/exposing-python-metrics-with-prometheus-c5c837c21e4d)

```
SLO failed validation: datasource is not a Mimir - Grafana SLO currently only works with Mimir datasources with the Ruler API enabled. please refer to the docs here: https://grafana.com/docs/grafana-cloud/alerting-and-irm/slo/set-up/terraform/#provision-slo-resources and try using a DestinationDatasourceUID of: grafanacloud-prom
```