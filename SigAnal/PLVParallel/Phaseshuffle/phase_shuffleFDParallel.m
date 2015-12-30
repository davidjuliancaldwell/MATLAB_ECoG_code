function y=phase_shuffleFDParallel(x)
% function y=phase_shuffle(x)
% this function generates a phase shuffled version of input signal x
% that has similar power spectrum, but destroys the temporal structure of x
% x is time x channels

n=size(x,1);
y=fft(x);
a=abs(y);
p=y./a;
ps=fftshift(p);
if mod(n,2)>0
    nc=round(n/2);
    ix=randperm(nc-1);
    ps(1:nc-1,:)=p(ix,:);
    ps(end:-1:nc+1,:)=conj(p(ix,:));
else
    nc=n/2+1;
    ix=randperm(nc-2)+1;
    ps(2:nc-1,:)=p(ix,:);
    ps(end:-1:nc+1,:)=conj(p(ix,:));
end
ps=ifftshift(ps);
y=real(ifft(a.*ps));
