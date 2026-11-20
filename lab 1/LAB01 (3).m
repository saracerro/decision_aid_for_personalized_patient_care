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
path = "/Users/utente/Desktop/DAPPC LAB/LAB01_17:03/dataset_weaning.xlsx" ;
% Read the Excel sheet
dataset = readtable(path, 'Sheet', "DATASET_V1");
fprintf('Original dataset: %d rows, %d columns. Total missing values: %d \n', ...
    size(dataset,1), size(dataset,2), sum(ismissing(dataset),"all"));

%% Dataset organization for imputation
% In this section the IDs and the class are extracted so that the
% dataset contains only the input features to be imputed.

IDs = dataset(:,1:3);
class = dataset(:,end);
inputFeatures = dataset(:,4:end-1);

% Backup the original input features for later use in class-wise imputation
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
    missing_idx = find(ismissing(inputFeatures.(col_name))); % trova gli indici delle roghe con MV
    if ~isempty(missing_idx) % il " ~ " indica una negaazione, quindi "se trovi righe senza alcun MV ...."
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
        mdl = fitcknn(X_train, y_train, 'NumNeighbors', k);

        % qui avviene la sostituzione dei dati mancanti con i valori previsti

    end
end

%% Save the completed dataset (STEP3a)

% Re-organize the dataset as the original one
dataset_complete = [IDs, inputFeatures, class];
fprintf('Completed dataset (all patients): %d rows, %d columns. Total missing values: %d \n', ...
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
            mdl = fitcknn(X_train, y_train, 'NumNeighbors', k);

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
fprintf('Completed dataset (class-wise imputation): %d rows, %d columns. Total missing values: %d \n', ...
    size(dataset_complete,1), size(dataset_complete,2), sum(ismissing(dataset_complete),"all"));
writetable(dataset_complete, path, 'Sheet', 'DATASET_Step3b');
disp('Saving of STEP3b completed.')
