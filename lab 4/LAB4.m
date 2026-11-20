clc
clear
close all

path = '/Users/antonellaalbanese/Desktop/università/DAPPC/LAB_DAPPC/LAB3/PatientClustersD_n15_neighbor1.mat';
load(path, 'patient_clusters');
nClust = 22;
path = '/Users/antonellaalbanese/Desktop/università/DAPPC/LAB_DAPPC/dataset_weaning_prova.xlsx';
sheetName = "DATASET_Step3d";
% Read the Excel sheet
dataset = readtable(path, 'Sheet', sheetName);
dataset_var = dataset(:, 4:end-1);

for i=1:nClust
    patients = dataset_var(find(patient_clusters==i),:);
    num_patients (i) = size(patients, 1);
end

[sorted_num_patients, sorted_indices_num_patients] = sort(num_patients, 'descend');

variabili15 = {'subject_id','stay_id','ICU','MRH','NP','chloride_min_value','hemoglobin_min_value','heart_rate_max_value','heart_rate_trend','respiratory_rate_trend','mean_airway_pressure_max_value','class'};               % <--- Inserisci qui i nomi delle variabili che vuoi plottare
variabili6 = {'subject_id','stay_id','ICU','heart_rate_trend','mean_airway_pressure_max_value','sedation_days','respiratory_rate_trend','CPC','PT_min_value', 'heart_rate_min_value','tidal_volume_trend','class'};               % <--- Inserisci qui i nomi delle variabili che vuoi plottare
variabili14 = {'subject_id','stay_id','ICU','heart_rate_trend','mean_airway_pressure_min_value','sedatives','sedation_days','pH_max_value','respiratory_rate_min_value','PEEP_trend','tidal_volume_trend','class'};               % <--- Inserisci qui i nomi delle variabili che vuoi plottare

Cluster15 = dataset(patient_clusters==15, variabili15);
Cluster6 = dataset(patient_clusters==6, variabili6);
Cluster14 = dataset(patient_clusters==14, variabili14);

Cluster15_1 = Cluster15(Cluster15.class==1,:);
Cluster15_0 = Cluster15(Cluster15.class==0,:);
Cluster14_1 = Cluster14(Cluster14.class==1,:);
Cluster14_0 = Cluster14(Cluster14.class==0,:);
Cluster6_1 = Cluster6(Cluster6.class==1,:);
Cluster6_0 = Cluster6(Cluster6.class==0,:);

save('Dataset_rid_Cluster6.mat',"Cluster6");
save('Dataset_rid_Cluster14.mat',"Cluster14");
save('Dataset_rid_Cluster15.mat',"Cluster15");

%%
clust = 15;
class = 1;

Dendogram = linkage(table2array(Cluster15_1), 'complete', 'cityblock');
dendrogram(Dendogram, 0, 'ColorThreshold');

flag = 'n';
while strcmpi(flag, 'n')
    nclust = input('Inserisci il numero di cluster desiderato: ');
    
    % Dendrogramma
    fig1 = figure;
    dendrogram(Dendogram, 0,'ColorThreshold',Dendogram(end-nclust+2,3));
    hold on
    yline(Dendogram(end - nclust + 2, 3), '--r', 'Taglio cluster');

    % Calcolo cluster
    clusters=cluster(Dendogram,'maxclust',nclust);
    
    flag = input('Il numero di cluster ci piace? (y/n): ', 's');

   % Se confermato, salva le figure
    if strcmpi(flag, 'y')
        %saveas(fig1, ['Dendrogram' num2str(clust) '_class' num2str(class) '_nclust=' num2str(nclust) '.png']);
        %save(['Clusters' num2str(clust) '_class' num2str(class) '_nclust=' num2str(nclust) '.mat'],'clusters');
    end

    close all;
end

%% CENTROIDI
clc
close all

variabili15 = {'MRH','NP','chloride_min_value','hemoglobin_min_value','heart_rate_max_value','heart_rate_trend','respiratory_rate_trend','mean_airway_pressure_max_value'};               % <--- Inserisci qui i nomi delle variabili che vuoi plottare
variabili6 = {'heart_rate_trend','mean_airway_pressure_max_value','sedation_days','respiratory_rate_trend','CPC','PT_min_value', 'heart_rate_min_value','tidal_volume_trend'};               % <--- Inserisci qui i nomi delle variabili che vuoi plottare
variabili14 = {'heart_rate_trend','mean_airway_pressure_min_value','sedatives','sedation_days','pH_max_value','respiratory_rate_min_value','PEEP_trend','tidal_volume_trend'};               % <--- Inserisci qui i nomi delle variabili che vuoi plottare


load("Clusters15_class1_nclust=10.mat");


cluster1 = 15;
class = 1;
nclust = 10;

Cl = Cluster15_1(:,4:end-1);
%Cl_array = table2array(Cl);
centroid = zeros(nclust, size(Cl,2));
centroid = array2table(centroid, 'VariableNames',variabili15);

for i=1:nclust
     indexes = find(clusters==i);
     centroid(i,:) = mode(Cl(indexes,:));
end

%save(['Centroidi_norm_cluster' num2str(cluster1) '_class' num2str(class) '.mat'],"centroid");

%% denormalizzazione
clc
close

load("Centroidi_norm_cluster15_class1.mat");

cluster1 = 15;
class = 1;

% === Parametri ===
filename = 'dataset_weaning_prova.xlsx';
sheet_normalized = 'DATASET_Step3d';   % Dataset normalizzato
sheet_original    = 'DATASET_V1';      % Dataset originale
colsToDenormalize = 4:57;              % Colonne delle feature (modifica se serve)

% === Lettura dei dataset ===
dataset_norm = readtable(filename, 'Sheet', sheet_normalized);
dataset_orig = readtable(filename, 'Sheet', sheet_original);
varNames = dataset_orig.Properties.VariableNames;
varNames = varNames(4:end-1);

% === Calcolo min e max dalle colonne originali ===
min_val = min(dataset_orig{:, colsToDenormalize}, [], 1, 'omitnan');
max_val = max(dataset_orig{:, colsToDenormalize}, [], 1, 'omitnan');

min_val = array2table(min_val,"VariableNames",varNames);
max_val = array2table(max_val,"VariableNames",varNames);

% === Denormalizzazione ===
var_giuste = centroid.Properties.VariableNames;

centroid_denorm = centroid;  % Copia del dataset normalizzato
for i = 1:size(centroid,2)
    col = var_giuste{i};
    centroid_denorm{:, col} = centroid{:, col} .* (max_val{1,col} - min_val{1,col}) + min_val{1,col};
end

save(['Centroidi_denorm_cluster' num2str(cluster1) '_class' num2str(class) '.mat'],"centroid_denorm");


%%
clc
close all
clear
load('Centroidi_denorm_cluster6_class0.mat')
