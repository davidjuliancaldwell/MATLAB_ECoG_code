fs=1200;
n=20;
t=(0:1/fs:n-1/fs)';

f1=18;
f2=138;

x=randn(size(t));
y=randn(size(t));
z=randn(size(t));

f3=f1+f2;

bw1=3;bw2=4;bw3=4;

xf=butter_filter(x,f1-bw1,f1+bw1,fs,4);
yf=butter_filter(y,f2-bw2,f2+bw2,fs,4);
zf=butter_filter(z,f3-bw3,f3+bw3,fs,4);


hx=hilbert(xf);
hy=hilbert(yf);
hz=hilbert(zf);

px=hx./abs(hx);
py=hy./abs(hy);
pz=hz./abs(hz);

pzc=px.*py;

az=abs(hz);

zc=z-zf+imag(hilbert(real(az.*pzc)));

fwa=3:30;
fwb=40:170;

[mapc,~,~]=compute_bplv_cont(x,y,zc,fwa,fwb,fs,1,-1);
figure
imagesc(fwa,fwb,mapc')
axis xy
drawnow;

[mapc,~,~]=compute_bplv_cont(x,y,cos(2*pi*120*t),fwa,fwb,fs,1,-1);
figure
imagesc(fwa,fwb,mapc')
axis xy
drawnow;

if 0
xx=reshape(x,1200,n);
yy=reshape(y,1200,n);
zz=reshape(zc,1200,n);

[bplv,fwc]=compute_bplv_wavelet(xx,yy,zz,[fwa fwb],fs,1,'CPUtest');
map=bplv(:,1:length(fwa),(1:length(fwb))+length(fwa));
figure
imagesc(fwa,fwb,squeeze(mean(abs(map)))')
axis xy
end
