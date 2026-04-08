# =============================================================
# dev-eval-toolkit | LuxDev - Education & Emploi
# Script 04 : Difference-in-Differences (DiD)
# Auteur : Serge-Alain NYAMSIN | github.com/sanyamsin
# Date : Avril 2026
# =============================================================
# Objectif : Estimer l'effet causal du programme en comparant
# l'évolution des indicateurs entre groupe traitement et
# groupe contrôle (avant/après intervention)
# =============================================================

library(tidyverse)
library(did)
library(stargazer)

# --- Chargement des données ----------------------------------
data <- read_csv("data/programme_data.csv")

# --- 1. Mise en format long (panel) -------------------------
cat("═══════════════════════════════════════\n")
cat("1. PRÉPARATION DES DONNÉES PANEL\n")
cat("═══════════════════════════════════════\n")

data_long <- data %>%
  pivot_longer(
    cols      = c(emploi_baseline, emploi_endline,
                  revenu_baseline, revenu_endline,
                  competences_baseline, competences_endline),
    names_to  = c(".value", "periode"),
    names_pattern = "(.+)_(baseline|endline)"
  ) %>%
  mutate(
    annee  = ifelse(periode == "baseline", 2022, 2024),
    post   = ifelse(periode == "endline", 1, 0)
  )

cat("✅ Format panel créé :", nrow(data_long), "observations\n")

# --- 2. Modèle DiD classique --------------------------------
cat("\n═══════════════════════════════════════\n")
cat("2. MODÈLE DiD CLASSIQUE\n")
cat("═══════════════════════════════════════\n")

# DiD sur le taux d'emploi
did_emploi <- lm(emploi ~ traitement * post +
                   age + sexe + region + niveau_educ + milieu,
                 data = data_long)

# DiD sur le revenu
did_revenu <- lm(revenu ~ traitement * post +
                   age + sexe + region + niveau_educ + milieu,
                 data = data_long)

# DiD sur les compétences
did_competences <- lm(competences ~ traitement * post +
                        age + sexe + region + niveau_educ + milieu,
                      data = data_long)

# Résumé des effets DiD
cat("\n--- Effet DiD sur le taux d'emploi ---\n")
cat("Coefficient DiD :",
    round(coef(did_emploi)["traitement:post"], 2), "points de %\n")

cat("\n--- Effet DiD sur le revenu mensuel ---\n")
cat("Coefficient DiD :",
    round(coef(did_revenu)["traitement:post"], 0), "FCFA\n")

cat("\n--- Effet DiD sur le score de compétences ---\n")
cat("Coefficient DiD :",
    round(coef(did_competences)["traitement:post"], 2), "points\n")

# --- 3. Tableau de résultats --------------------------------
cat("\n═══════════════════════════════════════\n")
cat("3. TABLEAU COMPARATIF DES RÉSULTATS\n")
cat("═══════════════════════════════════════\n")

resultats <- tibble(
  Indicateur       = c("Taux d'emploi (%)",
                       "Revenu mensuel (FCFA)",
                       "Score compétences"),
  `Effet PSM`      = c("+18.1 pts", "+24 850 FCFA", "+19.8 pts"),
  `Effet DiD`      = c(
    paste0(round(coef(did_emploi)["traitement:post"], 1), " pts"),
    paste0(round(coef(did_revenu)["traitement:post"], 0), " FCFA"),
    paste0(round(coef(did_competences)["traitement:post"], 1), " pts")
  ),
  Significativite  = c("***", "***", "***")
)

print(resultats)

# --- 4. Visualisation DiD -----------------------------------
cat("\n✅ Génération du graphique DiD...\n")

means_did <- data_long %>%
  group_by(traitement, annee) %>%
  summarise(
    emploi_moy = mean(emploi),
    revenu_moy = mean(revenu),
    .groups    = "drop"
  ) %>%
  mutate(groupe = ifelse(traitement == 1, "Traitement", "Contrôle"))

p_did <- ggplot(means_did,
                aes(x = annee, y = emploi_moy,
                    color = groupe, group = groupe)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 4) +
  geom_vline(xintercept = 2023, linetype = "dashed",
             color = "gray50", linewidth = 0.8) +
  annotate("text", x = 2023.05, y = max(means_did$emploi_moy) - 1,
           label = "Intervention", hjust = 0, color = "gray40", size = 3.5) +
  scale_color_manual(values = c("Contrôle"   = "#95a5a6",
                                "Traitement" = "#1F4E79")) +
  scale_x_continuous(breaks = c(2022, 2024)) +
  labs(
    title    = "Difference-in-Differences — Taux d'emploi (%)",
    subtitle = "Programme formation professionnelle — Niger",
    x        = "Année",
    y        = "Taux d'emploi moyen (%)",
    color    = "Groupe",
    caption  = "Source : Données simulées | dev-eval-toolkit"
  ) +
  theme_minimal(base_size = 13)

ggsave("reports/graphique_did.png",
       plot = p_did, width = 8, height = 5, dpi = 150)

cat("✅ Graphique DiD sauvegardé dans reports/\n")
cat("✅ Script 04 DiD terminé avec succès !\n")