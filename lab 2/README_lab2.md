# Lab 02 — Patient Clustering with Self-Organizing Maps (SOMs)

Identification of homogeneous patient groups on the imputed datasets from **Lab 01** (`DATASET_Step3a`, `DATASET_Step3b`, `DATASET_Step3c`, `DATASET_Step3d`) using **Self-Organizing Maps (SOMs)** and agglomerative hierarchical clustering on neuron weight vectors[cite: 13, 15, 16, 17, 18].

---

## 🎯 Objectives & Workflow

1. **Dataset Loading & Normalization:** Load an imputed dataset sheet from the Excel workbook and normalize input features (`4:end-1`) using min–max scaling[cite: 13, 18, 26].
2. **SOM Training & Exploration:** Configure square SOM networks (`selforgmap([n n])`) varying grid size $n \in [10, 15]$ and neighborhood parameter (`initNeighbor` $= 1$ and $2$)[cite: 13, 16, 17, 18, 26].
3. **Hierarchical Clustering on Neuron Weights:** Extract weight vectors (`som.IW{1,1}`), build the cluster tree (`linkage(..., 'complete', 'cityblock')`), cut the dendrogram into `nclust` clusters, inspect sample hits (`plotsomhits`) and cluster regions (`plot_som_clusters`)[cite: 13, 18, 19, 26, 31].
4. **Patient Assignment & Cluster Selection:** Map each patient to its winning neuron (`vec2ind`) and cluster label (`patient_clusters`), then select the best configuration using **minimum ICV** and **maximum ICD**[cite: 13, 18, 26, 28].

---

## 📂 Active Files in This Folder

- `LAB02.m`: Main MATLAB script for loading imputed data, normalizing features, training SOMs, building dendrograms, plotting SOM clusters, assigning patients to clusters, and saving `.mat` outputs[cite: 18].
- `plot_som_clusters.m`: Function that plots hexagonal SOM neurons color-coded by cluster assignment[cite: 19].
- `LAB2_ relazione.txt`: List of SOM configurations excluded during evaluation (`Neighbour = 2`, `n = 10..15` for Datasets A, B, and D)[cite: 27].
- `LAB2_file.pptx`: Presentation summarizing dendrograms, hit maps, cluster distributions, ICV/ICD trends, and final dataset selection across Datasets A, B, C, and D[cite: 28].
- `LAB2_file_ColumnClustered.xlsx.pdf`: Reference sheet/export related to column clustering results.

### Files Not Used in the Lab 02 SOM Pipeline
- `ACO_FS.m`, `objectiveFunction.m`, `createHoldOutIndex.m`: Feature selection (Ant Colony Optimization) and hold-out kNN evaluation utilities not invoked by the SOM scripts[cite: 20, 21, 29].
- `plot_hex_grid.m`: Alternative hexagonal grid plot function displaying cluster numbers inside each cell[cite: 30].
- `plot_som_clusters_2.m`, `LAB02_2.m`, `LAB02-MacBook Air di Antonella.m`, `DAPPC 24-25 Introduction to LAB2_2.pdf`: Duplicate or local-path variants not needed as standalone active files[cite: 13, 19, 22, 26, 31].

---

## 📊 Outputs & Key Takeaways (from `LAB2_file.pptx` & `LAB2_ relazione.txt`)

- For each evaluated SOM grid (`n = 10..15`) and neighborhood setting, outputs include the dendrogram, colored dendrogram, SOM hits map, SOM cluster map (`A`), and patient cluster assignments (`patient_clusters` saved in `.mat` files)[cite: 13, 18, 19, 28].
- Configurations with `Neighbour = 2` (`n = 10..15`) were excluded for **Dataset A**, **Dataset B**, and **Dataset D**[cite: 27].
- Across the compared datasets (`A`, `B`, `C`, `D`) using minimum ICV and maximum ICD, `15x15` was selected as the best grid size per dataset, with **Dataset D** identified as the best overall dataset in the report[cite: 28].

---

## 🚀 How to Run

1. Place the Excel dataset (containing the sheets from Lab 01) and `plot_som_clusters.m` in the working folder[cite: 13, 18, 19, 26].
2. Update `path` and `sheetName` (e.g., `"DATASET_Step3a"`, `"DATASET_Step3b"`, `"DATASET_Step3c"`, or `"DATASET_Step3d"`) in `LAB02.m`[cite: 13, 18, 26].
3. Run `LAB02.m` in MATLAB (requires *Deep Learning Toolbox* and *Statistics and Machine Learning Toolbox*)[cite: 18].
