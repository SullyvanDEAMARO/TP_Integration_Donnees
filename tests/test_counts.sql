-- Vérifier que les tables principales ont des lignes
SELECT 'dimbrand' AS table_name, COUNT() AS nb_lignes FROM off_dm.dim_brand
UNION ALL
SELECT 'dimcountry', COUNT() FROM off_dm.dim_country
UNION ALL
SELECT 'dimcategory', COUNT() FROM off_dm.dim_category
UNION ALL
SELECT 'dimtime', COUNT() FROM off_dm.dim_time
UNION ALL
SELECT 'dimproduct (is_current=true)', COUNT() FROM off_dm.dim_product WHERE is_current = TRUE
UNION ALL
SELECT 'factnutritionsnapshot', COUNT() FROM off_dm.fact_nutrition_snapshot;