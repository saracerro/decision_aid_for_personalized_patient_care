clc
clear
close all

%% STEP 1: load and prepare data
clc

path = '/Users/antonellaalbanese/Desktop/università/DAPPC/LAB_DAPPC/LAB3/PatientClustersD_n15_neighbor1.mat';
load(path, 'patient_clusters');
nClust = 22;
path = '/Users/antonellaalbanese/Desktop/università/DAPPC/LAB_DAPPC/LAB3/dataset_weaning_prova.xlsx';
sheetName = "DATASET_Step3d";
% Read the Excel sheet
dataset = readtable(path, 'Sheet', sheetName);
dataset_var = dataset(:, 4:end-1);

for i=1:nClust
    patients = dataset_var(find(patient_clusters==i),:);
    num_patients (i) = size(patients, 1);
end

[amount_biggest_clust, biggest_clust] = max(num_patients);

% Verifica
clust_indices = find(patient_clusters == biggest_clust);
clust_patients = dataset(clust_indices, 4:end-1);
clust_classes = dataset(clust_indices, :).class;

if any(clust_classes == 0) && any(clust_classes == 1)
    disp('CLUSTER ACCETTABILE');
else 
    disp('CLUSTER NON ACCETTABILE');
end

%% STEP 2: Features - class correlation
num_features = 54;
correlation = corr(table2array(clust_patients), clust_classes, 'Type', 'Pearson');
[sorted_correlation, sorted_indices] = sort(abs(correlation), 'descend');
Variables = dataset_var.Properties.VariableNames;
best_features = Variables(sorted_indices(1:5));

%% STEP 3: ACO Parameters initialization
clc

Max_iterations = 500;
tau = 0.5;
alpha = 1;
rho = 0.2;
beta = 2;
eta = 1;

init_ants = zeros(num_features, 5);
init_ants = init_ants';
for i=1:5
    init_ants(i, sorted_indices(i)) = 1;
end


for numero_cluster=1:nClust
    % Verifica
    clust_indices = find(patient_clusters == numero_cluster);
    clust_patients = dataset(clust_indices, 4:end-1);
    clust_classes = dataset(clust_indices, :).class;
    HO = createHoldOutIndex(size(clust_patients, 1), 0.3);

    for j = 1:20
        clc
        [dataset_reduce, n_features, index_features, convergence_curve] = ACO_FS(clust_patients, clust_classes, 5, Max_iterations, tau, eta, alpha, beta, rho, HO, init_ants);

        save(['dataset_reduce_cluster=' num2str(numero_cluster) '_ripetizione=' num2str(j) '.mat'], 'dataset_reduce');
        save(['n_features_cluster=' num2str(numero_cluster) '_ripetizione=' num2str(j) '.mat'], 'n_features');
        save(['index_features_cluster=' num2str(numero_cluster) '_ripetizione=' num2str(j) '.mat'], 'index_features');
        save(['convergence_curve_cluster=' num2str(numero_cluster) '_ripetizione=' num2str(j) '.mat'], 'convergence_curve');
    end
end




