%% Data Processing for Temperature and Time-of-Flight Measurements
clear; clc; close all;

%% 1. Load or define your data
% Replace this with your actual data or load from file
% temperature = your_temperature_data; % Nx1 array
% tof = your_time_of_flight_data; % Nx1 array

% Example data (remove when using real data)
load('pure_water_second.mat')
N = size(data,1);
temperature = data(:,2); 
tof = data(:,1); 

%% 2. Define maximum temperature threshold
T_max = 23.6; % Set your maximum temperature threshold

%% 3. Remove data above T_max
% Find indices where temperature is below or equal to T_max
valid_indices = temperature <= T_max;

% Filter both arrays using the same indices
temperature_filtered = temperature(valid_indices);
tof_filtered = tof(valid_indices);

fprintf('Original data points: %d\n', N);
fprintf('Filtered data points: %d\n', length(temperature_filtered));
fprintf('Removed %.1f%% of data\n', 100*(1 - length(temperature_filtered)/N));

%% 4. Perform linear fit (tof as function of temperature)
% Fit: tof = p1 * temperature + p2
p = polyfit(temperature_filtered, tof_filtered, 1);

% Generate fitted values
tof_fitted = polyval(p, temperature_filtered);

% Calculate R-squared
residuals = tof_filtered - tof_fitted;
SS_res = sum(residuals.^2);
SS_tot = sum((tof_filtered - mean(tof_filtered)).^2);
R2 = 1 - SS_res/SS_tot;

fprintf('\nLinear fit results:\n');
fprintf('Slope (p1): %.4f\n', p(1));
fprintf('Intercept (p2): %.4f\n', p(2));
fprintf('R-squared: %.4f\n', R2);

%% 5. Subtract DC component and compute STD
% Method 1: Subtract the linear fit (removes temperature dependence)
tof_detrended = tof_filtered - tof_fitted;

% Method 2: Alternatively, subtract mean (removes constant DC)
% tof_detrended = tof_filtered - mean(tof_filtered);

% Compute standard deviation
std_tof = std(tof_detrended);
std_original = std(tof_filtered);

fprintf('\nStandard Deviation Results:\n');
fprintf('Original STD (filtered data): %.4f\n', std_original);
fprintf('Detrended STD: %.4f\n', std_tof);
fprintf('Improvement factor: %.2f\n', std_original/std_tof);

%% 6. Visualization
figure('Position', [100, 100, 1200, 400]);

% Subplot 1: Original vs Filtered Data
subplot(1,3,1);
scatter(temperature, tof, 10, 'b', 'filled', 'DisplayName', 'Original');
hold on;
scatter(temperature_filtered, tof_filtered, 10, 'r', 'filled', 'DisplayName', 'Filtered');
xline(T_max, '--k', 'LineWidth', 1.5, 'DisplayName', sprintf('T_{max} = %.1f', T_max));
xlabel('Temperature');
ylabel('Time of Flight');
title('Original and Filtered Data');
legend('Location', 'best');
grid on;

% Subplot 2: Linear Fit
subplot(1,3,2);
scatter(temperature_filtered, tof_filtered, 10, 'b', 'filled', 'DisplayName', 'Data');
hold on;
plot(temperature_filtered, tof_fitted, 'r-', 'LineWidth', 2, 'DisplayName', 'Linear Fit');
xlabel('Temperature');
ylabel('Time of Flight');
title(sprintf('Linear Fit (R^2 = %.4f)', R2));
legend('Location', 'best');
grid on;

% Subplot 3: Detrended Data Distribution
subplot(1,3,3);
histogram(tof_detrended, 30, 'FaceColor', 'b', 'EdgeColor', 'k');
xlabel('Detrended Time of Flight');
ylabel('Count');
title(sprintf('Detrended Data Distribution\nSTD = %.4f', std_tof));
grid on;

% Add mean line
hold on;
y_limits = ylim();
plot([0, 0], y_limits, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Zero Mean');
legend('Data', 'Zero Mean');

%% 7. Additional Statistics (optional)
fprintf('\n--- Additional Statistics ---\n');
fprintf('Mean temperature (filtered): %.2f ¡À %.2f\n', mean(temperature_filtered), std(temperature_filtered));
fprintf('Mean TOF (filtered): %.2f ¡À %.2f\n', mean(tof_filtered), std_original);
fprintf('Mean detrended TOF: %.2f ¡À %.2f\n', mean(tof_detrended), std_tof);

% Calculate confidence intervals for the slope
n = length(temperature_filtered);
SE_slope = std(residuals) / (std(temperature_filtered) * sqrt(n-1));
t_val = tinv(0.975, n-2); % 95% confidence
CI_slope = [p(1) - t_val*SE_slope, p(1) + t_val*SE_slope];
fprintf('Slope 95%% Confidence Interval: [%.4f, %.4f]\n', CI_slope(1), CI_slope(2));

%% 8. Save processed data (optional)
save_processed_data = false; % Set to true to save
if save_processed_data
    processed_data.temperature = temperature_filtered;
    processed_data.tof = tof_filtered;
    processed_data.tof_detrended = tof_detrended;
    processed_data.linear_fit_params = p;
    processed_data.std_tof = std_tof;
    processed_data.T_max = T_max;
    
    save('processed_data.mat', 'processed_data');
    fprintf('\nProcessed data saved to processed_data.mat\n');
end