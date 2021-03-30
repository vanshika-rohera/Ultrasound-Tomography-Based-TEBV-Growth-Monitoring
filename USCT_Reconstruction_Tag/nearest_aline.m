 %% USE POLAR COORDINATES
 
function n = nearest_aline(i_mm,j_mm,listOfTransducers)

x_vec = listOfTransducers(1,1,:);
x_vec = reshape(x_vec,[1,size(listOfTransducers,3)]);
x_mean = mean(x_vec);
x_vec = x_vec - x_mean;
z_vec = listOfTransducers(1,3,:);
z_vec = reshape(z_vec,[1,size(listOfTransducers,3)]);
z_mean = mean(z_vec);
z_vec = z_vec - z_mean;
theta_vec = atan2(x_vec,z_vec);

theta_pxl = atan2(j_mm - x_mean, i_mm - z_mean);

diff_vec = theta_vec - theta_pxl;
[M, I] = min(abs(diff_vec)); % find the minimum difference

n = I; % index of the closest transducer

end