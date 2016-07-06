SELECT f_crimes_c1.date, jf_crimes_c1.arrest
FROM f_crimes_c1
INNER JOIN jf_crimes_c1
ON f_crimes_c1.id = jf_crimes_c1.id
LIMIT 10;
