## Data Export
![Table Data Export](https://raw.githubusercontent.com/austinstewartmsda-stack/MedicalReadmissions/main/gifs/TableDataExport.gif)

### How I think about it

I grouped the SQL into four parts

1. trend analysis  
2. change over time  
3. impact metrics  
4. stability and variation  

Each view answers a specific question.

---

## Trend Analysis

### average_monthly_readmit

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `average_monthly_readmit` AS select (case `t`.`Month_Num` when 1 then 'January' when 2 then 'February' when 3 then 'March' when 4 then 'April' when 5 then 'May' when 6 then 'June' when 7 then 'July' when 8 then 'August' when 9 then 'September' when 10 then 'October' when 11 then 'November' when 12 then 'December' end) AS `Service_Month_Name`,avg(`t`.`Readmission_Rate`) AS `Avg_Readmission_Rate` from (select month(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) AS `Month_Num`,`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` AS `Readmission_Rate` from `ffs-medicare-30-day-readmission-rate-puf`) `t` group by `t`.`Month_Num` order by `t`.`Month_Num`;
````

I group all rows by month and calculate the average readmission rate.
This helps me see if certain months are consistently higher or lower.

---

### yearly_average_readmits

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `yearly_average_readmits` AS select year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) AS `Year`,avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Avg_Readmission_Rate` from `ffs-medicare-30-day-readmission-rate-puf` group by year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) order by `Year`;
```

I group by year and calculate the average rate.
This shows long term trends.

---

## Change Over Time

### mom_change

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `mom_change` AS select `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` AS `Service_Month_Date`,`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays` AS `Index_Stays`,`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` AS `Readmission_Rate`,(`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays` - lag(`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays`) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` ) ) AS `MoM_Volume_Change`,(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` - lag(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` ) ) AS `MoM_Rate_Change` from `ffs-medicare-30-day-readmission-rate-puf` order by `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`;
```

I compare each row to the previous row using LAG.
This shows how things change month to month.

---

### yoy_change

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `yoy_change` AS select `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` AS `Service_Month_Date`,`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` AS `Readmission_Rate`,(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` - lag(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`,12) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` ) ) AS `YoY_Change` from `ffs-medicare-30-day-readmission-rate-puf` order by `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`;
```

I compare each month to the same month last year.
This removes seasonality.

---

## Impact Metrics

### baseline_rate

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `baseline_rate` AS select avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Baseline_Rate` from `ffs-medicare-30-day-readmission-rate-puf` where (year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) = (select min(year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`)) from `ffs-medicare-30-day-readmission-rate-puf`));
```

I define a baseline using the earliest year.
This is my reference point.

---

### avoided_readmissions

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `avoided_readmissions` AS select year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) AS `Year`,sum(`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays`) AS `Index_Stays`,avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Readmission_Rate`,((sum(`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays`) * 19.024166666666662) / 100) AS `Expected_Readmits_At_Baseline`,sum(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Stays`) AS `Actual_Readmits`,(((sum(`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays`) * 19.024166666666662) / 100) - sum(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Stays`)) AS `Avoided_Readmissions` from `ffs-medicare-30-day-readmission-rate-puf` group by year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) order by `Year`;
```

I compare expected vs actual readmissions.
The difference gives me avoided readmissions.

---

### cumulative_readmits_avoided

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cumulative_readmits_avoided` AS select `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` AS `Service_Month_Date`,sum((((`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays` * 19.024166666666662) / 100) - `ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Stays`)) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` )  AS `Cumulative_Avoided_Readmissions` from `ffs-medicare-30-day-readmission-rate-puf` order by `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`;
```

I track total impact over time.

---

## Stability and Variation

### readmission_rate_rolling_volatility

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `readmission_rate_rolling_volatility` AS select `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` AS `Service_Month_Date`,std(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)  AS `Rolling_12M_Volatility` from `ffs-medicare-30-day-readmission-rate-puf`;
```

I measure how much the rate fluctuates over time.
Higher values mean less stability.

---

## Why I built it this way

I did not want one large query that does everything.

I wanted

clear logic
reusable pieces
and the ability to debug each step

This makes it easier to trust the results and easier to extend later.

# Medical Readmission Project

## What I did
I looked at avoided readmissions and readmission rates over time to answer a simple question:

> Are higher avoided readmissions actually lowering the readmission rate?

I built a dashboard to track trends, compare the two metrics, and see where the biggest changes happen.

---

## Dashboard

## Videos Used To Help
Excel for Data Analytics – Full Course (Beginner to Advanced)
Charts

[![Excel for Data Analytics – Full Course](https://img.youtube.com/vi/pCJ15nGFgVg/0.jpg)](https://www.youtube.com/watch?v=pCJ15nGFgVg&t=10893s)

![Total Avoided Readmissions](image/Addtoreadmitgithub.png)

---

## What the data shows

I am working with two main metrics:
- Avoided readmissions in thousands  
- Average readmission rate  

I also calculated year over year improvement in the readmission rate to see when the biggest changes happened.

Each row is one year, so I can track how things change over time.

---

## What I found

### 1. Most avoided readmissions happen between 2012 and 2015
Avoided readmissions are very low from 2008 to 2011.

They increase sharply starting in 2012, peak around 2013 to 2015, and then drop in 2016.

This tells me most of the impact is concentrated in a short period.

---

### 2. The readmission rate steadily goes down
The readmission rate starts around 19 percent and slowly drops each year.

The biggest drop happens between 2011 and 2013.

After that, it keeps going down, but more slowly.

---

### 3. The biggest improvements happen in 2012 and 2013
When I look at year over year improvement:
- 2012 shows a large jump
- 2013 is the highest improvement point

After 2013, improvements get smaller.

This lines up with the spike in avoided readmissions.

---

### 4. There is a clear shift around 2012
Before 2012:
- low avoided readmissions  
- very small improvements  

After 2012:
- avoided readmissions increase fast  
- readmission rate drops faster  

This looks like a system level change, not just random variation.

---

### 5. 2016 does not follow the same pattern
Avoided readmissions drop a lot in 2016.

But the readmission rate still goes down, and improvement is still positive.

So I ask:

> If avoided readmissions are dropping, what is still pushing the rate down?

This suggests avoided readmissions are not the only driver.

---

## Skills I used

- Time series analysis  
- Reading trends over time  
- Comparing multiple metrics  
- Finding shifts in behavior  
- Turning charts into clear takeaways  

---

## Tools I used

- Excel for building charts and data analysis
- Powerpoint for visual design enhancement  
- SQL for data analysis, data cleaning and querying

---

## Why I think this matters

The data shows that improvements are not evenly spread over time.

Most of the change happens in a few key years.

If I only looked at totals, I would miss that.

I try to focus on:
- 1. When do changes happen?
- 2. How strong are the changes are when they happen?  
- 3. Do the changes stay consistent?

---

## What I would do next

- Add more data like hospital type or region  
- Test the relationship between the two metrics  
- Build a simple forecast  
- Look into what changed around 2012  

## SQL Analysis Layer

I built a set of SQL views to support everything in the dashboard.

Instead of writing one big query, I broke the logic into smaller pieces so I can reuse them and understand exactly what each part is doing.

---

### How I think about it

I grouped the SQL into four parts

1. trend analysis  
2. change over time  
3. impact metrics  
4. stability and variation  

Each view answers a specific question.

---

## Trend Analysis

### average_monthly_readmit

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `average_monthly_readmit` AS select (case `t`.`Month_Num` when 1 then 'January' when 2 then 'February' when 3 then 'March' when 4 then 'April' when 5 then 'May' when 6 then 'June' when 7 then 'July' when 8 then 'August' when 9 then 'September' when 10 then 'October' when 11 then 'November' when 12 then 'December' end) AS `Service_Month_Name`,avg(`t`.`Readmission_Rate`) AS `Avg_Readmission_Rate` from (select month(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) AS `Month_Num`,`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` AS `Readmission_Rate` from `ffs-medicare-30-day-readmission-rate-puf`) `t` group by `t`.`Month_Num` order by `t`.`Month_Num`;
````

I group all rows by month and calculate the average readmission rate.
This helps me see if certain months are consistently higher or lower.

---

### yearly_average_readmits

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `yearly_average_readmits` AS select year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) AS `Year`,avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Avg_Readmission_Rate` from `ffs-medicare-30-day-readmission-rate-puf` group by year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) order by `Year`;
```

I group by year and calculate the average rate.
This shows long term trends.

---

## Change Over Time

### mom_change

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `mom_change` AS select `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` AS `Service_Month_Date`,`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays` AS `Index_Stays`,`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` AS `Readmission_Rate`,(`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays` - lag(`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays`) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` ) ) AS `MoM_Volume_Change`,(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` - lag(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` ) ) AS `MoM_Rate_Change` from `ffs-medicare-30-day-readmission-rate-puf` order by `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`;
```

I compare each row to the previous row using LAG.
This shows how things change month to month.

---

### yoy_change

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `yoy_change` AS select `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` AS `Service_Month_Date`,`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` AS `Readmission_Rate`,(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` - lag(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`,12) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` ) ) AS `YoY_Change` from `ffs-medicare-30-day-readmission-rate-puf` order by `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`;
```

I compare each month to the same month last year.
This removes seasonality.

---

## Impact Metrics

### baseline_rate

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `baseline_rate` AS select avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Baseline_Rate` from `ffs-medicare-30-day-readmission-rate-puf` where (year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) = (select min(year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`)) from `ffs-medicare-30-day-readmission-rate-puf`));
```

I define a baseline using the earliest year.
This is my reference point.

---

### avoided_readmissions

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `avoided_readmissions` AS select year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) AS `Year`,sum(`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays`) AS `Index_Stays`,avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Readmission_Rate`,((sum(`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays`) * 19.024166666666662) / 100) AS `Expected_Readmits_At_Baseline`,sum(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Stays`) AS `Actual_Readmits`,(((sum(`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays`) * 19.024166666666662) / 100) - sum(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Stays`)) AS `Avoided_Readmissions` from `ffs-medicare-30-day-readmission-rate-puf` group by year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) order by `Year`;
```

I compare expected vs actual readmissions.
The difference gives me avoided readmissions.

---

### cumulative_readmits_avoided

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cumulative_readmits_avoided` AS select `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` AS `Service_Month_Date`,sum((((`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays` * 19.024166666666662) / 100) - `ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Stays`)) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` )  AS `Cumulative_Avoided_Readmissions` from `ffs-medicare-30-day-readmission-rate-puf` order by `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`;
```

I track total impact over time.

---

## Stability and Variation

### readmission_rate_rolling_volatility

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `readmission_rate_rolling_volatility` AS select `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` AS `Service_Month_Date`,std(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)  AS `Rolling_12M_Volatility` from `ffs-medicare-30-day-readmission-rate-puf`;
```

I measure how much the rate fluctuates over time.
Higher values mean less stability.

---

## Why I built it this way

I did not want one large query that does everything.

I wanted

clear logic
reusable pieces
and the ability to debug each step

This makes it easier to trust the results and easier to extend later.

Here is **everything in raw markdown**, no formatting tricks, ready to paste directly:

````markdown
## Additional SQL Views

These extend the analysis and help me go deeper into trends, stability, and comparisons.

---

### month_over_month_change

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `month_over_month_change` AS select `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` AS `Service_Month_Date`,`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` AS `Readmission_Rate`,(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` - lag(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` ) ) AS `MoM_Change` from `ffs-medicare-30-day-readmission-rate-puf` order by `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`;
````

I track how the readmission rate changes from one month to the next
This is a simpler view when I only care about the rate

---

### readmit_descriptive_stats

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `readmit_descriptive_stats` AS select avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Overall_Avg_Rate`,min(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Min_Rate`,max(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Max_Rate`,std(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `StdDev_Rate` from `ffs-medicare-30-day-readmission-rate-puf`;
```

I summarize the dataset into average, min, max, and standard deviation
This gives me a quick understanding of the distribution

---

### rolling_six_month_avg

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `rolling_six_month_avg` AS select `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` AS `Service_Month_Date`,`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` AS `Readmission_Rate`,avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)  AS `Rolling_6M_Avg` from `ffs-medicare-30-day-readmission-rate-puf` order by `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`;
```

I smooth the data over six months
This helps reduce noise and makes trends easier to see

---

### rolling_three_month_readmit_rate

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `rolling_three_month_readmit_rate` AS select `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` AS `Service_Month_Date`,`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` AS `Readmission_Rate`,avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) OVER (ORDER BY `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)  AS `Rolling_3M_Avg` from `ffs-medicare-30-day-readmission-rate-puf` order by `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`;
```

I smooth the data over three months
This reacts faster than the six month version

---

### seasonality

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `seasonality` AS select `t`.`Month_Name` AS `Month_Name`,`t`.`Avg_Readmission_Rate` AS `Avg_Readmission_Rate`,(`t`.`Avg_Readmission_Rate` - `t`.`Overall_Avg`) AS `Diff_From_Overall` from (select monthname(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) AS `Month_Name`,avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Avg_Readmission_Rate`,(select avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) from `ffs-medicare-30-day-readmission-rate-puf`) AS `Overall_Avg` from `ffs-medicare-30-day-readmission-rate-puf` group by monthname(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`)) `t` order by `t`.`Avg_Readmission_Rate` desc;
```

I compare each month to the overall average
This shows which months are above or below normal

---

### total_avoided_readmits

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `total_avoided_readmits` AS select sum((((`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays` * 19.024166666666662) / 100) - `ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Stays`)) AS `Total_Avoided_Readmissions` from `ffs-medicare-30-day-readmission-rate-puf`;
```

I sum everything into one number
This is the total impact

---

### year_month_index_stays

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `year_month_index_stays` AS select date_format(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`,'%Y-%m') AS `Year/Month`,`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays` AS `Index_Stays` from `ffs-medicare-30-day-readmission-rate-puf` order by `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`;
```

I format the date into year and month
This makes time series charts easier

---

### yoy_change_year

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `yoy_change_year` AS select `t`.`year` AS `year`,`t`.`avg_readmission_rate` AS `avg_readmission_rate`,(`t`.`avg_readmission_rate` - lag(`t`.`avg_readmission_rate`,1) OVER (ORDER BY `t`.`year` ) ) AS `YoY_Change` from (select year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`) AS `year`,avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `avg_readmission_rate` from `ffs-medicare-30-day-readmission-rate-puf` group by year(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`)) `t` order by `t`.`year`;
```

I compare each year to the previous year
This gives a clean long term comparison

---

### hrrp_periods

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `hrrp_periods` AS select `t`.`Policy_Period` AS `Policy_Period`,avg(`t`.`Readmission_Rate`) AS `Avg_Readmission_Rate`,avg(`t`.`Index_Stays`) AS `Avg_Index_Stays` from (select `ffs-medicare-30-day-readmission-rate-puf`.`Service_Month` AS `Service_Month`,`ffs-medicare-30-day-readmission-rate-puf`.`Index_Stays` AS `Index_Stays`,`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Stays` AS `Readmission_Stays`,`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate` AS `Readmission_Rate`,`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` AS `Service_Month_Date`,(case when (`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date` < '2012-10-01') then 'Pre-HRRP' else 'Post-HRRP' end) AS `Policy_Period` from `ffs-medicare-30-day-readmission-rate-puf`) `t` group by `t`.`Policy_Period`;
```

I split the data into before and after a policy change
This helps me see if the policy had an effect
