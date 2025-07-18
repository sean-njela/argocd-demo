my-chart/
├── Chart.yaml           # Metadata about the chart
├── values.yaml          # Default config values
├── templates/           # Templated Kubernetes YAML files
│   ├── deployment.yaml
│   ├── service.yaml
│   └── _helpers.tpl     # Reusable template snippets
└── charts/              # Dependencies (optional)