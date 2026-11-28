%-------------------------------------------------------------------%
%               DECISION AID FOR PERSONALIZED PATIENT CARE          %
%           LAB 03 - FEATURE SELECTION WITH ACO (MAIN)              %
%-------------------------------------------------------------------%
% Workflow:                                                         %
% 1. Load SOM patient clusters and imputed dataset                  %
% 2. Compute Pearson feature-class correlation (top 5 features)     %
% 3. Initialize ACO parameters & hold-out split (70% train / 30% test)%
% 4. Run ACO_FS across clusters and repetitions & save outputs      %
%-------------------------------------------------------------------%

clear;
close all;
clc;

%% STEP 1: Load and prepare data
cluster_path = 'PatientClustersD_n15_neighbor1.mat';
dataset_path = 'dataset_weaning_prova.xlsx';
sheetName    = "DATASET_Step3d";

load(cluster_path, 'patient_clusters');
dataset     = readtable(dataset_path, 'Sheet', sheetName);
dataset_var = dataset(:, 4:end-1);

nClust = max(patient_clusters);
num_patients = zeros(1, nClust);

for i = 1:nClust
    num_patients(i) = sum(patient_clusters == i);
end

[amount_biggest_clust, biggest_clust] = max(num_patients);
fprintf('Cluster più numeroso: Cluster %d (%d pazienti)\n', biggest_clust, amount_biggest_clust);

% Verifica presenza di entrambe le classi nel cluster più numeroso
clust_indices  = find(patient_clusters == biggest_clust);
clust_patients = dataset_var(clust_indices, :);
clust_classes  = dataset.class(clust_indices);

if any(clust_classes == 0) && any(clust_classes == 1)
    disp('CLUSTER ACCETTABILE (presenti entrambe le classi 0 e 1)');
else
    disp('CLUSTER NON ACCETTABILE');
end

%% STEP 2: Features - class correlation (Pearson)
num_features = width(dataset_var);
correlation  = corr(table2array(clust_patients), clust_classes, 'Type', 'Pearson', 'Rows', 'complete');
correlation(isnan(correlation)) = 0;

[sorted_correlation, sorted_indices] = sort(abs(correlation), 'descend');
Variables     = dataset_var.Properties.VariableNames;
best_features = Variables(sorted_indices(1:5));
disp('Top 5 feature più correlate (Pearson):');
disp(best_features);

%% STEP 3: ACO Parameters initialization
Max_iterations = 500;
tau            = 0.5;
alpha          = 1;
rho            = 0.2;
beta           = 2;
eta            = 1;
testRatio      = 0.3;

% Inizializzazione formiche (5 formiche x num_features)
num_ants  = 5;
init_ants = zeros(num_ants, num_features);
for i = 1:num_ants
    init_ants(i, sorted_indices(i)) = 1;
end

%% STEP 4: ACO implementation for Feature Selection
output_dir = fullfile('results', 'solutions');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

n_repetitions = 20;

for numero_cluster = 1:nClust
    clust_indices  = find(patient_clusters == numero_cluster);
    clust_patients = table2array(dataset_var(clust_indices, :));
    clust_classes  = dataset.class(clust_indices);

    % Salta cluster vuoti o con una sola classe
    if isempty(clust_classes) || ~(any(clust_classes == 0) && any(clust_classes == 1))
        continue;
    end

    % Suddivisione Hold-Out basata sul vettore delle classi
    HO = createHoldOutIndex(clust_classes, testRatio);

    for j = 1:n_repetitions
        [dataset_reduce, n_features, index_features, convergence_curve] = ...
            ACO_FS(clust_patients, clust_classes, num_ants, Max_iterations, tau, eta, alpha, beta, rho, HO, init_ants);

        save(fullfile(output_dir, sprintf('dataset_reduce_cluster=%d_ripetizione=%d.mat', numero_cluster, j)), 'dataset_reduce');
        save(fullfile(output_dir, sprintf('n_features_cluster=%d_ripetizione=%d.mat', numero_cluster, j)), 'n_features');
        save(fullfile(output_dir, sprintf('index_features_cluster=%d_ripetizione=%d.mat', numero_cluster, j)), 'index_features');
        save(fullfile(output_dir, sprintf('convergence_curve_cluster=%d_ripetizione=%d.mat', numero_cluster, j)), 'convergence_curve');
    end
end
