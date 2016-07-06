SELECT f_crimes_c_sub.date, jf_crimes_c_sub.arrest
FROM f_crimes_c_sub
INNER JOIN jf_crimes_c_sub
ON f_crimes_c_sub.id = jf_crimes_c_sub.id
LIMIT 10;
