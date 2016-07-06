SELECT f_crimes.date, jf_crimes.arrest
FROM f_crimes
INNER JOIN jf_crimes
ON f_crimes.id = jf_crimes.id
LIMIT 10;
