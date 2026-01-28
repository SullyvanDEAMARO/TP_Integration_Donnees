-- Produits sans marque / pays / catégorie (clé étrangère manquante)
SELECT COUNT() AS nb_dimproduct_sans_brand
FROM off_dm.dim_product p
LEFT JOIN off_dm.dim_brand b ON p.brand_sk = b.brand_sk
WHERE p.brand_sk IS NOT NULL AND b.brand_sk IS NULL;

SELECT COUNT() AS nb_dimproduct_sans_country
FROM off_dm.dim_product p
LEFT JOIN off_dm.dim_country c ON p.country_sk = c.country_sk
WHERE p.country_sk IS NOT NULL AND c.country_sk IS NULL;

SELECT COUNT() AS nb_dimproduct_sans_category
FROM off_dm.dim_product p
LEFT JOIN off_dm.dim_category c ON p.category_sk = c.category_sk
WHERE p.category_sk IS NOT NULL AND c.category_sk IS NULL;

-- Fact sans produit ou sans temps
SELECT COUNT() AS nb_fact_sans_product
FROM off_dm.fact_nutrition_snapshot f
LEFT JOIN off_dm.dim_product p ON f.product_sk = p.product_sk
WHERE f.product_sk IS NOT NULL AND p.product_sk IS NULL;

SELECT COUNT(*) AS nb_fact_sans_time
FROM off_dm.fact_nutrition_snapshot f
LEFT JOIN off_dm.dim_time t ON f.time_sk = t.time_sk
WHERE f.time_sk IS NOT NULL AND t.time_sk IS NULL;