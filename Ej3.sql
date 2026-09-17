SELECT product_name as producto, 
units_in_stock as stock,
reorder_level as nivel_reposicion,
units_on_order as pedido_a_proveedor,
CASE WHEN units_in_stock = 0 THEN 'CRITICO' ELSE 'AVISO' END AS situacion
FROM products 
WHERE discontinued = 0
AND units_in_stock <= reorder_level
