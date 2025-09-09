# 0. Librairies
library(tidyverse)

# 1. Chemin vers votre dossier de CSV
csv_dir <- "~/Experience_Psy/data/raw_data"

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
  df  <- read.csv(fp, header = TRUE, stringsAsFactors = FALSE)
  
  # si moins de 45 lignes, on skip
  if (nrow(df) < 45) {
    stop("Moins de 45 lignes dans le fichier")
  }
  
  df <- df[45:nrow(df), ]
  
  df %>%
    mutate(
      participant   = pid,
      condition     = case_when(
        grepl("FIX", ImagesDistracteursFile, ignore.case = TRUE)     ~ "Fixed",
        grepl("anim", ImagesDistracteursFile, ignore.case = TRUE) ~ "Animated",
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
}

# 4. Appliquer à chaque fichier en capturant les erreurs
df_list <- map(files, function(fp) {
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
df_all <- bind_rows(df_list)
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
# 6. (Optionnel) Afficher un barplot simple
df_all %>%
  group_by(condition) %>%
  summarise(mean_perf = mean(correct)) %>%
  ggplot(aes(x = condition, y = mean_perf)) +
  geom_col() +
  ylim(0,1) +
  labs(
    title = "Performance de reconnaissance\nFixed vs Animated",
    x     = "Condition",
    y     = "Proportion de réponses correctes"
  )

# modèle logistique sans effets aléatoires
glm1 <- glm(correct ~ condition,
            data   = df_all,
            family = binomial(link = "logit"))
summary(glm1)

# calculer l’IC 95 % sur les coefficients
confint(glm1, parm="conditionFixed", level=0.95)
# puis exp() pour transformer en OR

library(lme4)

glmer1 <- glmer(
  correct ~ condition + (1 | participant),
  data   = df_all,
  family = binomial(link = "logit"),
  control = glmerControl(optimizer = "bobyqa")
)
summary(glmer1)

glmer2 <- glmer(
  correct ~ condition + (1 | participant) + (1 | ImagesDistracteursFile),
  data   = df_all,
  family = binomial(link = "logit"),
  control = glmerControl(optimizer = "bobyqa")
)
summary(glmer2)

library(sjstats)
r2(glmer1)          # pseudo-R2
anova(glmer1, glm1) # test de rapport de vraisemblance


# 1. Charger / fusionner les covariables

library(readxl)
# supposons que participants soit déjà lu depuis votre Excel
participants <- read_excel("~/Downloads/TABLEAU-PARTICIPANTS 3.xlsx")

df_full <- df_all %>%
  left_join(participants, by = "participant")

# 2. Centrage / codage
df_full <- df_full %>%
  mutate(
    age_c        = scale(Âge, center = TRUE, scale = FALSE),
    #anxiety_c    = scale(Anxiete, center = TRUE, scale = FALSE),
    depression_c = scale(depression, center = TRUE, scale = FALSE),
    sex          = factor(Sexe),
    education    = factor(education, ordered = TRUE)
  )

# 3. Modèle principal avec covariables
library(lme4)
glmer_cov <- glmer(
  correct ~ condition
  + age_c
  + sex
  + education
  #+ anxiety_c
  + depression_c
  # éventuellement interactions, p.ex. condition:anxiety_c
  + (1 + condition | participant),
  data   = df_full,
  family = binomial(link = "logit"),
  control = glmerControl(optimizer = "bobyqa")
)
summary(glmer_cov)


glmer_simple <- glmer(
  correct ~ condition + age_c + sex + education + depression_c +
    (1 | participant),
  data    = df_full,
  family  = binomial(link = "logit"),
  control = glmerControl(optimizer = "bobyqa")
)
summary(glmer_simple)

glmer_int <- update(glmer_simple, . ~ . + condition:depression_c)
anova(glmer_simple, glmer_int, test = "Chisq")


### Test 

library(dplyr)

summary_df <- df_all %>%
  group_by(participant, condition) %>%
  summarise(
    pct_correct = mean(correct),
    .groups     = "drop"
  )

#Avec aov() et la syntaxe Error() pour spécifier l’effet aléatoire des sujets (ici participant) et la structure intra-sujets condition
rm_anova <- aov(
  pct_correct ~ condition + 
    Error(participant/condition),
  data = summary_df
)
summary(rm_anova)

install.packages("emmeans")
library(emmeans)
emmeans(rm_anova, ~ condition) %>% contrast("pairwise")


#4.	Extension en ANCOVA
#Pour contrôler vos covariables (âge, sexe, niveau d’études, score de dépression…), 
#vous pouvez passer à un plan mixte en ajoutant ces variables en tant que facteurs inter-sujets dans la formule aov() :
rm_ancova <- aov(
  correct ~ condition                # intra-sujets
  + age_c + sex + education + depression_c # inter-sujets
  + Error(participant/condition),
  data = df_full
)
summary(rm_ancova)

# 0. Installer / charger les packages
if (!require("emmeans")) install.packages("emmeans")
if (!require("effectsize")) install.packages("effectsize")
if (!require("ggplot2")) install.packages("ggplot2")
library(emmeans)
library(effectsize)
library(ggplot2)

# 1. Reprendre votre ANOVA à mesures répétées
rm_ancova <- aov(
  correct ~ condition
  + age_c + sex + education + depression_c
  + Error(participant/condition),
  data = df_full
)

# 2. Taille d’effet partielle (η²p) pour chaque source
eta2_results <- eta_squared(rm_ancova, partial = TRUE)
print(eta2_results)

# 3. Estimer les moyennes marginales pour 'education'
emm_edu <- emmeans(rm_ancova, ~ education)
print(emm_edu)

# 4. Comparaisons post‐hoc (Tukey) entre niveaux d’études
posthoc_edu <- contrast(emm_edu, method = "pairwise", adjust = "tukey")
print(posthoc_edu)

# 5. Contrastes polynomiaux (linéaire vs quadratique)
poly_edu <- contrast(emm_edu, method = "poly")
print(poly_edu)

# 6. Visualiser les moyennes par niveau d’études
df_plot <- as.data.frame(emm_edu)
ggplot(df_plot, aes(x = education, y = emmean)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.2) +
  labs(
    title = "Moyennes ajustées de performance par niveau d’études",
    x     = "Niveau d’études",
    y     = "Proportion corrigée moyenne"
  ) +
  theme_minimal()

# 7. Si vous voulez tester l’interaction condition×education
rm_int <- aov(
  correct ~ condition * education
  + age_c + sex + depression_c
  + Error(participant/condition),
  data = df_full
)
summary(rm_int)

# 8. Visualiser l’interaction condition×education
emm_int <- emmeans(rm_int, ~ condition | education)
df_int  <- as.data.frame(emm_int)
ggplot(df_int, aes(x = condition, y = emmean, group = education, color = education)) +
  geom_line() +
  geom_point(size = 2) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.1) +
  labs(
    title = "Interaction Condition × Niveau d’études",
    x     = "Condition",
    y     = "Proportion corrigée moyenne"
  ) +
  theme_minimal

######    CONCLUSION  #####

#On n’observe aucun effet de la présentation animée : ni l’ANOVA intra-sujets, ni les modèles mixtes (GLMM), 
#ni l’interaction avec le niveau d’études ne mettent en évidence de différence significative entre images « Fixed » et « Animated » (toutes p > 0,4).

#En revanche, le niveau d’études joue un rôle significatif : l’ANOVA révèle un effet principal (F(2, 33) = 4,61, p = 0,017, η²ₚ ≈ 0,22), 
#et les comparaisons post-hoc montrent que les participants universitaires performent en moyenne ~9 points de pourcentage de mieux que ceux de niveau secondaire (p = 0,035).

#Les autres covariables (âge, sexe, dépression) n’ont pas d’effet net (p > 0,1), et l’interaction condition × dépression reste non significative
#(p = 0,53).

#On conclut donc que la présentation animée n’améliore pas la reconnaissance, mais que le niveau d’études constitue le principal prédicteur de
#performance dans cet échantillon.

#### HYPOTHESE 2 #####

#Hypothèse concernant l'évaluation émotionnelle : Les participants évalueront les
#images animées comme étant plus émotionnellement intenses que les images nonanimées, avec des différences notables en fonction de la valence émotionnelle
#(négative vs neutre).
