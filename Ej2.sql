SELECT 
    country AS pais, 
    COUNT(*) AS num_clientes, 
    COUNT(DISTINCT city) AS num_ciudades
FROM customers
GROUP BY country 
HAVING COUNT(*) >= 5
ORDER BY num_clientes DESC;