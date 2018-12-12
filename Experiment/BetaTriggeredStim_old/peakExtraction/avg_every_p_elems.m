function [averages] = avg_every_p_elems(signal,p)
%
%
% time x trials/channels
% averages along 2nd dimension (channel/trial)
% David.J.Caldwell 10.26.2018
n  = size(signal,2);
m  = size(signal,1);
xx = reshape(signal(:,1:n - mod(n, p)),[],p,floor(n/p));
averages  = squeeze(sum(xx, 2) / p);

if mod(n,p) ~= 0
averages = [averages mean(signal(:,n-mod(n,p):end),2)];
end

end