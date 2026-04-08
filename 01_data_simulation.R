# =============================================================
# dev-eval-toolkit | LuxDev - Education & Emploi
# Script 01 : Simulation des données
# Auteur : Serge-Alain | github.com/sanyamsin
# Date : Avril 2026
# =============================================================
# Contexte : Évaluation d'impact d'un programme de formation
# professionnelle et insertion à l'emploi des jeunes au Niger
# Bénéficiaires : 1000 jeunes (500 traitement, 500 contrôle)
# Période : Baseline 2022 → Endline 2024
# =============================================================

library(tidyverse)

set.seed(42)  # Reproductibilité

n <- 1000  # Nombre total de jeunes

# --- Variables socio-démographiques --------------------------
data <- tibble(
  id          = 1:n,
  traitement  = c(rep(1, 500), rep(0, 500)),
  age         = round(rnorm(n, mean = 22, sd = 3)),
  sexe        = sample(c("Homme", "Femme"), n, replace = TRUE,
                       prob = c(0.55, 0.45)),
  region      = sample(c("Niamey", "Zinder", "Maradi", "Tahoua"),
                       n, replace = TRUE),
  niveau_educ = sample(c("Primaire", "Secondaire", "Technique"),
                       n, replace = TRUE, prob = c(0.3, 0.5, 0.2)),
  milieu      = sample(c("Urbain", "Rural"), n, replace = TRUE,
                       prob = c(0.6, 0.4))
)

# --- Indicateurs Baseline 2022 -------------------------------
data <- data %>%
  mutate(
    # Taux d'emploi baseline (%)
    emploi_baseline = round(rnorm(n, mean = 25, sd = 8)),
    
    # Revenu mensuel baseline (FCFA)
    revenu_baseline = round(rnorm(n, mean = 45000, sd = 12000)),
    
    # Score de compétences baseline (0-100)
    competences_baseline = round(rnorm(n, mean = 40, sd = 10))
  )

# --- Indicateurs Endline 2024 --------------------------------
# Le programme augmente : emploi +18pts, revenu +25000, compétences +20pts
data <- data %>%
  mutate(
    emploi_endline = round(emploi_baseline +
                             ifelse(traitement == 1,
                                    rnorm(n, mean = 18, sd = 5),
                                    rnorm(n, mean = 3,  sd = 5))),
    
    revenu_endline = round(revenu_baseline +
                             ifelse(traitement == 1,
                                    rnorm(n, mean = 25000, sd = 8000),
                                    rnorm(n, mean = 3000,  sd = 8000))),
    
    competences_endline = round(competences_baseline +
                                  ifelse(traitement == 1,
                                         rnorm(n, mean = 20, sd = 6),
                                         rnorm(n, mean = 4,  sd = 6)))
  )

# --- Sauvegarde ----------------------------------------------
write_csv(data, "data/programme_data.csv")

cat("✅ Données simulées avec succès !\n")
cat("📊 Dimensions :", nrow(data), "observations x", ncol(data), "variables\n")
cat("👥 Traitement :", sum(data$traitement), "| Contrôle :",
    sum(data$traitement == 0), "\n")