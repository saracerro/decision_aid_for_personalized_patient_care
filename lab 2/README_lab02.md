# Lab 02 — Patient Clustering with Self-Organizing Maps (SOMs)

Implementation of **Self-Organizing Maps (SOMs)** combined with agglomerative hierarchical clustering to identify homogeneous patient groups across the imputed weaning datasets produced in **Lab 01**[cite: 13, 15, 16, 17, 18].

---

## 🎯 Objectives

1. Load the imputed datasets (`DATASET_Step3a`, `DATASET_Step3b`, `DATASET_Step3c`, `DATASET_Step3d`) generated in Lab 01 and normalize feature values[cite: 13, 15, 18].
2. Train square SOM grids (`selforgmap([n n])`) varying grid size $n \in [10, 15]$ and initial neighborhood size (`initNeighbor` $= 1$ and $2$)[cite: 13, 16, 17, 18].
3. Extract neuron weight vectors (`IW{1,1}`), build dendrograms (`complete` linkage, `cityblock` distance), cut clusters, and inspect neuron hits and cluster bubbles (`plotsomhits` and `plot_som_clusters`)[cite: 13, 18, 19].
4. Map patients to clusters via winning neurons (`vec2ind`) and evaluate cluster quality using **Intra-Cluster Variance (ICV)** and **Inter-Cluster Distance (ICD)**[cite: 13, 18].

---

## 📁 Files in This Folder

- `LAB02_SOM_Clustering.m`: Unified script for normalization, SOM training, hierarchical clustering on neuron weights, patient cluster assignment, and ICV/ICD evaluation[cite: 13, 18].
- `plot_som_clusters.m`: Helper function that overlays color-coded hexagonal cluster regions onto the SOM grid[cite: 19].
- `README.md`: Documentation for Lab 02.

---

## 🚀 How to Run

### Prerequisites
- **MATLAB** with **Deep Learning Toolbox** (`selforgmap`, `plotsomhits`, `vec2ind`) and **Statistics and Machine Learning Toolbox** (`linkage`, `dendrogram`, `cluster`, `pdist`, `pdist2`).

### Execution
1. Place `dataset_weaning.xlsx` (containing the sheets from Lab 01) and `plot_som_clusters.m` in the working folder[cite: 13, 18, 19].
2. Select `sheetName` at the top of `LAB02_SOM_Clustering.m` (`DATASET_Step3a`, `DATASET_Step3b`, `DATASET_Step3c`, or `DATASET_Step3d`)[cite: 13, 18].
3. Run `LAB02_SOM_Clustering.m` to generate dendrograms, SOM maps, cluster assignments, and ICV/ICD metrics[cite: 13, 18].

---

## 📌 Outputs (Per SOM Size & Neighborhood)

For each SOM grid size ($n = 10 \dots 15$) and neighborhood setting (`initNeighbor` $= 1, 2$)[cite: 13, 17, 18]:
- **Dendrogram:** Hierarchical clustering tree on SOM neuron weights[cite: 13, 18].
- **Colored Dendrogram:** Dendrogram with color-coded cluster cut threshold[cite: 13, 18].
- **SOM Hits:** Sample hits visualization across the SOM grid (`plotsomhits`)[cite: 13, 18].
- **SOM Clusters (A):** Hexagonal SOM grid colored by neuron cluster assignment (`plot_som_clusters`)[cite: 13, 18, 19].
- **SOM Patient Clusters (A):** Patient-to-cluster assignments (`patient_clusters`) derived from winning neurons (`vec2ind`)[cite: 13, 18].
- **Cluster Evaluation Metrics:** Intra-Cluster Variance (`max_ICV`) and Inter-Cluster Distance (`min_ICD`)[cite: 13].
