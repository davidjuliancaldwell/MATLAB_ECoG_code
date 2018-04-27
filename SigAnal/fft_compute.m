
function [f,P1] = fft_compute(fs,dataEpoched)
%
T = 1/fs;
L = size(dataEpoched,1);

Y = fft(dataEpoched);
P2 = abs(Y/L);
P1 = P2(1:floor(L/2)+1,:,:);
P1(2:end-1,:,:) = 2*P1(2:end-1,:,:);
f = fs*(0:floor(L/2))/L;

end