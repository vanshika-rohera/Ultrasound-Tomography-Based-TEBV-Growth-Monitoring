% This reconstruction code ismodified from provious version
clear all;
clc;

% load data
load('210123_USCT_testing/data_210123_avg_10_TEBV_003.mat')
rf_us = DataArray3;

% remove high initial signals
sample = rf_us(501:1000,:);
rf_us(1:500,:) = sample;
% zero-center the signal
rf_us = rf_us - mean(rf_us(:));

% spatial filtering
% inter = zeros(5000, 1280);
% for i=1:5000
% B = rf_us(i,:);
% inter(i,:) = spacial_averaging(B);
% end
% 
% rf_us = inter;
%%
soundSpeed = 1430;
no_ele = 1;
fs = 80e6;
sampleSpacing = (1/fs)*soundSpeed*1000/2;
% the distance from image sensor to image center
r = 22.29; % [mm], computed from device geometry, from mirror to center
d = 2*r;
ns= round(d/sampleSpacing);
%% Time-Gain Compensation, applied here: exp(alpha*f_0*d)
% A=ones(size(rf_us,1),1);
% for i = 1:size(A,1)
%     dd = i * sampleSpacing / 10; %[cm]
%     A(i) = exp(0.022*6*dd*1.0);
% end
% TGC = repmat(A,1,size(rf_us,2));
% TGC_Alines = rf_us.*TGC;
TGC_Alines = rf_us;
%% Cut A lines for fixed focusing
focus = 12.7; % in [mm]
focus_sample = round(focus/sampleSpacing);
TGC_Alines = TGC_Alines(focus_sample:end,:);
%% Display A lines
figure(1);
TGC_Alines_bmode = abs(hilbert(TGC_Alines));
TGC_Alines_bmode = TGC_Alines_bmode./max(TGC_Alines_bmode(:));
TGC_Alines_bmode = db(TGC_Alines_bmode);
imagesc(TGC_Alines_bmode,[-30,0]);
axis image
colormap('gray')
%colorbar;
title('Alines: TEBV Phantom');
xlabel('Number of acquisitions');
ylabel('Number of samples');
%% Generate transducer positions
% or fixed focusing point positions
% rotate the position of transducer [0, 0, focus] wrt to target

Center = [0 0 r]/1000; % in [m]
step_interval = 2;
step_size = (-360/1280)*step_interval;
% fixed for the device rotates in clockwise direction
Angle_trans = 0:step_size:-360; %number of alines that are generated
new_trans_positions = rotatePhantom([0, 0, d]/1000, Angle_trans, Center);
new_trans_positions = new_trans_positions*1000; % in [mm]
%% plot transducer positions
% or fixed focusing point positions
new_trans_positions(1,1,:) = new_trans_positions(1,1,:) + r;
scatter3(new_trans_positions(1,1,:),new_trans_positions(1,2,:),new_trans_positions(1,3,:));
xlabel('x');
ylabel('y');
zlabel('z');
%% DAS beamforming
post_recon = zeros(ns,ns);
num_alines = size(Angle_trans,2)-1;

x_vec = new_trans_positions(1,1,:);
x_vec = reshape(x_vec,[1,size(new_trans_positions,3)]);
x_mean = mean(x_vec);
x_vec = x_vec - x_mean;
z_vec = new_trans_positions(1,3,:);
z_vec = reshape(z_vec,[1,size(new_trans_positions,3)]);
z_mean = mean(z_vec);
z_vec = z_vec - z_mean;
theta_vec = atan2(x_vec,z_vec);

for i = 1:ns
    for j = 1:ns
        % circular region
        if sqrt((i-(ns/2))^2 + (j-(ns/2))^2) < (ns/2)
            % go through lines in a fixed aperture
            
            i_mm = i * sampleSpacing;
            j_mm = j * sampleSpacing;
            
            % find nearest aline
            theta_pxl = atan2(j_mm - x_mean, ns*sampleSpacing - i_mm - z_mean);
            diff_vec = theta_vec - theta_pxl;
            [M, I] = min(abs(diff_vec)); % find the minimum difference
            idx_na = I;
            apt = 200;
            
            for angle_idx = idx_na-apt/2 : idx_na+apt/2
                
                if angle_idx <= 0
                    angle_idx = angle_idx + num_alines;
                elseif angle_idx > num_alines
                    angle_idx = angle_idx - num_alines;
                end
                
                trans_x = new_trans_positions(1,1,angle_idx);
                trans_z = new_trans_positions(1,3,angle_idx);
                
                dis = sqrt(((ns-i)*sampleSpacing-trans_z)^2+ ...
                    (j*sampleSpacing-trans_x)^2);
                
                pixeldis = round(dis/sampleSpacing);
                % limit into the range of sampled distance
                if pixeldis > 0 && pixeldis < size(TGC_Alines,1)
                    
                    value = (TGC_Alines(pixeldis,(angle_idx-1)*step_interval+1));
                    post_recon(i,j) = post_recon(i,j) + value;
                 
                end
            end
            
       end
    end
end
%% Kai's Visualization
% meanInt = mean(mean(post_recon(1600:1800,1600:1800)));
% 
% for i = 1:ns
%     for j = 1:ns
%         if post_recon(i,j) == 0
%             post_recon(i,j) = meanInt;
%         end
%     end
% end
% 
% post_recon = post_recon - meanInt;
% 

% post_recon = post_recon(s_start:s_end,s_start:s_end);
% 
env=abs(hilbert(post_recon));
% % 
env = env./max(max(env));
dbenv = db(env);

edge_1 = size(dbenv,1);
dbenv = dbenv(edge_1/4:3*edge_1/4,edge_1/4:3*edge_1/4);
% dbenv = dbenv(round(3*edge_1/8):round(5*edge_1/8),round(3*edge_1/8):round(5*edge_1/8));
edge_2 = size(dbenv,1);
% % 
s_start = -round(edge_2/2);
s_end = s_start + edge_2;
% s_start = -round(edge_2/2);
% s_end = s_start + edge_2;
x = [s_start:s_end] * sampleSpacing;
y = [s_start:s_end] * sampleSpacing;
%%
imagesc(x,y,dbenv,[-30,0])
colormap('gray')

%title('Bmode: Two Points Phantom');
title('Bmode: Single Point W Spatial Filtering');
ylabel('[mm]');
xlabel('[mm]');
axis image
colorbar;