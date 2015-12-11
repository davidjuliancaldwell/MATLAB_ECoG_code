%% 9 - 17 - 2015 DJC, attempts to better understand volume conduction and synchrony
% this is a script to try and plot various artificial signals, apply signal
% processing techniques to them, and in general better understand what I am
% doing 


fs=1000; %sampling frequency
sigma=0.01;
t=-0.5:1/fs:0.5; %time base
 
variance=sigma^2;
x=1/(sqrt(2*pi*variance))*(exp(-t.^2/(2*variance)));

%scale x down
x = x/20;



figure
% plot(t,x,'b');
% title(['Gaussian Pulse \sigma=', num2str(sigma),'s']);
xlabel('Time(s)');
ylabel('Amplitude');

%%
hold on
x_shift = circshift(x',100)';
% plot(t,x_shift,'r')

%% signals with different weights
weights = [1 -1 3 0 2];
sigs = weights'*x;
sigs = [sigs ; x_shift];

% add random noise
sigs = sigs+(rand(6,1001) - 0.5);


plot(t,sigs')


%% covariance, singular value decomposition 

CovMatSig = cov(sigs');
[U,S,V] = svd(CovMatSig);
figure
bar(diag(S))


%% PCA from matlab 


[coeff,score] = pca(sigs');
