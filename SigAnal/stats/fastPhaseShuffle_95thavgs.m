% function [ maskedIfsCorrs, maskedIfsPlvs, maskedRsCorrs, maskedRsPlvs, maskedHGCorrs, maskedHGPlvs, maskedbetaCorrs, maskedbetaPlvs,...
%     maskedalphaCorrs, maskedalphaPlvs, maskedthetaCorrs, maskedthetaPlvs, maskeddeltaCorrs, maskeddeltaPlvs ]...
%     = fastPhaseShuffle_revised( originalData, fs, badChans, realIfsCorrs, realIfsPlvs, realRsCorrs, realRsPlvs, ...
%     realHGCorrs, realHGPlvs, realbetaCorrs, realbetaPlvs, realalphaCorrs, realalphaPlvs, realthetaCorrs, realthetaPlvs, realdeltaCorrs, realdeltaPlvs )

function [ maskedIfsPlvs, maskedRsPlvs, maskedHGPlvs,  maskedbetaPlvs,...
    maskedalphaPlvs, maskedthetaPlvs, maskeddeltaPlvs ]...
    = fastPhaseShuffle_95thavgs( originalData, fs, badChans, realIfsPlvs, realRsPlvs, ...
    realHGPlvs, realbetaPlvs, realalphaPlvs, realthetaPlvs, realdeltaPlvs )


numChans = size(originalData,2);

ifsPlvMaxDist = [];
rsPlvMaxDist = [];
HGPlvMaxDist = [];
alphaPlvMaxDist = [];
betaPlvMaxDist = [];
thetaPlvMaxDist = [];
deltaPlvMaxDist = [];

for reps = 1:20;
    disp(reps);
    %shuffle the data
    shuffledData = phase_shuffleFD(originalData);
    %trim the ends for artifacts
    shuffledData = shuffledData(1000:end-1000,:);
    %bandpasses
    HGShuffled = hilbAmp(shuffledData, [70 200], fs).^2;
    alphaShuffled = hilbAmp(shuffledData, [8 13], fs).^2;
    betaShuffled = hilbAmp(shuffledData, [13 30], fs).^2;
    thetaShuffled = hilbAmp(shuffledData, [4 7], fs).^2;
    deltaShuffled = hilbAmp(shuffledData, [0 4], fs).^2;
    %secondary bandpasses
    ifsShuffled = infraslowBandpass(HGShuffled);
    newFs = 60;
    [p,q] = rat(newFs/fs);
    resamp_HG = resample(HGShuffled, p, q);
%     resamp_HG = resample(HGShuffled, newFs, fs);
    rsShuffled = reallyslowBandpass(resamp_HG);
    %corrs and plvs for each band
    HGshuffledPlv = plv_revised(HGShuffled);
    alphashuffledPlv = plv_revised(alphaShuffled);
    betashuffledPlv = plv_revised(betaShuffled);
    thetashuffledPlv = plv_revised(thetaShuffled);
    deltashuffledPlv = plv_revised(deltaShuffled);
    
    ifsshuffledPlv = plv_revised(ifsShuffled);
    rsshuffledPlv = plv_revised(rsShuffled);
    
    HGshuffledPlv(HGshuffledPlv==1) = 0;
    betashuffledPlv(betashuffledPlv==1) = 0;
    alphashuffledPlv(alphashuffledPlv==1) = 0;
    thetashuffledPlv(thetashuffledPlv==1) = 0;
    deltashuffledPlv(deltashuffledPlv==1) = 0;
    ifsshuffledPlv(ifsshuffledPlv==1) = 0;
    rsshuffledPlv(rsshuffledPlv==1) = 0;
    
    
    for i = 1:numChans;
        for j = 1:numChans;
            if ismember(i, badChans) || ismember(j,badChans);
                HGshuffledPlv(i,j) = 0;
                betashuffledPlv(i,j) = 0;
                alphashuffledPlv(i,j) = 0;
                thetashuffledPlv(i,j) = 0;
                deltashuffledPlv(i,j) = 0;
                ifsshuffledPlv(i,j) = 0;
                rsshuffledPlv(i,j) = 0;
            end
        end
    end
    
    ifsPlvMaxDist = [ifsPlvMaxDist prctile(squeeze(ifsshuffledPlv),95)];
    rsPlvMaxDist = [rsPlvMaxDist prctile(squeeze(rsshuffledPlv),95)];
    
    HGPlvMaxDist = [HGPlvMaxDist prctile(squeeze(HGshuffledPlv),95)];
    alphaPlvMaxDist = [alphaPlvMaxDist prctile(squeeze(alphashuffledPlv),95)];
    betaPlvMaxDist = [betaPlvMaxDist prctile(squeeze(betashuffledPlv),95)];
    
    thetaPlvMaxDist = [thetaPlvMaxDist prctile(squeeze(thetashuffledPlv),95)];
    deltaPlvMaxDist = [deltaPlvMaxDist prctile(squeeze(deltashuffledPlv),95)];
    
end

ifsPlvMax = mean(ifsPlvMaxDist);
rsPlvMax = mean(rsPlvMaxDist);

HGPlvMax = mean(HGPlvMaxDist);
alphaPlvMax = mean(alphaPlvMaxDist);
betaPlvMax = mean(betaPlvMaxDist);

thetaPlvMax = mean(thetaPlvMaxDist);
deltaPlvMax = mean(deltaPlvMaxDist);


maskedIfsPlvs = zeros(size(realIfsPlvs));
maskedRsPlvs = zeros(size(realRsPlvs));
maskedHGPlvs = zeros(size(realHGPlvs));
maskedbetaPlvs = zeros(size(realbetaPlvs));
maskedalphaPlvs = zeros(size(realalphaPlvs));
maskedthetaPlvs = zeros(size(realthetaPlvs));
maskeddeltaPlvs = zeros(size(realdeltaPlvs));


for i = 1:numChans;
    for j=1:numChans;
        if realIfsPlvs(i,j) >= ifsPlvMax;
            maskedIfsPlvs(i,j) = realIfsPlvs(i,j);
        end
        if realRsPlvs(i,j) >= rsPlvMax;
            maskedRsPlvs(i,j) = realRsPlvs(i,j);
        end
        if realHGPlvs(i,j) >= HGPlvMax;
            maskedHGPlvs(i,j) = realHGPlvs(i,j);
        end
        if realbetaPlvs(i,j) >= betaPlvMax;
            maskedbetaPlvs(i,j) = realbetaPlvs(i,j);
        end
        if realalphaPlvs(i,j) >= alphaPlvMax;
            maskedalphaPlvs(i,j) = realalphaPlvs(i,j);
        end
        if realthetaPlvs(i,j) >= thetaPlvMax;
            maskedthetaPlvs(i,j) = realthetaPlvs(i,j);
        end
        if realdeltaPlvs(i,j) >= deltaPlvMax;
            maskeddeltaPlvs(i,j) = realdeltaPlvs(i,j);
        end
    end
end

end

