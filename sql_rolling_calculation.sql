# 1- Get number of monthly active customers.
use sakila;
CREATE OR REPLACE VIEW customer_activity AS
    SELECT 
        customer_id,
        rental_date AS Activity_date,
        DATE_FORMAT(rental_date, '%m') AS Activity_month,
        DATE_FORMAT(rental_date, '%y') AS Activity_year
    FROM
        sakila.rental;
# checking the number of monthly user_activity

CREATE OR REPLACE VIEW Monthly_active_customer AS
    SELECT 
        COUNT(DISTINCT customer_id) AS active_customer,
        Activity_month,
        Activity_year
    FROM
        customer_activity
    GROUP BY 2 , 3
    ORDER BY 2 , 3;

# 2- Active users in the previous month.
create or replace view activity_comparison as 
select active_customer,
lag(active_customer, 1) over (partition by Activity_year) as last_month_active_customer, Activity_year, Activity_month
from Monthly_active_customer;
SELECT 
    *
FROM
    activity_comparison
WHERE
    last_month_active_customer IS NOT NULL;

# 3- Percentage change in the number of active customers.

with number_diff_customer as (select (active_customer - last_month_active_customer )*100/last_month_active_customer as percentage_change_of_active_customer, Activity_month, Activity_year
from activity_comparison)
select percentage_change_of_active_customer, Activity_month, Activity_year
from number_diff_customer
where percentage_change_of_active_customer is not null;

# 4- Retained customers every month.
create or replace view retained_customers_view as
with distinct_users as (select distinct customer_id , Activity_month, Activity_year
  from customer_activity)
select count(distinct d1.customer_id) as Retained_customers, d1.Activity_month, d1.Activity_year
from distinct_users d1
join distinct_users d2
on d1.customer_id = d2.customer_id and d1.activity_month = d2.activity_month + 1
group by d1.Activity_month, d1.Activity_year
order by d1.Activity_year, d1.Activity_month;


