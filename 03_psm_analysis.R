# =============================================================
# dev-eval-toolkit | LuxDev - Education & Emploi
# Script 03 : Propensity Score Matching (PSM)
# Auteur : Serge-Alain NYAMSIN | github.com/sanyamsin
# Date : Avril 2026
# =============================================================
# Objectif : Estimer l'effet causal du programme de formation
# en appariant les bénéficiaires à des non-bénéficiaires
# similaires sur la base de leurs caractéristiques baseline
# =============================================================

library(tidyverse)
library(MatchIt)
library(cobalt)

# --- Chargement des données ----------------------------------
data <- read_csv("data/programme_data.csv")

cat("═══════════════════════════════════════\n")
cat("1. PROPENSITY SCORE MATCHING\n")
cat("═══════════════════════════════════════\n")

# --- 1. Modèle de matching ----------------------------------
# On apparie sur les caractéristiques baseline
match_out <- matchit(
  traitement ~ age + sexe + region + niveau_educ +
    milieu + emploi_baseline + revenu_baseline +
    competences_baseline,
  data   = data,
  method = "nearest",  # Plus proche voisin
  ratio  = 1           # 1 contrôle pour 1 traitement
)

cat("\n--- Résumé du matching ---\n")
print(summary(match_out, un = FALSE))

# --- 2. Qualité du matching ---------------------------------
cat("\n--- Vérification de l'équilibre ---\n")
bal <- bal.tab(match_out, thresholds = c(m = 0.1))
print(bal)

# --- 3. Données appariées -----------------------------------
data_matched <- match.data(match_out)

cat("\n--- Dimensions après matching ---\n")
cat("Observations appariées :", nrow(data_matched), "\n")
cat("Traitement :", sum(data_matched$traitement), 
    "| Contrôle :", sum(data_matched$traitement == 0), "\n")

# --- 4. Estimation de l'effet (ATT) -------------------------
cat("\n═══════════════════════════════════════\n")
cat("2. ESTIMATION DE L'EFFET DU PROGRAMME\n")
cat("═══════════════════════════════════════\n")

# Effet sur l'emploi
att_emploi <- lm(emploi_endline ~ traitement + age + sexe +
                   region + niveau_educ + milieu +
                   emploi_baseline,
                 data    = data_matched,
                 weights = weights)

# Effet sur le revenu
att_revenu <- lm(revenu_endline ~ traitement + age + sexe +
                   region + niveau_educ + milieu +
                   revenu_baseline,
                 data    = data_matched,
                 weights = weights)

# Effet sur les compétences
att_competences <- lm(competences_endline ~ traitement + age + sexe +
                        region + niveau_educ + milieu +
                        competences_baseline,
                      data    = data_matched,
                      weights = weights)

# Résumé des effets
cat("\n--- Effet sur le taux d'emploi (%) ---\n")
cat("ATT :", round(coef(att_emploi)["traitement"], 2), "points de %\n")

cat("\n--- Effet sur le revenu mensuel (FCFA) ---\n")
cat("ATT :", round(coef(att_revenu)["traitement"], 0), "FCFA\n")

cat("\n--- Effet sur le score de compétences ---\n")
cat("ATT :", round(coef(att_competences)["traitement"], 2), "points\n")

# --- 5. Visualisation Love Plot -----------------------------
cat("\n✅ Génération du Love Plot...\n")

png("reports/love_plot_psm.png", width = 800, height = 500, res = 120)
love.plot(match_out,
          thresholds = c(m = 0.1),
          colors     = c("#e74c3c", "#1F4E79"),
          shapes     = c("circle", "square"),
          title      = "Équilibre des covariables — PSM\nProgramme Formation Professionnelle Niger")
dev.off()

cat("✅ Love Plot sauvegardé dans reports/\n")
cat("✅ Script 03 PSM terminé avec succès !\n")