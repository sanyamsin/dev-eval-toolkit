# =============================================================
# dev-eval-toolkit | LuxDev - Education & Emploi
# Script 02 : Statistiques descriptives
# Auteur : Trésor Sany | github.com/sanyamsin
# Date : Avril 2026
# =============================================================

library(tidyverse)
library(knitr)
library(kableExtra)
library(scales)

# --- Chargement des données ----------------------------------
data <- read_csv("data/programme_data.csv")

cat("✅ Données chargées :", nrow(data), "observations\n\n")

# --- 1. Profil des bénéficiaires ----------------------------
cat("═══════════════════════════════════════\n")
cat("1. PROFIL SOCIO-DÉMOGRAPHIQUE\n")
cat("═══════════════════════════════════════\n")

# Répartition par sexe et traitement
data %>%
  group_by(traitement, sexe) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(traitement = ifelse(traitement == 1, "Traitement", "Contrôle")) %>%
  print()

# Répartition par région
cat("\n--- Répartition par région ---\n")
data %>%
  group_by(region) %>%
  summarise(
    n = n(),
    pct = round(n() / nrow(data) * 100, 1)
  ) %>%
  arrange(desc(n)) %>%
  print()

# --- 2. Comparaison Baseline --------------------------------
cat("\n═══════════════════════════════════════\n")
cat("2. COMPARAISON BASELINE (2022)\n")
cat("═══════════════════════════════════════\n")

data %>%
  group_by(traitement) %>%
  summarise(
    n                    = n(),
    age_moyen            = round(mean(age), 1),
    emploi_baseline_moy  = round(mean(emploi_baseline), 1),
    revenu_baseline_moy  = round(mean(revenu_baseline), 0),
    competences_base_moy = round(mean(competences_baseline), 1)
  ) %>%
  mutate(traitement = ifelse(traitement == 1, "Traitement", "Contrôle")) %>%
  print()

# --- 3. Comparaison Endline ---------------------------------
cat("\n═══════════════════════════════════════\n")
cat("3. RÉSULTATS ENDLINE (2024)\n")
cat("═══════════════════════════════════════\n")

data %>%
  group_by(traitement) %>%
  summarise(
    emploi_endline_moy      = round(mean(emploi_endline), 1),
    revenu_endline_moy      = round(mean(revenu_endline), 0),
    competences_endline_moy = round(mean(competences_endline), 1)
  ) %>%
  mutate(traitement = ifelse(traitement == 1, "Traitement", "Contrôle")) %>%
  print()

# --- 4. Évolution des indicateurs ---------------------------
cat("\n═══════════════════════════════════════\n")
cat("4. ÉVOLUTION BASELINE → ENDLINE\n")
cat("═══════════════════════════════════════\n")

data %>%
  group_by(traitement) %>%
  summarise(
    delta_emploi      = round(mean(emploi_endline - emploi_baseline), 1),
    delta_revenu      = round(mean(revenu_endline - revenu_baseline), 0),
    delta_competences = round(mean(competences_endline - competences_baseline), 1)
  ) %>%
  mutate(traitement = ifelse(traitement == 1, "Traitement", "Contrôle")) %>%
  print()

# --- 5. Visualisation ---------------------------------------
cat("\n✅ Génération des graphiques...\n")

# Graphique 1 : Revenu baseline vs endline
p1 <- data %>%
  mutate(traitement = ifelse(traitement == 1, "Traitement", "Contrôle")) %>%
  pivot_longer(cols = c(revenu_baseline, revenu_endline),
               names_to = "periode", values_to = "revenu") %>%
  mutate(periode = ifelse(periode == "revenu_baseline",
                          "Baseline 2022", "Endline 2024")) %>%
  ggplot(aes(x = periode, y = revenu, fill = traitement)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_manual(values = c("Contrôle" = "#95a5a6",
                               "Traitement" = "#1F4E79")) +
  scale_y_continuous(labels = comma) +
  labs(
    title    = "Évolution du revenu mensuel (FCFA)",
    subtitle = "Programme formation professionnelle — Niger",
    x        = "Période",
    y        = "Revenu mensuel (FCFA)",
    fill     = "Groupe",
    caption  = "Source : Données simulées | dev-eval-toolkit"
  ) +
  theme_minimal(base_size = 13)

# Graphique 2 : Taux d'emploi
p2 <- data %>%
  mutate(traitement = ifelse(traitement == 1, "Traitement", "Contrôle")) %>%
  pivot_longer(cols = c(emploi_baseline, emploi_endline),
               names_to = "periode", values_to = "emploi") %>%
  mutate(periode = ifelse(periode == "emploi_baseline",
                          "Baseline 2022", "Endline 2024")) %>%
  ggplot(aes(x = periode, y = emploi, fill = traitement)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_manual(values = c("Contrôle" = "#95a5a6",
                               "Traitement" = "#1F4E79")) +
  labs(
    title    = "Évolution du taux d'emploi (%)",
    subtitle = "Programme formation professionnelle — Niger",
    x        = "Période",
    y        = "Taux d'emploi (%)",
    fill     = "Groupe",
    caption  = "Source : Données simulées | dev-eval-toolkit"
  ) +
  theme_minimal(base_size = 13)

# Sauvegarde des graphiques
ggsave("reports/graphique_revenu.png",    plot = p1, width = 8, height = 5, dpi = 150)
ggsave("reports/graphique_emploi.png",    plot = p2, width = 8, height = 5, dpi = 150)

cat("✅ Graphiques sauvegardés dans reports/\n")
cat("✅ Script 02 terminé avec succès !\n")