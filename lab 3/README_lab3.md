# Lab 03 — Feature Selection with Ant Colony Optimization (ACO)

Identification of relevant clinical features from the patient clusters obtained in **Lab 02** (SOM clustering) using **Ant Colony Optimization (ACO)** and hold-out wrapper evaluation (`kNN`)[cite: 20, 29, 36].

---

## 🎯 Objectives & Pipeline (`DAPPC LAB 3.pdf`)

1. **Load & Prepare Data (Step 1):** Load the selected SOM clustering results, normalize features if needed, and identify the largest cluster containing patients from both classes (`0` and `1`)[cite: 36, 37].
2. **Feature–Class Correlation (Step 2):** Compute the **Pearson** correlation of each feature with the target class and select the **5 most correlated features**[cite: 37].
3. **ACO & Hold-Out Setup (Step 3):** Configure ACO parameters (`max_Iter = 500`, `tau = 0.5`, `alpha = 1`, `rho = 0.2`, `beta = 2`, `eta = 1`), create the hold-out split (`70%` train / `30%` test) via `createHoldOutIndex`, and initialize ants from the top 5 correlated features[cite: 34, 37].
4. **Feature Selection Execution & Analysis (Step 4):** Run `ACO_FS`, track convergence over iterations (`curve`), extract the selected feature subset (`Sf`, `sFeat`, `Nf`), save results, and evaluate potential improvements[cite: 20, 37].

---

## 📂 Files in This Folder

- `ACO_FS_2.m`: ACO feature selection function using pheromone (`tau`) and heuristic (`eta`) probabilities, roulette-wheel selection, hold-out wrapper fitness evaluation, and pheromone evaporation/update[cite: 20, 29, 33].
- `createHoldOutIndex_2.m`: Helper function generating logical `training` and `test` indices via `cvpartition(..., 'HoldOut', testRatio)`[cite: 21, 34].
- `DAPPC LAB 3.pdf`: Official lab instructions and operational guidelines for Lab 03[cite: 35, 36, 37].
- `LAB3 (3).pptx` & `LAB3.pdf`: Group 15 summary report comparing selected features across `Cluster 4`, `Cluster 6`, `Cluster 14`, `Cluster 15`, and `Cluster 17`[cite: 38, 39, 40].
- `___All_Errors.txt`: Download error log listing files under `classificatore/` (`.fis`, `.mat`, `.asv`, `.jpg`, `.xlsx`, `.png`) that were not downloaded locally[cite: 32].

---

## 📊 Key Results Summary (from `LAB3.pdf` / `LAB3 (3).pptx`)

Across the analyzed clusters (`Cluster 4`, `Cluster 6`, `Cluster 14`, `Cluster 15`, `Cluster 17`), features frequently selected by ACO include `Heart_rate_trend` (present across all 5 clusters), `Sedation_days`, `Mean_airway_pressure_min_value`, `Heart_rate_max_value`, `Respiratory_rate_trend`, `pH_max_value`, and `Tidal_volume_trend`[cite: 38, 40].

---

## ⚠️ Technical Notes & Unused / Missing Items

- **Missing / Undownloaded Files:** The files listed in `___All_Errors.txt` (`classificatore/*`) are not present in this folder and belong to downstream classification/FIS steps[cite: 32].
- **Minimum Feature Filter in `ACO_FS_2.m`:** Each ant initially samples `num_feat = randi([4,8])` features, but candidate subsets with `< 12` selected features are penalized (`fit(i) = 1`) before wrapper evaluation[cite: 20, 29, 33]. Aligning `num_feat` and the `< 12` threshold is recommended if re-running experiments[cite: 33].

---

## 🚀 How to Run

1. Ensure `ACO_FS_2.m` and `createHoldOutIndex_2.m` (along with your wrapper `objectiveFunction.m`) are on the MATLAB path[cite: 20, 21, 29, 33, 34].
2. Create the hold-out partition:
   ```matlab
   HO = createHoldOutIndex(label, 0.30);
