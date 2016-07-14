function [PHA,T,AMP,Rsquare,FITLINE] = sinfit (Y,SPAN,TRANGE,X)
%SINFIT  Sine wave fit to data.
%   [PHA T AMP Rsquare FITLINE] = sinfit (Y,SPAN,TRANGE,X)
%
%   Fits data to the equation
%   y = AMP * sin(PHASE + 2*pi * x/T)
%
%   Y       data to be fitted
%   SPAN    smoothing span (odd number of samples)
%   TRANGE  range of sinusoid period in samples [lower upper]
%   X       x values (default: 1,2,3 etc)
%
%   Note: PHASE corresponds to the initial phase (@ 1st sample of Y)
%
%   Programmed by Stavros Zanos, Spring 2014

if size(Y,1)<size(Y,2)
    Y = Y';
end

if nargin<4
    X = [1:length(Y)]';
else
    if size(X,1)<size(X,2)
        X = X';
    end
end

Ysm = smooth(Y,SPAN,'moving',0); % smooth data via moving average
Ysm = Ysm-median(Ysm); % DC correction

% lower/upper values
amp_lu = [max(abs(Ysm))/3 max(abs(Ysm))*3];
ph_lu = [-pi pi];
T_lu = sort(TRANGE);

% start values
amp_sv = max(abs(Ysm));
ph_sv = 0;
T_sv = mean(TRANGE);

f = fitoptions('method','NonlinearLeastSquares','Robust','On',...
    'Lower',[amp_lu(1) ph_lu(1) T_lu(1)],'Upper',[amp_lu(2) ph_lu(2) T_lu(2)]);

st = [amp_sv ph_sv T_sv];
set(f,'Startpoint',st);

ft = fittype('a*sin(b+2*pi*X/c)',...
    'dependent',{'Ysm'},'independent',{'X'},...
    'coefficients',{'a', 'b', 'c'});

[cfun,gof,output] = fit(X,Ysm,ft,f);

AMP = cfun.a;
PHA = cfun.b;
T = cfun.c;
FITLINE = cfun(X);
Rsquare = gof.rsquare;

end