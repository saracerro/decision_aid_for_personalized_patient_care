%-------------------------------------------------------------------%
%               DECISION AID FOR PERSONALIZED PATIENT CARE          %
%                      LAB 02 - CLUSTERING WITH SOMs                %
%-------------------------------------------------------------------%
% Author: Alessandra Introvaia - alessandra.introvaia@polito.it     %
% Creation date: 27/03/2025                                         %
% Last modification: 31/03/2025 (AI)                                %
%-------------------------------------------------------------------%
% This script aims to implement a clustering method based on SOMs.  %
%-------------------------------------------------------------------%
% Parameters to be specified:                                       %
% - path: ....                                                      %
% - sheetName: name of dataset SHEET with the imputed dataset       %
%-------------------------------------------------------------------%

clear 
close all
clc


% Dataset Loading 

%% Specify the path of the Excel sheet
path = 'C:\Users\Utente\OneDrive - Politecnico di Torino\Desktop\Polito\DAPPC\LAB_2\dataset_weaning_prova.xlsx';
sheetName = "DATASET_Step3a";
% Read the Excel sheet
dataset = readtable(path, 'Sheet', sheetName);
fprintf('Original dataset: %d rows, %d columns. Total missing values: %d \n', size(dataset,1), size(dataset,2), sum(ismissing(dataset),"all"));

%% Patients division based on the class
% 
% class0 = dataset(dataset.class == 0,:);
% class1 = dataset(dataset.class == 1,:);
% 
% Normalize the features
num_colonne = 4:54;
num_variabili = numel(num_colonne);

% Inizializzazione degli array per min e max
min_val = zeros(1, num_variabili);
max_val = zeros(1, num_variabili);

dataset_norm = dataset(:,4:end-1);

% Calcolo dei valori minimi e massimi
for i = 1:num_variabili  % Ciclo su 1:num_variabili per evitare problemi di indicizzazione
    col_idx = num_colonne(i); % Otteniamo l'indice reale della colonna
    min_val(i) = min(dataset{:, col_idx});
    max_val(i) = max(dataset{:, col_idx});
end

% Normalizzazione 
for i = 1:num_variabili
    col_idx = num_colonne(i);

    % Evita divisioni per zero
    if max_val(i) ~= min_val(i)
        dataset_norm{:, col_idx} = (dataset{:, col_idx} - min_val(i)) / (max_val(i) - min_val(i));
    else
        dataset_norm{:, col_idx} = 0; % Se min = max, assegna 0
    end
end

 
%% Normalizzazione delle classi separatamente
% 
% % Inizializzazione degli array per min e max
% min_val = zeros(1, num_variabili);
% max_val = zeros(1, num_variabili);
% 
% %CLASSE 0
% class0_norm = class0(:,4:end-1);
% 
% 
% % Calcolo dei valori minimi e massimi
% for i = 1:num_variabili  % Ciclo su 1:num_variabili per evitare problemi di indicizzazione
%     col_idx = num_colonne(i); % Otteniamo l'indice reale della colonna
%     min_val(i) = min(class0{:, col_idx});
%     max_val(i) = max(class0{:, col_idx});
% end
% 
% % Normalizzazione
% for i = 1:num_variabili
%     col_idx = num_colonne(i);
% 
%     % Evita divisioni per zero
%     if max_val(i) ~= min_val(i)
%         class0_norm{:, col_idx} = (class0{:, col_idx} - min_val(i)) / (max_val(i) - min_val(i));
%     else
%         class0_norm{:, col_idx} = 0; % Se min = max, assegna 0
%     end
% end
% 
% %CLASSE 1
% class1_norm = class1(:,4:end-1);
% 
% % Calcolo dei valori minimi e massimi
% for i = 1:num_variabili  % Ciclo su 1:num_variabili per evitare problemi di indicizzazione
%     col_idx = num_colonne(i); % Otteniamo l'indice reale della colonna
%     min_val(i) = min(class1{:, col_idx});
%     max_val(i) = max(class1{:, col_idx});
% end
% 
% % Normalizzazione 
% for i = 1:num_variabili
%     col_idx = num_colonne(i);
% 
%     % Evita divisioni per zero
%     if max_val(i) ~= min_val(i)
%         class1_norm{:, col_idx} = (class1{:, col_idx} - min_val(i)) / (max_val(i) - min_val(i));
%     else
%         class1_norm{:, col_idx} = 0; % Se min = max, assegna 0
%     end
% end




% SOM construction
% In this section, you will construct, train, and use a Self-Organizing Map (SOM)  
% to identify clusters of patients. 
% The main steps are:  
%  
% 1. Define the dimensions of the SOM (square SOM).  
% 2. Create the SOM architecture (see function: selforgmap(...)).  
% 3. Train the SOM and save the trained network (see function: train(...)).  
% 4. Extract the weight matrix from the trained network and use hierarchical clustering:  
%    - Retrieve the weight vectors of the SOM neurons (weights = som.IW{1,1}, where som if the trained netowrk).
%    - Compute the agglomerative hierarchical cluster tree (function: linkage(...)).  
%    - Create, visualize and cut the dendrogram (function: dendrogram(...)). 
%    - Identify clusters of neurons (function: cluster(...)
% 5. Analyze the results:  
%    - Visualize the Sample Hits to observe neuron activation (see function: plotsomhits(...)).  
%    - Check 'bubbles of neurons' integrity: remember that a bubble is defined
%      as a group of neighboring neurons (use function plot_som_clusters (...) 
%      to visualize them upon the Sample Hits plot).  
% 6. Assign patients to clusters: each patient is assigned to a cluster based on its winner neuron. 
% 7. Save the clusters of patients obtained as you prefer (excel sheet,
%   .mat files, .csv files, etc.)

%% VICINATO = 1
n = 10;
neighbour =1;

selfOrgMap = selforgmap([n n],'initNeighbor',neighbour);
trainedNet = train(selfOrgMap,table2array(dataset_norm)');
weights = trainedNet.IW{1,1};
Dendogram_tree = linkage(weights, 'complete', 'cityblock');
figure;
dendrogram(Dendogram_tree, 0);
saveas(gcf, ['DendrogramA_n' num2str(n) '_neighbor' num2str(neighbour) '.png']);
title(['Dendrogram - n = ', num2str(n)]);

flag = 'n';

while strcmpi(flag, 'n')
    nclust = input('Inserisci il numero di cluster desiderato: ');
    %nclust=7; %numero di cluster
    figure;
    dendrogram(Dendogram_tree, 0,'ColorThreshold',Dendogram_tree(end-nclust+2,3));
    saveas(gcf, ['DendrogramA_COLORED_n' num2str(n) '_neighbor' num2str(neighbour) '.png']);
    clusters=cluster(Dendogram_tree,'maxclust',nclust);
    figure;
    plotsomhits(trainedNet, table2array(dataset_norm)');
    plot_som_clusters(clusters,n,nclust);
    saveas(gcf, ['SOM_ClustersA_n' num2str(n) '_neighbor' num2str(neighbour) '.png']);
    flag = input('Il numero di cluster è valido? (y/n): ', 's');
    close all;
end

% % Aspetta conferma prima di continuare
% disp('Controlla i plot. Premi un tasto per procedere al prossimo valore di n...');
% pause;
winner_neurons = vec2ind(trainedNet(table2array(dataset_norm)'));
% % Trova il neurone vincente per ciascun paziente
% Assegna il cluster al paziente in base al neurone vincente
patient_clusters = clusters(winner_neurons);

% Salvataggio variabili
save(['SelfOrgMapA_n' num2str(n) '_neighbor' num2str(neighbour) '.mat'], 'selfOrgMap');
save(['PatientClustersA_n' num2str(n) '_neighbor' num2str(neighbour) '.mat'], 'patient_clusters');


%% TAGLI MULTIPLI
clusters([2 3 12]) = 10;
nclust = 10;
plotsomhits(trainedNet, table2array(dataset_norm)');
plot_som_clusters(clusters,n,nclust);
saveas(gcf, ['SOM_ClustersA_n' num2str(n) '_neighbor' num2str(neighbour) '.png']);

%%
% %%
% % VICINATO = 2
% for n=10:15
%     selfOrgMap = selforgmap([n n],'initNeighbor',2);
% 
%     trainedNet = train(selfOrgMap,table2array(dataset_norm)');
%     weights = trainedNet.IW{1,1};
%     Dendogram_tree = linkage(weights, 'complete', 'cityblock');
%     figure;
%     dendrogram(Dendogram_tree,0,'ColorThreshold',25);
%     title(['Dendrogram - n = ', num2str(n)]);
% 
%         flag = 'n';
% 
%     while strcmpi(flag, 'n')
%         nclust = input('Inserisci il numero di cluster desiderato: ');
%         %nclust=7; %numero di cluster
%         figure;
%         dendrogram(Dendogram_tree, 0,'ColorThreshold',Dendogram_tree(end-nclust+1,3));
%         saveas(gcf, ['DendrogramA_n' num2str(n) '_neighbor2.png']);
%         clusters=cluster(Dendogram_tree,'maxclust',nclust);
%         figure;
%         plotsomhits(trainedNet, table2array(dataset_norm)');
%         plot_som_clusters(clusters,n,nclust);
%         flag = input('Il numero di cluster è valido? (y/n): ', 's');
%         close all;
%     end
% 
%     % Aspetta conferma prima di continuare
%     disp('Controlla i plot. Premi un tasto per procedere al prossimo valore di n...');
%     pause;
%     % Trova il neurone vincente per ciascun paziente
%     winner_neurons = vec2ind(trainedNet(table2array(dataset_norm)'));
%     % Assegna il cluster al paziente in base al neurone vincente
%     patient_clusters = clusters(winner_neurons);
% 
%     % Salvataggio variabili
%     save(['SelfOrgMapA_n' num2str(n) '_neighbor2.mat'], 'selfOrgMap');
%     save(['PatientClustersA_n' num2str(n) '_neighbor2.mat'], 'patient_clusters');
%     saveas(gcf, ['SOM_ClustersA_n' num2str(n) '_neighbor2.png']);
% end
    












