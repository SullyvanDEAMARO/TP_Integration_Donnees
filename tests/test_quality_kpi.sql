-- Complétude moyenne doit être > 0 et < 1
SELECT
    AVG(completeness_score) AS avg_completeness,
    MIN(completeness_score) AS min_completeness,
    MAX(completeness_score) AS max_completeness
FROM off_dm.fact_nutrition_snapshot;