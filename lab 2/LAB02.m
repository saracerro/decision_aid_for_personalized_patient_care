%-------------------------------------------------------------------%
%               DECISION AID FOR PERSONALIZED PATIENT CARE          %
%                      LAB 02 - CLUSTERING WITH SOMs                %
%-------------------------------------------------------------------%
% Author: Alessandra Introvaia - alessandra.introvaia@polito.it     %
% Creation date: 27/03/2025                                         %
% Last modification: 31/03/2025 (AI)                                %
%-------------------------------------------------------------------%
% This script aims to implement a clustering method based on SOMs    %
% across imputed datasets, evaluate cluster quality (ICV / ICD), and %
% save trained SOMs and patient cluster assignments.                %
%-------------------------------------------------------------------%
% Parameters to be specified:                                       %
% - path: file path of the Excel FILE (.xlsx)                       %
% - sheetName: name of dataset SHEET with the imputed dataset       %
%-------------------------------------------------------------------%

clear 
close all
clc

%% Dataset Loading

% Specify the path of the Excel sheet (relative path for GitHub)
path = 'dataset_weaning.xlsx';
sheetName = "DATASET_Step3c";
% Read the Excel sheet
dataset = readtable(path, 'Sheet', sheetName);
fprintf('Original dataset: %d rows, %d columns. Total missing values: %d \n', ...
    size(dataset,1), size(dataset,2), sum(ismissing(dataset),"all"));

%% Normalizzazione
% Normalize the features (columns 4 to end-1)
features_raw = dataset(:, 4:end-1);
num_variabili = width(features_raw);

min_val = zeros(1, num_variabili);
max_val = zeros(1, num_variabili);
dataset_norm = features_raw;

for i = 1:num_variabili
    col_data = features_raw{:, i};
    min_val(i) = min(col_data, [], 'omitnan');
    max_val(i) = max(col_data, [], 'omitnan');
    if max_val(i) ~= min_val(i)
        dataset_norm{:, i} = (col_data - min_val(i)) / (max_val(i) - min_val(i));
    else
        dataset_norm{:, i} = zeros(height(features_raw), 1);
    end
end

data_matrix = table2array(dataset_norm)';

%% SOM construction & exploration (n = 10:15, neighbour = 1, 2)
% 1. Define the dimensions of the SOM (square SOM [n n]).
% 2. Create the SOM architecture (selforgmap).
% 3. Train the SOM and save the trained network (train).
% 4. Extract weight vectors (som.IW{1,1}) and apply hierarchical clustering
%    (linkage, dendrogram, cluster).
% 5. Visualize sample hits (plotsomhits) and neuron clusters (plot_som_clusters).
% 6. Assign patients to clusters based on winner neuron (vec2ind).
% 7. Save SOM models and patient cluster assignments (.mat).

neighbors_list = [1, 2];
n_values = 10:15;

% Interactive / single-run setup (set run_grid_search = true to loop n=10:15 & neighbour=1,2)
run_grid_search = false;

if ~run_grid_search
    n = 10;
    neighbour = 1;

    selfOrgMap = selforgmap([n n], 'initNeighbor', neighbour);
    trainedNet = train(selfOrgMap, data_matrix);
    weights = trainedNet.IW{1,1};
    Dendogram_tree = linkage(weights, 'complete', 'cityblock');

    figure;
    dendrogram(Dendogram_tree, 0);
    title(['Dendrogram - n = ', num2str(n), ', neighbor = ', num2str(neighbour)]);
    saveas(gcf, ['Dendrogram_n' num2str(n) '_neighbor' num2str(neighbour) '.png']);

    flag = 'n';
    while strcmpi(flag, 'n')
        nclust = input('Inserisci il numero di cluster desiderato: ');
        figure;
        dendrogram(Dendogram_tree, 0, 'ColorThreshold', Dendogram_tree(end-nclust+2, 3));
        saveas(gcf, ['Dendrogram_COLORED_n' num2str(n) '_neighbor' num2str(neighbour) '.png']);

        clusters = cluster(Dendogram_tree, 'maxclust', nclust);
        figure;
        plotsomhits(trainedNet, data_matrix);
        plot_som_clusters(clusters, n, nclust);
        saveas(gcf, ['SOM_Clusters_n' num2str(n) '_neighbor' num2str(neighbour) '.png']);

        flag = input('Il numero di cluster è valido? (y/n): ', 's');
        close all;
    end

    winner_neurons = vec2ind(trainedNet(data_matrix));
    patient_clusters = clusters(winner_neurons);

    save(['SelfOrgMap_n' num2str(n) '_neighbor' num2str(neighbour) '.mat'], 'selfOrgMap', 'trainedNet');
    save(['PatientClusters_n' num2str(n) '_neighbor' num2str(neighbour) '.mat'], 'patient_clusters', 'clusters');
else
    for nb = neighbors_list
        for n = n_values
            selfOrgMap = selforgmap([n n], 'initNeighbor', nb);
            trainedNet = train(selfOrgMap, data_matrix);
            weights = trainedNet.IW{1,1};
            Dendogram_tree = linkage(weights, 'complete', 'cityblock');

            figure('Visible', 'off');
            dendrogram(Dendogram_tree, 0);
            title(['Dendrogram - n = ', num2str(n), ', neighbor = ', num2str(nb)]);
            saveas(gcf, ['Dendrogram_n' num2str(n) '_neighbor' num2str(nb) '.png']);
            close(gcf);

            winner_neurons = vec2ind(trainedNet(data_matrix));
            save(['SelfOrgMap_n' num2str(n) '_neighbor' num2str(nb) '.mat'], ...
                'selfOrgMap', 'trainedNet', 'Dendogram_tree', 'winner_neurons');
        end
    end
end

%% Cluster Quality Metrics: ICV & ICD
% Compute Intra-Cluster Variance (ICV) and Inter-Cluster Distance (ICD)
% for a given saved patient_clusters vector and number of clusters.

cluster_file = 'PatientClusters_n10_neighbor1.mat';
if exist(cluster_file, 'file')
    loaded_data = load(cluster_file, 'patient_clusters');
    patient_clusters_eval = loaded_data.patient_clusters;
    NumClust = max(patient_clusters_eval);

    features_eval = table2array(dataset_norm);
    mediadist_icv = zeros(1, NumClust);
    centroids = zeros(NumClust, size(features_eval, 2));

    for k = 1:NumClust
        idx_k = (patient_clusters_eval == k);
        if any(idx_k)
            pz_clust = features_eval(idx_k, :);
            centroids(k, :) = mean(pz_clust, 1);
            if size(pz_clust, 1) > 1
                mediadist_icv(k) = mean(pdist(pz_clust, 'cityblock'));
            else
                mediadist_icv(k) = 0;
            end
        end
    end

    max_ICV = max(mediadist_icv);

    % Inter-Cluster Distance (average distance from each centroid to all other centroids)
    mediadist_icd = zeros(1, NumClust);
    for i = 1:NumClust
        other_centroids = centroids([1:i-1, i+1:end], :);
        if ~isempty(other_centroids)
            d_inter = pdist2(centroids(i, :), other_centroids, 'cityblock');
            mediadist_icd(i) = mean(d_inter);
        end
    end
    min_ICD = min(mediadist_icd);

    fprintf('Evaluation on %s (%d clusters): max_ICV = %.4f | min_ICD = %.4f\n', ...
        cluster_file, NumClust, max_ICV, min_ICD);
end
