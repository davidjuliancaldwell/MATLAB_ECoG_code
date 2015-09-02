function y=conv_cpu(x,f)
% function y=conv_cpu(x,f)
if(size(x,1)>1)
y=ifft(fft([x;zeros(size(f))]).*fft([f;zeros(size(x))]));
y(end,:)=[];
else
    y=ifft(fft([x';zeros(size(f'))]).*fft([f';zeros(size(x'))]));
    y(end,:)=[];
    y=y';
end