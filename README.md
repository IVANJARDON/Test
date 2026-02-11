# 📊 **Senior Marketing Analyst – Technical Assignment**
## 📌**Overview**

This project simulates a real-world marketing analytics scenario where multi-channel advertising data is unified, transformed, and analyzed to generate cross-platform performance insights.

The objective was to integrate raw advertising data from Facebook Ads, Google Ads, and TikTok Ads into a unified data model and build a one-page dashboard to support strategic decision-making.

## 📂**Data Sources**

The following datasets were provided:

01_facebook_ads.csv 

02_google_ads.csv 

03_tiktok_ads.csv 

## 🗄️**Database Setup**

All three CSV files were uploaded to a cloud database environment.

**Cloud Database Used:**

Google Big Query

**Data Process:**

Uploaded raw CSV files into tables.
Standardized field names and data types.
Created a unified marketing performance table combining all platforms.

📄 SQL Script:
```
CREATE OR REPLACE TABLE `mx-viva-bi-sandbox.test.unified_ads` AS
WITH
-- Facebook Ads data
facebook AS (
  SELECT
    date,
    'facebook' AS source,
    campaign_id,
    campaign_name,
    ad_set_id AS ad_group_id,   -- Standardizing ad set to ad group naming
    ad_set_name AS ad_group_name,
    impressions,
    clicks,
    spend AS cost,              -- Mapping spend to cost for cross-platform consistency
    conversions,
    video_views,
    engagement_rate,
    reach,
    frequency,
    -- Placeholder columns for schema alignment with other platforms
    NULL AS conversion_value,
    NULL AS ctr,
    NULL AS avg_cpc,
    NULL AS quality_score,
    NULL AS search_impression_share,
    NULL AS likes,
    NULL AS shares,
    NULL AS comments,
    NULL AS video_watch_25,
    NULL AS video_watch_50,
    NULL AS video_watch_75,
    NULL AS video_watch_100
  FROM `mx-viva-bi-sandbox.test.facebook_ads`
),

-- Google Ads data
google AS (
  SELECT
    date,
    'google' AS source,
    campaign_id,
    campaign_name,
    ad_group_id,
    ad_group_name,
    impressions,
    clicks,
    cost,
    conversions,
    -- Placeholder columns for Facebook/TikTok specific metrics
    NULL AS video_views,
    NULL AS engagement_rate,
    NULL AS reach,
    NULL AS frequency,
    -- Google specific metrics
    conversion_value,
    ctr,
    avg_cpc,
    quality_score,
    search_impression_share,
    -- Placeholder columns for TikTok specific metrics
    NULL AS likes,
    NULL AS shares,
    NULL AS comments,
    NULL AS video_watch_25,
    NULL AS video_watch_50,
    NULL AS video_watch_75,
    NULL AS video_watch_100
  FROM `mx-viva-bi-sandbox.test.google_ads`
),

-- TikTok Ads data
tiktok AS (
  SELECT
    date,
    'tiktok' AS source,
    campaign_id,
    campaign_name,
    adgroup_id AS ad_group_id,   -- Standardizing adgroup to ad group naming
    adgroup_name AS ad_group_name,
    impressions,
    clicks,
    cost,
    conversions,
    video_views,
    -- Placeholder columns for Facebook/Google specific metrics
    NULL AS engagement_rate,
    NULL AS reach,
    NULL AS frequency,
    NULL AS conversion_value,
    NULL AS ctr,
    NULL AS avg_cpc,
    NULL AS quality_score,
    NULL AS search_impression_share,
    -- TikTok specific social and video metrics
    likes,
    shares,
    comments,
    video_watch_25,
    video_watch_50,
    video_watch_75,
    video_watch_100
  FROM `mx-viva-bi-sandbox.test.tiktok_ads`
)

-- Combine all sources into a single dataset
SELECT * FROM facebook
UNION ALL
SELECT * FROM google
UNION ALL
SELECT * FROM tiktok;
```

🧩 Unified Data Model

The unified table consolidates only relevant fields for all platforms:
```
SELECT
  date,
  source,
  campaign_id,
  campaign_name,
  ad_group_id,
  ad_group_name,
  impressions,
  clicks,
  cost,
  conversions
FROM `mx-viva-bi-sandbox.test.unified_ads`
```

This structure enables consistent cross-platform comparison and KPI analysis. This query was used to import data into Tableau directly from BigQuery.

## 📊 **Dashboard**

A one-page interactive dashboard was built in Tableau to visualize integrated performance data.

The Ad Performance Dashboard provides a consolidated view of multi-platform advertising performance (Facebook, Google, TikTok).

**Key Features:**

-**Top KPIs:** Spend, Impressions, Clicks, Conversions, CPC, CPM, CTR, and CPA.

-**Filters:** Platform, Campaign, Date Range, and Granularity (e.g., Daily).

-**Trend Analysis:** Daily spend by platform.

-**Distribution View:** Share of spend and conversions by platform.

-**Platform Comparison:** Spend & CPC, Clicks & CTR, Conversions & CR.

-**Campaign Table:** Detailed performance metrics with sorting and drill-down capability.

🔗 Live Dashboard:
https://public.tableau.com/app/profile/ivan.jardon/viz/AdPerformanceDashboard_17708209360260/AdPerformanceDashboard
