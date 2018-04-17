%Finds peak to peak amplitude in a signal
%Input is signal and an option
%   Option can be abs, rising, falling
%   rising means largest peak to peak during rising phase
%Output is largest peak-to-peak, location of peak and trough

%Also will look for minimum peak prominence of '5'.
%Because noise
%Can set this as needed depending on signal
%This was chosen arbitrarily
%Should probably figure a way to look at deviations in signal

% first written by Andrew ko, modified by DJC 4-13-2018


function [amp,pk_loc,tr_loc]=peak_to_peak(signal,opt)

if nargin2
    opt='abs';
end;

[ppks,plats]=findpeaks(signal,'minpeakprominence',5);
[npks,nlats]=findpeaks(-signal,'minpeakprominence',5);

falling=[];
falling_pk=[];
falling_tr=[];
for ii=1length(plats)
    nix=find(nlatsplats(ii),1);
    if ~isempty(nix)
        falling(length(falling)+1)=...
            ppks(ii)+npks(nix);
        falling_pk(length(falling_pk)+1)=...
            plats(ii);
        falling_tr(length(falling_tr)+1)=...
            nlats(nix);
    end;
end
rising=[];
rising_tr=[];
rising_pk=[];
for ii=1length(nlats)
    pix=find(platsnlats(ii),1);
    if ~isempty(pix)
        rising(length(rising)+1)=...
            npks(ii)+ppks(pix);
        rising_tr(length(rising_tr)+1)=...
            nlats(ii);
        rising_pk(length(rising_pk)+1)=...
            plats(pix);
        
    end;
end;

switch opt
    case 'abs'
        %Absolute maximum peak to peak
        pk2pk=[falling rising];
        [amp,ix]=max(pk2pk);
        pks=[falling_pk rising_pk];
        trs=[falling_tr rising_tr];
        pk_loc=pks(ix);
        tr_loc=trs(ix);
        
    case 'rising'
        %Only rising peak to peak
        [amp,ix]=max(rising);
        pk_loc=rising_pk(ix);
        tr_loc=rising_tr(ix);
        
    case 'falling'
        %Only falling peak to peak
        [amp,ix]=max(falling);
        pk_loc=falling_pk(ix);
        tr_loc=falling_tr(ix);
        
    otherwise
        %For any other parameter value same as abs
        pk2pk=[falling rising];
        [amp,ix]=max(pk2pk);
        pks=[falling_pk rising_pk];
        trs=[falling_tr rising_tr];
        pk_loc=pks(ix);
        tr_loc=trs(ix);
        
end;


end