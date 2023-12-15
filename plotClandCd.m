clc;
clear;
close all;

%% Read port locations
data_ports = readmatrix('ClarkY14_PortLocations.xlsx');

% Port Number
port_number = data_ports(:, 1);

% Extracting chordwise vector
x_port_coordinates = data_ports(:, 2);
y_port_coordinates = data_ports(:, 3);
z_port_coordinates = data_ports(:, 4);

% Define Chord Lengths
chordLength = 3.5031;
yChordLength = [y_port_coordinates(1:9); y_port_coordinates(11:17)]';
zChordLength = [z_port_coordinates(1:9); z_port_coordinates(11:17)]';

% Normalize the Chord Length
normalizedChordLength = y_port_coordinates / 3.5031;
subsetNormalizedChordlength = [normalizedChordLength(1:9); normalizedChordLength(11:17)]';

%% Read main data
wing_data = readmatrix('ASEN2802_InfiniteWing_FullRange.csv');

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

% Create arrays to store Cl and Cd values for each angle of attack
Cl_values = zeros(1, num_angles);
Cd_values = zeros(1, num_angles);

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

    % Calculate Cn and Ca using trapz
    Cn = -(1/chordLength) * trapz(y_port_coordinates, actualCP);
    Ca = (1/chordLength) * trapz(z_port_coordinates, actualCP);


    % Calculate Cl and Cd
    Cl = Cn * cosd(angles(angle_index) - 1) - Ca * sind(angles(angle_index) - 1);
    Cd = Cn * sind(angles(angle_index) - 1) + Ca * cosd(angles(angle_index) - 1);

    % Store Cl and Cd values in arrays
    Cl_values(angle_index) = Cl;
    Cd_values(angle_index) = Cd;
end

% Plot Cl and Cd vs Angle of Attack
figure;
subplot(2, 1, 1);
plot(angles, Cl_values, 'LineWidth', 2);
grid on;
xlabel('Angle of Attack (degrees)');
ylabel('Lift Coefficient (Cl)');
title('Lift Coefficient vs Angle of Attack');

subplot(2, 1, 2);
plot(angles, Cd_values, 'LineWidth', 2);
grid on;
xlabel('Angle of Attack (degrees)');
ylabel('Drag Coefficient (Cd)');
title('Drag Coefficient vs Angle of Attack');


