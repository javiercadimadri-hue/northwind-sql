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