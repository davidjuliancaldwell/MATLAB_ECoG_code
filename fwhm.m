function [fwhm_samples, fwhm_seconds] = fwhm()
%This function computes the full width at half max of a gaussian window.
%The user inputs the window size of the Gaussian window. Useful for
%figuring out smoothing. Also use frequency of sampling to compute time
%scale in seconds rather than samples. Written 7/25/2014 DJC

win = input('Input width of gaussian window ');
fs = input('Input frequency of sampling ');
gauss = gausswin(win);

%save unmodified gauss for plotting
gauss_plot = gauss;
t = [1:length(gauss_plot)];
t_fs = t/fs;

%calculate half_max value 
half_max = max(gauss)/2;

%compute value and index of point closest to half maximum value of gaussian
[value1, index1] = min(abs(gauss-half_max)); 

%eliminate value at first half max point in order to find the second.
gauss(index1) = [];
[value2, index2] = min(abs(gauss-half_max));

%adjust for removing one value from array when searching for the second
%index
index2 = index2+1;

fwhm_samples = (index2-index1);

fwhm_seconds = fwhm_samples/fs;

% plot the gaussian window function and vertical lines at each of the
% indices

figure
hold on

subplot(2,1,1)
plot(t,gauss_plot);
vline(index1);
vline(index2);

subplot(2,1,2)
plot(t_fs,gauss_plot);
vline(index1/fs);
vline(index2/fs);

end

