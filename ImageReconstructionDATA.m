clear all;
clc;
load('data_200806_avg_10_twopoints.mat')
rf_us = DataArray3;
% take sample to obtain mean signal, to replace the irregular part
sample = rf_us(500:600,:);
rf_us(1:500,:) = mean(sample(:));
rf_us(:,600:900) = 0;
rf_us = abs(hilbert(rf_us));
%%
soundSpeed = 1480;
no_ele = 1;
%channelSpacing = 0.2;
fs = 80e6;
sampleSpacing = (1/fs)*soundSpeed*1000/2;
times=1;
% the distance from image sensor to target
r = round(((2053+2173)/2)*sampleSpacing);
d = 2*r
ns= round(d/sampleSpacing);
%%
%field_init(0);
%Angle = 0:360;
%% Disply A lines
% figure(1);
% imagesc(rf_us);
% xlabel('Angle');
% ylabel('Number of Samples');​
%A=repmat(1:5000,1);
%%index_vector=flip(A);
%%TGC = 1./index_vector;
%TGC = A.^2';​
%for k= 1:361
    %TGC_Alines(:,k)=TGC.*rf_us(:,k);
    %%TGC_Alines(:,k)=rf_us(:,k);
%end​
%% Generate transducer positions
% need to be fixed
% rotate the position of transducer [0, 0, 0] wrt to target
Center = [0 0 r]/1000; % in [m]
step_interval = 1;
step_size = (360/1280)*step_interval;
Angle_trans = 0:-step_size:-360; %number of alines that are generated
new_trans_positions = rotatePhantom1([0, 0, 0], Angle_trans, Center);
new_trans_positions = new_trans_positions*1000;
%% plot trans positions
scatter3(new_trans_positions(1,1,:),new_trans_positions(1,2,:),new_trans_positions(1,3,:));
xlabel('x');
ylabel('y');
zlabel('z');
%% DAS beamforming
% add apodization
post_recon = zeros(ns,ns);
for i = 1:ns
    for j = 1:ns
        if sqrt((i-(ns/2))^2 + (j-(ns/2))^2) < (ns/2)
            
            for angle_idx = 1:size(Angle_trans,2)-1
                
                trans_x = new_trans_positions(1,1,angle_idx) + r;
                trans_z = new_trans_positions(1,3,angle_idx);
                
                dis = sqrt((i*sampleSpacing-trans_z)^2+ ...
                    (j*sampleSpacing-trans_x)^2);
                pixeldis = round(dis/sampleSpacing);
                if pixeldis > 0 && pixeldis < ns
                    
                    value = (rf_us(pixeldis,(angle_idx-1)*step_interval+1));
                    
                    post_recon(i,j) = post_recon(i,j) + value;
                 
                end
            end
            
        end
    end
end
%%
%env = abs(hilbert(post_recon));
env = abs(post_recon);
env = env./max(max(env));
env = db(env);
%%
figure(3)
%z = [1 ns] * sampleSpacing;
z = [(-ns/2) (ns/2)] * sampleSpacing;
x = [(-ns/2) (ns/2)] * sampleSpacing;
%imagesc(x,z,env,[-70,0]);
imagesc(x,z,env);
title('Final Image with 1 Degree Increments');
ylabel('Axial Distance [mm]');
xlabel('Lateral Distance [mm]');
colormap(gray);
axis image;
colorbar;