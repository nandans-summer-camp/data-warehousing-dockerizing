-- unweighted
WITH t AS (SELECT customer_number,
                  percentile_cont(0.75) WITHIN GROUP (ORDER BY discount_percentage DESC) AS thresh
           FROM order_facts
           GROUP BY customer_number)
SELECT customer_name, thresh
FROM t
LEFT JOIN customers
USING (customer_number)
WHERE thresh > 0.10
ORDER BY thresh DESC;

--- without percentile
WITH t AS (SELECT customer_number,
                  SUM((discount_percentage >= .1)::INT) as num_discounted,
                  COUNT(*)::FLOAT as sales
           FROM order_facts
           GROUP BY customer_number)
SELECT customer_name, num_discounted/sales
FROM t
LEFT JOIN customers
USING (customer_number)
WHERE num_discounted/sales >= 0.75
ORDER BY num_discounted/sales DESC;


------
WITH final AS (SELECT customer_name,
                          CAST(count(*) AS NUMERIC) AS total,
                          SUM(((msrp::NUMERIC)*0.9 >= price_each::NUMERIC)::INT)::FLOAT AS amount
                   FROM order_facts
                   LEFT JOIN customers
                   USING (customer_number)
                   GROUP BY customer_number, customer_name)
SELECT customer_name, amount/total as percent
FROM final
WHERE amount/total >= 0.75;


-- weighted by value
WITH t AS (SELECT customer_number, sales_amount/c.tot_sales AS weight, discount_percentage
           FROM order_facts
           LEFT JOIN (SELECT customer_number, SUM(sales_amount) AS tot_sales
                      FROM order_facts
                      GROUP BY customer_number) AS c
           USING (customer_number))
SELECT customer_name, SUM(weight) as perc_heavily_discounted
FROM t
LEFT JOIN customers
USING (customer_number)
WHERE discount_percentage >= 0.10
GROUP BY customer_number, customer_name
HAVING SUM(weight) >= 0.75
ORDER BY SUM(weight) DESC;
