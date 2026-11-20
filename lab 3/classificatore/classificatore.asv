clc
close all
clear

%%
% save('Cluster6.mat',"Cluster6");
% save('Cluster14.mat',"Cluster14");
% save('Cluster15.mat',"Cluster15");

%bisogan creare un dataset ridotto che contiene:
%   pazienti appartenenti al cluster 6
%   feature (senza id e classe) selezionate dal cluster 6 NELL'ORDINE IN CUI SONO INSERITE NEL
%   TOOLBOX
%% Cluster 6
load('Dataset_rid_Cluster6.mat');
dataset=table2array(Cluster6);
load('Cluster6.mat');

classificatore6=evalfis(Cluster6, dataset(:,4:(end-1)));
classificatore6_def=classificatore6;
for i=1:length(classificatore6)
    if classificatore6(i)<=0.5000
        classificatore6_def(i)=0;
    elseif classificatore6(i)>0.5000 & classificatore6(i)<=1.5
        classificatore6_def(i)=1;
    elseif classificatore6(i)>1.5
        classificatore6_def(i)=NaN;
    end
end

Winner6=[dataset(:,end), classificatore6_def];

%% Cluster 14
load('Dataset_rid_Cluster14.mat');
dataset=table2array(Cluster14);
load('Cluster14.mat');

classificatore14=evalfis(Cluster14, dataset(:,4:(end-1)));
classificatore14_def=classificatore14;
for i=1:length(classificatore14)
    if classificatore14(i)<=0.5000
        classificatore14_def(i)=0;
    elseif classificatore14(i)>0.5000 & classificatore14(i)<=1.5
        classificatore14_def(i)=1;
    elseif classificatore14(i)>1.5
        classificatore14_def(i)=NaN;
    end
end

Winner14=[dataset(:,end), classificatore14_def];

%% Cluster 15
load('Dataset_rid_Cluster15.mat');
dataset=table2array(Cluster15);
load('Cluster15.mat');

classificatore15=evalfis(Cluster15, dataset(:,4:(end-1)));
classificatore15_def=classificatore15;
for i=1:length(classificatore15)
    if classificatore15(i)<=0.5000
        classificatore15_def(i)=0;
    elseif classificatore15(i)>0.5000 & classificatore15(i)<=1.5
        classificatore15_def(i)=1;
    elseif classificatore15(i)>1.5
        classificatore15_def(i)=NaN;
    end
end

Winner15=[dataset(:,end), classificatore15_def];

%%
function createConfMatWithNaN(Winner, clusterName)
    % Sostituisci NaN con un valore specifico per "non classificato", es: 2
    predLabels = Winner(:, 2);
    trueLabels = Winner(:, 1);

    predLabels(isnan(predLabels)) = 2; % Nuova classe "Not predicted"

    % Etichette delle classi: 0, 1, Not predicted (2)
    classNames = {'Class 0', 'Class 1', 'Not predicted'};

    % Calcolo matrice di confusione
    C = confusionmat(trueLabels, predLabels, 'Order', [0 1 2]);

    % Visualizzazione
    figure;
    confusionchart(C, classNames);
    title(['Confusion Matrix (including NaN) - Cluster ', clusterName]);
    % Salva come immagine
    
    % Stampa in console (opzionale)
    disp(['Confusion matrix (with NaN) for Cluster ', clusterName, ':']);
    disp(array2table(C, 'VariableNames', classNames, 'RowNames', {'True 0','True 1','True N/A'}));
end

% === Cluster 6 ===
createConfMatWithNaN(Winner6, '6');

% === Cluster 14 ===
createConfMatWithNaN(Winner14, '14');

% === Cluster 15 ===
createConfMatWithNaN(Winner15, '15');


%% Cluster 14 - centroidi
clc
close all
clear
load('Centroidi_denorm_cluster14_class0.mat');
load('Cluster14.mat');

classificatore14_class0=evalfis(Cluster14, table2array(centroid_denorm));

load('Centroidi_denorm_cluster14_class1.mat');
classificatore14_class1=evalfis(Cluster14, table2array(centroid_denorm));

%% Cluster 6 - centroidi
clc
close all
clear
load('Centroidi_denorm_cluster6_class0.mat');
load('Cluster6.mat');

classificatore6_class0=evalfis(Cluster6, table2array(centroid_denorm));

load('Centroidi_denorm_cluster6_class1.mat');

classificatore6_class1=evalfis(Cluster6, table2array(centroid_denorm));

%% Cluster 15 - centroidi
clc
close all
clear
load('Centroidi_denorm_cluster15_class0.mat');
load('Cluster15.mat');

classificatore15_class0=evalfis(Cluster15, table2array(centroid_denorm));

load('Centroidi_norm_cluster15_class1.mat');

classificatore15_class1=evalfis(Cluster15, table2array(centroid));
