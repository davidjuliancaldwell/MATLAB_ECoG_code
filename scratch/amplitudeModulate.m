Fs = 24414;
Fp = 200;
L = Fs;

T = 1/Fs;
t = (0:L-1)*T;

% 20 hz sin wave
sin20 = sin(2*pi*20*t);

figure
plot(t,sin20)