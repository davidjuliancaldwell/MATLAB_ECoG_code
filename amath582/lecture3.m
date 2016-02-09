%%Lecture 3 - 1/08/2016 

clear all; close all; clc

L = 30; n=512;

x2 = linspace(-L/2,L/2,n+1); x=x2(1:n);

u=1.*sech(x);
ut=fft(u);

% un is noisy added to signal u 
noise = 10;

ave = 0*ut;
for j=1:30
unt=ut+noise*(randn(1,n)+i*randn(1,n));
ave = ave+unt;
un = ifft(ave);

%have to normalize by number of realizations, so divide by j 
plot(x,abs(un)/j,'r','LineWidth',2)
axis([-L/2 L/2 0 2])
pause(0.25) % pause to look atit
end



%% measurements in time and space

clear all; close all; clc

L=30; n= 512;
x2 = linspace(-L/2,L/2,n+1); x=x2(1:n);

% fourier transform thinks 2pi period domain, so scaling factor because we
% are working on scale of size L
% these are the wave numbers, cos(x), cos(2x), put this way because FFT
% flips things 
k=(2*pi/L)*[0:(n/2-1) -n/2:-1];

% slice is taking time snapshot, snapshot of time, each snapshot 30 units
% of time, 512 points. 
slice = [0:0.5:10]; 
[T,S] = meshgrid(x,slice);

% need to take snapshots of wave number space 
[K,S] = meshgrid(k,slice);

% bump that is moving around. The exp part is where it's sitting 
subplot(2,1,1)
U=sech(T-10*sin(S)).*exp(i*0*T);

% plot both U and it's fourier transform
waterfall(T,S,U), colormap([0 0 0]), view(-15,70)

noise=10;
subplot(2,1,2)
for j=1:length(slice)
    % grabbing each row of U, which is a snapshot, and fourier transform
    % it. Put it in big matrix Ut.
    % fftshift it to view it! 
   Ut(j,:)=(fft(U(j,:)))+noise*(randn(1,n)+i*randn(1,n));
   Un(j,:)=ifft(Ut(j,:));
    
end

waterfall(abs(fftshift(Ut)))
% right now, signal moving around in time, frequency not moving around 

subplot(2,1,1), waterfall(abs(Un))

%% want to average frequency domain!

figure(2)
ave = 0.*sech(x);

for j = 1:length(slice) 
    ave=ave+Ut(j,:);
end
ave = ave/21;
plot(abs(ifftshift(ave)))


