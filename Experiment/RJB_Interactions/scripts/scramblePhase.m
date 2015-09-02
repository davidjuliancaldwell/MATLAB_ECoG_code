function xs = scramblePhase(x)
    xf= fft (x);
    
    if (iseven(length(x)))
        dc = length(x)/2 + 1;
        before = (dc-1):-1:1;
        after  = (dc+1):1:length(x);

        % before should be longer
        xf_sub = xf(before);
        a=abs(xf_sub);
        p=xf_sub./a;

        xfs_sub=a.*p(randperm(length(p)));

        xfs = zeros(size(x));        
        xfs(before) = xfs_sub;        
        xfs(after) = conj(xfs_sub(1:length(after)));
    else
        error 'figure me out!';
    end
        

    
    xs=real(ifft(xfs));
end

% function xs = scramblePhase(x)
%     xf= fft (x);
%     a=abs(xf);
%     p=xf./a;
% 
%     xfs=a.*p(randperm(length(p)));
% 
%     xs=real(ifft(xfs));
% end

