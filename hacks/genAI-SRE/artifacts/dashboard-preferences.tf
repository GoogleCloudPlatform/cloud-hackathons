resource "google_monitoring_dashboard" "preferences_dashboard" {
  project        = var.gcp_project_id
  dashboard_json = <<EOF
  {
    "displayName": "MovieGuru-Preferences-Dashboard",
    "mosaicLayout": {
      "columns": 48,
      "tiles": [
        {
          "xPos": 24,
          "width": 24,
          "height": 16,
          "widget": {
            "xyChart": {
              "dataSets": [
                {
                  "timeSeriesQuery": {
                    "prometheusQuery": "histogram_quantile(0.1, sum(rate(movieguru_prefGet_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
                    "unitOverride": "s",
                    "outputFullDuration": false
                  },
                  "plotType": "LINE",
                  "legendTemplate": "",
                  "targetAxis": "Y1",
                  "dimensions": [],
                  "measures": [],
                  "breakdowns": []
                },
                {
                  "timeSeriesQuery": {
                    "prometheusQuery": "histogram_quantile(0.5, sum(rate(movieguru_prefGet_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
                    "unitOverride": "s",
                    "outputFullDuration": false
                  },
                  "plotType": "LINE",
                  "legendTemplate": "",
                  "targetAxis": "Y1",
                  "dimensions": [],
                  "measures": [],
                  "breakdowns": []
                },
                {
                  "timeSeriesQuery": {
                    "prometheusQuery": "histogram_quantile(0.9, sum(rate(movieguru_prefGet_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
                    "unitOverride": "s",
                    "outputFullDuration": false
                  },
                  "plotType": "LINE",
                  "legendTemplate": "",
                  "targetAxis": "Y1",
                  "dimensions": [],
                  "measures": [],
                  "breakdowns": []
                },
                {
                  "timeSeriesQuery": {
                    "prometheusQuery": "histogram_quantile(0.95, sum(rate(movieguru_prefGet_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
                    "unitOverride": "s",
                    "outputFullDuration": false
                  },
                  "plotType": "LINE",
                  "legendTemplate": "",
                  "targetAxis": "Y1",
                  "dimensions": [],
                  "measures": [],
                  "breakdowns": []
                },
                {
                  "timeSeriesQuery": {
                    "prometheusQuery": "histogram_quantile(0.99, sum(rate(movieguru_prefGet_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
                    "unitOverride": "s",
                    "outputFullDuration": false
                  },
                  "plotType": "LINE",
                  "legendTemplate": "",
                  "targetAxis": "Y1",
                  "dimensions": [],
                  "measures": [],
                  "breakdowns": []
                }
              ],
              "thresholds": [],
              "yAxis": {
                "label": "",
                "scale": "LINEAR"
              },
              "chartOptions": {
                "mode": "COLOR",
                "showLegend": false,
                "displayHorizontal": false
              }
            },
            "title": "Preferences Get Latency",
            "id": ""
          }
        },
        {
          "width": 24,
          "height": 16,
          "widget": {
            "xyChart": {
              "dataSets": [
                {
                  "timeSeriesQuery": {
                    "prometheusQuery": "histogram_quantile(0.1, sum(rate(movieguru_prefUpdate_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
                    "unitOverride": "ms",
                    "outputFullDuration": false
                  },
                  "plotType": "LINE",
                  "legendTemplate": "",
                  "targetAxis": "Y1",
                  "dimensions": [],
                  "measures": [],
                  "breakdowns": []
                },
                {
                  "timeSeriesQuery": {
                    "prometheusQuery": "histogram_quantile(0.5, sum(rate(movieguru_prefUpdate_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
                    "unitOverride": "ms",
                    "outputFullDuration": false
                  },
                  "plotType": "LINE",
                  "legendTemplate": "",
                  "targetAxis": "Y1",
                  "dimensions": [],
                  "measures": [],
                  "breakdowns": []
                },
                {
                  "timeSeriesQuery": {
                    "prometheusQuery": "histogram_quantile(0.9, sum(rate(movieguru_prefUpdate_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
                    "unitOverride": "ms",
                    "outputFullDuration": false
                  },
                  "plotType": "LINE",
                  "legendTemplate": "",
                  "targetAxis": "Y1",
                  "dimensions": [],
                  "measures": [],
                  "breakdowns": []
                },
                {
                  "timeSeriesQuery": {
                    "prometheusQuery": "histogram_quantile(0.95, sum(rate(movieguru_prefUpdate_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
                    "unitOverride": "ms",
                    "outputFullDuration": false
                  },
                  "plotType": "LINE",
                  "legendTemplate": "",
                  "targetAxis": "Y1",
                  "dimensions": [],
                  "measures": [],
                  "breakdowns": []
                },
                {
                  "timeSeriesQuery": {
                    "prometheusQuery": "histogram_quantile(0.99, sum(rate(movieguru_prefUpdate_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
                    "unitOverride": "ms",
                    "outputFullDuration": false
                  },
                  "plotType": "LINE",
                  "legendTemplate": "",
                  "targetAxis": "Y1",
                  "dimensions": [],
                  "measures": [],
                  "breakdowns": []
                }
              ],
              "thresholds": [],
              "yAxis": {
                "label": "",
                "scale": "LINEAR"
              },
              "chartOptions": {
                "mode": "COLOR",
                "showLegend": false,
                "displayHorizontal": false
              }
            },
            "title": "Preferences Update Latency",
            "id": ""
          }
        },
        {
          "yPos": 16,
          "width": 24,
          "height": 16,
          "widget": {
            "xyChart": {
              "dataSets": [
                {
                  "timeSeriesQuery": {
                    "prometheusQuery": "(sum(rate(movieguru_prefGet_success_total[$${__interval}])) / sum(rate(movieguru_prefGet_attempts_total[$${__interval}]))) *100",
                    "unitOverride": "",
                    "outputFullDuration": false
                  },
                  "plotType": "LINE",
                  "legendTemplate": "",
                  "targetAxis": "Y1",
                  "dimensions": [],
                  "measures": [],
                  "breakdowns": []
                }
              ],
              "thresholds": [],
              "yAxis": {
                "label": "",
                "scale": "LINEAR"
              },
              "chartOptions": {
                "mode": "COLOR",
                "showLegend": false,
                "displayHorizontal": false
              }
            },
            "title": "Preferences Get Success Rate",
            "id": ""
          }
        },
        {
          "xPos": 24,
          "yPos": 16,
          "width": 24,
          "height": 16,
          "widget": {
            "xyChart": {
              "dataSets": [
                {
                  "timeSeriesQuery": {
                    "prometheusQuery": "(sum(rate(movieguru_prefUpdate_success_total[$${__interval}])) / sum(rate(movieguru_prefUpdate_attempts_total[$${__interval}]))) *100",
                    "unitOverride": "",
                    "outputFullDuration": false
                  },
                  "plotType": "LINE",
                  "legendTemplate": "",
                  "targetAxis": "Y1",
                  "dimensions": [],
                  "measures": [],
                  "breakdowns": []
                }
              ],
              "thresholds": [],
              "yAxis": {
                "label": "",
                "scale": "LINEAR"
              },
              "chartOptions": {
                "mode": "COLOR",
                "showLegend": false,
                "displayHorizontal": false
              }
            },
            "title": "Preferences Update Success Rate",
            "id": ""
          }
        }
      ]
    },
    "dashboardFilters": [],
    "labels": {}
  }
  
  EOF
}