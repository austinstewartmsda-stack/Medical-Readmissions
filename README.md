<div align="center">

# Medical Readmission Project
Austin Stewart MSDS 
<img src="https://raw.githubusercontent.com/austinstewartmsda-stack/Medical-Readmissions/main/image/hospital.jpg" style="width:100%; border-radius:12px;">

## Project Overview
I analyzed hospital readmission data from 2008 through 2016 to identify trends, seasonal patterns, and periods of accelerated improvement. My project demonstrates data cleaning, SQL analysis, Tableau dashboard development, and data storytelling.

## Data Quality Issues
The data was dirty initially. I identified some common issues within the data.
![Original Data](https://raw.githubusercontent.com/austinstewartmsda-stack/Medical-Readmissions/main/image/Original_Dirty_Data.png)

Duplicate records 
Text standardization issues
Numeric fields imported as strings 
Non business metadata columns 
Spacing issues
Inconsitent Date Formats

## Data Cleaning Process
This showed me that I needed to perform some data cleaning. I removed duplicate records, standardized date formats, converted numeric fields stored as text into numeric data types, removed unnecessary metadata columns, standardized text values, and removed leading and trailing whitespace.

## Issues/Resolutions

Duplicate rows

I removed duplicate records.

Numeric fields stored as text

I converted them to numerics.

Date inconsistencies

I standardized them to a consistent format.

Leading/trailing spaces

I used TRIM functions to eliminate the whitespace.

## Business Recommendations
![Top and Bottom Readmission Values](https://raw.githubusercontent.com/austinstewartmsda-stack/Medical-Readmissions/main/image/highlowreadmits.png)

### Recommendation 1

Continue supporting initiatives associated with the reduction in readmission rates from 19.36% in 2008 to 17.30% in 2016 during the study period.

### Recommendation 2

Review differences between the highest readmission period (19.53% in January 2009) and the lowest readmission period (17.30% in April 2016) to identify opportunities for further improvement.


</div>



## Tableau Visuals
![Average Readmission Rate Decreasing Through 2012](https://raw.githubusercontent.com/austinstewartmsda-stack/Medical-Readmissions/main/gifs/Average_Readmission_Rate_Decreasing_Through_2012.gif)

## What I did

The cleaned dataset contains 101 monthly observations from January 2008 to May 2016.

I analyzed hospital readmission rates between 2008 and 2016 to identify trends, seasonal patterns, and periods of accelerated improvement.

I also developed a derived avoided readmissions metric to estimate the impact of declining readmission rates over time.

## Data Storage

I loaded the cleaned CSV data into a SQL database and used SQL views for trend analysis, seasonality analysis, rolling averages, year-over-year comparisons, and avoided readmission calculations.

![SQL Database GIF](https://raw.githubusercontent.com/austinstewartmsda-stack/Medical-Readmissions/main/gifs/SQLDataBase.gif)


## Data Cleaning

I used Excel functions such as LEFT, RIGHT, and TRIM to standardize text fields, clean inconsistent values, and prepare the dataset for analysis.

![Data Cleaning GIF](https://raw.githubusercontent.com/austinstewartmsda-stack/Medical-Readmissions/main/gifs/Data_Cleaning_With_Left.gif)


## Dashboard

I built a dashboard to visualize avoided readmissions and compare them to the readmission rate over time.

![Total Avoided Readmissions](image/Addtoreadmitgithub.png)


## What the data shows

I am working with two main metrics:

1. Avoided readmissions in thousands.

2. Average readmission rate.

The data is monthly, which allows me to analyze both short term changes and long term trends.


## What I found

### 1. Most avoided readmissions happen between 2012 and 2015.

Avoided readmissions are very low from 2008 to 2011.

They increase sharply starting in 2012, peak around 2013 to 2015, and then drop in 2016.

This shows most of the impact is concentrated in a short period.



### 2. The readmission rate steadily goes down.

The readmission rate starts around 19 percent and slowly drops each year. The biggest drop happens between 2011 and 2013. After that, it keeps going down, but the rate is slower.



### 3. The biggest improvements happen in 2012 and 2013.

When I look at year over year improvement, 2012 shows a large jump and 2013 is the highest improvement point. After 2013, improvements get smaller. This lines up with the spike in avoided readmissions.



### 4. There is a clear shift around 2012.

Before 2012, there were low avoided readmissions and very small improvements.

After 2012, I found that avoided readmissions increase quickly and I found that the readmission rate drops faster.



### 5. 2016 does not follow the same pattern.

Avoided readmissions drop in 2016. But the readmission rate still goes down and improvement is still positive. This made me wonder if avoided readmissions are dropping, what is still pushing the rate down. This suggests avoided readmissions are not the only driver and other factors may also be contributing.

## R² Values

<img src="image/Readmit_Years_Dashboard.png" width="100%"/>

![View Writing GIF](https://raw.githubusercontent.com/austinstewartmsda-stack/Medical-Readmissions/main/gifs/View_Writing.gif)


I’m using R² to understand how consistent the trend is over time. A higher R² means the trendline explains the data well, while a lower R² means the data is more scattered and less predictable.

In 2011, the R² is around 0.69, which shows the downward trend is fairly consistent, but there is still some variation.

![Average Readmission Rate 2011](image/Average_Readmit_Rate_2011.png)

In 2012, the R² increases to about 0.72, which is the strongest trend and means the decrease in readmission rates is the most consistent and predictable.

![Average Readmission Rate 2012](image/Average_Readmit_Rate_2012.png)

In 2013, the R² drops to around 0.62, which means the trend is still there, but there is more variability.

![Average Readmission Rate 2013](image/Average_Readmit_Rate_2013.png)

In 2014, the R² drops to about 0.27, which means the linear trend is not explaining much of the data and suggests other factors are influencing the rate.



## Why I think this matters

The data shows that improvements are not evenly spread over time. Most of the changes happen in specific years. If I only looked at totals, I would miss that. I decided to focus on when changes happen, how strong the changes are, and if the changes stay consistent.

## What I would do next

1. I would add more data like hospital type or region.

2. I would test the relationship between the two metrics.

3. I would build a simple forecast.

4. I would look into what changed around 2012.


## Skills I used

I used time series analysis, reading trends over time, comparing multiple metrics, finding shifts in behavior, and data storytelling.


## Tools I used

I used Excel for building charts and analysis.

I used Tableau for making dashboards.

I used SQL for data analysis and querying.


## SQL Analysis Layer

I built a set of SQL views to support everything in the dashboard.

Instead of writing one large query, I broke the logic into smaller pieces so I can reuse them and understand exactly what each part is doing.

## The SQL can be viewed here. 

[https://github.com/austinstewartmsda-stack/Medical-Readmissions/new/main/SQL](https://github.com/austinstewartmsda-stack/Medical-Readmissions/blob/main/SQL/SQL_Views.sql)

## Why I built it this way

I did not want one large query that does everything.

I wanted clear logic, reusable pieces, and the ability to debug each step.

This makes it easier to trust the results and extend the analysis later.

![Average Readmission Rate Decreasing Through 2012](https://raw.githubusercontent.com/austinstewartmsda-stack/MedicalReadmissions/main/gifs/Average_Readmission_Rate_Decreasing_Through_2012.gif)



<div align="center">

## References

Centers for Medicare & Medicaid Services. (n.d.). *Medicare hospital quality data*. https://data.cms.gov  

</div>
