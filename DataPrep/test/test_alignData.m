%% testing againse generated waveforms

t = -pi:pi/10000:pi;

x = 2*(1+cos(t)) .* (.5*cos(7*t + .234)) .* (0.25*cos(24*t + .1));
y = x(floor(3*length(x)/10):floor(5*length(x)/10));

floor(3*length(x)/10);

[d, e] = alignData(x, y, 100, 100, 3, true)

%% testing one data set against a subset
clear;

[a,b,c] = bci2kQuickLoad('..\data\d3\guger\finger_twister_guger001\7ee6bc_finger_twister_gugerS001R02.dat');

x = double(a(:,9));
y = x(floor(length(x)/5):2*floor(length(x)/5));

[d, e] = alignData(x, y, 1200, 1200, 3, true)

%% testing one data set against a noisy subset
clear;

[a,b,c] = bci2kQuickLoad('..\data\d3\guger\finger_twister_guger001\7ee6bc_finger_twister_gugerS001R02.dat');

x = double(a(:,9));
y = x(floor(length(x)/5):2*floor(length(x)/5));

for c = 1:length(y)
    y(c) = y(c) * random('norm', 1, .5);
end

[d, e] = alignData(x, y, 1200, 1200, 3, true)

%% testing clinical data set against a guger data set from the same
% recording session


load ..\data\d3\derived\7ee6bc_channel49.mat;
x = ecogFilter(channelData(5*3.4e6:5*3.9e6), false, 0, true, 5, true, 30, 2000);


[a,b,c] = bci2kQuickLoad('..\data\d3\guger\finger_twister_guger001\7ee6bc_finger_twister_gugerS001R02.dat');
y = double(a(:,9));
y = ecogFilter(y, false, 0, true, 5, true, 30, 1200);

[d, e] = alignData(x, y, 2000, 1200, 1, true, true)
