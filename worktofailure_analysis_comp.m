%Created by Samyuktha Kolluru, March 26th 2024
clc, clear, close all
% Define the folder where your CSV files are located
folder = '/Users/samyukthakolluru/Desktop/Research/Tear Test/20240313_TearTest_CompGelatinElastin/20240313_TearTest_CompGelatinElastin.is_ptf_Exports'; % Replace with the actual folder path

% List the CSV files in the folder
filePattern = fullfile(folder, '20240313_TearTest_CompGelatinElastin_*.csv');   %change it here too
fileList = dir(filePattern);

% Initialize a cell array to store data from each CSV file
data = cell(1, numel(fileList));

% Define l0- original length in m
lenmm = [10, 18, 20, 15, 22, 15, 18, 23];
% [25, 25, 25, 25, 25, 25, 25, 25];
lenm = lenmm / 1000; % Convert from mm to m

% Define thickness and width arrays (in mm)
thicknesses_mm= [0.76, 0.79, 0.62, 0.83, 0.70, 0.62, 0.77, 0.79];
widths_mm= [3, 3, 2.5, 1.5, 1.5, 4, 3, 3];
% [5, 5, 5, 5, 5, 5, 5, 5];
thicknesses = thicknesses_mm/1000 ; %Convert from mm to m
widths = widths_mm/1000 ;

% Calculate area based on thickness and width
area = thicknesses .* widths;

% Initialize an array to store the area under the curve for each file
areaUnderCurve = zeros(1, numel(fileList));

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

    % Divide each load value by the area
    stress = force ./ area(i);

    % Calculate volume for this file
    volume(i) = area(i) * lenm(i);

    % Calculate Strain
    strain = (displacement_m) ./ lenm(i);
    % Plot all the data
    plot(strain, stress);
    hold on;
    
    % Calculate the area under the curve using trapz function
    areaUnderCurve(i) = trapz(strain, stress);
end

% Add title and labels
title('Tear Test Data');
xlabel('Strain (m/m)');
ylabel('Stress (N-m)');

% Display legend
%legend({fileList.name}, 'Interpreter', 'none');

% Calculate and display the total area under the curve for all files
totalArea = sum(areaUnderCurve);
disp(['Total Area Under the Curve: ', num2str(totalArea)]);
