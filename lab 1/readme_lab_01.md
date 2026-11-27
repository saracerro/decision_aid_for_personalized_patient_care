# Lab 01 — Dataset Preparation & Missing Value Imputation

This directory contains the MATLAB scripts and documentation for **Laboratory 1** of the *Decision Aid for Personalized Patient Care (DAPPC)* course (A.A. 2024/2025, Politecnico di Torino).

The objective of this lab is to prepare the clinical weaning dataset (`dataset_weaning.xlsx`, extracted from MIMIC-IV) by removing high-missingness features and records, imputing the remaining missing values using four distinct strategies, and analyzing variable distributions across classes.

---

## 📁 Files Included

* **`LAB01_MV_imputation.m`**: Performs initial data filtering (Steps 1–2) and executes four missing data imputation pipelines (Steps 3a–3d), saving each resulting dataset to a dedicated Excel sheet.
* **`LAB01_graphics.m`**: Loads the imputed datasets and generates comparative boxplots (continuous features) and grouped bar charts (categorical/binary features) across target classes (Step 4).

---

## 🛠️ Pipeline Overview

### 1. Data Cleaning (`LAB01_MV_imputation.m` — Steps 1 & 2)
Starting from the raw `DATASET` sheet (3,329 patients × 85 columns), the script creates a cleaned baseline sheet (`DATASET_V1`):
* **Step 1 (Feature Filtering):** Removes clinical feature columns (columns 4 to 84) containing $\ge 200$ missing values.
* **Step 2 (Patient Filtering):** Removes patient rows containing $\ge 20$ missing values.

### 2. Missing Value Imputation (`LAB01_MV_imputation.m` — Step 3)
Missing values are imputed using four approaches and saved into separate sheets within `dataset_weaning.xlsx`:
* **Step 3a (`DATASET_Step3a`) — Global kNN Imputation:** Trains a standardized $k$-Nearest Neighbors model ($k = 5$) on all complete patient rows for each incomplete feature.
* **Step 3b (`DATASET_Step3b`) — Class-Wise kNN with Gaussian Noise:** Performs kNN imputation ($k = 5$) independently on `Class 0` (failure) and `Class 1` (success), adding calibrated Gaussian noise ($\mathcal{N}(0, \sigma^2)$) to preserve intra-class variance.
* **Step 3c (`DATASET_Step3c`) — Global Hierarchical Clustering:** Normalizes features to $[0, 1]$, applies agglomerative hierarchical clustering (`complete` linkage, `cityblock` distance, 20 clusters) on complete records (TRS), assigns incomplete patients to the closest cluster centroid, and imputes continuous variables via cluster mean and categorical/binary variables via cluster median/mode.
* **Step 3d (`DATASET_Step3d`) — Class-Wise Hierarchical Clustering:** Applies the hierarchical clustering imputation pipeline separately within `Class 0` and `Class 1`.

### 3. Graphical Representation & Outlier Analysis (`LAB01_graphics.m` — Steps 4 & 5)
* **Dendrograms:** Automatically exported during clustering (`Dendrogram_TRS.png`, `Dendrogram_TRS0.png`, `Dendrogram_TRS1.png`) showing the 20-cluster cutoff threshold.
* **Boxplots (`Boxplot_<feature>.png`):** Compares normalized distributions of continuous clinical variables across `Class 0` and `Class 1` for all four imputed datasets (`Step3a`–`Step3d`) to support visual outlier detection.
* **Bar Charts (`Barchart_<feature>.png`):** Compares class frequencies for binary and categorical variables across the four imputation strategies.

---

## ▶️ How to Run

### Requirements
* **MATLAB** (R2022b or newer)
* **Statistics and Machine Learning Toolbox**

### Execution Steps
1. Ensure `dataset_weaning.xlsx` is located in the same directory as the scripts (or update the `path` variable at the top of both files).
2. Run the cleaning and imputation script first:
   ```matlab
   LAB01_Imputation
   ```
3. Once the Excel sheets (`DATASET_Step3a` through `DATASET_Step3d`) have been generated, run the visualization script:
   ```matlab
   LAB01_Plots
   ```
