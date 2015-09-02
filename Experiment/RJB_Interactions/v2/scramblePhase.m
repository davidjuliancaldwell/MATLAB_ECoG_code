function xs = scramblePhase(x)
    xf= fft (x);
    a=abs(xf);
    p=xf./a;

    xfs=a.*p(randperm(length(p)));

    xs=real(ifft(xfs));
end