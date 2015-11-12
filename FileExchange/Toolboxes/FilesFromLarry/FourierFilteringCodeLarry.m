x=kwinsTotal{1,55};
figure;plot(x)
FT=fft(x);
figure;plot(abs(FT))
% remove the stimulation pulses
x(3060:3115,:)=0;
% remove the stimulation pulse above 9000
x(9001:9157,:)=0;
figure;plot(x)
FT=fft(x);
figure;plot(abs(FT))
figure;plot(real(ifft(FT)))

% remove the first pair of peaks
FT(46,:)=0;
FT(9113,:)=0;
figure;plot(abs(FT))
x1=real(ifft(FT));
figure;plot(x1)

% remove the second pair of peaks
FT(136,:)=0;
FT(9023,:)=0;
figure;plot(abs(FT))
x2=real(ifft(FT));
figure;plot(x2)

% remove the third pair of peaks
FT(226,:)=0;
FT(8933,:)=0;
figure;plot(abs(FT))
x3=real(ifft(FT));
figure;plot(x3)

% remove all the high frequencies
figure;plot(abs(FT))
FT(300:9157-300,:)=0;
figure;plot(abs(FT))
x4=real(ifft(FT));
figure;plot(x4)


% plot the histograms at different times
% I accidentally used where instead of when  ;-)

where=2000;
for j=1:146;peak(j)=x(where,j);end
figure;subplot(1,5,1);hist(peak,xbins)
for j=1:146;peak(j)=x1(where,j);end
hold on;subplot(1,5,2);hist(peak,xbins)
for j=1:146;peak(j)=x2(where,j);end
hold on;subplot(1,5,3);hist(peak,xbins)
for j=1:146;peak(j)=x3(where,j);end
hold on;subplot(1,5,4);hist(peak,xbins)
for j=1:146;peak(j)=x4(where,j);end
hold on;subplot(1,5,5);hist(peak,xbins)

where=3000;
for j=1:146;peak(j)=x(where,j);end
figure;subplot(1,5,1);hist(peak,xbins)
for j=1:146;peak(j)=x1(where,j);end
hold on;subplot(1,5,2);hist(peak,xbins)
for j=1:146;peak(j)=x2(where,j);end
hold on;subplot(1,5,3);hist(peak,xbins)
for j=1:146;peak(j)=x3(where,j);end
hold on;subplot(1,5,4);hist(peak,xbins)
for j=1:146;peak(j)=x4(where,j);end
hold on;subplot(1,5,5);hist(peak,xbins)

where=3200;
for j=1:146;peak(j)=x(where,j);end
figure;subplot(1,5,1);hist(peak,xbins)
for j=1:146;peak(j)=x1(where,j);end
hold on;subplot(1,5,2);hist(peak,xbins)
for j=1:146;peak(j)=x2(where,j);end
hold on;subplot(1,5,3);hist(peak,xbins)
for j=1:146;peak(j)=x3(where,j);end
hold on;subplot(1,5,4);hist(peak,xbins)
for j=1:146;peak(j)=x4(where,j);end
hold on;subplot(1,5,5);hist(peak,xbins)