
***

# Neuro-Psychology-Study

This repository gathers all scripts, datasets, and analyses related to an experimental study on the **influence of visual animation** and **emotional valence** on episodic memory and attention.

## Project Overview

The study aims to determine how animation (animated vs. static images) and emotional valence (negative vs. neutral) of stimuli affect:
- Memory performance (recognition task)
- Emotional arousal and subjective pleasure
- The role of demographic variables (age, sex, education level, etc.)

## Repository Structure

- `Experience_Psy/`
  - `data/`: raw datasets (.csv), participant files (.xlsx)
  - `output/`: results, figures, exports
  - `Hypothese_Gemini.R`: R script for main hypothesis analysis (replaces former Hypothese 1)
  - `Hypothese 2.R`, `Hypothese 3.R`: R scripts for additional hypothesis analyses
  - `Initialisation.R`: preprocessing and data import pipeline
  - Images and graphics related to analyses
  - Notes and supplementary documents

## Requirements

- **R** (version ≥ 4.0)
- Main packages:
  - tidyverse
  - lme4, ez, emmeans, effectsize, ggplot2, etc.

## Quickstart

1. **Clone the repository**
   ```bash
   git clone https://github.com/YannisMzg/Neuro-Psychology-Study.git
   cd Neuro-Psychology-Study/Experience_Psy
   ```

2. **Open the project in RStudio:**  
   Double-click on `Experience_Psy.Rproj`

3. **Run the initialization script**  
   Launch `Initialisation.R` to load and prepare the data.

4. **Analyze the hypotheses**  
   - Run one of the scripts: `Hypothese_Gemini.R`, `Hypothese 2.R`, or `Hypothese 3.R`
   - Results (statistics, plots, mixed models, ANOVA analyses) are generated automatically.

## Scientific Summary

- **Gemini Hypothesis:** Animation provides no significant advantage for memory, but educational level strongly predicts performance.
- **Hypothesis 2:** Animation increases emotional arousal (but not pleasure); negative valence increases arousal and reduces pleasure.
- **Hypothesis 3:** (To be completed according to documentation and associated analyses)

## Author

Yannis Mzg  
Contact: via GitHub

***

You can adapt the Gemini hypothesis description further if the focus or results have evolved with the new script.

[1](https://github.com/YannisMzg/Neuro-Psychology-Study/new/main?filename=README.md)
