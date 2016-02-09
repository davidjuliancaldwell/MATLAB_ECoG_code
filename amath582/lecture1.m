%% examples from lecture 1/fourier part of book
% DJC 1/5/2016

clear all; close all; clc

L = 20; % computational domain [-L/2,L/2]
n = 128; % number of Fourier modes 2^n

x2 = linspace(-L/2,L/2,n+1); % define the domain discretization
x = x2(1:n); % periodicity!

u = exp(-x.*x); % function to take a derivative of
ut = fft(u); % FFT
utshift = fftshift(ut); % shift

figure(1), plot(x,u) % plot initial gaussian
figure(2), plot(abs(ut)) % plot unshifted gaussian
figure(3), plot(abs(utshift)) % plot shifted


%% redo scaling from second lecture 
clear all;close all;clc
L=30;
n=512;


x2 = linspace(-L/2,L/2,n+1); % define the domain discretization
x = x2(1:n); % periodicity!


k=(2*pi/L)*[0:(n/2-1) (-n/2):-1];

u=exp(-x.^2);
ut=fftshift(fft(u));

subplot(2,1,1), plot(x,u)
subplot(2,1,2), plot(fftshift(k),abs(ut))

figure
plot(k,abs(fft(u)))