/* ===========================================================
   KPI 1.1 - Répartition Nutri-Score par MARQUE
=========================================================== */
SELECT
    b.brand_name AS marque,
    f.nutriscore_grade AS nutriscore,
    COUNT(*) AS nb_produits
FROM off_dm.fact_nutrition_snapshot f
JOIN off_dm.dim_product p
    ON f.product_sk = p.product_sk
JOIN off_dm.dim_brand b
    ON p.brand_sk = b.brand_sk
WHERE p.is_current = TRUE
  AND f.nutriscore_grade IS NOT NULL
GROUP BY b.brand_name, f.nutriscore_grade
ORDER BY b.brand_name, f.nutriscore_grade;


/* ===========================================================
   KPI 1.2 - Répartition Nutri-Score par CATEGORIE
=========================================================== */
SELECT
    c.category_name AS categorie,
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
   KPI 1.3 - Répartition Nutri-Score par PAYS
=========================================================== */
SELECT
    co.country_name AS pays,
    f.nutriscore_grade AS nutriscore,
    COUNT(*) AS nb_produits
FROM off_dm.fact_nutrition_snapshot f
JOIN off_dm.dim_product p
    ON f.product_sk = p.product_sk
JOIN off_dm.dim_country co
    ON p.country_sk = co.country_sk
WHERE p.is_current = TRUE
  AND f.nutriscore_grade IS NOT NULL
GROUP BY co.country_name, f.nutriscore_grade
ORDER BY co.country_name, f.nutriscore_grade;



/* ===========================================================
   KPI 2 - Évolution de la complétude des nutriments
   Variante : hebdomadaire via dim_time
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



/* ===========================================================
   KPI 3 - Taux d’anomalies (valeurs hors bornes)
   Exemple avec sugars_100g > 80 et salt_100g > 25
   (À ajuster selon ce que tu filtres ou tags dans l’ETL)
=========================================================== */
SELECT
    COUNT(*) AS total_produits,

    -- produits avec sucres très élevés
    SUM(CASE WHEN f.sugars_100g > 80 THEN 1 ELSE 0 END) AS nb_high_sugars,
    ROUND(
        SUM(CASE WHEN f.sugars_100g > 80 THEN 1 ELSE 0 END)::numeric
        / NULLIF(COUNT(*)::numeric, 0) * 100, 4
    ) AS pct_high_sugars,

    -- produits avec sel très élevé
    SUM(CASE WHEN f.salt_100g > 25 THEN 1 ELSE 0 END)   AS nb_high_salt,
    ROUND(
        SUM(CASE WHEN f.salt_100g > 25 THEN 1 ELSE 0 END)::numeric
        / NULLIF(COUNT(*)::numeric, 0) * 100, 4
    ) AS pct_high_salt
FROM off_dm.fact_nutrition_snapshot f;



/* ===========================================================
   KPI 3 (complément) - Incohérences d’unités (ex sel / sodium)
=========================================================== */
SELECT
    COUNT(*) AS total_produits,
    SUM(
        CASE
            WHEN f.sodium_100g IS NOT NULL
             AND f.salt_100g   IS NOT NULL
             AND f.salt_100g   > f.sodium_100g * 3
            THEN 1 ELSE 0
        END
    ) AS nb_incoherences_sel_sodium,
    ROUND(
        SUM(
            CASE
                WHEN f.sodium_100g IS NOT NULL
                 AND f.salt_100g   IS NOT NULL
                 AND f.salt_100g   > f.sodium_100g * 3
                THEN 1 ELSE 0
            END
        )::numeric / NULLIF(COUNT(*)::numeric, 0) * 100,
        4
    ) AS pct_incoherences_sel_sodium
FROM off_dm.fact_nutrition_snapshot f;



/* ===========================================================
   KPI 4 - Classement des marques par "qualité nutritionnelle moyenne"
   (moyenne de sugars_100g et salt_100g)
=========================================================== */
SELECT
    b.brand_name AS marque,
    ROUND(AVG(f.sugars_100g)::numeric, 2) AS avg_sugars_100g,
    ROUND(AVG(f.salt_100g)::numeric, 2) AS avg_salt_100g,
    COUNT(*) AS nb_produits
FROM off_dm.fact_nutrition_snapshot f
JOIN off_dm.dim_product p
    ON f.product_sk = p.product_sk
JOIN off_dm.dim_brand b
    ON p.brand_sk = b.brand_sk
WHERE p.is_current = TRUE
  AND f.sugars_100g IS NOT NULL
  AND f.salt_100g   IS NOT NULL
GROUP BY b.brand_name
HAVING COUNT(*) >= 10
ORDER BY
    avg_sugars_100g ASC,
    avg_salt_100g   ASC;



/* ===========================================================
   KPI 4 (variante) - Classement par médiane (PostgreSQL)
=========================================================== */
SELECT
    b.brand_name AS marque,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f.sugars_100g)
        AS median_sugars_100g,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f.salt_100g)
        AS median_salt_100g,
    COUNT(*) AS nb_produits
FROM off_dm.fact_nutrition_snapshot f
JOIN off_dm.dim_product p
    ON f.product_sk = p.product_sk
JOIN off_dm.dim_brand b
    ON p.brand_sk = b.brand_sk
WHERE p.is_current = TRUE
  AND f.sugars_100g IS NOT NULL
  AND f.salt_100g   IS NOT NULL
GROUP BY b.brand_name
HAVING COUNT(*) >= 10
ORDER BY
    median_sugars_100g ASC,
    median_salt_100g   ASC;
