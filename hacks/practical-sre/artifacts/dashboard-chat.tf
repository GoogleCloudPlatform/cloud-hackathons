# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_monitoring_dashboard" "chat_dashboard" {
  project = var.gcp_project_id
  dashboard_json = jsonencode({
    "displayName" : "MovieGuru-Chat-Dashboard",
    "mosaicLayout" : {
      "columns" : 48,
      "tiles" : [
        {
          "width" : 24,
          "height" : 16,
          "widget" : {
            "title" : "Chat Success Rate",
            "xyChart" : {
              "dataSets" : [
                {
                  "timeSeriesQuery" : {
                    "prometheusQuery" : "label_replace((sum(rate(movieguru_chat_calls_success_total[$${__interval}])) / sum(rate(movieguru_chat_calls_total[$${__interval}]))) * 100, \"legend\", \"Success Rate\", \"\", \"\")",
                    "unitOverride" : "%"
                  },
                  "plotType" : "LINE"
                }
              ],
              "yAxis" : {
                "scale" : "LINEAR"
              },
              "chartOptions" : {
                "mode" : "COLOR"
              }
            }
          }
        },
        {
          "xPos" : 24,
          "width" : 24,
          "height" : 16,
          "widget" : {
            "title" : "User Engagement Rate",
            "xyChart" : {
              "dataSets" : [
                {
                  "timeSeriesQuery" : {
                    "prometheusQuery" : "label_replace((sum(rate(movieguru_chat_outcome_counter_total{Outcome=~\"Engaged\"}[$${__interval}])) / sum(rate(movieguru_chat_outcome_counter_total[$${__interval}]))) * 100, \"legend\", \"Engagement Rate\", \"\", \"\")",
                    "unitOverride" : "%"
                  },
                  "plotType" : "LINE"
                }
              ],
              "yAxis" : {
                "scale" : "LINEAR"
              },
              "chartOptions" : {
                "mode" : "COLOR"
              }
            }
          }
        },
        {
          "yPos" : 16,
          "width" : 24,
          "height" : 16,
          "widget" : {
            "title" : "User Sentiment Rate",
            "xyChart" : {
              "dataSets" : [
                {
                  "timeSeriesQuery" : {
                    "prometheusQuery" : "label_replace((sum(rate(movieguru_chat_sentiment_counter_total{Sentiment=\"Positive\"}[$${__interval}])) / sum(rate(movieguru_chat_sentiment_counter_total[$${__interval}]))) * 100, \"legend\", \"Positive Sentiment\", \"\", \"\")",
                    "unitOverride" : "%"
                  },
                  "plotType" : "LINE"
                },
                {
                  "timeSeriesQuery" : {
                    "prometheusQuery" : "label_replace((sum(rate(movieguru_chat_sentiment_counter_total{Sentiment=\"Negative\"}[$${__interval}])) / sum(rate(movieguru_chat_sentiment_counter_total[$${__interval}]))) * 100, \"legend\", \"Negative Sentiment\", \"\", \"\")", 
                    "unitOverride" : "%"
                  },
                  "plotType" : "LINE"
                },
                {
                  "timeSeriesQuery" : {
                    "prometheusQuery" : "label_replace((sum(rate(movieguru_chat_sentiment_counter_total{Sentiment=\"Neutral\"}[$${__interval}])) / sum(rate(movieguru_chat_sentiment_counter_total[$${__interval}]))) * 100, \"legend\", \"Neutral Sentiment\", \"\", \"\")",
                    "unitOverride" : "%"
                  },
                  "plotType" : "LINE"
                }
              ],
              "yAxis" : {
                "scale" : "LINEAR"
              },
              "chartOptions" : {
                "mode" : "COLOR"
              }
            }
          }
        },
        {
          "xPos" : 24,
          "yPos" : 16,
          "width" : 24,
          "height" : 16,
          "widget" : {
            "title" : "Chat Latency",
            "xyChart" : {
              "dataSets" : [
                {
                  "timeSeriesQuery" : {
                    "prometheusQuery" : "label_replace(histogram_quantile(0.1, sum(rate(movieguru_chat_latency_bucket[$${__interval}])) by (le)), \"legend\", \"0.1 Quantile\", \"\", \"\")",
                    "unitOverride" : "ms"
                  },
                  "plotType" : "LINE"
                },
                {
                  "timeSeriesQuery" : {
                    "prometheusQuery" : "label_replace(histogram_quantile(0.5, sum(rate(movieguru_chat_latency_bucket[$${__interval}])) by (le)), \"legend\", \"0.5 Quantile\", \"\", \"\")",
                    "unitOverride" : "ms"
                  },
                  "plotType" : "LINE"
                },
                {
                  "timeSeriesQuery" : {
                    "prometheusQuery" : "label_replace(histogram_quantile(0.9, sum(rate(movieguru_chat_latency_bucket[$${__interval}])) by (le)), \"legend\", \"0.9 Quantile\", \"\", \"\")",
                    "unitOverride" : "ms"
                  },
                  "plotType" : "LINE"
                },
                {
                  "timeSeriesQuery" : {
                    "prometheusQuery" : "label_replace(histogram_quantile(0.95, sum(rate(movieguru_chat_latency_bucket[$${__interval}])) by (le)), \"legend\", \"0.95 Quantile\", \"\", \"\")",
                    "unitOverride" : "ms"
                  },
                  "plotType" : "LINE"
                },
                {
                  "timeSeriesQuery" : {
                    "prometheusQuery" : "label_replace(histogram_quantile(0.99, sum(rate(movieguru_chat_latency_bucket[$${__interval}])) by (le)), \"legend\", \"0.99 Quantile\", \"\", \"\")",
                    "unitOverride" : "ms"
                  },
                  "plotType" : "LINE"
                }
              ],
              "yAxis" : {
                "scale" : "LINEAR"
              },
              "chartOptions" : {
                "mode" : "COLOR"
              }
            }
          }
        },
        {
          "yPos" : 32,
          "width" : 24,
          "height" : 16,
          "widget" : {
            "title" : "Chat Safety Issue Rate",
            "xyChart" : {
              "dataSets" : [
                {
                  "timeSeriesQuery" : {
                    "prometheusQuery" : "label_replace( (sum(rate(movieguru_chat_safetyissue_counter_total[$${__interval}])) / sum(rate(movieguru_chat_calls_total[$${__interval}]))) * 100, \"legend\", \"Safety Issue Rate\", \"\", \"\")",
                    "unitOverride" : "%"
                  },
                  "plotType" : "LINE"
                }
              ],
              "yAxis" : {
                "scale" : "LINEAR"
              },
              "chartOptions" : {
                "mode" : "COLOR"
              }
            }
          }
        }
      ]
    }
  })
}