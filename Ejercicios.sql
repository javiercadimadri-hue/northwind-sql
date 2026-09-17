SELECT product_name AS producto, ROUND(unit_price::numeric, 2) AS precio
FROM products
WHERE discontinued = 0 AND unit_price BETWEEN 10 AND 50
ORDER BY precio DESC;

SELECT 
    country AS pais, 
    COUNT(*) AS num_clientes, 
    COUNT(DISTINCT city) AS num_ciudades
FROM customers
GROUP BY country
HAVING COUNT(*) >= 5
ORDER BY num_clientes DESC;

SELECT 
    product_name AS producto,
    units_in_stock AS stock,
    reorder_level AS nivel_reposicion,
    units_on_order AS pedido_a_proveedor,
    CASE 
        WHEN units_in_stock = 0 THEN 'CRITICO' 
        ELSE 'AVISO' 
    END AS situacion
FROM products
WHERE discontinued = 0 
  AND units_in_stock <= reorder_level;

SELECT p.product_name as producto,
c.category_name as categoria,
s.company_name as proveedor,
s.country as pais,
s.city as ciudad
FROM products as p
INNER JOIN categories as c
ON c.category_id = p.category_id
INNER JOIN suppliers as s
ON s.supplier_id = p.supplier_id
WHERE s.country IN ('Italy','France','Spain')
ORDER BY pais , producto;


SELECT c.contact_name as cliente,
o.order_date as fecha_pedido,
p.product_name as producto,
p.unit_price as precio_unitario,
od.quantity as cantidad,
od.discount as descuento,
ROUND((od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS importe_linea
FROM products as p
INNER JOIN order_details as od USING (product_id)
INNER JOIN orders as o USING (order_id)
INNER JOIN customers as c USING (customer_id)
WHERE order_id=10248;

SELECT 
    c.category_name AS categoria,
    COUNT(od.order_id) AS num_lineas,
    COUNT(DISTINCT p.product_id) AS num_productos,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS facturacion
FROM categories c
INNER JOIN products p USING (category_id)
INNER JOIN order_details od USING (product_id)
GROUP BY c.category_name
HAVING SUM(od.unit_price * od.quantity * (1 - od.discount)) > 100000
ORDER BY facturacion DESC;

SELECT 
    c.company_name AS cliente,
    c.country AS pais,
    COUNT(o.order_id) AS num_pedidos,
    COALESCE(MAX(o.order_date)::text, 'SIN PEDIDOS') AS ultimo_pedido
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.company_name, c.country
ORDER BY num_pedidos ASC, cliente ASC;

SELECT
(emp.first_name || ' ' || emp.last_name) AS empleado,
emp.title as cargo,
COALESCE((jefe.first_name || ' ' || jefe.last_name),'DIRECCION GENERAL') AS responsable,
COALESCE((jefe.title),'DIRECCION GENERAL') AS cargo_responsable
FROM employees as emp
LEFT JOIN employees as jefe ON emp.reports_to= jefe.employee_id

SELECT 
    c.category_name AS categoria,
    a.anio,
    COALESCE(ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2), 0) AS facturacion
FROM categories AS c
CROSS JOIN (
    SELECT DISTINCT EXTRACT(YEAR FROM order_date)::integer AS anio 
    FROM orders
) AS a
LEFT JOIN products AS p ON c.category_id = p.category_id
LEFT JOIN orders AS o ON EXTRACT(YEAR FROM o.order_date) = a.anio
LEFT JOIN order_details AS od ON p.product_id = od.product_id AND o.order_id = od.order_id
GROUP BY c.category_name, a.anio
ORDER BY categoria, anio;


SELECT 
    COALESCE(c.country, s.country) AS pais,
    COALESCE(c.num_clientes, 0) AS num_clientes,
    COALESCE(s.num_proveedores, 0) AS num_proveedores,
    CASE 
        WHEN c.country IS NOT NULL AND s.country IS NOT NULL THEN 'AMBOS'
        WHEN c.country IS NOT NULL THEN 'SOLO CLIENTES'
        ELSE 'SOLO PROVEEDORES'
    END AS tipo_presencia
FROM (
    SELECT country, COUNT(customer_id) AS num_clientes
    FROM customers
    GROUP BY country
) AS c
FULL JOIN (
    SELECT country, COUNT(supplier_id) AS num_proveedores
    FROM suppliers
    GROUP BY country
) AS s ON c.country = s.country
ORDER BY pais;


SELECT 
'CLIENTE' as origen,
UPPER(contact_name) as contacto,
company_name as organizacion,
city as ciudad,
country as pais
FROM customers	
UNION ALL 

SELECT
'PROVEEDOR' as origen,
UPPER(contact_name) as contacto,
company_name as organizacion,
city as ciudad,
country as pais
FROM suppliers
UNION ALL 

SELECT
'EMPLEADO' as origen,
UPPER(first_name || ' ' || last_name) as contacto,
'NORTHWIND TRADERS' as organizacion,
city as ciudad,
country as pais
from employees
;

SELECT country as pais FROM customers
EXCEPT
SELECT country FROM suppliers
ORDER BY pais
;

SELECT country as pais FROM customers
INTERSECT
SELECT country FROM suppliers
ORDER BY pais
;

SELECT 
c.contact_name as cliente,
c.country as pais,
COUNT(o.*) as pedidos_realizados
FROM customers as c 
INNER JOIN orders as o
ON c.customer_id= o.customer_id
WHERE c.customer_id NOT IN (SELECT o.customer_id 
							FROM orders as o
							INNER JOIN order_details as od ON o.order_id = od.order_id
							INNER JOIN products as p ON p.product_id=od.product_id
							INNER JOIN categories as c ON p.category_id=c.category_id
							WHERE c.category_name = 'Seafood')
GROUP BY cliente , pais
ORDER BY pedidos_realizados DESC;
;

SELECT 
product_name as producto,
unit_price as precio ,
(SELECT ROUND(AVG(unit_price)::numeric,2) FROM products) as precio_promedio_catalogo,
ROUND((unit_price - (SELECT AVG(unit_price) FROM products))::numeric, 2) AS diferencia
FROM products
WHERE discontinued= 0 
AND unit_price >(SELECT AVG(unit_price) FROM products)
ORDER BY diferencia DESC;



SELECT
    c.contact_name AS cliente,
    c.country AS pais,
    COUNT(t.order_id) AS num_pedidos,
    ROUND(SUM(t.total_pedido)::numeric, 2) AS importe_total,
    ROUND(AVG(t.total_pedido)::numeric, 2) AS ticket_medio
FROM (
    SELECT 
        o.customer_id,
        od.order_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_pedido
    FROM order_details AS od
    INNER JOIN orders AS o ON od.order_id = o.order_id
    GROUP BY o.customer_id, od.order_id
) AS t
INNER JOIN customers AS c ON t.customer_id = c.customer_id
GROUP BY c.contact_name, c.country
ORDER BY ticket_medio DESC 
LIMIT 15;

SELECT 
    c.category_name AS categoria,
    p.product_name AS producto,
    p.unit_price AS precio,
    (SELECT ROUND(AVG(sub_p.unit_price)::numeric, 2) 
     FROM products AS sub_p 
     WHERE sub_p.category_id = p.category_id) AS precio_medio_categoria
FROM products AS p
INNER JOIN categories AS c ON c.category_id = p.category_id
WHERE p.unit_price = (
    SELECT MAX(sub_p.unit_price) 
    FROM products AS sub_p 
    WHERE sub_p.category_id = p.category_id
)
ORDER BY categoria;


WITH cte1 AS (
    SELECT 
        c.customer_id,
        c.contact_name AS cliente,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS facturacion
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    INNER JOIN order_details od ON od.order_id = o.order_id
    GROUP BY c.customer_id, c.contact_name
),
cte2 AS (
    SELECT 
        customer_id,
        cliente,
        facturacion,
        NTILE(4) OVER (ORDER BY facturacion DESC) AS cuartil
    FROM cte1
),
cte3 AS (
    SELECT 
        customer_id,
        facturacion,
        CASE 
            WHEN cuartil = 1 THEN 'A - Estratégico'
            WHEN cuartil = 2 THEN 'B - Consolidado'
            WHEN cuartil = 3 THEN 'C - Ocasional'
            WHEN cuartil = 4 THEN 'D - Marginal'
        END AS segmento
    FROM cte2
)
SELECT 
    segmento,
    COUNT(customer_id) AS num_clientes,
    ROUND(SUM(facturacion)::numeric, 2) AS facturacion_segmento,
    ROUND((SUM(facturacion) / (SELECT SUM(facturacion) FROM cte1) * 100)::numeric, 2) AS porcentaje_sobre_total
FROM cte3
GROUP BY segmento
ORDER BY segmento;

WITH ventas_productos AS (
    SELECT 
        c.category_name AS categoria,
        p.product_name AS producto,
        SUM(od.quantity) AS unidades,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS facturacion
    FROM products p
    INNER JOIN categories c ON p.category_id = c.category_id
    INNER JOIN order_details od ON p.product_id = od.product_id
    GROUP BY c.category_name, p.product_name
),
ranking_productos AS (
    SELECT 
        categoria,
        producto,
        unidades,
        facturacion,
        DENSE_RANK() OVER (
            PARTITION BY categoria 
            ORDER BY facturacion DESC
        ) AS posicion_en_categoria,
        DENSE_RANK() OVER (
            ORDER BY facturacion DESC
        ) AS posicion_global
    FROM ventas_productos
)
SELECT 
    categoria,
    posicion_en_categoria,
    producto,
    unidades,
    facturacion,
    posicion_global
FROM ranking_productos
WHERE posicion_en_categoria <= 3
ORDER BY categoria, posicion_en_categoria;



WITH facturacion_mensual AS (
    SELECT 
        DATE_TRUNC('month', o.order_date)::date AS mes,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS facturacion
    FROM orders o
    INNER JOIN order_details od ON o.order_id = od.order_id
    WHERE o.order_date >= '1997-01-01' AND o.order_date < '1998-01-01'
    GROUP BY DATE_TRUNC('month', o.order_date)::date
),
metricas_temporales AS (
    SELECT 
        mes,
        facturacion,
        SUM(facturacion) OVER (ORDER BY mes) AS acumulado,
        ROUND(AVG(facturacion) OVER (
            ORDER BY mes 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )::numeric, 2) AS media_movil_3m,
        LAG(facturacion, 1) OVER (ORDER BY mes) AS mes_anterior
    FROM facturacion_mensual
)
SELECT 
    mes,
    facturacion,
    acumulado,
    media_movil_3m,
    mes_anterior,
    ROUND(((facturacion - mes_anterior) / mes_anterior * 100)::numeric, 2) AS variacion_pct
FROM metricas_temporales
ORDER BY mes;



WITH facturacion_base AS (
    SELECT 
        c.category_name AS categoria,
        ROUND(COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount)) 
            FILTER (WHERE EXTRACT(YEAR FROM o.order_date) = 1996), 0)::numeric, 2) AS f_1996,
        ROUND(COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount)) 
            FILTER (WHERE EXTRACT(YEAR FROM o.order_date) = 1997), 0)::numeric, 2) AS f_1997,
        ROUND(COALESCE(SUM(od.unit_price * od.quantity * (1 - od.discount)) 
            FILTER (WHERE EXTRACT(YEAR FROM o.order_date) = 1998), 0)::numeric, 2) AS f_1998,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total
    FROM categories c
    INNER JOIN products p ON c.category_id = p.category_id
    INNER JOIN order_details od ON p.product_id = od.product_id
    INNER JOIN orders o ON od.order_id = o.order_id
    GROUP BY ROLLUP(c.category_name)
)
SELECT 
    COALESCE(categoria, 'TOTAL') AS categoria,
    f_1996,
    f_1997,
    f_1998,
    total,
    ROUND((total / SUM(total) OVER() * 100)::numeric, 2) AS peso_pct,
    CASE 
        WHEN categoria IS NULL THEN '-'
        -- NOTA: 1998 solo contiene datos hasta mayo, mientras que 1997 contiene el año completo.
        -- La comparación directa no está normalizada temporalmente.
        WHEN f_1998 > f_1997 THEN 'Crecimiento'
        ELSE 'Decrecimiento'
    END AS tendencia
FROM facturacion_base
ORDER BY (categoria = 'TOTAL'), total DESC;