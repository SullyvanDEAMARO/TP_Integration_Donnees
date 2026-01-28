/* ===========================================================
   1) Top 10 marques par proportion de produits Nutri-Score A/B
=========================================================== */
SELECT
    b.brand_name AS marque,
    COUNT(*) AS nb_produits,
    SUM(CASE WHEN f.nutriscore_grade IN ('A','B')
             THEN 1 ELSE 0 END) AS nb_produits_AB,
    ROUND(
        SUM(CASE WHEN f.nutriscore_grade IN ('A','B')
                 THEN 1 ELSE 0 END)::numeric
        / NULLIF(COUNT(*)::numeric, 0) * 100, 2
    ) AS pct_AB
FROM off_dm.fact_nutrition_snapshot f
JOIN off_dm.dim_product p
    ON f.product_sk = p.product_sk
JOIN off_dm.dim_brand b
    ON p.brand_sk = b.brand_sk
WHERE p.is_current = TRU
  AND f.nutriscore_grade IS NOT NULL
GROUP BY b.brand_name
ORDER BY pct_AB DESC, nb_produits DESC
LIMIT 10;


/* ===========================================================
   2) Distribution du Nutri-Score par niveau 2 de catégorie
=========================================================== */
SELECT
    c.category_name AS categorie_niveau2,
    f.nutriscore_grade AS nutriscore,
    COUNT(*) AS nb_produits
FROM off_dm.fact_nutrition_snapshot f
JOIN off_dm.dim_product p
    ON f.product_sk = p.product_sk
JOIN off_dm.dim_category c
    ON p.category_sk = c.category_sk
WHERE p.is_current = TRUE
  AND f.nutriscore_grade IS NOT NULL
GROUP BY c.category_name, f.nutriscore_grade
ORDER BY c.category_name, f.nutriscore_grade;


/* ===========================================================
   3) Heatmap pays × catégorie : moyenne de sugars_100g
=========================================================== */
SELECT
    co.country_name AS pays,
    c.category_name AS categorie,
    ROUND(AVG(f.sugars_100g)::numeric, 2) AS avg_sugars_100g,
    COUNT(*) AS nb_produits
FROM off_dm.fact_nutrition_snapshot f
JOIN off_dm.dim_product p
    ON f.product_sk = p.product_sk
JOIN off_dm.dim_country co
    ON p.country_sk = co.country_sk
JOIN off_dm.dim_category c
    ON p.category_sk = c.category_sk
WHERE p.is_current = TRUE
  AND f.sugars_100g IS NOT NULL
GROUP BY co.country_name, c.category_name
ORDER BY co.country_name, c.category_name;


/* ===========================================================
   4) Taux de complétude des nutriments par marque
=========================================================== */
SELECT
    b.brand_name AS marque,
    ROUND(AVG(f.completeness_score)::numeric * 100, 2) AS avg_completeness_pct,
    COUNT(*) AS nb_produits
FROM off_dm.fact_nutrition_snapshot f
JOIN off_dm.dim_product p
    ON f.product_sk = p.product_sk
JOIN off_dm.dim_brand b
    ON p.brand_sk = b.brand_sk
WHERE p.is_current = TRUE
GROUP BY b.brand_name
ORDER BY avg_completeness_pct DESC;


/* ===========================================================
   5) Liste des anomalies nutriments (salt_100g > 25 ou sugars_100g > 80)
=========================================================== */
SELECT
    p.code,
    p.product_name,
    b.brand_name,
    c.category_name,
    co.country_name,
    f.sugars_100g,
    f.salt_100g,
    f.quality_issues_json
FROM off_dm.fact_nutrition_snapshot f
JOIN off_dm.dim_product p
    ON f.product_sk = p.product_sk
LEFT JOIN off_dm.dim_brand b
    ON p.brand_sk = b.brand_sk
LEFT JOIN off_dm.dim_category c
    ON p.category_sk = c.category_sk
LEFT JOIN off_dm.dim_country co
    ON p.country_sk = co.country_sk
WHERE p.is_current = TRUE
  AND (
        f.salt_100g  > 25   -- sel très élevé
     OR f.sugars_100g > 80  -- sucres très élevés
  )
ORDER BY
    f.salt_100g  DESC NULLS LAST,
    f.sugars_100g DESC NULLS LAST;


/* ===========================================================
   6) Évolution hebdomadaire de la complétude (via dim_time)
=========================================================== */
SELECT
    t.year,
    t.week,
    MIN(t.date) AS week_start_date,
    ROUND(AVG(f.completeness_score)::numeric * 100, 2) AS avg_completeness_pct,
    COUNT(*) AS nb_produits
FROM off_dm.fact_nutrition_snapshot f
JOIN off_dm.dim_time t
    ON f.time_sk = t.time_sk
GROUP BY t.year, t.week
ORDER BY t.year, t.week;
