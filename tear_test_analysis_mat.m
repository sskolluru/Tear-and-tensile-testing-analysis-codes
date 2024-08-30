%Created by Samyuktha Kolluru, October 16th 2023
clc, clear, close all
% Define the folder where your CSV files are located
folder = '/Users/samyukthakolluru/Desktop/Research/Tear Test/20240210_TearTest_Mat15/20240210_TearTest_Mat15.is_ptf_Exports'; % Replace with the actual folder path


% List the CSV files in the folder
filePattern = fullfile(folder, '20240210_TearTest_Mat15_*.csv');   %change it here too
fileList = dir(filePattern);

% Initialize a cell array to store data from each CSV file
data = cell(1, numel(fileList));

% Initialize an array to store the average force values
averageForceValues = zeros(1, numel(fileList));

% Define the threshold for the first derivative
threshold = -0.5;

% PY: Makes a folder
newfolder= append(folder,'\figures');
if not(isfolder(newfolder)) %Makes a folder if it doesnt exist to store data
    mkdir(newfolder);
end

% Loop through the files and process the data
for i = 1:numel(fileList)
    filename = fullfile(folder, fileList(i).name);
    
    % Load the data from the CSV file using readtable
    data{i} = readtable(filename);
    
    % Extract the columns as arrays
    time = data{i}.Time_s_;
    displacement = data{i}.Displacement_mm_;
    force = data{i}.Force_N_;
    
    % Find indices where time is less than or equal to 18 seconds
    validIndices = time <= 18.0;
    
    % Filter time and force arrays based on the condition
    time = time(validIndices);
    force = force(validIndices);
    
    % Calculate the first derivative of the change in load
    dForce = diff(force);
    dTime = diff(time);
    derivative = dForce ./ dTime;
    
    % Find the index where the derivative crosses the threshold
    crossingIndex = find(derivative < threshold, 1);
    
    if ~isempty(crossingIndex)
        % Eliminate data prior to the crossing point
        time = time(crossingIndex:end);
        force = force(crossingIndex:end);
    end
    
    % Calculate the average force value of the remaining data points
    averageForce = mean(force);
    averageForceValues(i) = averageForce;
end

% Now 'data' contains the processed data for all files, and 'averageForceValues' contains the average force values for each file.

% Loop through the files and create a separate plot for each dataset
for i = 1:numel(fileList)
    % Create a new figure for each file's data
    figure;
    
    time = data{i}.Time_s_;
    force = data{i}.Force_N_;
    
    % Find indices where time is less than or equal to 18 seconds
    validIndices = time <= 18.0;
    
    % Filter time and force arrays based on the condition
    time = time(validIndices);
    force = force(validIndices);
    
    plot(time, force);
    
    % Add a title indicating the filename
    title(['Tear Test Data - ' fileList(i).name], 'Interpreter', 'none');
    
    % Add a line indicating the average force value for each dataset
    averageForce = averageForceValues(i);
    hold on;
    plot([min(time), max(time)], [averageForce, averageForce], 'r--', 'LineWidth', 1.5);
    hold off;

    % Save figures
    cd(newfolder)
    tempfig = "figure %s";
    figname = sprintf(tempfig,['Tear Test Data - ' fileList(i).name]);
    figname = erase(figname,".csv");
    figname = append(figname,'.png');
    saveas(gcf,figname)
    cd(folder)
end
