clc
clear
close all

%% Read port locations
data_ports = readmatrix('ClarkY14_PortLocations.xlsx');

% Port Number
port_number = data_ports(:, 1);

% Extracting chordwise vector
x_port_coordinates = data_ports(:, 2);
y_port_coordinates = data_ports(:, 3);
z_port_coordinates = data_ports(:, 4);

% Normalize the Chord Length
normalizedChordLength = y_port_coordinates / 3.5031;
subsetNormalizedChordlength = [normalizedChordLength(1:9); normalizedChordLength(11:17)]';

%% Read main data
wing_data = readmatrix('ASEN2802_InfiniteWing_FullRange.csv');

% Extract Relevant Variables......Dynamic Pressure
%                           ......Scanivalve Pressure Measurements
%
%

% Get Scanivalve Pressures
scanivalvePressures = wing_data(:, 15:30);

% Get Density (Atmospheric)
rhoAtmo = wing_data(:, 3);

% Get Atmospheric Pressure
Patmo = wing_data(:, 2);

% Get Velocity (Air Speed m/s)
V_infinity = wing_data(:, 4);

% Get Pitot Dynamic Pressure
dynamicPressure = wing_data(:, 5);

%% Calculate Average Dynamic Pressure for All Angles of Attack

num_angles = 32; % Set the maximum number of angles of attack
angles = linspace(-15, 16, num_angles); % Adjust the range of angles

% Create a subplot grid
rows = ceil(sqrt(num_angles));
cols = ceil(num_angles / rows);

figure('Name', 'Pressure Coefficient vs Normalized Chord Length for Different Angles of Attack');

for angle_index = 1:num_angles
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

    % Subplot position
    subplot(rows, cols, angle_index);
    
    % Plot for each angle of attack
    plot(actualNormalizedChordLength, actualCP, 'LineWidth', 2);
    grid on;
    xlabel('Normalized Chord Length');
    ylabel('Coefficient of Pressure');
    title(sprintf('a = %d', angles(angle_index)));
    ax = gca;
    ax.FontSize = 8; % Adjust font size if needed
    ax.LineWidth = 1.5;
    set(gca, 'Ydir', 'reverse');
end

% Adjust layout
sgtitle('Pressure Coefficient vs Normalized Chord Length for Different Angles of Attack');

Chord_Length = 3.5031;

    Y_ChordLength  = [y_port_coordinates(1:17)];
   Z_ChordLength  = [z_port_coordinates(1:17)];

for angle_index = 1: num_angles
CP_values(i)

   Cn(i) = -1 ./ Chord_Length.* trapz(actualCP(i), Y_ChordLength); 
   Ca(i) = 1 ./ Chord_Length.* trapz(actualCP(i), Z_ChordLength); 

end
