function rf_us = generateRF2(new_phantom_positions)


% Generate the transducer apertures for send and receive
f0 = 5e6; % Transducer center frequency [Hz]
fs = 60e6; % Sampling frequency [Hz]
c = 1540; % Speed of sound [m/s]
lambda = c / f0; % Wave length [m]f
pitch = 0.1/1000 ;%[m]
% pitch_r = pitch/2;
pitch_r = pitch;
width = .95*pitch;
width_r = .95*pitch_r;
element_height = 0.3/1000; % Height of element [m]
kerf = pitch-width; % Kerf [m]
kerf_r = pitch_r - width_r;
focus = [0 0 0]/100; % Fixed focal point [m]
N_elements = 1; % Number of elements in the transducer
N_elements_r = 1;
% N_active = 1; % Active elements in the transducer
% Set the sampling frequency
set_sampling(fs);
% Generate aperture for emission
emit_aperture = xdc_linear_array(N_elements, width, element_height, kerf, 1, 1, focus);
% Set the impulse response and excitation of the emit aperture
impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response .* hanning(max(size(impulse_response)))';
xdc_impulse(emit_aperture, impulse_response);
excitation = sin(2*pi*f0*(0:1/fs:2/f0));
xdc_excitation(emit_aperture, excitation);
% Generate aperture for reception
receive_aperture = xdc_linear_array(N_elements_r, width_r, element_height, kerf_r, 1, 1, focus);
% Set the impulse response for the receive aperture
xdc_impulse(receive_aperture, impulse_response);
%  Define the point phantom
% phantom_positions = [1 0 3] / 100;  %  The position of the phantom [m]
% new_phantom_positions = rotatePhantom(phantom_positions, 0:1:360);
[m,n] = size(new_phantom_positions);
phantom_amplitudes = 20*ones(m,1);      %  The amplitude of the back-scatter
% Do linear array imaging
no_lines = N_elements;%N_elements - N_active + 1; % Number of A-lines in image
dx = width; % Increment for image
% z_focus = 30/100;
% Pre-allocate some storage
image_data = zeros(3000,N_elements_r);
% RFframe = zeros(2000,N_elements_r,N_elements);
xdc_focus_times(emit_aperture,0,zeros(1,N_elements));
xdc_focus_times(receive_aperture,0,zeros(1,N_elements_r));
% times = zeros(1,1);
[v,t] = calc_scat (emit_aperture, receive_aperture, new_phantom_positions, phantom_amplitudes);
% [v,t] = calc_scat_all (emit_aperture, receive_aperture, new_phantom_positions, phantom_amplitudes, 1);

xdc_free(emit_aperture)
xdc_free(receive_aperture)

% prebeam = zeros(size(v,1),N_elements,N_elements);
% 
% for i = 1:N_elements
%     
%     prebeam(:,:,i) = v(:,(i-1)*N_elements+1:((i-1)*N_elements+1)+(N_elements-1));
%     
% end
% t*fs;

rf_us = v;
%rf_us = vertcat(zeros(round(t*fs-60-20),1),rf_us);
% cat for focus compensation
%rf_us = vertcat(zeros(round(t*fs-30+12),1),rf_us); 
rf_us = vertcat(zeros(round(t*fs-30-12),1),rf_us); 
end