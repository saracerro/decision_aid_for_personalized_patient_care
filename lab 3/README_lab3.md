# Lab 03 — Feature Selection with Ant Colony Optimization (ACO)

Feature selection on patient clusters obtained from **Lab 02** (SOM clustering) using **Ant Colony Optimization (ACO)**, Pearson correlation initialization, and hold-out `kNN` wrapper evaluation[cite: 20, 29, 39, 48, 49, 52].

---

## 🎯 Workflow & Operational Guidelines (`DAPPC LAB 3.pdf`)

1. **Step 1 — Load & Prepare Data:** Load the clustering results (`patient_clusters`) and the imputed dataset sheet (`DATASET_Step3d`), inspect cluster sizes, and verify presence of both classes (`0` and `1`)[cite: 48, 49, 52].
2. **Step 2 — Feature–Class Correlation:** Compute the **Pearson** correlation of each feature with the class label and identify the **5 most correlated features**[cite: 49, 52].
3. **Step 3 — ACO & Hold-Out Initialization:** Set ACO parameters (`max_Iter = 500`, `tau = 0.5`, `alpha = 1`, `rho = 0.2`, `beta = 2`, `eta = 1`), initialize ants using the top 5 correlated features, and create the hold-out split (`30%` test / `70%` train) via `createHoldOutIndex`[cite: 46, 49, 52].
4. **Step 4 — ACO Execution & Results:** Run `ACO_FS` across clusters and repetitions (`20` repetitions per cluster in `LAB3.m`), inspect convergence over iterations, extract selected features, and save outputs[cite: 39, 50, 52].

---

## 📂 Folder Structure & Files

- `LAB3.m`: Main script implementing Steps 1–4, Pearson correlation ranking, ACO parameter setup, and repeated runs per cluster[cite: 49, 52].
- `ACO_FS.m`: Core ACO feature selection algorithm (pheromone/heuristic probability, roulette-wheel selection, hold-out wrapper evaluation, and pheromone update)[cite: 20, 29, 39].
- `createHoldOutIndex.m`: Helper function generating hold-out `training` and `test` partitions via `cvpartition`[cite: 46].
- `DAPPC LAB 3.pdf`: Official Lab 03 instructions[cite: 47, 48, 49, 50].
- `LAB3.pdf`: Final report summarizing selected features across clusters (`Cluster 4`, `Cluster 6`, `Cluster 14`, `Cluster 15`, `Cluster 17`)[cite: 27, 28].
- `results/solutions/`: Selected `.mat` files produced by `ACO_FS` runs:
  - `convergence_curve_cluster=<k>_ripetizione=<j>.mat`: Objective function evolution across iterations[cite: 40, 41, 42, 43, 44, 52].
  - `dataset_reduce_cluster=<k>_ripetizione=<j>.mat`: Feature-reduced matrix for the best subset[cite: 52].
  - `index_features_cluster=<k>_ripetizione=<j>.mat`: Indices of selected features (`Sf`)[cite: 39, 52].
  - `n_features_cluster=<k>_ripetizione=<j>.mat`: Number of selected features (`Nf`)[cite: 39, 52].

### Note on Included Solution Files
Because full ACO runs generate many files across every cluster and all `20` repetitions (`convergence_curve`, `dataset_reduce`, `index_features`, and `n_features`), **not all generated files are uploaded to this repository**[cite: 40, 41, 42, 43, 44, 52]. Only a **selected and useful subset** of `.mat` solution files (such as key clusters/repetitions and convergence curves) is included to keep the repository clean and lightweight while preserving representative results.

---

## ⚠️ Technical Notes

- **Duplicate Variants Removed:** Extra local copies (`ACO_FS_2.m`, `ACO_FS_3.m`, `createHoldOutIndex_3.m`) are consolidated into single canonical functions (`ACO_FS.m` and `createHoldOutIndex.m`)[cite: 21, 22, 39, 46].
- **Minimum Feature Threshold in `ACO_FS.m`:** Ants sample `num_feat = randi([4,8])` initial features, while candidate subsets with `< 12` total selected features are penalized (`fit(i) = 1`) before wrapper evaluation[cite: 20, 29, 39].
- **Hold-Out Call in `LAB3.m`:** `createHoldOutIndex` expects class labels (`clust_classes`) and `testRatio` (`0.3`); verify input arguments if re-running `LAB3.m`[cite: 46, 52].

---

## 🚀 How to Run

1. Place `ACO_FS.m`, `createHoldOutIndex.m`, and `objectiveFunction.m` on the MATLAB path[cite: 20, 29, 39, 46].
2. Update the dataset and cluster file paths in `LAB3.m` to relative paths[cite: 52].
3. Run `LAB3.m` to execute the feature selection pipeline and save `.mat` solution files[cite: 52].
