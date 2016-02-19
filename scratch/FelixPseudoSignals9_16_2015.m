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


figure
% plot(t,x,'b');
% title(['Gaussian Pulse \sigma=', num2str(sigma),'s']);
xlabel('Time(s)');
ylabel('Amplitude');
plot(t,sigs')


%% covariance, singular value decomposition 
% 
% CovMatSig = cov(sigs');
% [u,s,v] = svd(CovMatSig);

% DJC - 2-16-2016, david additions after AMATH, the previous was from Felix
% 

[u,s,v] = svd(sigs);
figure
bar(diag(s))

%%

% look at diagonal of matrix S - singular values
figure
plot(diag(s),'ko','Linewidth',[2])

% to get percentage in mode
subplot(2,1,1) % plot normal
plot(diag(s)/sum(diag(s)),'ko','Linewidth',[2])
subplot(2,1,2) % plot semilog
semilogy(diag(s)/sum(diag(s)),'ko','Linewidth',[2])

% look at the modes 
figure
x = 1:6;
plot(x,u(:,1:6),'Linewidth',[2])

% look at temporal part - columns of v
figure
plot(t,v(:,1:6),'Linewidth',[2])

%%
% low rank reconstruction 
figure
for j = 1:4
   ff = u(:,1:j)*s(1:j,1:j)*v(:,1:j)';
   subplot(2,2,j)
   surfl(x,t,ff'),shading interp
    
end



%% PCA from matlab 


[coeff,score] = pca(sigs');
