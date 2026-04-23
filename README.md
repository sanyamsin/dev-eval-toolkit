# dev-eval-toolkit 📊

> Boîte à outils pour l'évaluation d'impact des projets et programmes de développement

## 📄 Rapport d'évaluation

[![PDF](https://img.shields.io/badge/Rapport-PDF-red)](reports/evaluation_report.pdf)
[![HTML](https://img.shields.io/badge/Rapport-HTML-blue)](reports/evaluation_report.html)

**[→ Télécharger le rapport PDF complet](reports/evaluation_report.pdf)**

Le rapport couvre :
- **1 000 bénéficiaires** simulés - programme formation professionnelle Niger
- **Propensity Score Matching (PSM)** - effet causal de la formation
- **Difference-in-Differences (DiD)** - robustesse des résultats
- **Résultats clés** : +18 pts d'emploi, +25 000 FCFA de revenu mensuel

> Rapport reproductible généré avec RMarkdown — méthodes OCDE/CAD standard.

Développé par **Serge-Alain NYAMSIN** - Expert Évaluation & Data Science  
🔗 [github.com/sanyamsin](https://github.com/sanyamsin)

---

## 🎯 Objectif

Ce projet simule une évaluation d'impact complète d'un programme de
**formation professionnelle et insertion à l'emploi des jeunes au Niger**,
dans le cadre des secteurs d'intervention de la coopération au développement
(Éducation, formation et emploi).

Il démontre l'application des méthodes quantitatives d'évaluation
standards (OCDE/CAD) combinées aux outils modernes de data science.

---

## 🗂️ Structure du projet

    dev-eval-toolkit/
    ├── data/
    │   └── programme_data.csv        # Données simulées (1000 bénéficiaires)
    ├── R/
    │   ├── 01_data_simulation.R      # Simulation des données
    │   ├── 02_descriptive_stats.R    # Statistiques descriptives
    │   ├── 03_psm_analysis.R         # Propensity Score Matching
    │   ├── 04_did_analysis.R         # Difference-in-Differences
    │   └── 05_visualizations.R       # Visualisations complémentaires
    ├── reports/
    │   ├── evaluation_report.Rmd     # Rapport RMarkdown
    │   ├── evaluation_report.html    # Rapport HTML généré
    │   ├── graphique_revenu.png      # Évolution du revenu
    │   ├── graphique_emploi.png      # Évolution du taux d'emploi
    │   ├── graphique_did.png         # Graphique DiD
    │   └── love_plot_psm.png         # Équilibre PSM
    └── sql/
        └── indicators_queries.sql    # Requêtes SQL suivi indicateurs
---

## 🔬 Méthodes d'évaluation

### 1. Propensity Score Matching (PSM)
Appariement des bénéficiaires avec des non-bénéficiaires similaires
sur la base de leurs caractéristiques socio-démographiques baseline.
Permet d'estimer l'effet moyen du traitement sur les traités (ATT).

### 2. Difference-in-Differences (DiD)
Comparaison de l'évolution des indicateurs entre groupe traitement
et groupe contrôle sur deux périodes (baseline 2022 / endline 2024).
Contrôle les biais liés aux facteurs non observables fixes dans le temps.

---

## 📈 Résultats clés

| Indicateur | Effet PSM | Effet DiD |
|------------|-----------|-----------|
| Taux d'emploi | +18 pts % | +17 pts % |
| Revenu mensuel | +25 000 FCFA | +24 500 FCFA |
| Score compétences | +20 pts | +19 pts |

> Les deux méthodes convergent — les résultats sont robustes.

---

## 🛠️ Technologies utilisées

- **R 4.5.3** — Analyse statistique et visualisation
- **Packages** : tidyverse, MatchIt, cobalt, did, ggplot2, rmarkdown
- **SQL / PostgreSQL** — Suivi des indicateurs
- **RMarkdown** — Rapport reproductible

---

## 🚀 Reproduire l'analyse

```r
# 1. Cloner le repo
git clone https://github.com/sanyamsin/dev-eval-toolkit.git

# 2. Installer les packages
install.packages(c("tidyverse", "MatchIt", "cobalt",
                   "did", "stargazer", "knitr",
                   "rmarkdown", "kableExtra"))

# 3. Exécuter les scripts dans l'ordre
source("R/01_data_simulation.R")
source("R/02_descriptive_stats.R")
source("R/03_psm_analysis.R")
source("R/04_did_analysis.R")

# 4. Générer le rapport
rmarkdown::render("reports/evaluation_report.Rmd")
```

---

## 👤 Auteur

**Serge-Alain NYAMSIN**  
MSc Data Science & AI — DSTI Paris  
12+ ans en coopération au développement (Sahel, Afrique centrale)  
🔗 [github.com/sanyamsin](https://github.com/sanyamsin)

---

*Ce projet s'inscrit dans une démarche de modernisation des systèmes
d'évaluation dans la coopération au développement — combinant rigueur
méthodologique et outils data science.*