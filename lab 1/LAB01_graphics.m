%-------------------------------------------------------------------%
%               DECISION AID FOR PERSONALIZED PATIENT CARE          %
%               LAB 01 - GRAPHICAL REPRESENTATION (STEP 4)          %
%-------------------------------------------------------------------%
% This script loads the four imputed datasets from the Excel file   %
% and generates boxplots (continuous variables) and bar charts      %
% (categorical/binary variables) to compare class distributions.    %
%-------------------------------------------------------------------%

clear 
close all
clc

%% Dataset Loading

path = 'dataset_weaning.xlsx';

dataset_V1 = readtable(path, 'Sheet', "DATASET_V1");
dataset_3a = readtable(path, 'Sheet', "DATASET_Step3a");
dataset_3b = readtable(path, 'Sheet', "DATASET_Step3b");
dataset_3c = readtable(path, 'Sheet', "DATASET_Step3c");
dataset_3d = readtable(path, 'Sheet', "DATASET_Step3d");

class = dataset_V1(:, end);
y = class{:, 1};

inputFeatures_3a = dataset_3a(:, 4:end-1);
inputFeatures_3b = dataset_3b(:, 4:end-1);
inputFeatures_3c = dataset_3c(:, 4:end-1);
inputFeatures_3d = dataset_3d(:, 4:end-1);

% Normalize Step 3a and 3b to [0,1] using min/max of DATASET_V1
% for direct comparison with Step 3c and 3d
minimo = min(dataset_V1(:, 4:end-1));
massimo = max(dataset_V1(:, 4:end-1));

norm_3a = (inputFeatures_3a - minimo) ./ (massimo - minimo);
norm_3b = (inputFeatures_3b - minimo) ./ (massimo - minimo);

datasets_all = {norm_3a, norm_3b, inputFeatures_3c, inputFeatures_3d};
dataset_names = {'DATASET_Step3a', 'DATASET_Step3b', 'DATASET_Step3c', 'DATASET_Step3d'};

AllColumnsNames = dataset_V1.Properties.VariableNames;
ContinuousVariables = AllColumnsNames([16, 17, 19, 20, 22, 23, 25, 26, 28, 29, 31, 32, 34, 35, 37, 38, 40, 41, 43, 44, 46, 47, 49, 50, 52, 53, 55, 56]);
CategoricalBinaryVariables = AllColumnsNames([4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57]);

%% Boxplots for Continuous Variables (STEP 4)

for v = 1:length(ContinuousVariables)
    varName = ContinuousVariables{v};
    data_box = [];
    groups_box = {};
    for d = 1:4
        vals = datasets_all{d}.(varName);
        for c = [0, 1]
            vals_c = vals(y == c);
            data_box = [data_box; vals_c];
            groups_box = [groups_box; repmat({[dataset_names{d}, ' - Class ', num2str(c)]}, length(vals_c), 1)];
        end
    end
    figure('Visible', 'off');
    boxplot(data_box, groups_box);
    xtickangle(35);
    ylabel(varName, 'Interpreter', 'none');
    title(['Boxplot for variable: ', varName], 'Interpreter', 'none');
    saveas(gcf, ['Boxplot_', varName, '.png']);
    close(gcf);
end

%% Bar Charts for Categorical/Binary Variables (STEP 4)

for v = 1:length(CategoricalBinaryVariables)
    varName = CategoricalBinaryVariables{v};
    figure('Visible', 'off');
    for d = 1:4
        subplot(1, 4, d);
        vals = datasets_all{d}.(varName);
        unique_vals = sort(unique(vals(~isnan(vals))));
        freq_matrix = zeros(length(unique_vals), 2);
        for u = 1:length(unique_vals)
            freq_matrix(u, 1) = sum(vals(y == 0) == unique_vals(u));
            freq_matrix(u, 2) = sum(vals(y == 1) == unique_vals(u));
        end
        bar(freq_matrix);
        xticklabels(arrayfun(@(x) ['Valore ', num2str(x)], 0:length(unique_vals)-1, 'UniformOutput', false));
        xtickangle(35);
        xlabel('Valori');
        ylabel('Frequenza');
        title(['Dataset ', char('A' + d - 1)]);
        if d == 1
            legend({'Classe 0', 'Classe 1'}, 'Location', 'best');
        end
    end
    sgtitle(['Distribuzione di ', varName], 'Interpreter', 'none');
    saveas(gcf, ['Barchart_', varName, '.png']);
    close(gcf);
end

disp('STEP 4 graphical representations completed.')
