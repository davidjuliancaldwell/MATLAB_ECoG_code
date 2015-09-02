function y=conv_gpu(x,f)
% function y=conv_gpu(x,f)
a=complex(gzeros(size(x,1)+size(f,1),size(x,2)));
b=a;
a(1:size(x,1),:)=x;
b(1:size(f,1),:)=f;
a=fft(a);
b=fft(b);
c=a.*b;
y=ifft(c);


