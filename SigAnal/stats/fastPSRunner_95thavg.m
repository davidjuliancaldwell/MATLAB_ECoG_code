
%     [ maskedIfsCorrs, maskedIfsPlvs, maskedRsCorrs, maskedRsPlvs, maskedHGCorrs, maskedHGPlvs, maskedbetaCorrs, maskedbetaPlvs,...
%     maskedalphaCorrs, maskedalphaPlvs, maskedthetaCorrs, maskedthetaPlvs, maskeddeltaCorrs, maskeddeltaPlvs ]...
%     = fastPhaseShuffle_revised( trimmed_sig, fs, Montage.BadChannels, ifsCorrs, ifsPlv, rsCorrs, rsPlv, ...
%     HGcorrs, HGplv, betaCorrs, betaPlv, alphaCorrs, alphaPlv, thetaCorrs, thetaPlv, deltaCorrs, deltaPlv );
%     

load(strcat(subjid, '_phaseShuffled.mat'), 'HGplvs', 'Montage', 'alphaPlvs', 'betaPlvs', 'deltaPlvs', 'fs', 'ifsPlv', 'numChans', 'rsPlv', 'subjid', 'trimmed_sig', 'thetaPlvs')

% [ maskedIfsPlvs, maskedRsPlvs, maskedHGPlvs,  maskedbetaPlvs,...
%     maskedalphaPlvs, maskedthetaPlvs, maskeddeltaPlvs ]...
%     = fastPhaseShuffle_50thpctile( trimmed_sig, fs, [], ifsPlv, rsPlv, ...
%     HGplv, betaPlv, alphaPlv, thetaPlv, deltaPlv );

[ maskedIfsPlvs, maskedRsPlvs, maskedHGPlvs,  maskedbetaPlvs,...
    maskedalphaPlvs, maskedthetaPlvs, maskeddeltaPlvs ]...
    = fastPhaseShuffle_95thavgs( trimmed_sig, fs, Montage.BadChannels, ifsPlv, rsPlv, ...
    HGplv, betaPlv, alphaPlv, thetaPlv, deltaPlv );


save(strcat(subjid, '_phaseShuffled_95thavg'));


alpha_shortestPath = charpath(nansum(cat(3,maskedalphaPlvs,maskedalphaPlvs'),3));
alpha_numLinks = degrees_und(nansum(cat(3,maskedalphaPlvs,maskedalphaPlvs'),3));
alpha_density = density_und(nansum(cat(3,maskedalphaPlvs,maskedalphaPlvs'),3));

beta_shortestPath = charpath(nansum(cat(3,maskedbetaPlvs,maskedbetaPlvs'),3));
beta_numLinks = degrees_und(nansum(cat(3,maskedbetaPlvs,maskedbetaPlvs'),3));
beta_density = density_und(nansum(cat(3,maskedbetaPlvs,maskedbetaPlvs'),3));

theta_shortestPath = charpath(nansum(cat(3,maskedthetaPlvs,maskedthetaPlvs'),3));
theta_numLinks = degrees_und(nansum(cat(3,maskedthetaPlvs,maskedthetaPlvs'),3));
theta_density = density_und(nansum(cat(3,maskedthetaPlvs,maskedthetaPlvs'),3));

HG_shortestPath = charpath(nansum(cat(3,maskedHGPlvs,maskedHGPlvs'),3));
HG_numLinks = degrees_und(nansum(cat(3,maskedHGPlvs,maskedHGPlvs'),3));
HG_density = density_und(nansum(cat(3,maskedHGPlvs,maskedHGPlvs'),3));

delta_shortestPath = charpath(nansum(cat(3,maskeddeltaPlvs,maskeddeltaPlvs'),3));
delta_numLinks = degrees_und(nansum(cat(3,maskeddeltaPlvs,maskeddeltaPlvs'),3));
delta_density = density_und(nansum(cat(3,maskeddeltaPlvs,maskeddeltaPlvs'),3));

ifsHG_shortestPath = charpath(nansum(cat(3,maskedIfsPlvs,maskedIfsPlvs'),3));
ifsHG_numLinks = degrees_und(nansum(cat(3,maskedIfsPlvs,maskedIfsPlvs'),3));
ifsHG_density = density_und(nansum(cat(3,maskedIfsPlvs,maskedIfsPlvs'),3));

rsHG_shortestPath = charpath(nansum(cat(3,maskedRsPlvs,maskedRsPlvs'),3));
rsHG_numLinks = degrees_und(nansum(cat(3,maskedRsPlvs,maskedRsPlvs'),3));
rsHG_density = density_und(nansum(cat(3,maskedRsPlvs,maskedRsPlvs'),3));



save(strcat(subjid, '_phaseShuffled_withgraph'));


    
%     save(strcat(subjid, '_postBCI_phaseShuffled'));
    
    