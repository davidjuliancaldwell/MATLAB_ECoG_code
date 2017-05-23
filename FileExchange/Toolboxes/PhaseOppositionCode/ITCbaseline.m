function baseline = ITCbaseline(nbtrials,method,nbbootstrap,pthreshold);
%baseline = ITCbaseline(nbtrials,method,nbbootstrap,pthreshold);
%computes the baseline (or chance-level) ITC expected from nbtrials with a
%uniform random phase distribution. method is an optional argument: if 1
%(default) we use the formula from Moratti et al, Hum Brain Mapp (2007),
%otherwise we use a bootstrap procedure with nbbootstrap repetitions 
%(optional argument, default 1000). pthreshold is an optional argument: how
%many observations would we expect above this ITC value (default is 0.5,
%corresponding to chance level); by using 0.05 or lower values, one can get
%a significance ITC threshold.

if nargin < 2 || isempty(method)
    method = 1;
end;
if nargin < 3 || isempty(nbbootstrap)
    nbbootstrap = 1000;
end;
if nargin < 4 || isempty(pthreshold)
    pthreshold = 0.5;
end;

if method == 1
    baseline = sqrt(-log(pthreshold)/nbtrials);
else
    randmat = exp(sqrt(-1)*2*pi.*rand(nbtrials,nbbootstrap));
    randvec = sort(abs(mean(randmat,1)),'descend');
    baseline = randvec(ceil(pthreshold*length(randvec)));
end;