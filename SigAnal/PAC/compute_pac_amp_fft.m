function [map,fa,fb]=compute_pac_amp_fft(x,y,fra,frb,fs,nfft,varargin)
n=floor(size(x,1)/nfft);

xx=reshape(x(1:n*nfft),nfft,n);
yy=reshape(y(1:n*nfft),nfft,n);
wind=hanning(nfft);
xx=xx.*repmat(wind,1,n);
yy=yy.*repmat(wind,1,n);

xf=fft(xx,nfft*2);
yf=fft(yy,nfft*2);

xf=xf(1:nfft,:);
yf=yf(1:nfft,:);
f=(0:nfft-1)/nfft*fs/2;

ixa=find(f>=fra(1) & f<=fra(2));
ixb=find(f>=frb(1) & f<=frb(2));
fa=f(ixa);
fb=f(ixb);
px=xf(ixa,:)./abs(xf(ixa,:));
ay=abs(yf(ixb,:));

map=abs(ay*px')/n;
if nargin>6
    switch varargin{1}
        case 'norm'
            map=map./repmat(mean(ay,2),1,size(map,2));
    end
end
