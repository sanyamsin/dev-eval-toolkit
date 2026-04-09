-- =============================================================
-- dev-eval-toolkit | LuxDev - Education & Emploi
-- Requ??tes SQL : Suivi des indicateurs de performance
-- Auteur : Serge-Alain NYAMSIN | github.com/sanyamsin
-- Date : Avril 2026
-- =============================================================

-- -------------------------------------------------------------
-- 1. CR??ATION DE LA TABLE PRINCIPALE
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS beneficiaires (
    id                   INTEGER PRIMARY KEY,
    traitement           INTEGER,
    age                  INTEGER,
    sexe                 VARCHAR(10),
    region               VARCHAR(50),
    niveau_educ          VARCHAR(20),
    milieu               VARCHAR(10),
    emploi_baseline      NUMERIC,
    revenu_baseline      NUMERIC,
    competences_baseline NUMERIC,
    emploi_endline       NUMERIC,
    revenu_endline       NUMERIC,
    competences_endline  NUMERIC
);

-- -------------------------------------------------------------
-- 2. INDICATEURS GLOBAUX DU PROGRAMME
-- -------------------------------------------------------------

-- Taux d'insertion global
SELECT
    CASE WHEN traitement = 1 THEN 'Traitement' ELSE 'Contr??le' END AS groupe,
    COUNT(*)                                    AS nb_beneficiaires,
    ROUND(AVG(emploi_baseline), 1)              AS emploi_baseline_moy,
    ROUND(AVG(emploi_endline), 1)               AS emploi_endline_moy,
    ROUND(AVG(emploi_endline - emploi_baseline), 1) AS delta_emploi
FROM beneficiaires
GROUP BY traitement
ORDER BY traitement DESC;

-- -------------------------------------------------------------
-- 3. SUIVI DES INDICATEURS PAR R??GION
-- -------------------------------------------------------------
SELECT
    region,
    COUNT(*)                                        AS nb_total,
    SUM(traitement)                                 AS nb_traitement,
    ROUND(AVG(emploi_endline), 1)                   AS emploi_moy,
    ROUND(AVG(revenu_endline), 0)                   AS revenu_moy,
    ROUND(AVG(competences_endline), 1)              AS competences_moy,
    ROUND(AVG(emploi_endline - emploi_baseline), 1) AS progression_emploi
FROM beneficiaires
GROUP BY region
ORDER BY progression_emploi DESC;

-- -------------------------------------------------------------
-- 4. ANALYSE PAR SEXE ET MILIEU
-- -------------------------------------------------------------
SELECT
    sexe,
    milieu,
    COUNT(*)                                        AS nb_beneficiaires,
    ROUND(AVG(emploi_endline), 1)                   AS emploi_moy,
    ROUND(AVG(revenu_endline), 0)                   AS revenu_moy,
    ROUND(AVG(emploi_endline - emploi_baseline), 1) AS progression_emploi
FROM beneficiaires
WHERE traitement = 1
GROUP BY sexe, milieu
ORDER BY sexe, milieu;

-- -------------------------------------------------------------
-- 5. IDENTIFICATION DES B??N??FICIAIRES ?? RISQUE
-- (progression faible malgr?? le programme)
-- -------------------------------------------------------------
SELECT
    id,
    region,
    sexe,
    milieu,
    niveau_educ,
    ROUND(emploi_baseline, 1)               AS emploi_base,
    ROUND(emploi_endline, 1)                AS emploi_fin,
    ROUND(emploi_endline - emploi_baseline) AS progression
FROM beneficiaires
WHERE traitement = 1
  AND (emploi_endline - emploi_baseline) < 5
ORDER BY progression ASC
LIMIT 20;

-- -------------------------------------------------------------
-- 6. TABLEAU DE BORD SYNTH??TIQUE DU PROGRAMME
-- -------------------------------------------------------------
SELECT
    'Programme Global'                              AS scope,
    COUNT(*)                                        AS nb_total,
    SUM(traitement)                                 AS nb_traites,
    ROUND(AVG(CASE WHEN traitement = 1
              THEN emploi_endline END), 1)          AS emploi_traitement,
    ROUND(AVG(CASE WHEN traitement = 0
              THEN emploi_endline END), 1)          AS emploi_controle,
    ROUND(AVG(CASE WHEN traitement = 1
              THEN emploi_endline END) -
          AVG(CASE WHEN traitement = 0
              THEN emploi_endline END), 1)          AS effet_brut_emploi,
    ROUND(AVG(CASE WHEN traitement = 1
              THEN revenu_endline END) -
          AVG(CASE WHEN traitement = 0
              THEN revenu_endline END), 0)          AS effet_brut_revenu
FROM beneficiaires;

-- -------------------------------------------------------------
-- 7. ALERTE : R??GIONS SOUS-PERFORMANTES
-- -------------------------------------------------------------
SELECT
    region,
    ROUND(AVG(emploi_endline - emploi_baseline), 1) AS progression_moy,
    CASE
        WHEN AVG(emploi_endline - emploi_baseline) < 10
             THEN '?????? Attention requise'
        WHEN AVG(emploi_endline - emploi_baseline) BETWEEN 10 AND 15
             THEN '??? Dans la moyenne'
        ELSE '???? Performant'
    END AS statut
FROM beneficiaires
WHERE traitement = 1
GROUP BY region
ORDER BY progression_moy ASC;