SELECT f_crimes.id, jf_crimes.primary_type
FROM f_crimes
INNER JOIN jf_crimes
ON f_crimes.date = jf_crimes.date
LIMIT 10;
