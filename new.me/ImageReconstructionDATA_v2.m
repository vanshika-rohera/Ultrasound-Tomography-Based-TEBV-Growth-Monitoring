clear all;
clc;

load('200927_New_Calibration_Data/data_200927_avg_10_clip_004.mat')

rf_us = DataArray3;
% take sample to obtain mean signal, to replace the irregular part
%trim = 65;
%rf_us = rf_us(trim+1:end,:);
sample = rf_us(301:500,:);
rf_us(1:200,:) = sample;
%rf_us(:,801:end) = 0;
%%
soundSpeed = 1440;
no_ele = 1;
fs = 80e6;
sampleSpacing = (1/fs)*soundSpeed*1000/2;
% the distance from image sensor to image center
r = 22; % [mm], computed from device geometry
d = 2*r;
ns= round(d/sampleSpacing);
%% Disply A lines
% figure(1);
% imagesc(rf_us);
% xlabel('Angle');
% ylabel('Number of Samples');
%% Time-Gain Compensation, applied here: exp(alpha*f_0*d)
A=ones(size(rf_us,1),1);
for i = 1:size(A,1)
    dd = i * sampleSpacing / 10; %[cm]
    A(i) = exp(0.0022*10*dd*1.0);
end
TGC = repmat(A,1,1280);
TGC_Alines = rf_us.*TGC;
% experiment finds the square law work well
%TGC = A';
% TGC = A.^2';
% for k= 1:size(rf_us,2 )
%     TGC_Alines(:,k)=TGC.*rf_us(:,k);
% end
%TGC_Alines = rf_us;
%% Cut A lines for fixed focusing
focus = 0.0; % in [mm]
focus_sample = round(focus/sampleSpacing)+1;
TGC_Alines = TGC_Alines(focus_sample:end,:);
%ns = size(TGC_Alines,1);
%% Generate transducer positions
% need to be fixed
% rotate the position of transducer [0, 0, focus] wrt to target

Center = [0 0 r]/1000; % in [m]
step_interval = 5;
step_size = (-360/1280)*step_interval;
% fixed for the device rotates in clockwise direction
Angle_trans = 0:step_size:-360; %number of alines that are generated
%new_trans_positions = rotatePhantom([0, 0, 0], Angle_trans, Center);
new_trans_positions = rotatePhantom([0, 0, d/1000-focus/1000], Angle_trans, Center);
new_trans_positions = new_trans_positions*1000;
%% plot trans positions
new_trans_positions(1,1,:) = new_trans_positions(1,1,:) + r;
scatter3(new_trans_positions(1,1,:),new_trans_positions(1,2,:),new_trans_positions(1,3,:));
xlabel('x');
ylabel('y');
zlabel('z');
%% DAS beamforming
post_recon = zeros(ns,ns);
for i = 1:ns
    for j = 1:ns
        if sqrt((i-(ns/2))^2 + (j-(ns/2))^2) < (ns/2)
            
            for angle_idx = 1:size(Angle_trans,2)-1
                
                trans_x = new_trans_positions(1,1,angle_idx);
                trans_z = new_trans_positions(1,3,angle_idx);
                
                dis = sqrt(((ns-i)*sampleSpacing-trans_z)^2+ ...
                    (j*sampleSpacing-trans_x)^2);
                
                pixeldis = round(dis/sampleSpacing);

                if pixeldis > 0 && pixeldis < ns
                    
                    value = (TGC_Alines(pixeldis,(angle_idx-1)*step_interval+1));
                    post_recon(i,j) = post_recon(i,j) + value;
                 
                end
            end
            
       end
    end
end
%% Kai's Visualization
meanInt = mean(mean(post_recon(1600:1800,1600:1800)));

for i = 1:ns
    for j = 1:ns
        if post_recon(i,j) == 0
            post_recon(i,j) = meanInt;
        end
    end
end

post_recon = post_recon - meanInt;

s_start = round(ns /4);
s_end = s_start + round(ns/2);
post_recon = post_recon(s_start:s_end,s_start:s_end);

env=abs(hilbert(post_recon));
% 
env = env./max(max(env));
dbenv = db(env);
% 
x = [s_start:s_end] * sampleSpacing;
y = [s_start:s_end] * sampleSpacing;
%%
imagesc(x,y,dbenv,[-20,0])
colormap('gray')

%title('Bmode: Two Points Phantom');
title('Bmode: Bioreactor');
ylabel('[mm]');
xlabel('[mm]');
colormap(gray);
axis image;
colorbar;