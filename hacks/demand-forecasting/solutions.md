# Implementing Demand Forecasting on GCP

## Introduction

pass

## Coach's Guides

- Challenge 1: Let’s start importing data!
- Challenge 2: How quickly can you start training?
- Challenge 3: Getting the evaluation results 
- Challenge 4: Time for batch prediction

## Challenge 1: Let’s start importing data!

### Notes & Guidance

```python
training_job = aiplatform.AutoMLForecastingTrainingJob(
    display_name=MODEL_DISPLAY_NAME,
    optimization_objective="minimize-quantile-loss",
    column_specs=COLUMN_SPECS,
)
```

## Challenge 2: How quickly can you start training?

### Notes & Guidance

```python
quantiles=[0.4,0.5,0.6]
model = training_job.run(
    dataset=dataset,
    target_column=target_column,
    time_column=time_column,
    time_series_identifier_column=time_series_identifier_column,
    available_at_forecast_columns=[time_column],
    unavailable_at_forecast_columns=[target_column],
    time_series_attribute_columns=["city", "zip_code", "county"],
    forecast_horizon=30,
    context_window=30,
    data_granularity_unit="day",
    data_granularity_count=1,
    weight_column=None,
    budget_milli_node_hours=1000,
    model_display_name=MODEL_DISPLAY_NAME,
    predefined_split_column_name=None,
    quantiles=quantiles,
    sync = False
)
```

## Challenge 3: Getting the evaluation results

### Notes & Guidance

```python
model_evaluations = model.list_model_evaluations()

for model_evaluation in model_evaluations:
    print(model_evaluation.to_dict())
```

## Challenge 4: Time for batch prediction

### Notes & Guidance

```python
batch_prediction_job = model.batch_predict(
    job_display_name=f"iowa_liquor_sales_forecasting_predictions_{UUID}",
    bigquery_source=PREDICTION_DATASET_BQ_PATH,
    instances_format="bigquery",
    bigquery_destination_prefix=batch_predict_bq_output_uri_prefix,
    predictions_format="bigquery",
    generate_explanation=True,
    sync=False,
)

print(batch_prediction_job)
```