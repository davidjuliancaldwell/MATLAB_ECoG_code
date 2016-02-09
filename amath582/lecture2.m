%% radar example from lecture 2

%% part from the book
clear all;close all;clc
% generate electromagnetic pulse
L = 30; % time slot to transform
n=512; % mnumber of Foruier modes 2^9
t2 = linspace(-L,L,n+1); t=t2(1:n); % time discretization
k =(2*pi/(2*L))*[0:(n/2-1) -n/2:-1]; % frequency components of FFT

u =sech(t); %ideal signal in the time domain
figure(1), subplot(3,1,1),plot(t,u,'k'), hold on 

% add noise to signal 
noise = 1;
ut=fft(u);
unt = ut+noise*(randn(1,n)+i*randn(1,n)); % utn means noise 
un = ifft(unt);

%filter
center = 0;
filter = exp(-0.1*(k-center).^2); 

unft=unt.*filter; % filter multiplication in frequency 
unf = ifft(unft); % resulting denoised signal in  time


figure(1),subplot(2,1,1), plot(t,abs(un),'k'), hold on
plot(t,abs(unf),'g','Linewidth',[2])
axis([-30 30 0 2])
xlabel('time (t)'), ylabel('|u|')
subplot(2,1,2)
plot(fftshift(k),abs(fftshift(unt))/max(abs(fftshift(unt))),'k')
axis([-25 25 0 1])
xlabel('wavenumber (k)'), ylabel('|ut|/max(|ut)')

%% part from his lecture 

clear all;close all;clc
L=30;
n=512;


x2 = linspace(-L/2,L/2,n+1); % define the domain discretization
x = x2(1:n); % periodicity!


k=(2*pi/L)*[0:(n/2-1) (-n/2):-1];

noise = 10; % strength of noise 

u=exp(-x.^2);
ut=(fft(u));
utn = ut + noise*(randn(1,n)+i*randn(1,n)); % real and imaginary part added
% the i is for a phase component, that way you're not making assumptions
% about symmetry 
% this gives it a phase offset at component of every frequency 

un=ifft(utn);

% make filter with gaussian of certain width - filter at given frequency
% filter in k-space, frequency space

% number in front of k changes width, smaller number, fatter?
%to move filter, add center
center = 20; 
filter = exp(-0.1*(k-center).^2); 

utnf=utn.*filter; % filter multiplication in frequency 
unf = ifft(utnf); % resulting denoised signal in  time


% subplot(2,1,1), plot(x,u)
% subplot(2,1,2), plot(k,abs(ut))
% add fftshift for plotting! takes care of the red line that would
% otherwise be there. 

% threshold
thresh = 0*x+0.4;

% normalize by maximum values 
subplot(2,1,1), plot(x,u,'k'), hold on
plot(x,un,'r','Linewidth',[2]);
plot(x,unf,'m','Linewidth',[2]);
plot(x,thresh,'k:','Linewidth',[2])

subplot(2,1,2),
plot(fftshift(k),abs(fftshift(ut)/max(abs(ut))),'k'), hold on
plot(fftshift(k),abs(fftshift(utn)/max(abs(utn))),'r','Linewidth',[2])
plot(fftshift(k),fftshift(filter),'b','Linewidth',[2])
plot(fftshift(k),abs(fftshift(utnf))/max(abs(utnf)),'m','Linewidth',[2])
