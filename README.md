# OpenSearch Infra

[![License Apache](https://img.shields.io/github/license/openshift-assisted/opensearch-infra)](https://opensource.org/licenses/Apache-2.0)

## About

This repository contains the configuration and auxiliary applications for OpenSearch infrastructure that is needed to run some services:
- [Assisted Events Scrape](https://github.com/openshift-assisted/assisted-events-scrape/)
- [Prow Jobs Scraper](https://github.com/openshift-assisted/prow-jobs-scraper)

## Export Kibana dashboards

1. Log in Kibana
2. Inspect your browser and locate your cookie
3. Export your cookie `export COOKIE="xxx"`
4. `make create-backups URL=xxx` where URL is the Kibana URL
