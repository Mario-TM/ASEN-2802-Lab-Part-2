clc
clear
close all

%% Read port locations
data_ports = readmatrix('ClarkY14_PortLocations.xlsx');
%% Read main data
data_main = readmatrix('ASEN2802_InfiniteWing_FullRange.csv');

% Port Number
port_number = data_ports(:, 1);

% Extracting chordwise vector
x_port_coordinates = data_ports(:, 2);
y_port_coordinates = data_ports(:, 3);
z_port_coordinates = data_ports(:, 4);

% Normalize the chord Length
normalized_ChordLength = y_port_coordinates / 3.5031;
theNormalized_ChordLength = [normalized_ChordLength(1:9); normalized_ChordLength(11:17)]';


% Get Scanivalve Pressures
scn_pressure = data_main(:, 15:30);

% Get Density (Atmospheric)
den_atmo = data_main(:, 3);

% Get Atmospheric Pressure
p_atmo = data_main(:, 2);

% Get Velocity (Air Speed m/s)
v = data_main(:, 4);

% Get Pitot Dynamic Pressure
dynamic_pressure = data_main(:, 5);

angles = data_main(:, 8); 



%{

%% Attack Angles
angle_ranges = [1, 20; 21, 40; 41, 60];  % Define the attack angle ranges for each angle
CP_neg15 = calculatePressureCoefficients(dynamic_pressure, scn_pressure, angle_ranges);

figure('Name', '1')
subplot(2, 2, 1)
plot(theNormalized_ChordLength, CP_neg15);
grid on;
% Add more attack angles as needed


function CP = calculatePressureCoefficients(dynamic_pressure, scn_pressure, angle_range)
    CP = ones(1, size(scn_pressure, 2));
    
    for i = 1:size(scn_pressure, 2)
        start_index = angle_range(i, 1);
        end_index = angle_range(i, 2);
        
        avg_dyn = mean(dynamic_pressure(start_index:end_index));
        
        scan_avg = mean(scn_pressure(start_index:end_index, i));
        CP(i) = scan_avg / avg_dyn;
    end
end
%}