clear all;
clc;
soundSpeed = 1540;
no_ele = 1;
%channelSpacing = 0.2;
fs = 60e6;
sampleSpacing = (1/fs)*soundSpeed*1000/2;
times = 1;
%%
field_init(0);
Angle = 0:360;
%% Trianglar phantom
% phantom_position = [0, 0, 20; ...
%    -5, 0, 30; ...
%    0, 0, 30; ...
%    5, 0, 30; ...
%    -10, 0, 40; ...
%    -5, 0, 40; ...
%    0, 0, 40; ...
%    5, 0, 40; ...
%    10, 0, 40]/1000; % in m
%% Point Phantom
phantom_position = [0,0,10]/1000;
Center = [0, 0, 30]/1000;
new_phantom_positions = rotatePhantom1(phantom_position, Angle, Center);
%% Ring Phantom
phantom_profile = [0 0 15]/1000; 
angle = [0:359]; %it controls number of points in circle phantom
Center = [0 0 30] / 1000; % in [m]
phantom_generated = rotatePhantom1(phantom_profile,angle,Center);
phantom_g1 = zeros(size(phantom_generated,3),3);
for i = 1:size(angle,2)
     phantom_g1(i,:) = phantom_generated(1,:,i);
end
phantom_positions = vertcat(phantom_g1); 
% phantom_amplitudes = vertcat(20*ones(size(phantom_generated,3),1),25*ones(size(phantom_generated,3),1),30*ones(size(phantom_generated,3),1));
new_phantom_positions = rotatePhantom1(phantom_positions, Angle, Center);
%% plot phantom points
% scatter3(new_phantom_positions(:,1),new_phantom_positions(:,2),new_phantom_positions(:,3));
% xlabel('x');
% ylabel('y');
% zlabel('z');
%%
ns = 5000;
rf_us = zeros(ns,size(new_phantom_positions,3));
for angle = 1:size(new_phantom_positions,3)
    temp = generateRF2(new_phantom_positions(:,:,angle));
    rf_us(1:size(temp,1),angle) = temp;
end
% for i=1:size(rf_us,1)
%     if i-1> 0 && i + 1< size(rf_us,1)
%         rf_us(i,:) = rf_us(i,:)*2 - ((rf_us(i+1,:)-rf_us(i-1,:)));
%     end
% end​
rf_us = abs(hilbert(rf_us));
%% Disply A lines
figure(1);
imagesc(rf_us);
xlabel('Angle');
ylabel('Number of Samples');

A=repmat(1:5000,1);
%index_vector=flip(A);
%TGC = 1./index_vector;
TGC = A.^2';

for k= 1:361
    TGC_Alines(:,k)=TGC.*rf_us(:,k);
    %TGC_Alines(:,k)=rf_us(:,k);
end

%% Generate transducer positions
% need to be fixed
% rotate the position of transducer [0, 0, 0] wrt to target
step_size = 1;
Angle_trans = 0:-step_size:-360; %number of alines that are generated
new_trans_positions = rotatePhantom1([0, 0, 0], Angle_trans, Center);
new_trans_positions = new_trans_positions*1000;
%% plot trans positions
% scatter3(new_trans_positions(1,1,:),new_trans_positions(1,2,:),new_trans_positions(1,3,:));
% xlabel('x');
% ylabel('y');
% zlabel('z');
%% DAS beamforming
% add apodization
post_recon = zeros(4676,4676);
for i = 1:4676
    for j = 1:4676
        if sqrt((i-2338)^2 + (j-2338)^2) < 2338
            
            for angle_idx = 1:size(Angle_trans,2)-1
                
                trans_x = new_trans_positions(1,1,angle_idx) + 30;
                trans_z = new_trans_positions(1,3,angle_idx);
                
                dis = sqrt((i*sampleSpacing-trans_z)^2+ ...
                    (j*sampleSpacing-trans_x)^2);
                pixeldis = round(dis/sampleSpacing);
                if pixeldis > 0 && pixeldis < ns
                    
                    value = (TGC_Alines(pixeldis,(angle_idx-1)*step_size+1));
                    
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
%env = db(env);
%%
figure(3)
z = [1 4676] * sampleSpacing;
x = [-2338 2338] * sampleSpacing;
%imagesc(x,z,env,[-40,0]);
imagesc(x,z,env);
title('Final Image with 1 Degree Increments');
ylabel('Axial Distance [mm]');
xlabel('Lateral Distance [mm]');
colormap(gray);
axis image;
colorbar;