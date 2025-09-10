
***

🇫🇷 Version française
======================

Neuro-Psychology-Study
----------------------

**Analyse avancée des processus mémoire/attention en situations émotionnelles : un véritable use case Data Science en neurosciences expérimentales**

### 🏆 Data Scientist Skills

- **Maîtrise des packages statistiques avancés :**
    - `lme4` et `ez` : modèles linéaires mixtes et ANOVA à mesures répétées adaptés aux données croisés et stratifiées de l’étude (participants exposés à plusieurs conditions). Ils servent à tester l’effet de l’animation, de l’émotion et de leur interaction sur la mémoire.
    - `emmeans`, `effectsize` : génération automatisée des contrastes post-hoc et taille d’effet, facilitant la comparaison de conditions expérimentales et la synthèse des résultats.
    - `tidyverse` : pipelines fonctionnels pour le nettoyage, la structuration des variables (préparation par batch et automatisation), et l’extraction de sous-populations descriptives (par sexe, niveau d’études, scores de questionnaires).
    - `ggplot2` : création de figures reproductibles et interactives, permettant de visualiser les effets principaux (ex : graphes de boîte comparant les taux de reconnaissance par condition).

### 🚀 Objectifs scientifiques et technos

Le projet cherche à comprendre comment l’animation visuelle et la valence émotionnelle des images modulent la mémoire épisodique et l’attention chez l’humain, avec prise en compte des facteurs démographiques et émotionnels.

### 🖥️ Stack & pipeline complet

- `Experience_Psy/data/` : Données brutes structurées.
- `Experience_Psy/Initialisation.R` : Nettoyage, scoring (anxiété, tristesse, etc.) et préparation automatique des jeux de données.
- `Experience_Psy/Hypothese_*.R` : Scripts analysant indépendamment chaque hypothèse (effet principal/interaction) et produisant graphiques & tableaux.
- `Experience_Psy/Plots` : Figures-clés générées pour publication, dont :
    - **Animees vs Fixes.png** : Compare directement la mémoire pour les stimuli animés vs fixes.
    - **Reco par condition.png** : Synthétise les taux de reconnaissance selon la valence (neutre/négatif) et l’aspect animé ou statique.
    - **Interaction Condition x Niveau d etudes.png** : Met en lumière des effets croisés, par exemple plus marqués pour certains groupes d’études supérieures.
    - **Moyennes ajustees.png** : Affiche les scores ajustés par modèle mixte, après contrôle des covariables.
- `output/` : Tableaux de résultats (ex. Tableau ANOVA.pdf) et exports exploitables.

### 📈 Visualisation & résultats

- L’analyse statistique révèle :
    - **Aucun effet significatif de l’animation** seule sur la mémoire épisodique : les taux de reconnaissance sont similaires pour les images animées et statiques (`Animees vs Fixes.png`).
    - **Effet marqué de la valence émotionnelle :** Les images négatives sont nettement mieux reconnues que les images neutres, toutes modalités confondues (`Reco par condition.png`). Cette différence est robuste et confirmée par plusieurs modèles mixtes et les tests d’EZ ANOVA.
    - **Effets croisés secondaires :** Un impact du niveau d’études ou de sous-groupes démographiques sur la modulation émotionnelle : l’effet de la valence est accentué chez certains profils (`Interaction Condition x Niveau d etudes.png`).
    - **Visualisation** : Toutes les figures sont générées par le pipeline, documentées dans `Experience_Psy/Plots/` et reprises dans les rapports.

### 🙋 À propos

**Yannis Mzg — Data Scientist, R & neurosciences, expert analyse expérimentale. Contact via GitHub.**

***

🇬🇧 English version
====================

Neuro-Psychology-Study
----------------------

**Advanced analysis of memory/attention in emotional contexts: a true Data Science case study in experimental neuroscience**

### 🏆 Data Scientist skillset in action

- **Advanced statistical package use:**
    - `lme4` and `ez`: mixed-effects models and repeated-measures ANOVA tailored to the cross-stratified dataset (participants exposed to all conditions). These tools test the effects (main and interaction) of animation and emotion on episodic memory.
    - `emmeans`, `effectsize`: automated post-hoc contrasts and effect size calculations for easy condition comparisons and reporting.
    - `tidyverse`: functional pipelines for cleaning, variable transformation (batch prepping), and subgroup analysis (by gender, education, questionnaire scores).
    - `ggplot2`: reproducible and interactive figure creation, illustrating key effects (e.g., boxplots of recognition rates by condition).

### 🚀 Scientific and tech goals

The project interrogates how visual animation and image valence modulate episodic memory and attention in humans, while considering demographic and emotional factors.

### 🖥️ Full stack & pipeline

- `Experience_Psy/data/`: Raw structured data.
- `Experience_Psy/Initialisation.R`: Cleaning, scoring (anxiety, sadness etc.) and automatic prep of analysis files.
- `Experience_Psy/Hypothese_*.R`: Independent scripts for each hypothesis (main/interaction effects) producing focused charts and tables.
- `Experience_Psy/Plots`: Key publication figures, including:
    - **Animees vs Fixes.png**: Direct memory performance comparison for animated vs static cues.
    - **Reco par condition.png**: Summarizes recognition rates by valence (neutral/negative) and animated/static nature.
    - **Interaction Condition x Niveau d etudes.png**: Highlights interaction effects, e.g., sharper valence effects in higher-education subgroups.
    - **Moyennes ajustees.png**: Modeled adjusted group means, controlling covariates.
- `output/`: Results tables (e.g., Tableau ANOVA.pdf) and export files.

### 📈 Visualization & results

- Statistical analysis reveals:
    - **No significant animation effect** on episodic memory: recognition rates do not differ between animated and static stimuli (`Animees vs Fixes.png`).
    - **Clear emotional valence effect**: negative images are recognized much better than neutral images, a robust and replicated finding (`Reco par condition.png`), confirmed via mixed models and ANOVA.
    - **Secondary interaction effects**: demographic factors such as education modulate the emotional effect: valence impact is more pronounced in certain subgroups (`Interaction Condition x Niveau d etudes.png`).
    - **Visualization**: All figures generated by pipeline, in `Experience_Psy/Plots/` and referenced in reporting.

### 🙋 About

**Yannis Mzg — Data Scientist, R & neuroscience, experimental analysis expert. Contact via GitHub.**

***

