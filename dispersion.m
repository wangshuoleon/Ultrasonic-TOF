%% Pulse Propagation in Dispersive Medium - Superluminal Group Velocity Demo
% Demonstrates how pulse reshaping near resonance can make peak appear to
% travel faster than c0 (without violating causality)

clear all; close all; clc;

%% Parameters
c0 = 3e8;  % speed of light in vacuum (m/s)
L = 10;    % medium length (m) - normalized units

% Pulse parameters
t = linspace(-50, 150, 2000);  % time (normalized units)
f0 = 1.0;  % carrier frequency
sigma_t = 10;  % pulse width

% Initial Gaussian pulse
input_pulse = exp(-(t-0).^2/(2*sigma_t^2)) .* cos(2*pi*f0*t);

%% Define dispersive medium (Lorentz model near resonance)
% Resonant frequency
omega_0 = 2*pi*f0;  % resonance matches carrier

% Parameters for Lorentz oscillator model
omega_p = 0.5*omega_0;  % plasma frequency
gamma = 0.1*omega_0;    % damping coefficient

% Frequency domain
N = length(t);
dt = t(2) - t(1);
df = 1/(N*dt);
omega = 2*pi*ifftshift((-N/2:N/2-1)*df);

% Complex refractive index (Lorentz model)
epsilon = 1 + omega_p^2./(omega_0^2 - omega.^2 - 1i*gamma*omega);
n = sqrt(epsilon);

% Phase and group velocities
v_phase = c0./real(n);
v_group = c0./(real(n) + omega.*real(gradient(n, omega)));

% Propagation factor
H = exp(1i*real(n).*omega*L/c0) .* exp(-imag(n).*omega*L/c0);

%% Propagate pulse through medium
% FFT of input pulse
E_in_f = fft(input_pulse);

% Apply propagation
E_out_f = E_in_f .* H;

% Back to time domain
output_pulse = real(ifft(E_out_f));

% For animation: propagate through slices of medium
num_slices = 20;
z_positions = linspace(0, L, num_slices);
pulse_at_z = zeros(num_slices, N);

for k = 1:num_slices
    z = z_positions(k);
    H_z = exp(1i*real(n).*omega*z/c0) .* exp(-imag(n).*omega*z/c0);
    pulse_z_f = E_in_f .* H_z;
    pulse_at_z(k,:) = real(ifft(pulse_z_f));
end

%% Calculate arrival times at comparator threshold
threshold = 0.2;  % detection threshold
arrival_times = zeros(1, num_slices);
for k = 1:num_slices
    pulse_env = abs(hilbert(pulse_at_z(k,:)));
    idx = find(pulse_env > threshold, 1);
    if ~isempty(idx)
        arrival_times(k) = t(idx);
    end
end

% Fit velocity from arrival times
valid_idx = arrival_times > 0;
if sum(valid_idx) > 2
    p = polyfit(z_positions(valid_idx), arrival_times(valid_idx), 1);
    measured_velocity = 1/p(1);  % slope is dt/dz
    apparent_v_over_c = measured_velocity / c0;
end

%% Visualization
figure('Position', [100, 100, 1200, 900]);

% 1. Pulse evolution through medium
subplot(3,2,1);
imagesc(t, z_positions, pulse_at_z);
xlabel('Time (normalized)');
ylabel('Position z (m)');
title('Pulse Evolution in Medium');
colorbar;
colormap('jet');
hold on;
plot(arrival_times(valid_idx), z_positions(valid_idx), 'w--', 'LineWidth', 2);
legend('Comparator threshold crossing', 'Location', 'northwest');

% 2. Input vs Output pulse
subplot(3,2,2);
plot(t, input_pulse, 'b', 'LineWidth', 1.5);
hold on;
plot(t, output_pulse, 'r', 'LineWidth', 1.5);
xlabel('Time (normalized)');
ylabel('Amplitude');
title('Input vs Output Pulse');
legend('Input pulse', 'Output pulse');
grid on;

% 3. Envelopes to see reshaping
subplot(3,2,3);
env_input = abs(hilbert(input_pulse));
env_output = abs(hilbert(output_pulse));
plot(t, env_input, 'b-', 'LineWidth', 1.5);
hold on;
plot(t, env_output, 'r-', 'LineWidth', 1.5);
plot([t(1) t(end)], [threshold threshold], 'k--', 'LineWidth', 1);
xlabel('Time (normalized)');
ylabel('Envelope');
title('Pulse Envelopes');
legend('Input envelope', 'Output envelope', 'Comparator threshold');
grid on;

% Mark threshold crossings
idx_in = find(env_input > threshold, 1);
idx_out = find(env_output > threshold, 1);
if ~isempty(idx_in) && ~isempty(idx_out)
    plot(t(idx_in), threshold, 'bo', 'MarkerSize', 10, 'LineWidth', 2);
    plot(t(idx_out), threshold, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    
    % Calculate apparent velocity
    dt_cross = t(idx_out) - t(idx_in);
    v_apparent = L / dt_cross;
    text(0.05, 0.9, sprintf('Apparent v/c_0 = %.2f', v_apparent/c0), ...
        'Units', 'normalized', 'BackgroundColor', 'w');
end

% 4. Dispersion relation and velocities
subplot(3,2,4);
yyaxis left;
plot(omega/omega_0, real(n), 'b-', 'LineWidth', 1.5);
ylabel('n(\omega)');
hold on;
plot([1 1], [min(real(n)) max(real(n))], 'k--');
yyaxis right;
plot(omega/omega_0, v_group/c0, 'r-', 'LineWidth', 1.5);
ylabel('v_g/c_0');
xlabel('\omega/\omega_0');
title('Refractive Index and Group Velocity');
legend('n(\omega)', 'Resonance', 'v_g/c_0', 'Location', 'best');
grid on;
xlim([0.5 1.5]);

% 5. Arrival time vs position
subplot(3,2,5);
if sum(valid_idx) > 2
    plot(z_positions(valid_idx), arrival_times(valid_idx), 'o-', ...
        'LineWidth', 2, 'MarkerSize', 8);
    xlabel('Position z (m)');
    ylabel('Arrival time');
    title('Threshold Crossing Time vs Position');
    grid on;
    
    % Show fit
    hold on;
    z_fit = linspace(0, max(z_positions), 100);
    t_fit = polyval(p, z_fit);
    plot(z_fit, t_fit, 'r--', 'LineWidth', 2);
    legend('Data', sprintf('Fit: v = %.2f c_0', apparent_v_over_c));
    
    % Mark regions
    if apparent_v_over_c > 1
        text(0.5, 0.9, 'APPEARS superluminal!', ...
            'Units', 'normalized', 'Color', 'r', 'FontWeight', 'bold');
    end
end

% 6. Phase and group velocity in resonance region
subplot(3,2,6);
plot(omega/omega_0, v_phase/c0, 'g-', 'LineWidth', 1.5);
hold on;
plot(omega/omega_0, v_group/c0, 'r-', 'LineWidth', 1.5);
plot([1 1], [0 2], 'k--');
plot([0.5 1.5], [1 1], 'k:', 'LineWidth', 1);
xlabel('\omega/\omega_0');
ylabel('Velocity / c_0');
title('Phase and Group Velocities');
legend('v_{phase}/c_0', 'v_{group}/c_0', 'Resonance', 'c_0', 'Location', 'best');
grid on;
xlim([0.5 1.5]);
ylim([0 2]);

% Add explanatory text
annotation('textbox', [0.02, 0.02, 0.96, 0.06], ...
    'String', ['Demonstration: Near resonance (¦Ø?), strong dispersion causes pulse reshaping. ' ...
    'The output pulse peak/edge can cross threshold BEFORE the input peak would in vacuum, ' ...
    'giving apparent v > c?. This is due to interference/reshaping, not information traveling faster than light. ' ...
    'The front velocity (first detectable signal) remains ¡Ü c?.'], ...
    'FitBoxToText', 'off', 'BackgroundColor', 'w', 'EdgeColor', 'k', ...
    'FontSize', 9);

%% Additional analysis: Energy velocity
% Calculate Poynting vector-like quantity (approximation)
S_input = trapz(t, input_pulse.^2);
S_output = trapz(t, output_pulse.^2);
energy_transmission = S_output / S_input;

% Energy centroid arrival time
t_centroid_input = trapz(t, t.*env_input.^2) / trapz(t, env_input.^2);
t_centroid_output = trapz(t, t.*env_output.^2) / trapz(t, env_output.^2);

fprintf('\n=== Analysis Results ===\n');
fprintf('Energy transmission: %.2f%%\n', energy_transmission*100);
fprintf('Input pulse centroid time: %.2f\n', t_centroid_input);
fprintf('Output pulse centroid time: %.2f\n', t_centroid_output);
if exist('v_apparent', 'var')
    fprintf('Apparent velocity from threshold: %.2f c?\n', v_apparent/c0);
end
if exist('apparent_v_over_c', 'var')
    fprintf('Velocity from arrival time fit: %.2f c?\n', apparent_v_over_c);
end
fprintf('Note: Apparent v > c? is due to pulse reshaping, not superluminal information transfer.\n');