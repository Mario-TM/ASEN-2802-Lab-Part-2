
clear; clc; close all;

dimensionFile = 'ClarkY14_PortLocations.xlsx';
wingDataFile = 'ASEN2802_InfiniteWing_FullRange.csv';
angle_of_attack = -15;  % <====== Input desired angle of attack

plotCpFromFiles(dimensionFile, wingDataFile, angle_of_attack);


function actualCP=plotCpFromFiles(dimensionFile, wingDataFile, alpha)
    % Read airfoil dimension data
    data_ports = readmatrix(dimensionFile);

    % Extract relevant airfoil dimension variables
    x_port_coordinates = data_ports(:, 2);
    y_port_coordinates = data_ports(:, 3);

    % Normalize the Chord Length
    normalizedChordLength = y_port_coordinates / 3.5031;
    subsetNormalizedChordlength = [normalizedChordLength(1:9); normalizedChordLength(11:17)]';

    % Read wing data
    wing_data = readmatrix(wingDataFile);

    % Extract relevant wing data variables
    angles = linspace(-15, 16, 32);
    scanivalvePressures = wing_data(:, 15:30);
    dynamicPressure = wing_data(:, 5);

    % Find the index corresponding to the given angle of attack
    angle_index = find(angles == alpha);

    % Calculate Average Dynamic Pressure for the specified angle of attack
    avg_dyn = mean(dynamicPressure((angle_index - 1) * 20 + 1:angle_index * 20));

    CP_values = ones(1, 16);

    for i = 1:16
        scan_avg = mean(scanivalvePressures((angle_index - 1) * 20 + 1:angle_index * 20, i));
        CP_values(i) = scan_avg / avg_dyn;
    end

    % Polyfit Stuff
    topLine = polyfit(normalizedChordLength(8:9), CP_values(8:9), 1);
    bottomLine = polyfit(normalizedChordLength(10:11), CP_values(10:11), 1);

    % Polyval stuff
    topLineofBestFit = polyval(topLine, 1);
    bottomLineofBestFit = polyval(bottomLine, 1);

    meanCPTrailingEdge = (bottomLineofBestFit + topLineofBestFit) / 2;

    actualNormalizedChordLength = [subsetNormalizedChordlength(1:9), 1, subsetNormalizedChordlength(10:16)];
    actualCP = [CP_values(1:9), meanCPTrailingEdge, CP_values(10:16)];

    % Plot
    figure;
    plot(actualNormalizedChordLength, actualCP, 'LineWidth', 2);
    grid on;
    xlabel('Normalized Chord Length');
    ylabel('Coefficient of Pressure');
    title(sprintf('Pressure Coefficient vs Normalized Chord Length at a = %d degrees', alpha));
    set(gca, 'Ydir', 'reverse');

    

end


