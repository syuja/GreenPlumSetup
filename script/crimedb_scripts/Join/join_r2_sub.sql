SELECT f_crimes_r_sub.date, jf_crimes_r_sub.arrest
FROM f_crimes_r_sub
INNER JOIN jf_crimes_r_sub
ON f_crimes_r_sub.id = jf_crimes_r_sub.id
LIMIT 10;

