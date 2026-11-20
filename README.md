# Decision Aid for Personalized Patient Care — Lab Work
Decision Aid for Personalized Patient Care (DAPPC) — Master's Degree in Biomedical Engineering, Politecnico di Torino, A.A. 2024/25
# Project
Application of unsupervised machine learning and soft-computing techniques to a real clinical dataset for ICU patient stratification and weaning outcome prediction. The dataset consists of physiological and clinical variables from patients undergoing (or failing) mechanical ventilation weaning — a critical ICU decision where early prediction of failure can prevent respiratory complications.
# Labs
Lab	Topic	Methods

| Laboratory | Main Topic | Topic Description |
| --- | --- | --- |
| lab 1 | Exploratory Data Analysis | Descriptive statistics, histograms, dendrograms, missing values, Bar diagrams, box plots, comparative multi-variable visualization |
| lab 2 | Clustering | SOM (Self-Organizing Maps), k-means, cluster quality metrics (silhouette, DB index) |
| lab 3 | Feature Selection | ACO (Ant Colony Optimization), hold-out cross-validation |
| lab 4 |	Classifier Design |	Fuzzy Inference System (FIS), centroid-based classification, parameter optimization |

# Clinical Context
The weaning dataset contains ICU time-series measurements (heart rate, respiratory rate, blood gas parameters, PEEP, tidal volume, etc.) for two patient groups: successful and unsuccessful weaning. The goal is to:

1. Identify clinically meaningful patient subgroups via clustering
2. Select the most discriminant physiological variables via ACO
3. Build a soft classifier to support the weaning decision (Fuzzy Logic)
# Repository Structure
```text
DAPPC-LAB/
├── labs/
│   ├── lab01/             # EDA — MATLAB script + lab specs + bar/box plots with comparative figures
│   ├── lab02/             # SOM + k-means clustering with quality metrics
│   ├── lab03/             # ACO feature selection
│   └── lab04/             # Fuzzy Inference System design
├── data/
│   └── dataset_weaning_final.xlsx   # ICU weaning dataset
├── results/
│   ├── centroids/         # Cluster centroids (.mat)
│   └── clusters/          # Cluster assignments per patient (.mat)
└── reports/               # Group reports (PDF + PPTX)
```
