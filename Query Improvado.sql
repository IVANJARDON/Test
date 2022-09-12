WITH
  platforms AS (
  --Union for the two platforms
  SELECT
    DISTINCT "Platform 1" AS provider,
    "channel 1" AS network,
    t1.* EXCEPT(ad_name),
    t3.* EXCEPT(date,
      account_id,
      campaign_id,
      adset_id,
      ad_id)
  FROM
    `vb-datalake-01-prd.test.Table_1` t1
  JOIN (
    SELECT
      date,
      account_id,
      campaign_id,
      adset_id,
      ad_id,
      FIRST_VALUE(headline1) OVER (PARTITION BY ad_id ORDER BY date DESC) AS headline1,
      FIRST_VALUE(headline2) OVER (PARTITION BY ad_id ORDER BY date DESC) AS headline2,
      headline3,
      description,
      final_url,
      path1,
      path2
    FROM
      `vb-datalake-01-prd.test.Table_3`) t3
  USING
    (date,
      account_id,
      campaign_id,
      adset_id,
      ad_id)
  UNION ALL
  SELECT
    DISTINCT "Platform 2" AS provider,
    "channel 2" AS network,
    t2.*,
    t4.* EXCEPT( account_id,
      campaign_id,
      adset_id,
      ad_id),
  FROM
    `vb-datalake-01-prd.test.Table_2` t2
  JOIN (
    SELECT
      account_id,
      campaign_id,
      adset_id,
      ad_id,
      headline1,
      headline2,
      "" AS headline3,
      "" AS description,
      destination_url,
      "" AS path1,
      "" AS path2
    FROM
      `vb-datalake-01-prd.test.Table_4` t4 ) t4
  USING
    (account_id,
      campaign_id,
      adset_id,
      ad_id) ),

analytics AS (
--Group and sum analytics data
  SELECT
    date,
    utm_source,
    campaign,
    SUM(sessions) AS sessions,
    SUM(users) AS users,
    SUM(new_users) AS new_users,
    SUM(page_views) AS page_views
  FROM
    `vb-datalake-01-prd.test.Table_5`
  GROUP BY
    1,
    2,
    3 )
--Output for result table, joining "platforms" and "analytics" CTEs 
SELECT
  DISTINCT platforms.date,
  platforms.provider,
  platforms.network,
  platforms.account_id,
  SPLIT(REGEXP_REPLACE(platforms.campaign_name, r'\_\w{2}',''),'|') [OFFSET (1)] campaign_name_short,
  FIRST_VALUE(platforms.date) OVER (PARTITION BY platforms.campaign_id ORDER BY platforms.date) AS campaign_start_date,
  FIRST_VALUE(platforms.date) OVER (PARTITION BY platforms.campaign_id ORDER BY platforms.date DESC) AS campaign_end_date,
  SPLIT(REGEXP_REPLACE(platforms.campaign_name, r'\_\w{2}',''),'|') [OFFSET (2)] AS brand,
  SPLIT(REGEXP_REPLACE(platforms.campaign_name, r'\_\w{2}',''),'|') [OFFSET (3)] AS free_field,
  adset_name,
IF
  (platforms.adset_name LIKE '%|%',REGEXP_EXTRACT(platforms.adset_name, r'[\w\s]+',1,1),NULL) AS adset_group,
  CONCAT(platforms.headline1,"|",platforms.headline2,"|",platforms.headline3) AS ad_name,
  CASE
    WHEN path2!='' THEN CONCAT(REGEXP_EXTRACT(platforms.final_url,r'[\w]+\.[\w_-]+\.[\w_-]+'),"/",path1,"/",path2)
    WHEN path1!='' THEN CONCAT(REGEXP_EXTRACT(platforms.final_url,r'[\w]+\.[\w_-]+\.[\w_-]+'),"/",path1)
  ELSE
  REGEXP_EXTRACT(platforms.final_url,r'[\w]+\.[\w_-]+\.[\w_-]+')
END
  AS display_path,
  platforms.ad_type,
  platforms.device,
  platforms.spend,
  platforms.clicks,
  platforms.imps AS impressions,
  platforms.conversions,
  analytics.sessions,
  analytics.users,
  analytics.new_users,
  analytics.page_views
FROM
  platforms
LEFT JOIN
  analytics
ON
  platforms.date=analytics.date
  AND analytics.utm_source=platforms.provider
  AND LOWER(SPLIT(REGEXP_REPLACE(platforms.campaign_name, r'\_\w{2}',''),'|') [OFFSET(1)])=analytics.campaign
ORDER BY
  date,
  campaign_name_short