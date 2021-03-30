clear all;
clc;

load('210123_USCT_testing_quantification/PSF_quantification.mat')

env=abs(hilbert(post_recon));
env = env./max(max(env));
dbenv = db(env);

profile = env(2563,:);

soundSpeed = 1430;
fs = 80e6;
sampleSpacing = (1/fs)*soundSpeed*1000/2;

edge_1 = size(dbenv,1);
dbenv = dbenv(edge_1/4:3*edge_1/4,edge_1/4:3*edge_1/4);
profile = profile(edge_1/4:3*edge_1/4);
edge_2 = size(dbenv,1);
s_start = -round(edge_2/2);
s_end = s_start + edge_2;
x = [s_start:s_end-1] * sampleSpacing;

plot(x,profile)
axis([-10 10 0 0.6])
xline(0.4,'--r')
xline(-0.4,'--r')