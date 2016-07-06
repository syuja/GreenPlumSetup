SELECT f_crimes_r1.id, jf_crimes_r1.primary_type
FROM f_crimes_r1
INNER JOIN jf_crimes_r1
ON f_crimes_r1.date = jf_crimes_r1.date
LIMIT 10;
