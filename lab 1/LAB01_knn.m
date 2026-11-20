%-------------------------------------------------------------------%
%               DECISION AID FOR PERSONALIZED PATIENT CARE          %
%                    LAB 01 - DATASET PREPARATION                   %
%-------------------------------------------------------------------%
% Author: Alessandra Introvaia - alessandra.introvaia@polito.it     %
% Creation date: 12/03/2025                                         %
% Last modification: 14/03/2025 (AI)                                %
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
path = 'C:\Users\Utente\Desktop\Polito\DAPPC\Lab1\dataset_weaning.xlsx';
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

%% kNN Imputation with all patients

% For each column with at least 1 MV we should:
% 1. Identify rows with MVs.
% 2. Create a TRS without MVs: delete the rows identified at step 1 and
%    remove also the columns with MVs.
% 3. Traing a kNN classifier with the TRS: the outcome predicted by the
%    model must be the feature to be imputated
% 4. Make imputation by predicting on the MVs identified at step 1
% Iterate these steps for all the featuers with at least 1 MV.

featuresNames = missingValues.Properties.VariableNames;

for i = 1:length(featuresNames)
    feature = featuresNames{i};

    missingRows = ismissing(inputFeatures.(feature));  % Identifica le righe con valori mancanti
    missingIndices = find(missingRows);

    % Crea il TRS senza le righe con valori mancanti
    TRS = inputFeatures(~missingRows, :);
    yTrain = inputFeatures.(feature)(~missingRows);  % Valori noti di questa colonna

    % Addestra il modello kNN usando le altre caratteristiche per predire questa colonna
    if ~isempty(yTrain)  % Evita errori se tutti i valori sono mancanti
        k = round(sqrt(size(dataset, 1)));  % Calcola il valore di k

        % Addestra il modello kNN
        Mdl = fitcknn(TRS, yTrain, 'NumNeighbors', k, 'Standardize', true);

        % Predici i valori mancanti usando i pazienti simili
        inputFeatures.(feature)(missingIndices) = predict(Mdl, inputFeatures(missingIndices, :));
    end
end





%% Save the completed dataset

% Re-organize the dataset as the original one
dataset_complete = [IDs, inputFeatures, class];
% Save the dataset obtained
fprintf('Completed dataset: %d rows, %d columns. Total missing values: %d \n', size(dataset_complete,1), size(dataset_complete,2), sum(ismissing(dataset_complete),"all"));
writetable(dataset_complete, path, 'Sheet', 'DATASET_Step3a');
disp('Saving completed.')

%% Imputation using kNN separately with patients of class 0 and class 1

% Repeat the operations implemented for STEP3(a) by dividing the patients 
% with respect to class (class 0 and class 1). For each class, 
% perform the imputation based on the kNN classifier. 

dataset_0=dataset(dataset.class==0,:);
dataset_1=dataset(dataset.class==1,:);

IDs0 = dataset_0(:,1:3);
IDs1 = dataset_1(:,1:3);


class_0 = dataset_0(:,end);
class_1 = dataset_1(:,end);

inputFeatures0 = dataset_0(:,4:end-1);
inputFeatures1 = dataset_1(:,4:end-1);
% Identify which features contain missing values and how many
missingValues0 = array2table(sum(ismissing(inputFeatures0),1), 'VariableNames', inputFeatures0.Properties.VariableNames);
missingValues1 = array2table(sum(ismissing(inputFeatures1),1), 'VariableNames', inputFeatures1.Properties.VariableNames);
% Keep only columns with missing values greater than 0
missingValues0 = missingValues0(:, missingValues0{1,:} > 0);
missingValues1 = missingValues1(:, missingValues1{1,:} > 0);

featuresNames0 = missingValues0.Properties.VariableNames;
featuresNames1 = missingValues1.Properties.VariableNames;

for i = 1:length(featuresNames0)
    feature = featuresNames0{i};

    missingRows = ismissing(inputFeatures0.(feature));  % Identifica le righe con valori mancanti
    missingIndices = find(missingRows);

    % Crea il TRS senza le righe con valori mancanti
    TRS0 = inputFeatures0(~missingRows, :);
    yTrain0 = inputFeatures0.(feature)(~missingRows);  % Valori noti di questa colonna

    % Addestra il modello kNN usando le altre caratteristiche per predire questa colonna
    if ~isempty(yTrain0)  % Evita errori se tutti i valori sono mancanti
        k0 = round(sqrt(size(dataset_0, 1)));  % Calcola il valore di k

        % Addestra il modello kNN
        Mdl_0 = fitcknn(TRS0, yTrain0, 'NumNeighbors', k0, 'Standardize', true);

        % Predici i valori mancanti usando i pazienti simili
        inputFeatures0.(feature)(missingIndices) = predict(Mdl_0, inputFeatures0(missingIndices, :));
    end
end


for i = 1:length(featuresNames1)
    feature = featuresNames1{i};

    missingRows = ismissing(inputFeatures1.(feature));  % Identifica le righe con valori mancanti
    missingIndices = find(missingRows);

    % Crea il TRS senza le righe con valori mancanti
    TRS1 = inputFeatures1(~missingRows, :);
    yTrain1 = inputFeatures1.(feature)(~missingRows);  % Valori noti di questa colonna

    % Addestra il modello kNN usando le altre caratteristiche per predire questa colonna
    if ~isempty(yTrain1)  % Evita errori se tutti i valori sono mancanti
        k1 = round(sqrt(size(dataset_1, 1)));  % Calcola il valore di k

        % Addestra il modello kNN
        Mdl_1 = fitcknn(TRS1, yTrain1, 'NumNeighbors', k1, 'Standardize', true);

        % Predici i valori mancanti usando i pazienti simili
        inputFeatures1.(feature)(missingIndices) = predict(Mdl_1, inputFeatures1(missingIndices, :));
    end
end
%% Combine the imputed data for both classes
%% Save the completed dataset

% Re-organize the dataset as the original one
dataset_complete_0 = [IDs0, inputFeatures0, class_0];
dataset_complete_1 = [IDs1, inputFeatures1, class_1];

% Remove 'class' column and 'ID' from dataset_1 before concatenation
dataset_complete_0 = dataset_complete_0(:, [1:3, 4:end]);  % Keep the first three columns (ID, class, etc.) and features
dataset_complete_1 = dataset_complete_1(:, [1:3, 4:end]);  % Same for dataset_1

dataset_complete_class = [dataset_complete_0; dataset_complete_1];

% Save the dataset obtained
fprintf('Completed dataset: %d rows, %d columns. Total missing values: %d \n', size(dataset_complete_0,1), size(dataset_complete_1,2), sum(ismissing(dataset_complete_class),"all"));
writetable(dataset_complete_class, path, 'Sheet', 'DATASET_Step3a');
disp('Saving completed.')
