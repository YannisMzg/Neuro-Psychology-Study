# 0. Librairies
library(tidyverse)

# 1. Chemin vers votre dossier de CSV
csv_dir <- "~/Experience_Psy/data definitf 2"

# 2. Lister tous les fichiers CSV “_Emotion…csv” et filtrer ceux qui sont vides
files <- list.files(
  path       = csv_dir,
  pattern    = "_Emotion.*\\.csv$",
  full.names = TRUE
)

# retirer les fichiers de taille 0
file_sizes <- file.info(files)$size
files <- files[file_sizes > 0]

# 3. La fonction de traitement inchangée
process_data <- function(fp) {
  pid <- str_extract(basename(fp), "\\d+(?=_Emotion)")
  df2  <- read.csv(fp, header = TRUE, stringsAsFactors = FALSE)
  
  # si moins de 45 lignes, on skip
  if (nrow(df2) < 45) {
    stop("Moins de 45 lignes dans le fichier")
  }
  
  df2 <- df2[1:42, ]
  
  df2 %>%
    mutate(
      participant   = pid,
      condition     = case_when(
        grepl("FIX", ImageFile, ignore.case = TRUE)     ~ "Fixed",
        grepl("animees", ImageFile, ignore.case = TRUE) ~ "Animated",
        TRUE                                                         ~ NA_character_
      )
    ) %>%
    filter(!is.na(condition))
}

# 4. Appliquer à chaque fichier en capturant les erreurs
df2_list <- map(files, function(fp) {
  tryCatch(
    process_data(fp),
    error = function(e) {
      warning(sprintf(
        "→ Fichier '%s' ignoré : %s",
        basename(fp), e$message
      ))
      return(NULL)
    }
  )
})

# 5. Empiler les data‐frames valides
df2_all <- bind_rows(df2_list)


### extraire le fichier 
write.csv(df2_all,"df2_all.csv")

# 2. Préparer les facteurs
df2 <- df2_all %>%
  mutate(
    Animation = factor(condition, levels = c("Fixed", "Animated"),
                       labels = c("Static", "Animated")),
    Valence   = factor(ifelse(str_detect(ImageFile, regex("NEGA", ignore_case = TRUE)),
                              "Negative", "Neutral"))
  )

# 3. Vérifier la structure des données
table(df2$Animation, df2$Valence)


library(readxl)
# supposons que participants soit déjà lu depuis votre Excel
participants <- read_excel("~/Downloads/TABLEAU-PARTICIPANTS 3.xlsx")

df2_full <- df2 %>%
  left_join(participants, by = "participant")


library(lme4)
library(car)

# éveil émotionnel
m_eveil <- lmer(EVEIL.response ~ Animation*Valence 
                + Anxiete1 + Anxiete2 + depression
                + (1|participant),
                data = df2_full)
Anova(m_eveil, type="III")

# plaisir ressenti
m_plaisir <- lmer(Plaisir.response ~ Animation*Valence 
                  + Anxiete1 + Anxiete2 + depression
                  + (1|participant),
                  data = df2_full)
a <- Anova(m_plaisir, type="III")


library(readxl)
library(dplyr)
library(ggplot2)
library(scales)

library(readxl)
library(dplyr)
library(ggplot2)
library(scales)

# 1. Charger et préparer BECK
df <- read_excel("~/Downloads/TABLEAU-PARTICIPANTS 3.xlsx") %>%
  transmute(Score = as.numeric(depression))

# 2. Seuils normatifs BECK
thresholds_dep <- tibble::tribble(
  ~thresh, ~label,
  0,   "0–4 : En dessous de la norme",
  5,   "5–9 : Normal",
  10,   "10–18 : Faible–modéré",
  19,   "19–29 : Modéré–sévère",
  30,   "30–63 : Sévère"
)

# 3. Tracé avec labels de pourcentage
ggplot(df, aes(x = Score)) +
  # Histogramme en %
  geom_histogram(
    aes(y = after_stat(count / sum(count))),
    binwidth = 5,
    boundary = 0,
    fill     = "#228B22",
    color    = "white",
    alpha    = 0.7,
    position = "identity"
  ) +
  # Labels de pourcentage au-dessus
  geom_text(
    stat     = "bin",
    aes(
      y     = after_stat(count / sum(count)),
      # on arrondit à 1 décimale *avant* le sprintf 
    label = ifelse(
        after_stat(count) > 0,
        sprintf("%.1f%%", round(after_stat(count / sum(count) * 100), 1)),
        ""
      )
    ),
    binwidth  = 5,
    boundary  = 0,
    vjust     = -0.3,
    size      = 4,
    color     = "black",
    position  = "identity"
  ) +
  # Seuils normatifs BECK
  geom_vline(
    data      = thresholds_dep,
    aes(xintercept = thresh),
    linetype  = "dashed",
    color     = "purple"
  ) +
  geom_text(
    data      = thresholds_dep,
    aes(x = thresh, y = 0, label = label),
    angle     = 90,
    vjust     = -0.3,
    nudge_x   = 1.9,
    nudge_y   = 0.75,
    color     = "purple",
    size      = 5
  ) +
  scale_x_continuous(
    breaks = seq(0, 63, by = 5),
    limits = c(0, 63)
  ) +
  scale_y_continuous(
    labels = percent_format(accuracy = 1),
    breaks = seq(0, 1, by = 0.2),
    limits = c(0, 1),
    expand = c(0, 0)
  ) +
  labs(
    title    = "Distribution des scores du questionnaire de dépression BECK",
    subtitle = "Echelle BDI-13 de BECK",
    x        = "Score total (BECK)",
    y        = "Pourcentage de participants"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title     = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle  = element_text(hjust = 0.5)
  )



###### BECK TEST 

library(readxl)
library(dplyr)
library(ggplot2)
library(scales)

# 1. Charger et préparer BECK + créer les bins alignés sur 0–5,5–10 …
df_bins <- read_excel("~/Downloads/TABLEAU-PARTICIPANTS 3.xlsx") %>%
  transmute(Score = as.numeric(depression)) %>%
  mutate(bin = cut(Score,
                   breaks = seq(0, 65, by = 5),
                   right  = FALSE,
                   include.lowest = TRUE)) %>%
  count(bin) %>%
  mutate(
    pct_raw    = n / sum(n) * 100,
    pct_round  = round(pct_raw, 1)
  )

# 2. Ajuster le dernier bin pour que la somme soit 100.0 %
total_diff <- 100 - sum(df_bins$pct_round)
# on ajoute cet écart au dernier niveau de bin
df_bins$pct_round[nrow(df_bins)] <- df_bins$pct_round[nrow(df_bins)] + total_diff

# 3. Calculer le centre des bins pour l’axe X
df_bins <- df_bins %>%
  mutate(
    bin_start = as.numeric(sub("\\[(\\d+),.*", "\\1", bin)),
    bin_mid   = bin_start + 2.5
  )

# 4. Seuils normatifs BECK
thresholds_dep <- tibble::tribble(
  ~thresh, ~label,
  0,   "0–4 : En dessous de la norme",
  5,   "5–9 : Normal",
  10,  "10–18 : Faible–modéré",
  19,  "19–29 : Modéré–sévère",
  30,  "30–63 : Sévère"
)

# 5. Tracé final
ggplot(df_bins, aes(x = bin_mid, y = pct_round / 100)) +
  geom_col(
    width = 5,
    fill  = "#228B22",
    color = "white",
    alpha = 0.7
  ) +
  geom_text(
    aes(label = sprintf("%.1f%%", pct_round)),
    vjust = -0.3,
    size  = 4
  ) +
  # seuils normatifs
  geom_vline(
    data      = thresholds_dep,
    aes(xintercept = thresh),
    linetype  = "dashed",
    color     = "purple"
  ) +
  geom_text(
    data    = thresholds_dep,
    aes(x = thresh, y = 0, label = label),
    angle   = 90,
    vjust   = -0.3,
    nudge_x = 1.9,
    nudge_y = 0.8,
    color   = "purple",
    size    = 5
  ) +
  scale_x_continuous(
    breaks = seq(0, 63, by = 5),
    limits = c(0, 63)
  ) +
  scale_y_continuous(
    labels = percent_format(accuracy = 1),
    breaks = seq(0, 1, by = 0.2),
    limits = c(0, 1),
    expand = c(0, 0.02)
  ) +
  labs(
    title    = "Distribution des scores du questionnaire de dépression BECK",
    subtitle = "Échelle BDI-13 de BECK",
    x        = "Score total (BECK)",
    y        = "Pourcentage de participants"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title    = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5),
    axis.text.x   = element_text(angle = 45, hjust = 1)
  )


  library(readxl)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(scales)
  
  # 1. Charger et préparer les données
  df_bins <- read_excel("~/Downloads/TABLEAU-PARTICIPANTS 3.xlsx") %>%
    select(Anxiete1, Anxiete2) %>%
    rename(
      `STAI État`  = Anxiete1,
      `STAI Trait` = Anxiete2
    ) %>%
    pivot_longer(c(`STAI État`, `STAI Trait`),
                 names_to = "Measure",
                 values_to = "Score") %>%
    mutate(Score = as.numeric(Score),
           # définir directement le bin de 5 en 5
           bin_start = floor(Score / 5) * 5,
           bin_mid   = bin_start + 2.5  # centre de l'intervalle
    ) %>%
    group_by(Measure, bin_start, bin_mid) %>%
    summarise(count = n(), .groups = "drop") %>%
    group_by(Measure) %>%
    mutate(pct = count / sum(count)) %>%
    ungroup()
  
  # 2. Seuils normatifs STAI
  thresholds_stai <- tibble::tribble(
    ~Measure,      ~thresh, ~label,
    "STAI État",     0,     "Très faible (<36)",
    "STAI État",     36,     "Faible (36–45)",
    "STAI État",     46,     "Moyen (46–55)",
    "STAI État",     56,     "Élevé (56–65)",
    "STAI Trait",    0,     "Très faible (<36)",
    "STAI Trait",    36,     "Faible (36–45)",
    "STAI Trait",    46,     "Moyen (46–55)",
    "STAI Trait",    56,     "Élevé (56–65)"
  )
  
  # 3. Tracé avec échelle continue
  ggplot(df_bins, aes(x = bin_mid, y = pct, fill = Measure)) +
    geom_col(color="white", alpha=0.8, width = 5, position="identity") +
    # labels avec 1 décimale
    geom_text(aes(label = sprintf("%.1f%%", pct*100)),
              vjust = -0.3, size = 3) +
    # seuils normatifs
    geom_vline(data = thresholds_stai,
               aes(xintercept = thresh),
               linetype="dashed", color="black") +
    geom_text(data = thresholds_stai,
              aes(x = thresh, y = 0, label = label),
              angle=90, vjust=-0.3, nudge_x=2, nudge_y=0.8, size=3) +
    facet_wrap(~ Measure, ncol=1, scales="fixed") +
    scale_x_continuous(
      breaks = seq(0, 80, by = 5),
      limits = c(0, 80)
    ) +
    scale_y_continuous(
      labels = percent_format(accuracy = 0.1),
      limits = c(0, 1),
      expand = c(0, 0.02)
    ) +
    scale_fill_manual(values = c("STAI État"="#1f77b4","STAI Trait"="#d62728")) +
    labs(
      title    = "Distribution des scores du questionnaire STAI",
      subtitle = "STAI : State-Trait Anixety",
      x        = "Score T (STAI)",
      y        = "Pourcentage de participants",
      fill     = ""
    ) +
    theme_minimal(base_size=14) +
    theme(
      plot.title      = element_text(hjust=0.5, face="bold"),
      plot.subtitle   = element_text(hjust=0.5),
      legend.position = "none",
      strip.text      = element_text(face="bold")
    )

  
  ##### TEST STAI 
  library(readxl)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(scales)
  
  # 1. Niveaux d’ordre explicite
  palier_levels <- c(
    "<36   Très faible",
    "36-45 Faible",
    "46-55 Moyen",
    "56-65 Élevé",
    ">65   Très élevé"
  )
  
  # 2. Charger + long + créer Palier
  df_norm <- read_excel("~/Downloads/TABLEAU-PARTICIPANTS 3.xlsx") %>%
    select(Anxiete1, Anxiete2) %>%
    rename(
      `STAI État`  = Anxiete1,
      `STAI Trait` = Anxiete2
    ) %>%
    pivot_longer(c(`STAI État`, `STAI Trait`),
                 names_to  = "Measure",
                 values_to = "Score") %>%
    mutate(
      Score = as.numeric(Score),
      Palier = cut(
        Score,
        breaks = c(-Inf, 36, 46, 56, 66, Inf),
        labels = palier_levels,
        right  = FALSE
      )
    )
  
  # 3. Compter et compléter pour voir tous les palier
  df_bins <- df_norm %>%
    group_by(Measure, Palier) %>%
    summarise(n = n(), .groups="drop") %>%
    complete(
      Measure,
      Palier = palier_levels,
      fill = list(n = 0)
    ) %>%
    group_by(Measure) %>%
    mutate(pct = n / sum(n)) %>%
    ungroup() %>%
    mutate(
      # on redéfinit le facteur ici, pour s'assurer de l'ordre
      Palier = factor(Palier, levels = palier_levels)
    )
  
  # 4. Tracé final
  ggplot(df_bins, aes(x = Palier, y = pct, fill = Palier)) +
    geom_col(color = "white", alpha = 0.8) +
    geom_text(aes(label = ifelse(n>0, sprintf("%.1f%%", pct*100), "")),
              vjust = -0.3, size = 3) +
    facet_wrap(~ Measure, ncol = 1, scales = "fixed") +
    scale_x_discrete(drop = FALSE, limits = palier_levels) +  # <— impose l’ordre
    scale_y_continuous(labels = percent_format(accuracy = 0.1),
                       limits = c(0, 1), expand = c(0, 0.02)) +
    scale_fill_brewer(palette = "Spectral", direction = -1) +
    labs(
      title    = "Distribution des scores STAI par palier normatif",
      subtitle = "STAI : State vs Trait Anxiety",
      x        = "Palier normatif (Score T)",
      y        = "Pourcentage de participants",
      fill     = "Palier"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title      = element_text(hjust = 0.5, face = "bold"),
      plot.subtitle   = element_text(hjust = 0.5),
      axis.text.x     = element_text(angle = 45, hjust = 1),
      legend.position = "none"
    )
  
  
  ##### TEST BECK 
  
  library(readxl)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(scales)
  
  # 1. Définir les paliers BECK dans l'ordre voulu
  palier_beck <- c(
    "<4   En dessous de la norme",
    "5-9  Normal",
    "10-18 Faible–modéré",
    "19-29 Modéré–sévère",
    ">=30 Sévère"
  )
  
  # 2. Charger + créer le facteur Palier dépression
  df_beck <- read_excel("~/Downloads/TABLEAU-PARTICIPANTS 3.xlsx") %>%
    transmute(Score = as.numeric(depression)) %>%
    mutate(
      Palier = cut(
        Score,
        # on passe de 5 au lieu de 4 pour inclure le score 4 dans le premier bin
        breaks = c(-Inf, 5, 10, 19, 30, Inf),
        labels = palier_beck,
        right  = FALSE
      )
    )
  
  # 3. Calculer n et pct, et forcer la présence de tous les paliers
  df_beck_bins <- df_beck %>%
    count(Palier) %>%
    complete(
      Palier = palier_beck,
      fill   = list(n = 0)
    ) %>%
    mutate(
      pct = n / sum(n),
      Palier = factor(Palier, levels = palier_beck)
    )
  
  # 4. Tracé
  ggplot(df_beck_bins, aes(x = Palier, y = pct, fill = Palier)) +
    geom_col(color = "white", alpha = 0.8) +
    geom_text(aes(
      label = ifelse(
        n > 0,
        sprintf(
          "%.1f%%",
          # on multiplie par 1000, on floor, puis on divise par 10 => 1 décimale tronquée
          floor(pct * 1000) / 10
        ),
        ""
      )
    ),
    vjust = -0.3, size = 3
    ) +
    scale_y_continuous(
      labels = percent_format(accuracy = 0.1),
      limits = c(0, 1),
      expand = c(0, 0.02)
    ) +
    scale_fill_brewer(palette = "Spectral", direction = -1) +
    labs(
      title    = "Distribution des scores BECK Dépression par palier normatif",
      subtitle = "Échelle BDI-13",
      x        = "Palier BECK (Score total)",
      y        = "Pourcentage de participants",
      fill     = "Palier"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title     = element_text(hjust = 0.5, face = "bold"),
      plot.subtitle  = element_text(hjust = 0.5),
      axis.text.x    = element_text(angle = 45, hjust = 1),
      legend.position = "none"
    )