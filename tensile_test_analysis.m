clc, clear, close all
%Created by Samyuktha Kolluru, Febuary 13th, 2024
%Modified SK March 26th, 2024
%In this code length is a different value for each sample

% Define the folder where your CSV files are located
folder = '/Users/samyukthakolluru/Desktop/Research/Tensile Test/20240213_Tensile_Mat8/20240213_Tensile_Mat8.is_ptf_Exports'; % Replace with the actual folder path

% List the CSV files in the folder
filePattern = fullfile(folder, '20240213_Tensile_Mat8_*.csv');   % Change it here too
fileList = dir(filePattern);

% Initialize a cell array to store data from each CSV file
data = cell(1, numel(fileList));

% Define l0- original length in m
lenmm = [25, 25, 25, 25, 25, 25, 25, 25];
% [25, 25, 25, 25, 25, 25, 25, 25];
lenm = lenmm / 1000; % Convert from mm to m

% Define thickness and width arrays (in mm)
thicknesses_mm= [0.20, 0.14, 0.14, 0.18, 0.19, 0.19, 0.18, 0.11];
widths_mm= [5, 5, 5, 5, 5, 5, 5, 5];
% [5, 5, 5, 5, 5, 5, 5, 5];
thicknesses = thicknesses_mm/1000 ; %Convert from mm to m
widths = widths_mm/1000 ;

% Calculate area based on thickness and width
area = thicknesses .* widths;

% Loop through the files and process the data
for i = 1:numel(fileList)
    filename = fullfile(folder, fileList(i).name);
    
    % Load the data from the CSV file using readtable
    data{i} = readtable(filename);
    
    % Extract the columns as arrays
    time = data{i}.Time_s_;
    force = data{i}.Force_N_;
    displacement_mm = data{i}.Displacement_mm_; % Keep the original data in mm
    
    % Convert displacement from mm to m
    displacement_m = displacement_mm / 1000;
    
    % Find indices where time is less than or equal to 18 seconds
    validIndices = time <= 18.0;
    
    % Filter time, force, and displacement arrays based on the condition
    time = time(validIndices);
    force = force(validIndices);
    displacement_m = displacement_m(validIndices);

    % Find the peak load and its corresponding time
    [PL, indexPL] = max(force);
    maxForceTimes(i) = time(indexPL);

    % Find the indices for the loading part of the curve (up to the time of max force)
    loadingIndices = time <= maxForceTimes(i);

    % Filter time, force, and displacement arrays based on the loading condition
    loadingTime = time(loadingIndices);
    loadingForce = force(loadingIndices);
    loadingDisplacement = displacement_m(loadingIndices);

    % Divide each load value by the area
    loadingStress = loadingForce ./ area(i);

    % Calculate volume for this file
    volume(i) = area(i) * lenm(i);

    % Calculate Strain
    loadingStrain = (loadingDisplacement) ./ lenm(i);
    
    % Store the maximum loading strain for this file
    FailureStrains(i) = max(loadingStrain);
    
    % Calculate the number of points to skip (first 25%)
    skipPoints = round(0.25 * numel(loadingStrain));

    % Fit a linear regression model to the loading part (after skipping points)
    linearModel = fitlm(loadingStrain(skipPoints+1:end), loadingStress(skipPoints+1:end));
    
    % Extract the slope (elastic modulus) from the linear model
    elasticModuli(i) = linearModel.Coefficients.Estimate(2); % Assuming a simple linear model
    
    % Calculate the area under the curve
    strainenergy(i) = trapz(loadingStrain, loadingStress);
    strainenergydensity(i) = strainenergy(i) / volume(i);

    % Calculate ultimate tensile strength as the maximum stress
    ultimateTensileStrength(i) = max(loadingStress);

    % Create a new figure for (time, force)
    figure;
    plot(loadingTime, loadingForce);
    title(['Force vs. Time - ' fileList(i).name], 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('Force (N)');
    
    % Create a new figure for (strain, stress)
    figure;
    plot(loadingStrain, loadingStress);
    hold on;
    plot(loadingStrain, linearModel.predict(loadingStrain), 'r--', 'LineWidth', 1.5);
    title(['Stress vs. Strain - ' fileList(i).name], 'Interpreter', 'none');
    xlabel('Strain (m/m)');
    ylabel('Stress (N/m^2)');
    legend('Original Curve', 'Linear Fit', 'Location', 'best');
    text(0.5, 0.8, ['Elastic Modulus: ' num2str(elasticModuli(i)) ' N/m^2'], 'Units', 'normalized', 'Color', 'r');
    hold off;
end

% Create a new figure for combined plots
figure;

% Loop through the files and plot on the same graph
for i = 1:numel(fileList)
    time = data{i}.Time_s_;
    force = data{i}.Force_N_;
    
    % Find indices where time is less than or equal to the time of max force
    validIndices = time <= maxForceTimes(i);
    
    % Filter time and force arrays based on the condition
    time = time(validIndices);
    force = force(validIndices);
    
    hold on;
    plot(time, force, 'DisplayName', fileList(i).name);
    hold off;
end

% Add title and legend
title('Combined Tensile Test Data');
legend('Location', 'best');

% Save combined figure
combinedFigName = 'Combined_Tensile_Test_Data.png';
saveas(gcf, combinedFigName);