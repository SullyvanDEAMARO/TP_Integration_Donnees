# TP Atelier Intégration des Données – Nutrition & Qualité (OpenFoodFacts)

Ce projet met en place un pipeline ETL Spark sur les données OpenFoodFacts afin d'alimenter un datamart analytique `off_dm` (modèle étoile) dans PostgreSQL.  
L'objectif est de mesurer la **qualité des données nutritionnelles** et de produire plusieurs KPI métier (Nutri-Score, complétude, anomalies, etc.).

---

## 1. Structure du dépôt

.  
├── docs/  
│   ├── Rapport_TP_Nutrition&Qualité_DE-AMARO_YAZAN.docx  
│   ├── README.md  
│   └── requirements.txt  
├── etl/  
│   └── nutrition_qualite_etl.ipynb  
├── sql/  
│   ├── base_dd.sql  
│   ├── Perimetre_fonctionnel.sql  
│   └── Requetes_analytiques.sql  
├── tests/  
│   ├── test_counts.sql  
│   ├── test_foreign_keys.sql  
│   └── test_quality_kpi.sql  
├── logs/  
│   ├── metrics_20260120_133055.json  
│   └── ...  
└── conf/  
    ├── db_postgres.ini  
    └── postgresql-42.7.8.jar  

---

## 2. Prérequis

- Python 3.x  
- Java + Spark (utilisé via PySpark)  
- PostgreSQL avec une base par exemple nommée `TpOFF`

---

## 3. Configuration

Les paramètres de connexion et chemins peuvent être définis dans `conf/db_postgres.example.env` (à copier en `.env`) ou dans un fichier `.ini`.

Exemple `.env` :

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=TpOFF
DB_SCHEMA=off_dm
DB_USER=postgres
DB_PASSWORD=root

SPARK_APP_NAME=OFF_ETL
SPARK_MASTER=local[*]

CSV_PATH=./data/300k_off.csv
LOGS_DIR=./logs
```

Adapter ces valeurs selon votre environnement (mot de passe, ports, chemins…).

---

## 4. Initialisation de la base

Créer le schéma et les tables du datamart dans PostgreSQL à partir du script DDL :


Cela crée notamment :

- `off_dm.dim_brand`, `off_dm.dim_country`, `off_dm.dim_category`, `off_dm.dim_time`, `off_dm.dim_product`  
- `off_dm.fact_nutrition_snapshot`

---

## 5. Exécution du pipeline ETL Spark

Le pipeline principal est dans `etl/nutrition_qualite_etl.py`. Il enchaîne :

1. Lecture du CSV brut (`data/300k_off.csv`) en niveau **Bronze**.  
2. Nettoyages, filtrages, règles de qualité (bornes, cohérence sel/sodium, complétude, anomalies) → **Silver**.  
3. Construction des dimensions et de la fact (modèle étoile) → **Gold / datamart off_dm**.  
4. Écriture dans PostgreSQL + export d'un fichier de métriques de qualité au format JSON dans `logs/`.

---

## 6. Tests (dossier `/tests`)

Quelques tests SQL permettent de vérifier que le datamart est cohérent et correctement alimenté.

- `tests/test_counts.sql`  
  Vérifie que les tables principales contiennent des lignes (`dim_*`, `fact_nutrition_snapshot`).

- `tests/test_foreign_keys.sql`  
  Vérifie l'intégrité référentielle logique :  
  - aucun produit sans marque/pays/catégorie,  
  - aucune fact sans produit ni temps.  

- `tests/test_quality_kpi.sql`  
  Vérifie que `completeness_score` est renseigné avec des valeurs comprises entre 0 et 1 (moyenne, min, max).

---

## 7. Requêtes analytiques & KPI

Les requêtes associées au périmètre fonctionnel et aux questions métier se trouvent dans :

- `sql/Perimetre_fonctionnel.sql` :  
  - répartition Nutri-Score par catégorie/marque/pays,  
  - évolution de la complétude,  
  - taux d'anomalies,  
  - classement des marques par qualité nutritionnelle, etc.

- `sql/Requetes_analytiques.sql` :  
  - top marques Nutri-Score A/B,  
  - heatmap pays × catégorie,  
  - taux de complétude par marque,  
  - liste détaillée des anomalies nutriments, etc.

Ces requêtes sont utilisées dans le rapport pour illustrer les KPI et l'analyse métier.

---

## 8. Note d'architecture

Une note d'architecture plus détaillée est fournie dans `docs/` (schéma Bronze/Silver/Gold, modèle du datamart...).

---

## 9. Auteur

- Étudiant : **DE AMARO & YAZAN**  
- Sujet : *Atelier Intégration des Données – Nutrition & Qualité (OpenFoodFacts)*
