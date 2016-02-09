%% modified by DJC 1-22-2016

%%
close all;clear all;clc
sid = '0b5a2e';
%there appears to be no montage for this subject currently
Montage.Montage = 64;
Montage.MontageTokenized = {'Grid(1:64)'};
Montage.MontageString = Montage.MontageTokenized{:};
Montage.MontageTrodes = zeros(64, 3);
Montage.BadChannels = [25 29];
Montage.Default = true;

% get electrode locations
locs = trodeLocsFromMontage(sid, Montage, false);

%% some more preprocessing if desired, NEED MONTAGE LOADED 

% post load
subjid = '0b5a2e';
suffixPost = 'postStimRestDecimated';
load(strcat(subjid, '_', suffixPost), 'fs', 'Blck')
BlckPost = Blck;
clear Blck;

% pre load
suffixPre = 'preStimRestDecimated';
load(strcat(subjid,'_',suffixPre), 'fs', 'Blck')
BlckPre = Blck;
clear Blck;

% account for bad channels 
bads = Montage.BadChannels;

% common average rereference 
BlckPreCAR = ReferenceCAR(Montage.Montage,Montage.BadChannels,BlckPre);
BlckPostCAR = ReferenceCAR(Montage.Montage,Montage.BadChannels,BlckPost);
clear BlckPre;
clear BlckPost;

% notch filter at 60
BlckPreCARnotch = notch(BlckPreCAR,60,fs);
BlckPostCARnotch = notch(BlckPostCAR,60,fs);
clear BlckPreCAR;
clear BlckPostCAR;

% high pass filter at 0.5
BlckPreCARfiltered = highpass(BlckPreCARnotch,0.5,fs);
BlckPostCARfiltered = highpass(BlckPostCARnotch,0.5,fs);
clear BlckPreCARnotch;
clear BlckPostCARnotch;

%% post state 
post_trimmed_sig = BlckPostCARfiltered;
% post_alpha = hilbAmp(post_trimmed_sig, [8 12], fs).^2;
post_beta = hilbAmp(post_trimmed_sig, [13 30], fs).^2;
% post_HG = hilbAmp(post_trimmed_sig, [70 200], fs).^2;
% post_theta = hilbAmp(post_trimmed_sig, [4 8], fs).^2;
% post_delta = hilbAmp(post_trimmed_sig, [0 4], fs).^2;
% post_ifsHG = bandpass(post_HG,1,0.1,fs);
% % newFs = 60; [p,q] = rat(newFs/fs); resamp_HG = resample(post_HG, p, q);
% % post_rsHG = reallyslowBandpass(resamp_HG);
% post_fs = fs;

% clear 'trimmed_sig'

%% pre state 

trimmed_sig = BlckPreCARfiltered;
% alpha = hilbAmp(trimmed_sig, [8 12], fs).^2;
beta = hilbAmp(trimmed_sig, [13 30], fs).^2;
% HG = hilbAmp(trimmed_sig, [70 200], fs).^2;
% theta = hilbAmp(trimmed_sig, [4 8], fs).^2;
% delta = hilbAmp(trimmed_sig, [0 4], fs).^2;
% ifsHG = bandpass(HG,1,0.1,fs);
% newFs = 60; [p,q] = rat(60/fs); resamp_HG = resample(HG, p, q);
% rsHG = reallyslowBandpass(resamp_HG);

%%

% difference matrices show POSITIVE values if pair had HIGHER connectivity
% in post session, NEGATIVE value of LOWER in post session

% load(strcat(subjid,'_basicanalysis'), 'Montage', 'biHemi', 'ReconHemi', 'numChans')

windowSize = round(10 * fs); %sliding window will be 10 second long segments
numChans = 64;
% should add multiple comparisons 

% fprintf('alpha\n');
% [diff_alpha_plv, alpha_pmin, alpha_pmax] = changeTScoreWithStats(alpha, post_alpha, windowSize);
% masked_alpha_plvdiff = NaN(numChans, numChans);
% for i = 1:numChans;
%     for j=1:numChans;
%         if alpha_pmax(i,j)<=0.025 || alpha_pmin(i,j)<0.025;
%             masked_alpha_plvdiff(i,j) = diff_alpha_plv(i,j);
%         end
%     end
% end

fprintf('beta\n');
[diff_beta_plv, beta_pmin, beta_pmax] = changeTScoreWithStats(beta, post_beta, windowSize);
masked_beta_plvdiff = NaN(numChans, numChans);
for i = 1:numChans;
    for j=1:numChans;
        if beta_pmax(i,j)<=0.025 || beta_pmin(i,j)<0.025;
            masked_beta_plvdiff(i,j) = diff_beta_plv(i,j);
        end
    end
end

masked_beta_plvdiff2 = masked_beta_plvdiff;
masked_beta_plvdiff2(bads,:) = NaN;
masked_beta_plvdiff2(:,bads) = NaN;


% 
% fprintf('theta\n');
% [diff_theta_plv, theta_pmin, theta_pmax] = changeTScoreWithStats(theta, post_theta, windowSize);
% masked_theta_plvdiff = NaN(numChans, numChans);
% for i = 1:numChans;
%     for j=1:numChans;
%         if theta_pmax(i,j)<=0.025 || theta_pmin(i,j)<0.025;
%             masked_theta_plvdiff(i,j) = diff_theta_plv(i,j);
%         end
%     end
% end
% 
% fprintf('HG\n');
% [diff_HG_plv, HG_pmin, HG_pmax] = changeTScoreWithStats(HG, post_HG, windowSize);
% masked_HG_plvdiff = NaN(numChans, numChans);
% for i = 1:numChans;
%     for j=1:numChans;
%         if HG_pmax(i,j)<=0.025 || HG_pmin(i,j)<0.025;
%             masked_HG_plvdiff(i,j) = diff_HG_plv(i,j);
%         end
%     end
% end
% 
% windowSize = round(20 * fs); %sliding window will be 20 second long segments - these are too slow for 10
% 
% fprintf('delta\n');
% [diff_delta_plv, delta_pmin, delta_pmax] = changeTScoreWithStats(delta, post_delta, windowSize);
% masked_delta_plvdiff = NaN(numChans, numChans);
% for i = 1:numChans;
%     for j=1:numChans;
%         if delta_pmax(i,j)<=0.025 || delta_pmin(i,j)<0.025;
%             masked_delta_plvdiff(i,j) = diff_delta_plv(i,j);
%         end
%     end
% end
% 
% 
% fprintf('ifs\n');
% [diff_ifs_plv, ifs_pmin, ifs_pmax] = changeTScoreWithStats(ifsHG, post_ifsHG, windowSize);
% masked_ifs_plvdiff = NaN(numChans, numChans);
% for i = 1:numChans;
%     for j=1:numChans;
%         if ifs_pmax(i,j)<=0.025 || ifs_pmin(i,j)<0.025;
%             masked_ifs_plvdiff(i,j) = diff_ifs_plv(i,j);
%         end
%     end
% end

% fprintf('rs\n');
% [diff_rs_plv, rs_pmin, rs_pmax] = changeTScoreWithStats(rsHG, post_rsHG, windowSize);
% masked_rs_plvdiff = NaN(numChans, numChans);
% for i = 1:numChans;
%     for j=1:numChans;
%         if rs_pmax(i,j)<=0.025 || rs_pmin(i,j)<0.025;
%             masked_rs_plvdiff(i,j) = diff_rs_plv(i,j);
%         end
%     end
% end
% 

%%

% clear 'HG' 'alpha' 'beta' 'delta' 'ifsHG' 'i' 'j' 'newFs' 'p' 'post_HG' 'post_alpha' 'post_beta' 'post_delta' 'post_ifsHG' 'post_rsHG' 'post_theta' 'post_trimmed_sig' 'q' 'resamp_HG' 'rsHG' 'theta' 'trimmed_sig'
% 
% save(strcat(subjid, '_change_post', taskID));
%  


% PlotDots('9ab7ab', Montage, diff_ifsPlv_sq(40,:), ones(size(diff_ifsPlv,1)), ReconHemi, clims_plv, 20, 'loc_colormap', biHemi, 0);

