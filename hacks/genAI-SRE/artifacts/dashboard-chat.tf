resource "google_monitoring_dashboard" "chat_dashboard" {
  project        = var.gcp_project_id
  dashboard_json = <<EOF
  {
  "displayName": "MovieGuru-Chat-Dashboard",
  "mosaicLayout": {
    "columns": 48,
    "tiles": [
      {
        "width": 24,
        "height": 16,
        "widget": {
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "prometheusQuery": "(sum(rate(movieguru_chat_calls_success_total[$${__interval}])) / sum(rate(movieguru_chat_calls_total[$${__interval}]))) * 100",
                  "unitOverride": "%",
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
          "title": "Chat Success Rate",
          "id": ""
        }
      },
      {
        "xPos": 24,
        "width": 24,
        "height": 16,
        "widget": {
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "prometheusQuery": "(sum(rate(movieguru_chat_outcome_counter_total{Outcome=\"Engaged\"}[$${__interval}])) / sum(rate(movieguru_chat_outcome_counter_total[$${__interval}]))) * 100",
                  "unitOverride": "%",
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
          "title": "User Engagement Rate",
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
                  "prometheusQuery": "(sum(rate(movieguru_chat_sentiment_counter_total{Sentiment=\"Positive\"}[$${__interval}])) / sum(rate(movieguru_chat_sentiment_counter_total[$${__interval}]))) * 100\n",
                  "unitOverride": "%",
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
                  "prometheusQuery": "(sum(rate(movieguru_chat_sentiment_counter_total{Sentiment=\"Negative\"}[$${__interval}])) / sum(rate(movieguru_chat_sentiment_counter_total[$${__interval}]))) * 100",
                  "unitOverride": "%",
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
                  "prometheusQuery": "(sum(rate(movieguru_chat_sentiment_counter_total{Sentiment=\"Neutral\"}[$${__interval}])) / sum(rate(movieguru_chat_sentiment_counter_total[$${__interval}]))) * 100\n",
                  "unitOverride": "%",
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
          "title": "User Sentiment Rate",
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
                  "prometheusQuery": "histogram_quantile(0.1, sum(rate(movieguru_chat_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
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
                  "prometheusQuery": "histogram_quantile(0.5, sum(rate(movieguru_chat_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
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
                  "prometheusQuery": "histogram_quantile(0.9, sum(rate(movieguru_chat_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
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
                  "prometheusQuery": "histogram_quantile(0.95, sum(rate(movieguru_chat_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
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
                  "prometheusQuery": "histogram_quantile(0.99, sum(rate(movieguru_chat_latency_milliseconds_bucket[$${__interval}])) by (le))\n",
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
          "title": "Chat Latency",
          "id": ""
        }
      },
      {
        "yPos": 32,
        "width": 24,
        "height": 16,
        "widget": {
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "prometheusQuery": "(sum(movieguru_chat_calls_success_total) / sum(movieguru_chat_calls_total)) * 100",
                  "unitOverride": "%",
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
          "title": "Chat Safety Issue Rate",
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