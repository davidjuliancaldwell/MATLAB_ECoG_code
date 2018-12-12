function [av,ci,N,s,ss] = trigav(dat,trig,wn)
% function [av,ci,N,s,ss] = trigav(dat,trig,wn)
%   Triggered average of a time series.
%   dat = time series
%   trig = indices of triggers
%   wn = pre/post-trigger window size in samples (e.g. [-20 40])
%   av = triggered average
%   ci = 95% confidence interval on the average
%   N = number of triggers used for average
%   s = sum of windowed data (use to average over multiple calls to this function)
%   ss = sum of squares of windowed data (use to average over multiple calls to this function) 
Nd = length(dat);
if size(trig,1)==1, trig = trig'; end
Nt = length(trig);
swn = wn(1):wn(2);
Nw = length(swn);
mtrig = trig*ones(1,Nw) + ones(Nt,1)*swn;
[iskp,jskp] = find(mtrig<1 | mtrig>Nd);
iskp = unique(iskp);
mtrig(iskp,:) = [];
s = nansum(dat(mtrig));
ss = nansum(dat(mtrig).^2);
N = Nt-length(iskp);
av = s/N;
ci = 1.96*sqrt(ss/N-av.^2)/sqrt(N);