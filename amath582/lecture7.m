%% lecture 1/22/2016
% AMATH 582 
close all;clear all;clc 

A = imread('cap','jpeg'); % loads images 

% need to take data from uint8 format -> double precisions to do MATH ON
% IT!!!!!!

% make black and white version
Abw = double(rgb2gray(A));

% added noise to every component 
noise = 20000;
[m,n] =size(Abw);
At = fftshift(fft2(Abw)+(noise*(randn(m,n)+1i*randn(m,n))));

Abwn = ifftn(fft2(Abw)+(noise*(randn(m,n)+1i*randn(m,n))));
figure(4)
imshow(uint8(abs(Abwn)))


% figure(1)
% %imshow works with uint8 
% imshow(A)

% figure(3)
% pcolor(Abw), shading interp
% 

figure(2)
%pcolor works with double precision
pcolor(abs(At)), shading interp, colormap(hot)
% axis([350 450 275 350])

% filtering cuts out noise, gets rid of high frequencies => blurring 
