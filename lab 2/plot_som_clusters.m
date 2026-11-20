function plot_som_clusters(clustDend, N, nclust)
%-------------------------------------------------------------------%
% Visualization of SOM clusters.                                    %
% This function plots the Self-Organizing Map (SOM) as a hexagonal  %
% grid, where each neuron (node) is color-coded according to its    %
% assigned cluster.                                                 %
%-------------------------------------------------------------------%
% INPUT:                                                            %
% - clustDend: output of the cluster function, indicating the       %
%              cluster assignment for each neuron.                  %
% - N: size of the square SOM grid (NxN).                           %
% - nclust: number of identified clusters.                          %
%-------------------------------------------------------------------%
% OUTPUT:                                                           %
% - A figure displaying the hexagonal SOM grid with color-coded     %
%   neuron clusters.                                                %
%-------------------------------------------------------------------%
% Last modified: 31/03/2025 (AI)                                    %
%-------------------------------------------------------------------%

    % Create a colormap with as many colors as the number of clusters
    % You can change the colormap if you want to.
    color_map = jet(nclust); 

    hold on;
    % Loop through all neurons
    for i = 1:length(clustDend)
        % Compute the row and column position of the current neuron
        row = ceil(i / N);
        col = mod(i-1, N) + 1;

        % Compute the center of the hexagon
        x_center = (col - 1) + 0.5 * mod(row, 2); % Adjust x-center
        y_center = (row - 1) * sqrt(3) / 2; % Adjust y-center

        % Adjust for odd and even rows
        if mod(row,2) == 1
            x_center = x_center - 0.5;
        else
            x_center = x_center + 0.5;
        end

        % Create a hexagon shape
        Scale = 1.153;
        hexagon = polyshape(x_center + Scale * cos((0:5) * 2 * pi / 6 + (pi / 6)) / 2, ...
                            y_center + Scale * sin((0:5) * 2 * pi / 6 + (pi / 6)) / 2);

        % Plot the hexagon with its corresponding cluster color
        plot(hexagon, 'FaceColor', color_map(clustDend(i), :), ...
             'EdgeColor', color_map(clustDend(i), :), 'FaceAlpha', 0.3);
    end
end
