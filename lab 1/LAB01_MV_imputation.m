%-------------------------------------------------------------------%
%               DECISION AID FOR PERSONALIZED PATIENT CARE          %
%               LAB 01 - DATA CLEANING & MISSING IMPUTATION         %
%-------------------------------------------------------------------%
% Author: Alessandra Introvaia - alessandra.introvaia@polito.it     %
% Creation date: 12/03/2025                                         %
% Last modification: 20/03/2025 (AI)                                %
%-------------------------------------------------------------------%
% This script loads a dataset from an Excel sheet, performs data    %
% cleaning (STEP 1 & STEP 2) and missing data imputation            %
% (STEP 3a, 3b, 3c, 3d).                                            %
% The script updates the Excel file with the completed datasets.    %
%-------------------------------------------------------------------%
% Parameter to be specified:                                        %
% - path: file path of the Excel FILE (.xlsx)                       %
%-------------------------------------------------------------------%

clear 
close all
clc

%% Dataset Loading & Initial Cleaning (STEP 1 & STEP 2)

% Specify the path of the Excel sheet (relative path for GitHub)
path = 'dataset_weaning.xlsx';

% Load raw sheet 'DATASET' (3329 patients, 85 columns)
raw_dataset = readtable(path, 'Sheet', "DATASET");
fprintf('Raw dataset: %d rows, %d columns. Total missing values: %d \n', ...
    size(raw_dataset,1), size(raw_dataset,2), sum(ismissing(raw_dataset),"all"));

% STEP 1: Delete feature columns (4 to 84) with at least 200 missing values
IDs_raw = raw_dataset(:, 1:3);
features_raw = raw_dataset(:, 4:end-1);
class_raw = raw_dataset(:, end);

col_missing = sum(ismissing(features_raw), 1);
features_step1 = features_raw(:, col_missing < 200);
dataset_step1 = [IDs_raw, features_step1, class_raw];

% STEP 2: Delete rows (patients) with at least 20 missing values
row_missing = sum(ismissing(features_step1), 2);
dataset = dataset_step1(row_missing < 20, :);

% Save cleaned dataset as 'DATASET_V1'
writetable(dataset, path, 'Sheet', 'DATASET_V1');
fprintf('Cleaned dataset (DATASET_V1): %d rows, %d columns. Total missing values: %d \n', ...
    size(dataset,1), size(dataset,2), sum(ismissing(dataset),"all"));

%% Dataset organization for imputation
% In this section the IDs and the class are extracted so that the
% dataset contains only the input features to be imputed.

IDs = dataset(:,1:3);
class = dataset(:,end);
inputFeatures = dataset(:,4:end-1);

% Backup the original input features for later use in the next steps
inputFeatures_original = inputFeatures;

% Identify which features contain missing values and how many
missingValues = array2table(sum(ismissing(inputFeatures),1), ...
    'VariableNames', inputFeatures.Properties.VariableNames);
% Keep only columns with missing values > 0
missingValues = missingValues(:, missingValues{1,:} > 0);
% attraverso i due missingValues contiamo quanti valori mancanti ci sono
% in ogni colonna mantenendo solo le colonne che hanno almeno un valore
% mancante

%% kNN Imputation with all patients (STEP3a)

% For each feature with at least one missing value:
% 1. Identify rows with missing values.
% 2. Create a training set (TRS) by selecting rows without a missing value 
%    in that feature and then restrict the predictor set to only the columns 
%    that are complete (i.e. contain no missing values in these rows).
% 3. Train a kNN regressor (here, with k = 5) where the outcome is the 
%    feature to be imputed.
% 4. Predict and impute the missing values.

k = 5; % number of neighbors
varNamesMV = missingValues.Properties.VariableNames; % prende i nomi delle colonne contenenti missing values

for i = 1:length(varNamesMV) % ciclo che agisce solo sulle colonne contenenti missing values
    % partiamo con l'identificazione delle righe che hanno dati mancanti
    % nella colonna corrente che il ciclo for sta analizzando
    col_name = varNamesMV{i}; % identifica l'i-esima colonna che contengono Missing Values (MV)
    missing_idx = find(ismissing(inputFeatures.(col_name))); % trova gli indici delle righe con MV
    if ~isempty(missing_idx) % il " ~ " indica una negazione, quindi "se trovi righe con MV ...."
        % Select training rows (rows without missing in the current feature)
        training_idx = setdiff(1:height(inputFeatures), missing_idx); % seleziona tutte le altre righe, quindi quelle senza MV
        
        % Determine predictors: use only those columns that are complete 
        % in the training set.
        % selezioniamo solo le colonne che NON hanno MV nelle righe di
        % training escludendo la colonna corrente (che è da imputare)
        complete_vars = inputFeatures.Properties.VariableNames(all(~ismissing(inputFeatures{training_idx, :}), 1));
        % Exclude the target column from predictors
        predictors = setdiff(complete_vars, {col_name});
        
        if isempty(predictors) % verifica della disponibilità di predittori, se non ci sono colonne complete, l'imputazione viene saltata per quella colonna
            warning('No complete predictors available for imputation of feature %s. Skipping imputation for this feature.', col_name);
            continue;
        end
        
        % Questo è l'addestramento del modello kNN e previsione dei valori
        % mancanti. In particolare questo modello kNN implementato viene
        % addestrato sui dati completi X_train e y_train
        X_train = inputFeatures{training_idx, predictors};
        y_train = inputFeatures{training_idx, col_name};
        
        % Prepare test data (rows with missing value)
        X_test = inputFeatures{missing_idx, predictors}; % X_test sono le righe con MV e y_pred la predizione per queste righe
        
        % Train the kNN regressor and predict missing values
        mdl = fitcknn(X_train, y_train, 'NumNeighbors', k, 'Standardize', true);
        
        % qui avviene la sostituzione dei dati mancanti con i valori previsti
        y_pred = predict(mdl, X_test);
        inputFeatures{missing_idx, col_name} = y_pred;
    end
end

%% Save the completed dataset (STEP3a)

% Re-organize the dataset as the original one
dataset_complete = [IDs, inputFeatures, class];
fprintf('Completed dataset (all patients - Step3a): %d rows, %d columns. Total missing values: %d \n', ...
    size(dataset_complete,1), size(dataset_complete,2), sum(ismissing(dataset_complete),"all"));
writetable(dataset_complete, path, 'Sheet', 'DATASET_Step3a');
disp('Saving of STEP3a completed.')

%% Imputation using kNN separately with patients of class 0 and class 1 (STEP3b)

% Revert to the original input features (with missing values)
inputFeatures = inputFeatures_original;

% Get unique class labels (assumed numeric)
unique_classes = unique(class{:,1});
for c = 1:length(unique_classes)
    curr_class = unique_classes(c);
    % Find indices for patients in the current class
    class_idx = find(class{:,1} == curr_class);
    
    % Loop through every feature in the input features table
    for i = 1:width(inputFeatures)
        col_name = inputFeatures.Properties.VariableNames{i};
        % Identify rows within the current class that have missing values
        missing_idx_class = class_idx(ismissing(inputFeatures{class_idx, col_name}));
        if ~isempty(missing_idx_class)
            % Select training rows within the current class that are complete 
            % for the current feature
            training_idx_class = setdiff(class_idx, missing_idx_class);
            
            % Determine predictors: only those columns that are complete in the training set for this class
            complete_vars = inputFeatures.Properties.VariableNames(...
                all(~ismissing(inputFeatures{training_idx_class, :}), 1));
            predictors = setdiff(complete_vars, {col_name});
            
            if isempty(predictors)
                warning('No complete predictors available for imputation of feature %s in class %d. Skipping imputation for this feature.', col_name, curr_class);
                continue;
            end
            
            % Prepare training and test data for the current class subset
            X_train = inputFeatures{training_idx_class, predictors};
            y_train = inputFeatures{training_idx_class, col_name};
            X_test = inputFeatures{missing_idx_class, predictors};
            
            % Train kNN regressor and predict missing values for current class
            mdl = fitcknn(X_train, y_train, 'NumNeighbors', k, 'Standardize', true);

            y_pred = predict(mdl, X_test);
            std_noise = std(y_train, 'omitnan');
            noise = randn(size(y_pred)) * std_noise;
            y_pred_noisy = abs(y_pred + noise);
            y_pred_noisy = round(y_pred_noisy, 2);
            inputFeatures{missing_idx_class, col_name} = y_pred_noisy;
        end
    end
end

%% Save the completed dataset (STEP3b)

% Re-organize the dataset as the original one
dataset_complete = [IDs, inputFeatures, class];
fprintf('Completed dataset (class-wise imputation - Step3b): %d rows, %d columns. Total missing values: %d \n', ...
    size(dataset_complete,1), size(dataset_complete,2), sum(ismissing(dataset_complete),"all"));
writetable(dataset_complete, path, 'Sheet', 'DATASET_Step3b');
disp('Saving of STEP3b completed.')

%% Imputation with clustering with all patients (STEP3c)

% Revert to the original input features (with missing values)
inputFeatures = inputFeatures_original;

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

%% Save the completed dataset (STEP3c)

% Re-organize the dataset as the original one
dataset_complete = [IDs, inputFeatures, class];

% Save the dataset obtained
fprintf('Completed dataset (clustering all patients - Step3c): %d rows, %d columns. Total missing values: %d \n', ...
    size(dataset_complete,1), size(dataset_complete,2), sum(ismissing(dataset_complete),"all"));
writetable(dataset_complete, path, 'Sheet', 'DATASET_Step3c');
disp('Saving of STEP3c completed.')

%% Imputation with clustering separately with patients of class 0 and class 1 (STEP3d)

% Repeat the operations implemented for STEP3(c) by dividing the patients 
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
    TRS0 = TRS0(~missingRows0, :);

    missingRows1 = ismissing(TRS1.(feature));  % Identifica le righe con valori mancanti
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

missing_dataset0 = Full_features0(missingIndices0, :);
missing_dataset1 = Full_features1(missingIndices1, :);
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
            if (inputFeatures0{rowIdx0, missingColumnIndex0} ~= 0) && (inputFeatures0{rowIdx0, missingColumnIndex0} ~= 1)
                inputFeatures0{rowIdx0, missingColumnIndex0} = mode(ImputationValues0_array);
            end
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
        colName1 = inputFeatures1.Properties.VariableNames{missingColumnIndex1}; 
        ImputationValues1_array = table2array(ImputationValues1);
        if ismember(colName1, ContinuousVariables)
            inputFeatures1{rowIdx1, missingColumnIndex1} = mean(ImputationValues1_array, 'omitnan');
        end
        if ismember(colName1, CategoricalBinaryVariables)
            inputFeatures1{rowIdx1, missingColumnIndex1} = median(ImputationValues1_array, 'omitnan');
            if (inputFeatures1{rowIdx1, missingColumnIndex1} ~= 0) && (inputFeatures1{rowIdx1, missingColumnIndex1} ~= 1)
                inputFeatures1{rowIdx1, missingColumnIndex1} = mode(ImputationValues1_array);
            end
        end
    end
end

%% Save the completed dataset (STEP3d)

% Re-organize the dataset as the original one (preserving original row order)
inputFeatures_01 = inputFeatures;
inputFeatures_01(class0_index, :) = inputFeatures0;
inputFeatures_01(class1_index, :) = inputFeatures1;
dataset_complete_01 = [IDs, inputFeatures_01, class];

% Save the dataset obtained
fprintf('Completed dataset (clustering class-wise - Step3d): %d rows, %d columns. Total missing values: %d \n', ...
    size(dataset_complete_01,1), size(dataset_complete_01,2), sum(ismissing(dataset_complete_01),"all"));
writetable(dataset_complete_01, path, 'Sheet', 'DATASET_Step3d');
disp('Saving of STEP3d completed.')
