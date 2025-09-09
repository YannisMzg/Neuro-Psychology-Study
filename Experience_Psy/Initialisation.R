library(tidyverse)  # inclut dplyr, purrr, stringr…

# 1. Spécifier le chemin vers le dossier "data definitif 2"
csv_dir <- "~/Experience_Psy/data definitf 2"
# 1. Lister tous les CSV “participant_Emotion…” du dossier courant
files <- list.files(
  path       = csv_dir,                          # ou le chemin vers votre dossier
  pattern    = "_Emotion.*\\.csv$",          # nom contenant “_Emotion” et fin “.csv”
  full.names = TRUE
)

# 2. Fonction de traitement d’un fichier unique
process_data <- function(fp) {
  # extraire les chiffres avant "_Emotion"
  pid <- str_extract(basename(fp), "\\d+(?=_Emotion)")
  
  # lire et ne garder que les lignes 45 à la fin
  df <- read.csv(fp, header = TRUE, stringsAsFactors = FALSE)
  df <- df[45:nrow(df), ]
  
  # créer les nouvelles variables
  df <- df %>%
    mutate(
      participant   = pid,
      condition     = case_when(
        grepl("FIX", ImagesDistracteursFile, ignore.case = TRUE)     ~ "Fixed",
        grepl("ANIMEES", ImagesDistracteursFile, ignore.case = TRUE) ~ "Animated",
        TRUE                                                         ~ NA_character_
      ),
      is_distractor = grepl("Distracteurs", ImagesDistracteursFile, ignore.case = TRUE),
      correct       = case_when(
        is_distractor & mouse.clicked_name == "Faux" ~ 1,
        !is_distractor & mouse.clicked_name == "Vrai" ~ 1,
        TRUE                                         ~ 0
      )
    ) %>%
    filter(!is.na(condition))
  
  return(df)
}

# 3. Appliquer à tous les fichiers et empiler
df_all <- map_dfr(files, process_data)

# 4. Résumé des performances par participant et condition
perf_summary <- df_all %>%
  group_by(participant, condition) %>%
  summarise(
    trials    = n(),
    mean_perf = mean(correct),
    sd_perf   = sd(correct),
    .groups   = "drop"
  )

print(perf_summary)

# 5. Test statistique global (Fixed vs Animated, sans tenir compte du participant)
t_test <- t.test(correct ~ condition, data = df_all)
print(t_test)
