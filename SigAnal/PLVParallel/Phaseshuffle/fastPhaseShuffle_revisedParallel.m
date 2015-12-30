% function [ maskedIfsCorrs, maskedIfsPlvs, maskedRsCorrs, maskedRsPlvs, maskedHGCorrs, maskedHGPlvs, maskedbetaCorrs, maskedbetaPlvs,...
%     maskedalphaCorrs, maskedalphaPlvs, maskedthetaCorrs, maskedthetaPlvs, maskeddeltaCorrs, maskeddeltaPlvs ]...
%     = fastPhaseShuffle_revised( originalData, fs, badChans, realIfsCorrs, realIfsPlvs, realRsCorrs, realRsPlvs, ...
%     realHGCorrs, realHGPlvs, realbetaCorrs, realbetaPlvs, realalphaCorrs, realalphaPlvs, realthetaCorrs, realthetaPlvs, realdeltaCorrs, realdeltaPlvs )

function [ maskedIfsPlvs, maskedRsPlvs, maskedHGPlvs,  maskedbetaPlvs,...
    maskedalphaPlvs, maskedthetaPlvs, maskeddeltaPlvs ]...
    = fastPhaseShuffle_revisedParallel( originalData, fs, badChans, realIfsPlvs, realRsPlvs, ...
    realHGPlvs, realbetaPlvs, realalphaPlvs, realthetaPlvs, realdeltaPlvs )


numChans = size(originalData,2);

% ifsCorrMaxDist = [];
ifsPlvMaxDist = [];
% rsCorrMaxDist = [];
rsPlvMaxDist = [];
% HGCorrMaxDist = [];
HGPlvMaxDist = [];
% alphaCorrMaxDist = [];
alphaPlvMaxDist = [];
% betaCorrMaxDist = [];
betaPlvMaxDist = [];
% thetaCorrMaxDist = [];
thetaPlvMaxDist = [];
% deltaCorrMaxDist = [];
deltaPlvMaxDist = [];

parfor reps = 1:20;
    disp(reps);
    %shuffle the data
    shuffledData = phase_shuffleFDParallel(originalData);
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
%     HGshuffledCorrs = corr(HGShuffled);
    HGshuffledPlv = plv_revised(HGShuffled);
%     alphashuffledCorrs = corr(alphaShuffled);
    alphashuffledPlv = plv_revised(alphaShuffled);
%     betashuffledCorrs = corr(betaShuffled);
    betashuffledPlv = plv_revised(betaShuffled);
%     thetashuffledCorrs = corr(thetaShuffled);
    thetashuffledPlv = plv_revised(thetaShuffled);
%     deltashuffledCorrs = corr(deltaShuffled);
    deltashuffledPlv = plv_revised(deltaShuffled);
    
%     ifsshuffledCorrs = corr(ifsShuffled);
    ifsshuffledPlv = plv_revised(ifsShuffled);
%     rsshuffledCorrs = corr(rsShuffled);
    rsshuffledPlv = plv_revised(rsShuffled);
    
%     HGshuffledCorrs(HGshuffledCorrs==1) = 0;
    HGshuffledPlv(HGshuffledPlv==1) = 0;
%     betashuffledCorrs(betashuffledCorrs==1) = 0;
    betashuffledPlv(betashuffledPlv==1) = 0;
%     alphashuffledCorrs(alphashuffledCorrs==1) = 0;
    alphashuffledPlv(alphashuffledPlv==1) = 0;
%     thetashuffledCorrs(thetashuffledCorrs==1) = 0;
    thetashuffledPlv(thetashuffledPlv==1) = 0;
%     deltashuffledCorrs(deltashuffledCorrs==1) = 0;
    deltashuffledPlv(deltashuffledPlv==1) = 0;
%     ifsshuffledCorrs(ifsshuffledCorrs==1) = 0;
    ifsshuffledPlv(ifsshuffledPlv==1) = 0;
%     rsshuffledCorrs(rsshuffledCorrs==1) = 0;
    rsshuffledPlv(rsshuffledPlv==1) = 0;
    
    
    for i = 1:numChans;
        for j = 1:numChans;
            if ismember(i, badChans) || ismember(j,badChans);
%                 HGshuffledCorrs(i,j) = 0; 
                HGshuffledPlv(i,j) = 0;
%                 betashuffledCorrs(i,j) = 0; 
                betashuffledPlv(i,j) = 0;
%                 alphashuffledCorrs(i,j) = 0; 
                alphashuffledPlv(i,j) = 0;
%                 thetashuffledCorrs(i,j) = 0; 
                thetashuffledPlv(i,j) = 0;
%                 deltashuffledCorrs(i,j) = 0; 
                deltashuffledPlv(i,j) = 0;
%                 ifsshuffledCorrs(i,j) = 0; 
                ifsshuffledPlv(i,j) = 0;
%                 rsshuffledCorrs(i,j) = 0; 
                rsshuffledPlv(i,j) = 0;
            end
        end
    end
    
%     ifsCorrMaxDist =[ifsCorrMaxDist max(max(abs(ifsshuffledCorrs)))];
    ifsPlvMaxDist = [ifsPlvMaxDist max(max(abs(ifsshuffledPlv)))];
%     rsCorrMaxDist = [rsCorrMaxDist max(max(abs(rsshuffledCorrs)))];
    rsPlvMaxDist = [rsPlvMaxDist max(max(abs(rsshuffledPlv)))];
    
%     HGCorrMaxDist = [HGCorrMaxDist max(max(abs(HGshuffledCorrs)))];
    HGPlvMaxDist = [HGPlvMaxDist max(max(abs(HGshuffledPlv)))];
%     alphaCorrMaxDist = [alphaCorrMaxDist max(max(abs(alphashuffledCorrs)))];
    alphaPlvMaxDist = [alphaPlvMaxDist max(max(abs(alphashuffledPlv)))];
%     betaCorrMaxDist = [betaCorrMaxDist max(max(abs(betashuffledCorrs)))];
    betaPlvMaxDist = [betaPlvMaxDist max(max(abs(betashuffledPlv)))];
    
%     thetaCorrMaxDist = [thetaCorrMaxDist max(max(abs(thetashuffledCorrs)))];
    thetaPlvMaxDist = [thetaPlvMaxDist max(max(abs(thetashuffledPlv)))];
%     deltaCorrMaxDist = [deltaCorrMaxDist max(max(abs(deltashuffledCorrs)))];
    deltaPlvMaxDist = [deltaPlvMaxDist max(max(abs(deltashuffledPlv)))];
    
end

% ifsCorrMax = prctile(ifsCorrMaxDist,95);
ifsPlvMax = prctile(ifsPlvMaxDist,95);
% rsCorrMax = prctile(rsCorrMaxDist,95);
rsPlvMax = prctile(rsPlvMaxDist,95);

% HGCorrMax = prctile(HGCorrMaxDist,95);
HGPlvMax = prctile(HGPlvMaxDist,95);
% alphaCorrMax = prctile(alphaCorrMaxDist,95);
alphaPlvMax = prctile(alphaPlvMaxDist,95);
% betaCorrMax = prctile(betaCorrMaxDist,95);
betaPlvMax = prctile(betaPlvMaxDist,95);

% thetaCorrMax = prctile(thetaCorrMaxDist,95);
thetaPlvMax = prctile(thetaPlvMaxDist, 95);
% deltaCorrMax = prctile(deltaCorrMaxDist, 95);
deltaPlvMax = prctile(deltaPlvMaxDist, 95);


% maskedIfsCorrs = zeros(size(realIfsCorrs));
maskedIfsPlvs = zeros(size(realIfsPlvs));
% maskedRsCorrs = zeros(size(realRsCorrs));
maskedRsPlvs = zeros(size(realRsPlvs));
% maskedHGCorrs = zeros(size(realHGCorrs));
maskedHGPlvs = zeros(size(realHGPlvs));
% maskedbetaCorrs = zeros(size(realbetaCorrs));
maskedbetaPlvs = zeros(size(realbetaPlvs));
% maskedalphaCorrs = zeros(size(realalphaCorrs));
maskedalphaPlvs = zeros(size(realalphaPlvs));
% maskedthetaCorrs = zeros(size(realthetaCorrs));
maskedthetaPlvs = zeros(size(realthetaPlvs));
% maskeddeltaCorrs = zeros(size(realdeltaCorrs));
maskeddeltaPlvs = zeros(size(realdeltaPlvs));


parfor i = 1:numChans;
    for j=1:numChans;
%         if abs(realIfsCorrs(i,j)) >= ifsCorrMax;
%             maskedIfsCorrs(i,j) = realIfsCorrs(i,j);
%         end
        if realIfsPlvs(i,j) >= ifsPlvMax;
            maskedIfsPlvs(i,j) = realIfsPlvs(i,j);
        end
%         if abs(realRsCorrs(i,j)) >= rsCorrMax;
%             maskedRsCorrs(i,j) = realRsCorrs(i,j);
%         end
        if realRsPlvs(i,j) >= rsPlvMax;
            maskedRsPlvs(i,j) = realRsPlvs(i,j);
        end
%         if abs(realHGCorrs(i,j)) >= HGCorrMax;
%             maskedHGCorrs(i,j) = realHGCorrs(i,j);
%         end
        if realHGPlvs(i,j) >= HGPlvMax;
            maskedHGPlvs(i,j) = realHGPlvs(i,j);
        end
%         if abs(maskedbetaCorrs(i,j)) >= betaCorrMax;
%             maskedbetaCorrs(i,j) = realbetaCorrs(i,j);
%         end
        if realbetaPlvs(i,j) >= betaPlvMax;
            maskedbetaPlvs(i,j) = realbetaPlvs(i,j);
        end
%         if abs(realalphaCorrs(i,j)) >= alphaCorrMax;
%             maskedalphaCorrs(i,j) = realalphaCorrs(i,j);
%         end
        if realalphaPlvs(i,j) >= alphaPlvMax;
            maskedalphaPlvs(i,j) = realalphaPlvs(i,j);
        end
%         if abs(realthetaCorrs(i,j)) >= thetaCorrMax;
%             maskedthetaCorrs(i,j) = realthetaCorrs(i,j);
%         end
        if realthetaPlvs(i,j) >= thetaPlvMax;
            maskedthetaPlvs(i,j) = realthetaPlvs(i,j);
        end
%         if abs(realdeltaCorrs(i,j)) >= deltaCorrMax;
%             maskeddeltaCorrs(i,j) = realdeltaCorrs(i,j);
%         end
        if realdeltaPlvs(i,j) >= deltaPlvMax;
            maskeddeltaPlvs(i,j) = realdeltaPlvs(i,j);
        end
    end
end

end

