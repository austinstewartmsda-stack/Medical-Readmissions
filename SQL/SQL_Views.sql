
```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `avg_monthly_readmit_rate_2011` AS 
select 
str_to_date(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`,'%Y-%m-%d') AS `Service_Date`,
avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Avg_Readmission_Rate_2011`
from `ffs-medicare-30-day-readmission-rate-puf`
where year(str_to_date(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`,'%Y-%m-%d')) = 2011
group by `Service_Date`
order by `Service_Date`;
````

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `avg_monthly_readmit_rate_2012` AS 
select 
str_to_date(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`,'%Y-%m-%d') AS `Service_Date`,
avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Avg_Readmission_Rate_2012`
from `ffs-medicare-30-day-readmission-rate-puf`
where year(str_to_date(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`,'%Y-%m-%d')) = 2012
group by `Service_Date`
order by `Service_Date`;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `avg_monthly_readmit_rate_2013` AS 
select 
str_to_date(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`,'%Y-%m-%d') AS `Service_Date`,
avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Avg_Readmission_Rate_2013`
from `ffs-medicare-30-day-readmission-rate-puf`
where year(str_to_date(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`,'%Y-%m-%d')) = 2013
group by `Service_Date`
order by `Service_Date`;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `avg_monthly_readmit_rate_2014` AS 
select 
str_to_date(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`,'%Y-%m-%d') AS `Service_Date`,
avg(`ffs-medicare-30-day-readmission-rate-puf`.`Readmission_Rate`) AS `Avg_Readmission_Rate_2014`
from `ffs-medicare-30-day-readmission-rate-puf`
where year(str_to_date(`ffs-medicare-30-day-readmission-rate-puf`.`Service_Month_Date`,'%Y-%m-%d')) = 2014
group by `Service_Date`
order by `Service_Date`;
```

## Trend Analysis

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `average_monthly_readmit` AS 
select 
case t.Month_Num 
when 1 then 'January' 
when 2 then 'February' 
when 3 then 'March' 
when 4 then 'April' 
when 5 then 'May' 
when 6 then 'June' 
when 7 then 'July' 
when 8 then 'August' 
when 9 then 'September' 
when 10 then 'October' 
when 11 then 'November' 
when 12 then 'December' 
end AS Service_Month_Name,
avg(t.Readmission_Rate) AS Avg_Readmission_Rate
from (
select 
month(Service_Month_Date) AS Month_Num,
Readmission_Rate
from `ffs-medicare-30-day-readmission-rate-puf`
) t
group by t.Month_Num
order by t.Month_Num;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `yearly_average_readmits` AS 
select 
year(Service_Month_Date) AS Year,
avg(Readmission_Rate) AS Avg_Readmission_Rate
from `ffs-medicare-30-day-readmission-rate-puf`
group by year(Service_Month_Date)
order by Year;
```



## Change Over Time

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `mom_change` AS 
select 
Service_Month_Date,
Index_Stays,
Readmission_Rate,
(Index_Stays - lag(Index_Stays) over (order by Service_Month_Date)) AS MoM_Volume_Change,
(Readmission_Rate - lag(Readmission_Rate) over (order by Service_Month_Date)) AS MoM_Rate_Change
from `ffs-medicare-30-day-readmission-rate-puf`
order by Service_Month_Date;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `yoy_change` AS 
select 
Service_Month_Date,
Readmission_Rate,
(Readmission_Rate - lag(Readmission_Rate,12) over (order by Service_Month_Date)) AS YoY_Change
from `ffs-medicare-30-day-readmission-rate-puf`
order by Service_Month_Date;
```



## Impact Metrics

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `baseline_rate` AS 
select 
avg(Readmission_Rate) AS Baseline_Rate
from `ffs-medicare-30-day-readmission-rate-puf`
where year(Service_Month_Date) = (
select min(year(Service_Month_Date)) 
from `ffs-medicare-30-day-readmission-rate-puf`
);
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `avoided_readmissions` AS 
select 
year(Service_Month_Date) AS Year,
sum(Index_Stays) AS Index_Stays,
avg(Readmission_Rate) AS Readmission_Rate,
(sum(Index_Stays) * (select Baseline_Rate from baseline_rate) / 100) AS Expected_Readmits_At_Baseline,
sum(Readmission_Stays) AS Actual_Readmits,
((sum(Index_Stays) * (select Baseline_Rate from baseline_rate) / 100) - sum(Readmission_Stays)) AS Avoided_Readmissions
from `ffs-medicare-30-day-readmission-rate-puf`
group by year(Service_Month_Date)
order by Year;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cumulative_readmits_avoided` AS 
select 
Service_Month_Date,
sum(((Index_Stays * (select Baseline_Rate from baseline_rate) / 100) - Readmission_Stays)) 
over (order by Service_Month_Date) AS Cumulative_Avoided_Readmissions
from `ffs-medicare-30-day-readmission-rate-puf`
order by Service_Month_Date;
```



## Stability and Variation

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `readmission_rate_rolling_volatility` AS 
select 
Service_Month_Date,
std(Readmission_Rate) over (
order by Service_Month_Date 
rows between 11 preceding and current row
) AS Rolling_12M_Volatility
from `ffs-medicare-30-day-readmission-rate-puf`;
```



## Additional Analysis

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `month_over_month_change` AS 
select 
Service_Month_Date,
Readmission_Rate,
(Readmission_Rate - lag(Readmission_Rate) over (order by Service_Month_Date)) AS MoM_Change
from `ffs-medicare-30-day-readmission-rate-puf`
order by Service_Month_Date;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `readmit_descriptive_stats` AS 
select 
avg(Readmission_Rate) AS Overall_Avg_Rate,
min(Readmission_Rate) AS Min_Rate,
max(Readmission_Rate) AS Max_Rate,
std(Readmission_Rate) AS StdDev_Rate
from `ffs-medicare-30-day-readmission-rate-puf`;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `rolling_six_month_avg` AS 
select 
Service_Month_Date,
Readmission_Rate,
avg(Readmission_Rate) over (
order by Service_Month_Date 
rows between 5 preceding and current row
) AS Rolling_6M_Avg
from `ffs-medicare-30-day-readmission-rate-puf`
order by Service_Month_Date;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `rolling_three_month_readmit_rate` AS 
select 
Service_Month_Date,
Readmission_Rate,
avg(Readmission_Rate) over (
order by Service_Month_Date 
rows between 2 preceding and current row
) AS Rolling_3M_Avg
from `ffs-medicare-30-day-readmission-rate-puf`
order by Service_Month_Date;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `seasonality` AS 
select 
t.Month_Name,
t.Avg_Readmission_Rate,
(t.Avg_Readmission_Rate - t.Overall_Avg) AS Diff_From_Overall
from (
select 
monthname(Service_Month_Date) AS Month_Name,
avg(Readmission_Rate) AS Avg_Readmission_Rate,
(select avg(Readmission_Rate) from `ffs-medicare-30-day-readmission-rate-puf`) AS Overall_Avg
from `ffs-medicare-30-day-readmission-rate-puf`
group by monthname(Service_Month_Date)
) t
order by t.Avg_Readmission_Rate desc;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `total_avoided_readmits` AS 
select 
sum(((Index_Stays * (select Baseline_Rate from baseline_rate) / 100) - Readmission_Stays)) AS Total_Avoided_Readmissions
from `ffs-medicare-30-day-readmission-rate-puf`;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `year_month_index_stays` AS 
select 
date_format(Service_Month_Date,'%Y-%m') AS YearMonth,
Index_Stays
from `ffs-medicare-30-day-readmission-rate-puf`
order by Service_Month_Date;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `yoy_change_year` AS 
select 
t.year,
t.avg_readmission_rate,
(t.avg_readmission_rate - lag(t.avg_readmission_rate,1) over (order by t.year)) AS YoY_Change
from (
select 
year(Service_Month_Date) AS year,
avg(Readmission_Rate) AS avg_readmission_rate
from `ffs-medicare-30-day-readmission-rate-puf`
group by year(Service_Month_Date)
) t
order by t.year;
```

```sql
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `hrrp_periods` AS 
select 
t.Policy_Period,
avg(t.Readmission_Rate) AS Avg_Readmission_Rate,
avg(t.Index_Stays) AS Avg_Index_Stays
from (
select 
Service_Month,
Index_Stays,
Readmission_Stays,
Readmission_Rate,
Service_Month_Date,
case 
when Service_Month_Date < '2012-10-01' then 'Pre HRRP'
else 'Post HRRP'
end AS Policy_Period
from `ffs-medicare-30-day-readmission-rate-puf`
) t
group by t.Policy_Period;
```
