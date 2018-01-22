function pac=compute_pac_plv(x,y,fwx,fwy,fs)
% function compute_pac_plv(x,y,fwx,fwy,fs)
% computes plv between amplitude of y and phase of x
% PAC estimate according to Foster & Parvizi 2012
doi:10.1016/j.neuroimage.2011.12.019

pac=zeros(length(fwx),length(fwy));
[~,~,Callx,~]=time_frequency_wavelet(x,fwx,fs,1,1,'CPUtest');
px=Callx./abs(Callx);

bw=max(fwx);
for i=1:length(fwy)
    ya=abs(hilbert(butter_filter(y,fwy(i)-bw,fwy(i)+bw,fs,4)));
    [~,~,Cally,~]=time_frequency_wavelet(ya,fwx,fs,1,1,'CPUtest');
    py=Cally./abs(Cally);
    pac(:,i)=abs(mean(px.*conj(py),1))';
end
