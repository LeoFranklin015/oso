{#
  This model aggregates user events to collections on
  a monthly basis. It is used to calculate various 
  user engagement metrics.
#}

SELECT
  from_id,
  from_namespace,
  collection_id,
  event_type,
  TIMESTAMP_TRUNC(time, MONTH) AS bucket_month,
  COUNT(DISTINCT TIMESTAMP_TRUNC(time, DAY)) AS count_days,
  SUM(amount) AS total_amount
FROM {{ ref('int_events_to_collection') }}
GROUP BY
  from_id,
  from_namespace,
  collection_id,
  event_type,
  TIMESTAMP_TRUNC(time, MONTH)
