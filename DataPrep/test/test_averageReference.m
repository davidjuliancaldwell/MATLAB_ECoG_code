t = -2*pi:0.001:2*pi;

common = 3*sin(60*t);

data = zeros([length(t), 3]);

data(:,1) = sin(5*t+.123) + 0.1*rand(size(t)) + common;
data(:,2) = sin(3*t+.544) + 0.1*rand(size(t)) + common;
data(:,3) = sin(6*t+.243) + 0.1*rand(size(t)) + common;

figure;

subplot(211); plot(t, data);

rData = averageReference(data);

subplot(212); plot(t, rData);