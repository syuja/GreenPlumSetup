SELECT f_crimes_r1.date, jf_crimes_r1.arrest
FROM f_crimes_r1
INNER JOIN jf_crimes_r1
ON f_crimes_r1.id = jf_crimes_r1.id
LIMIT 10;

