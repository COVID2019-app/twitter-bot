SELECT
    latest.id,
    latest.rec_ts,
    latest.rec_territory,
    latest.rec_category,
    latest.nn,
    latest.rec_value AS total,
    latest.rec_value - previous.rec_value AS value,
    previous.rec_value AS previous_value,
    post_breaking_data.id AS post_id

FROM
    (
        SELECT
            id,
            rec_ts,
            rec_territory,
            rec_category,
            ROW_NUMBER()
            OVER (PARTITION BY rec_territory, rec_category ORDER BY rec_ts DESC) AS nn,
            rec_value
        FROM
            record_changelog
    ) AS latest

    LEFT JOIN(
        SELECT
            rec_territory,
            rec_category,
            ROW_NUMBER() OVER (PARTITION BY rec_territory, rec_category ORDER BY rec_ts DESC) AS nn,
            rec_value

        FROM
            record_changelog
    ) AS previous
             ON latest.nn = 1
                     AND previous.nn = 2
                     AND latest.rec_territory = previous.rec_territory
                     AND latest.rec_category = previous.rec_category

    LEFT JOIN post_breaking_data AS post_breaking_data
              ON latest.id = post_breaking_data.changelog_id

WHERE
      latest.rec_category IN ('case', 'death')
  AND latest.nn = 1 -- only latest update
  AND latest.rec_value > previous.rec_value -- exclude negative adjustments
  AND post_breaking_data.id IS NULL -- not posted before
  AND latest.rec_ts > current_timestamp - INTERVAL '1 hour' -- update during past hour
