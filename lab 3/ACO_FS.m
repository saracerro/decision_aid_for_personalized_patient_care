function [sFeat, Nf, Sf, curve] = ACO_FS(feat, label, N, max_Iter, tau, eta, alpha, beta, rho, HO, init_ants)
%-------------------------------------------------------------------%
% Ant Colony Optimization for Feature Selection                     %
% This function applies the Ant Colony Optimization (ACO) meta-     %
% heuristic to select an optimal subset of features from the input  %
% dataset. Each ant constructs a subset of features based on        %
% pheromone trails (learned experience) and heuristic desirability  %
% (e.g., feature relevance such as correlation).                    %
%                                                                   %
% The algorithm works as follows:                                   %
% 1. Each ant starts from a predefined feature (from X_init) or     %
%    randomly selected one.                                         %
% 2. Each ant constructs a feature subset by probabilistically      %
%    selecting additional features, influenced by pheromone values  %
%    and heuristic information.                                     %
% 3. Each solution (subset) is evaluated using a objective function   %
%    based on classification error on a hold-out set.               %
% 4. Pheromone trails are updated based on the performance of all   %
%    ants and the global best solution, encouraging the selection   %
%    of informative features.                                       %
% 5. The best subset found across all iterations is returned.       %
%                                                                   %
% The goal is to identify a compact and informative set of features %
% that maximizes classification performance.                        %
%-------------------------------------------------------------------%
% INPUT ARGUMENTS:                                                  %
% - feat    : Matrix containing the dataset features (samples x dim)%
% - label   : Vector of class labels for each sample                %
% - N       : Number of ants (i.e., candidate solutions)            %
% - max_Iter: Maximum number of iterations                          %
% - tau_init: Initial pheromone trail value                         %
% - eta_init: Initial heuristic information value                   %
% - alpha   : Importance factor of pheromone trail                  %
% - beta    : Importance factor of heuristic information            %
% - rho     : Pheromone evaporation rate (0 < rho < 1)              %
% - HO      : Hold-out rate for train-test split during evaluation  %
% - X_init  : Custom binary initialization matrix (N x dim), where  %
%             each row indicates the initial feature for each ant   %
%-------------------------------------------------------------------%
% OUTPUT ARGUMENTS:                                                 %
% - sFeat: Reduced feature matrix corresponding to the best subset  %
% - Nf   : Number of features selected in the best subset           %
% - Sf   : Indices of the selected features in the best solution    %
% - curve: Objective function values over all iterations            %
%          (convergence curve)                                      %
%-------------------------------------------------------------------%
% Last update: 14/04/2025 (AI)                                      %
%-------------------------------------------------------------------%

fun  = @objectiveFunction; 
dim  = size(feat,2); 
tau  = tau * ones(dim,dim);
eta  = eta * ones(dim,dim);

fitG = inf;
fit  = zeros(1,N);
curve = inf;
t = 1; 

while t <= max_Iter 
    X = zeros(N,dim); 
    for i = 1:N
        num_feat = randi([4,8]);
        X(i,1)   = find(init_ants(i,:)); 
        k        = [];
        if num_feat > 1
            for d = 2:num_feat
                k = [k(1:end), X(i, d-1)];
                P = (tau(k(end),:) .^ alpha) .* (eta(k(end),:) .^ beta); 
                P(k)   = 0; 
                prob   = P ./ sum(P(:)); 
                route  = jRouletteWheelSelection(prob);
                X(i,d) = route;
            end
        end
    end

    X_bin = zeros(N,dim);
    for i = 1:N
        ind           = X(i,:); 
        ind(ind == 0) = []; 
        X_bin(i,ind)  = 1;
    end

    % Filter out solutions with fewer than 12 features
    for i = 1:N
        if sum(X_bin(i,:)) < 12
            % Force a poor solution or skip objective evaluation
            fit(i) = 1;
            continue;
        end
    end
    for i = 1:N
        fit(i) = fun(feat,label,X_bin(i,:),HO);
        if fit(i) < fitG
            Xgb  = X(i,:);
            fitG = fit(i);
        end
    end

    tauK = zeros(dim,dim); 
    for i = 1:N
        tour = X(i,:); 
        tour(tour == 0) = []; 
        len_x = length(tour); 
        tour  = [tour(1:end), tour(1)];
        for d = 1:len_x
            x = tour(d); 
            y = tour(d + 1);
            tauK(x,y) = tauK(x,y) + (1 / (1 + fit(i)));
        end
    end

    tauG = zeros(dim,dim);
    tour = Xgb; 
    tour(tour == 0) = [];
    len_g = length(tour); 
    tour  = [tour(1:end), tour(1)];
    for d = 1:len_g
        x = tour(d); 
        y = tour(d + 1);
        tauG(x,y) = 1 / (1 + fitG); 
    end

    tau = (1 - rho) * tau + tauK + tauG; 
    curve(t) = fitG; 
    fprintf('\nIteration %d Best (ACO)= %f',t,curve(t))
    t = t + 1;
end

Sf    = Xgb; 
Sf(Sf == 0) = []; 
sFeat = feat(:,Sf); 
Nf    = length(Sf);
end

function Index = jRouletteWheelSelection(prob)
C = cumsum(prob);
P = rand();
for i = 1:length(C)
	if C(i) > P
    Index = i;
    break;
  end
end
end
