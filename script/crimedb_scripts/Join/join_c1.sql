SELECT f_crimes_c1.id, jf_crimes_c1.primary_type
FROM f_crimes_c1
INNER JOIN jf_crimes_c1
ON f_crimes_c1.date = jf_crimes_c1.date
LIMIT 10;
