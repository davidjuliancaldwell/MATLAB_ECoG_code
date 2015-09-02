function y=gconv_felix(x,f)
% function y=gconv_felix(x,f)
a=gzeros(size(x,1)+size(f,1),size(x,2))+i-i;
b=gzeros(size(x,1)+size(f,1),size(x,2))+i-i;
a(1:size(x,1),:)=x;
b(1:size(f,1),:)=f;
af=fft(a);
bf=fft(b);
c=af.*bf;
y=ifft(c);

