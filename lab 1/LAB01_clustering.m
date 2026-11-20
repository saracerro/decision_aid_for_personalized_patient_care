%-------------------------------------------------------------------%
%               DECISION AID FOR PERSONALIZED PATIENT CARE          %
%                  LAB 01 PART 2 - DATASET PREPARATION              %
%-------------------------------------------------------------------%
% Author: Alessandra Introvaia - alessandra.introvaia@polito.it     %
% Creation date: 17/03/2025                                         %
% Last modification: 20/03/2025 (AI)                                %
%-------------------------------------------------------------------%
% This script loads a dataset from an Excel sheet and performs      %
% missing data imputation.                                          %
% The script updates the Excel sheet with the completed dataset.    %
%-------------------------------------------------------------------%
% Parameter to be specified:                                        %
% - path: file path of the Excel FILE (.xlsx)                       %
%-------------------------------------------------------------------%

clear 
close all
clc

%% Dataset Loading

% Specify the path of the Excel sheet
path = '.../dataset_weaning_prova.xlsx';
% Read the Excel sheet
dataset = readtable(path, 'Sheet', "DATASET_V1");
fprintf('Original dataset: %d rows, %d columns. Total missing values: %d \n', size(dataset,1), size(dataset,2), sum(ismissing(dataset),"all"));

%% Dataset organization for imputation
% in this section the ID of the rows and the class are extracted from the
% dataset so in the dataset only the input features are mantained

IDs = dataset(:,1:3);
class = dataset(:,end);
inputFeatures = dataset(:,4:end-1);
% Identify which features contain missing values and how many
missingValues = array2table(sum(ismissing(inputFeatures),1), 'VariableNames', inputFeatures.Properties.VariableNames);
% Keep only columns with missing values greater than 0
missingValues = missingValues(:, missingValues{1,:} > 0);

%% Imputation with clustering with all patients

minimo = min(dataset(:, 4:end-1));
massimo = max(dataset(:, 4:end-1));

% Normalizzo il dataset
dataset_norm = (inputFeatures - minimo)./(massimo - minimo);

dataset_norm = [IDs, dataset_norm, class];
inputFeatures = dataset_norm(:,4:end-1);

class0_index = find(any(class{:,:} == 0, 2));
class1_index = find(any(class{:,:} == 1, 2));

inputFeatures0 = inputFeatures(class0_index,:);
inputFeatures1 = inputFeatures(class1_index,:);

% Costruisco TRS
featuresNames = missingValues.Properties.VariableNames;
Full_features = dataset_norm(:, ~ismember(dataset_norm.Properties.VariableNames, featuresNames));
Full_features = Full_features(:, 4:end-1);
TRS = inputFeatures(:,:);

for i = 1:length(featuresNames)
    feature = featuresNames{i};

    missingRows = ismissing(TRS.(feature));  % Identifica le righe con valori mancanti
    missingIndices = find(missingRows);

    TRS = TRS(~missingRows, :);
end

TRS_array = table2array(TRS);
Dendogram_tree = linkage(TRS_array, 'complete', 'cityblock');


NumClusters = 20;
figure;
dendrogram(Dendogram_tree, 0, 'ColorThreshold',Dendogram_tree(end-NumClusters+2,3));
hold on
yline(Dendogram_tree(end - NumClusters + 2, 3), '--r', 'Taglio cluster');
saveas(gcf, ['Dendrogram_TRS' '.png']);
Assignment = cluster(Dendogram_tree, 'MaxClust', NumClusters);

% Calcolo centroidi
centroids = zeros(NumClusters, size(TRS, 2));

for k=1:NumClusters
    indexes = find(Assignment==k);
    centroids(k,:) = mean(TRS_array(indexes, :),1);
end

missingTable = ismissing(inputFeatures);
missingRows = any(missingTable(:,:), 2);  % Identifica le righe con valori mancanti
missingIndices = find(missingRows);

missing_dataset = Full_features(missingIndices, :);
missing_dataset_array = table2array(missing_dataset);
distance = pdist2(missing_dataset_array, centroids(:, ~ismember(inputFeatures.Properties.VariableNames, featuresNames)), 'cityblock');

for m = 1:size(distance, 1)
    patient_distance(m,1) = min(distance(m, :));
    patient_cluster(m,1) = find(distance(m,:) == patient_distance(m,1), 1);
end

AllColumnsNames = dataset_norm.Properties.VariableNames;
ContinuousVariables = AllColumnsNames([16, 17, 19, 20, 22, 23, 25, 26, 28, 29, 31, 32, 34, 35, 37, 38, 40, 41, 43, 44, 46, 47, 49, 50, 52, 53, 55, 56]);
CategoricalBinaryVariables = AllColumnsNames([4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57]);


% PROVA
for p = 1:size(missingIndices, 1)
    rowIdx = missingIndices(p);
    conta_missing = sum(missingTable(rowIdx,:));
    for g = 1:conta_missing
        missingColumnIndex = find(missingTable(rowIdx, :) == 1, 1);
        missingTable(rowIdx, missingColumnIndex) = 0;
        ClusterNumber = patient_cluster(p);
        ImputationValues = TRS(Assignment==ClusterNumber, missingColumnIndex);
        colName = inputFeatures.Properties.VariableNames{missingColumnIndex}; 
        ImputationValues_array = table2array(ImputationValues);
        if ismember(colName, ContinuousVariables)
            inputFeatures{rowIdx, missingColumnIndex} = mean(ImputationValues_array, 'omitnan');
        end
        if ismember(colName, CategoricalBinaryVariables)
            inputFeatures{rowIdx, missingColumnIndex} = median(ImputationValues_array, 'omitnan');
            if (inputFeatures{rowIdx, missingColumnIndex} ~= 0) && (inputFeatures{rowIdx, missingColumnIndex} ~= 1)
                inputFeatures{rowIdx, missingColumnIndex} = mode(ImputationValues_array);
            end
        end
    end
end

% Helpful functions: 
% - linkage: Compute the agglomerative hierarchical cluster tree
% - dendrogram: Allow to visualize the cluster tree (set P = 0)
% - cluster: Construct agglomerative clusters from a cluster tree (set the
%   'MaxClust' or the 'Cutoff' parameter)
% - pdist2: Compute distances between matrices (set the 'Distance' 
%   parameter to 'cityblock' for L1, to 'chebychev' for Linf). Otherwise
%   you can use the function pdist to compute the distances between a
%   vector and a matrix


%% Save the completed dataset

% Re-organize the dataset as the original one
dataset_complete = [IDs, inputFeatures, class];


% Save the dataset obtained
fprintf('Completed dataset: %d rows, %d columns. Total missing values: %d \n', size(dataset_complete,1), size(dataset_complete,2), sum(ismissing(dataset_complete),"all"));
writetable(dataset_complete, path, 'Sheet', 'DATASET_Step3c');
disp('Saving completed.')


%% Imputation with clustering separately with patients of class 0 and class 1

% Repeat the operations implemented for STEP3(b) by dividing the patients 
% with respect to class (class 0 and class 1). For each class, 
% perform the imputation based on the hierarchical clustering approach.

% Costruisco TRS
Full_features0 = Full_features(class0_index, :);
Full_features1 = Full_features(class1_index, :);

TRS0 = inputFeatures0(:,:);
TRS1 = inputFeatures1(:,:);

for i = 1:length(featuresNames)
    feature = featuresNames{i};

    missingRows0 = ismissing(TRS0.(feature));  % Identifica le righe con valori mancanti
    missingIndices0 = find(missingRows0);
    TRS0 = TRS0(~missingRows0, :);

    missingRows1 = ismissing(TRS1.(feature));  % Identifica le righe con valori mancanti
    missingIndices1 = find(missingRows1);
    TRS1 = TRS1(~missingRows1, :);
end

TRS0_array = table2array(TRS0);
TRS1_array = table2array(TRS1);

Dendogram_tree0 = linkage(TRS0_array, 'complete', 'cityblock');
Dendogram_tree1 = linkage(TRS1_array, 'complete', 'cityblock');
figure;
dendrogram(Dendogram_tree0, 0, 'ColorThreshold',Dendogram_tree0(end-NumClusters+2,3));
hold on
yline(Dendogram_tree0(end - NumClusters + 2, 3), '--r', 'Taglio cluster');
saveas(gcf, ['Dendrogram_TRS0' '.png']);
figure;
dendrogram(Dendogram_tree1, 0, 'ColorThreshold',Dendogram_tree1(end-NumClusters+2,3));
hold on
yline(Dendogram_tree1(end - NumClusters + 2, 3), '--r', 'Taglio cluster');
saveas(gcf, ['Dendrogram_TRS1' '.png']);

Assignment0 = cluster(Dendogram_tree0, 'MaxClust', NumClusters);
Assignment1 = cluster(Dendogram_tree1, 'MaxClust', NumClusters);


% Calcolo centroidi
centroids0 = zeros(NumClusters, size(TRS0, 2));
centroids1 = zeros(NumClusters, size(TRS1, 2));

for k=1:NumClusters
    indexes0 = find(Assignment0==k);
    centroids0(k,:) = mean(TRS0_array(indexes0, :),1);

    indexes1 = find(Assignment1==k);
    centroids1(k,:) = mean(TRS1_array(indexes1, :),1);
end

missingTable0 = ismissing(inputFeatures0(:,:));
missingTable1 = ismissing(inputFeatures1(:,:));
missingRows0 = any(missingTable0(:,:), 2);  
missingRows1 = any(missingTable1(:,:), 2);  
missingIndices0 = find(missingRows0);
missingIndices1 = find(missingRows1);

missing_dataset0 = Full_features(missingIndices0, :);
missing_dataset1 = Full_features(missingIndices1, :);
missing_dataset0_array = table2array(missing_dataset0);
missing_dataset1_array = table2array(missing_dataset1);
distance0 = pdist2(missing_dataset0_array, centroids0(:, ~ismember(inputFeatures0.Properties.VariableNames, featuresNames)), 'cityblock');
distance1 = pdist2(missing_dataset1_array, centroids1(:, ~ismember(inputFeatures1.Properties.VariableNames, featuresNames)), 'cityblock');

for m = 1:size(distance0, 1)
    patient_distance0(m,1) = min(distance0(m, :));
    patient_cluster0(m,1) = find(distance0(m,:) == patient_distance0(m,1), 1);
end

for f = 1:size(distance1, 1)
    patient_distance1(f,1) = min(distance1(f, :));
    patient_cluster1(f,1) = find(distance1(f,:) == patient_distance1(f,1), 1);
end

% PROVA
for p = 1:size(missingIndices0, 1)
    rowIdx0 = missingIndices0(p);
    conta_missing0 = sum(missingTable0(rowIdx0,:));
    for g = 1:conta_missing0
        missingColumnIndex0 = find(missingTable0(rowIdx0, :) == 1, 1);
        missingTable0(rowIdx0, missingColumnIndex0) = 0;
        ClusterNumber0 = patient_cluster0(p);
        ImputationValues0 = TRS0(Assignment0==ClusterNumber0, missingColumnIndex0);
        colName0 = inputFeatures0.Properties.VariableNames{missingColumnIndex0}; 
        ImputationValues0_array = table2array(ImputationValues0);
        if ismember(colName0, ContinuousVariables)
            inputFeatures0{rowIdx0, missingColumnIndex0} = mean(ImputationValues0_array, 'omitnan');
        end
        if ismember(colName0, CategoricalBinaryVariables)
            inputFeatures0{rowIdx0, missingColumnIndex0} = median(ImputationValues0_array, 'omitnan');
        end
    end
end

for d = 1:size(missingIndices1, 1)
    rowIdx1 = missingIndices1(d);
    conta_missing1 = sum(missingTable1(rowIdx1,:));
    for g = 1:conta_missing1
        missingColumnIndex1 = find(missingTable1(rowIdx1, :) == 1, 1);
        missingTable1(rowIdx1, missingColumnIndex1) = 0;
        ClusterNumber1 = patient_cluster1(d);
        ImputationValues1 = TRS1(Assignment1==ClusterNumber1, missingColumnIndex1);
        colName1 = inputFeatures.Properties.VariableNames{missingColumnIndex1}; 
        ImputationValues1_array = table2array(ImputationValues1);
        if ismember(colName1, ContinuousVariables)
            inputFeatures1{rowIdx1, missingColumnIndex1} = mean(ImputationValues1_array, 'omitnan');
        end
        if ismember(colName1, CategoricalBinaryVariables)
            inputFeatures1{rowIdx1, missingColumnIndex1} = median(ImputationValues1_array, 'omitnan');
        end
    end
end



%% Save the completed dataset

% Re-organize the dataset as the original one
inputFeatures_01 = [inputFeatures0; inputFeatures1];
dataset_complete_01 = [IDs, inputFeatures_01, class];

% Save the dataset obtained
fprintf('Completed dataset: %d rows, %d columns. Total missing values: %d \n', size(dataset_complete,1), size(dataset_complete,2), sum(ismissing(dataset_complete),"all"));
writetable(dataset_complete, path, 'Sheet', 'DATASET_Step3d');
disp('Saving completed.')

