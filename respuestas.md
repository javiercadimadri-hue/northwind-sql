# Respuestas a los Ejercicios - Northwind

## Pregunta 1 - Productos en catálogo activos entre 10 y 50 dólares

**Enunciado:** Listar el nombre y precio redondeado a dos decimales de los productos que siguen a la venta y cuyo precio está entre 10 y 50 dólares, ordenados de mayor a menor precio.

**Consulta:**

```sql
SELECT product_name AS producto, ROUND(unit_price::numeric, 2) AS precio
FROM products
WHERE discontinued = 0 AND unit_price BETWEEN 10 AND 50
ORDER BY precio DESC;

## Pregunta 2 - Concentración geográfica de la cartera

**Enunciado:** Cuenta cuántos clientes hay en cada país y muestra únicamente aquellos países con 5 o más clientes, ordenados de mayor a menor. Indica también cuántas ciudades distintas hay en cada uno de esos países.

**Consulta:**

```sql
SELECT 
    country AS pais, 
    COUNT(*) AS num_clientes, 
    COUNT(DISTINCT city) AS num_ciudades
FROM customers
GROUP BY country
HAVING COUNT(*) >= 5
ORDER BY num_clientes DESC;

## Pregunta 3 - Alerta de reposición

**Enunciado:** Localiza los productos activos cuyas unidades en stock sean inferiores o iguales a su nivel de reposición. Muestra el nombre, las unidades en stock, el nivel de reposición, las unidades ya pedidas al proveedor y una columna de texto que indique 'CRÍTICO' cuando el stock sea 0 y 'AVISO' en el resto de casos.

**Consulta:**

```sql
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

  ## Pregunta 4 – Ficha completa de producto

**Enunciado:** Para los productos suministrados por empresas de Italia, Francia o España, muestra el nombre del producto, el nombre de la categoría, el nombre del proveedor, su país y su ciudad. Ordena por país y, dentro de cada país, por nombre de producto.

**Consulta:**

```sql
SELECT 
    p.product_name AS producto,
    c.category_name AS categoria,
    s.company_name AS proveedor,
    s.country AS pais,
    s.city AS ciudad
FROM products AS p
INNER JOIN categories AS c 
    ON c.category_id = p.category_id
INNER JOIN suppliers AS s 
    ON s.supplier_id = p.supplier_id
WHERE s.country IN ('Italy', 'France', 'Spain')
ORDER BY pais, producto;

## Pregunta 5 – Detalle valorizado de un pedido

**Enunciado:** Muestra, para el pedido 10248, el nombre del producto, el precio unitario aplicado, la cantidad, el descuento y el importe final de cada línea. Añade el nombre del cliente y la fecha del pedido.

**Consulta:**

```sql
SELECT 
    c.company_name AS cliente,
    o.order_date AS fecha_pedido,
    p.product_name AS producto,
    od.unit_price AS precio_unitario,
    od.quantity AS cantidad,
    od.discount AS descuento,
    ROUND((od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS importe_linea
FROM products p
INNER JOIN order_details od USING (product_id)
INNER JOIN orders o USING (order_id)
INNER JOIN customers c USING (customer_id)
WHERE order_id = 10248;

## Pregunta 6 – Ranking de categorías por facturación

**Enunciado:** Calcula la facturación total de cada categoría durante toda la historia de la compañía. Muestra el nombre de la categoría, el número de líneas de pedido que ha generado, el número de productos distintos vendidos y la facturación total. Incluye únicamente las categorías que superen los 100.000 euros de facturación, ordenadas de mayor a menor.

**Consulta:**

```sql
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

## Pregunta 7 – Clientes sin actividad comercial

**Enunciado:** Lista todos los clientes con el número de pedidos que ha realizado cada uno y la fecha de su último pedido. Los clientes sin ningún pedido deben aparecer igualmente, con un 0 en el conteo y el texto 'SIN PEDIDOS' en lugar de la fecha. Ordena de forma que los clientes inactivos aparezcan primero.

**Consulta:**

```sql
SELECT 
    c.company_name AS cliente,
    c.country AS pais,
    COUNT(o.order_id) AS num_pedidos,
    COALESCE(MAX(o.order_date)::text, 'SIN PEDIDOS') AS ultimo_pedido
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.company_name, c.country
ORDER BY num_pedidos ASC, cliente ASC;

## Pregunta 8 – Organigrama de la fuerza de ventas

**Enunciado:** Muestra cada empleado con su nombre completo, su cargo, el nombre completo de la persona a la que reporta y el cargo de esa persona. El empleado que no reporta a nadie debe aparecer también, con el texto 'DIRECCIÓN GENERAL' en el campo del responsable.

**Consulta:**

```sql
SELECT 
    (emp.first_name || ' ' || emp.last_name) AS empleado,
    emp.title AS cargo,
    COALESCE(jefe.first_name || ' ' || jefe.last_name, 'DIRECCIÓN GENERAL') AS responsable,
    COALESCE(jefe.title, 'DIRECCIÓN GENERAL') AS cargo_responsable
FROM employees emp
LEFT JOIN employees jefe ON emp.reports_to = jefe.employee_id;


## Pregunta 9 – Rejilla de cobertura categoría × año

**Enunciado:** Control de gestión quiere una rejilla completa de facturación por categoría y año, sin huecos: si una categoría no vendió nada en un año concreto, debe aparecer con un 0, no desaparecer de la tabla. Genera todas las combinaciones posibles de las 8 categorías con los 3 años del histórico (24 filas) y asocia a cada combinación su facturación. Ordena por categoría y año.

**Consulta:**

```sql
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

## Pregunta 10 – Mapa de países: clientes frente a proveedores

**Enunciado:** Expansión internacional quiere una única tabla que muestre, para cada país en el que la compañía tiene presencia, cuántos clientes y cuántos proveedores hay. Deben aparecer los países que solo tienen clientes, los que solo tienen proveedores y los que tienen ambos.

**Consulta:**

```sql
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

## Pregunta 11 – Directorio unificado de contactos

**Enunciado:** Sistemas va a migrar el CRM y necesita una exportación única con todos los contactos de la compañía, vengan de donde vengan. Construye una sola tabla que reúna los contactos de clientes, los de proveedores y los empleados. Cada fila debe indicar el origen ('CLIENTE', 'PROVEEDOR', 'EMPLEADO'), el nombre de la persona de contacto en mayúsculas, la organización a la que pertenece, la ciudad y el país. Para los empleados, la organización es el literal 'NORTHWIND TRADERS' y el nombre de contacto se forma concatenando nombre y apellidos. Ordena por origen y luego por país.

**Consulta:**

```sql
SELECT 
    'CLIENTE' AS origen,
    UPPER(contact_name) AS contacto,
    company_name AS organizacion,
    city AS ciudad,
    country AS pais
FROM customers

UNION ALL

SELECT 
    'PROVEEDOR' AS origen,
    UPPER(contact_name) AS contacto,
    company_name AS organizacion,
    city AS ciudad,
    country AS pais
FROM suppliers

UNION ALL

SELECT 
    'EMPLEADO' AS origen,
    UPPER(first_name || ' ' || last_name) AS contacto,
    'NORTHWIND TRADERS' AS organizacion,
    city AS ciudad,
    country AS pais
FROM employees

ORDER BY origen, pais;

## Pregunta 12 – Mercados con desequilibrio

**Enunciado:** Compras y Ventas mantienen una discusión recurrente: ¿en qué países vendemos sin tener proveedor local, y en cuáles coincidimos? Resuelve las dos preguntas en dos consultas independientes:
a) Países donde hay clientes pero ningún proveedor.
b) Países donde hay a la vez clientes y proveedores.
Ordena ambos resultados alfabéticamente.

**Consulta Apartado a:**

```sql
SELECT country AS pais FROM customers
EXCEPT
SELECT country FROM suppliers
ORDER BY pais;

**Consulta Apartado b:**
SELECT country AS pais FROM customers
INTERSECT
SELECT country FROM suppliers
ORDER BY pais;

## Pregunta 13 – Clientes que nunca han comprado pescado

**Enunciado:** El responsable de la categoría Seafood quiere una lista de cuentas sobre las que hacer campaña de captación. Localiza los clientes que nunca han incluido un producto de la categoría 'Seafood' en ninguno de sus pedidos. Muestra el nombre del cliente, su país y el número total de pedidos que sí ha realizado, de mayor a menor.

**Consulta:**

```sql
SELECT 
    c.contact_name AS cliente,
    c.country AS pais,
    COUNT(o.order_id) AS pedidos_realizados
FROM customers AS c
INNER JOIN orders AS o ON c.customer_id = o.customer_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM orders AS sub_o
    INNER JOIN order_details AS od ON sub_o.order_id = od.order_id
    INNER JOIN products AS p ON p.product_id = od.product_id
    INNER JOIN categories AS cat ON p.category_id = cat.category_id
    WHERE sub_o.customer_id = c.customer_id 
      AND cat.category_name = 'Seafood'
)
GROUP BY c.customer_id, c.contact_name, c.country
ORDER BY pedidos_realizados DESC;

## Pregunta 14 – Productos por encima de la media

**Enunciado:** El comité de precios quiere identificar el segmento premium del catálogo. Muestra los productos activos cuyo precio unitario supere el precio medio de todo el catálogo. Incluye en cada fila el precio del producto, el precio medio general y la diferencia entre ambos, todo redondeado a dos decimales. Ordena por diferencia descendente.

**Consulta:**

```sql
SELECT 
    product_name AS producto,
    unit_price AS precio,
    (SELECT ROUND(AVG(unit_price)::numeric, 2) FROM products) AS precio_medio_catalogo,
    ROUND((unit_price - (SELECT AVG(unit_price) FROM products))::numeric, 2) AS diferencia
FROM products
WHERE discontinued = 0 
  AND unit_price > (SELECT AVG(unit_price) FROM products)
ORDER BY diferencia DESC;

## Pregunta 15 – Ticket medio por cliente

**Enunciado:** Dirección comercial quiere segmentar la cartera por valor medio de pedido, no por volumen total. Calcula, para cada cliente que haya comprado alguna vez, el número de pedidos, el importe total acumulado y el importe medio por pedido. Muestra los 15 clientes con mayor ticket medio.

**Consulta:**

```sql
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

## Pregunta 17 – Segmentación ABC de la cartera de clientes

**Enunciado:** Dirección quiere clasificar a los clientes en tres tramos de valor para asignar recursos comerciales. Usando expresiones de tabla común (CTE), construye una consulta que calcule la facturación total de cada cliente, los divida en cuartiles mediante `NTILE(4)`, les asigne un segmento ('A - Estratégico', 'B - Consolidado', 'C - Ocasional', 'D - Marginal') y devuelva el número de clientes, la facturación total y el porcentaje sobre el total por cada segmento.

**Consulta:**

```sql
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

## Pregunta 18 – Los tres productos más vendidos de cada categoría

**Enunciado:** El equipo de categoría necesita el podio de cada familia para negociar con proveedores. Para cada categoría, obtén los tres productos con mayor facturación. Muestra la categoría, la posición dentro de la categoría, el nombre del producto, las unidades vendidas y la facturación. Incluye además una columna con la posición global del producto en el conjunto de la compañía.

**Consulta:**

```sql
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

## Pregunta 20 – Cuadro de mando anual por categoría

**Enunciado:** Construye una tabla donde cada fila sea una categoría y las columnas muestren la facturación de 1996, 1997 y 1998 en columnas separadas, más el total de los tres años. Añade al final una fila de totales generales. Incluye además una columna que indique el peso de cada categoría sobre la facturación total de la compañía, y otra que muestre si la categoría creció o decreció entre 1997 y 1998.

**Consulta:**

```sql
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
        -- NOTA DE CONTROL DE GESTIÓN: 1998 solo contiene datos hasta mayo, 
        -- mientras que 1997 abarca el año completo. La tendencia nominal refleja
        -- decrecimiento por sesgo de ventana temporal no homogénea.
        WHEN f_1998 > f_1997 THEN 'Crecimiento'
        ELSE 'Decrecimiento'
    END AS tendencia
FROM facturacion_base
ORDER BY (categoria = 'TOTAL'), total DESC;