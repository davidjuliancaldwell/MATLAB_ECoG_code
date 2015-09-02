function pac=compute_pac_amp(x,y,fwx,fwy,fs,pr)
% function compute_pac_amp(x,y,fwx,fwy,fs)
% amplitude phase locking
 
[~,~,Callx,~]=time_frequency_wavelet(x,fwx,fs,pr,1,'CPUtest');
[~,~,Cally,~]=time_frequency_wavelet(y,fwy,fs,pr,1,'CPUtest');
px=Callx./abs(Callx);
ay=abs(Cally);
pac=abs(ay'*px)/size(px,1);
end