%% 1-20-2016 - Code from AMATH 582 Lecture 6
clear all; close all;clc

L = 10; n=2048;
t2 = linspace(0,L,n+1); t=t2(1:n);

% define k vector in shifted space 
k = (2*pi/L)*[0:(n/2)-1 -n/2:-1];

% undo shift with fftshift 
ks = fftshift(k); 

% look at signal
S = (3*sin(2*t)+0.5*tanh(0.5*(t-3))+0.2*exp(-(t-4).^2)...
    +1.5*sin(5*t)+4*cos(3*(t-6).^2))/10+(t/20).^3;
St = fft(S);

figure(1)
subplot(3,1,1) % time domain
plot(t,S,'k')
set(gca,'Fontsize',[14]),
xlabel('Time (t)'), ylabel('S(t)')

subplot(3,1,2) % Fourier domain
plot(ks,abs(fftshift(St))/max(abs(St)),'k');
axis([-50 50 0 1])
set(gca,'Fontsize',[14])
xlabel('frequency (\omega)'),ylabel('FFT(S)')

%% filter 
% domain goes from 0-> 10

% start with gaussian centered at 4
g = exp(-20*(t-4).^2);
figure(3), plot(t,S,'k',t,g,'r','Linewidth',[2])

% super gaussian? 
g = exp(-2*(t-4).^10);
figure(4), plot(t,S,'k',t,g,'r','Linewidth',[2])


% slide and filter!

figure(5)

Spec = [];
tslide = 0:0.1:10;

for j=1:length(tslide)
    g = exp(-0.1*(t-tslide(j)).^10);
    % draw now tells you to DRAW IT RIGHT NOW!!!!!
%     plot(t,g), drawnow

    subplot(3,1,1)
    plot(t,S,'k',t,g,'r','Linewidth',[2])
    
    Sf = g.*S;
    
    % this here is the frequency content for a given window!
    Sft = fftshift(fft(Sf));
    Spec = [Spec; Sft];
    
    subplot(3,1,2)
    plot(t,Sf,'Linewidth',[2])
    axis([0 10 -1 1])
    
    subplot(3,1,3)
    plot(ks,Sft,'Linewidth',[2]), axis([-50 50 0 100])

    drawnow
end

%% spectrogram plot
figure(4)
pcolor(tslide,ks,abs(Spec).'), shading interp 
colormap('hot')
colorbar
axis([0 10 -60 60])