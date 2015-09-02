NCHANS = 9;

%% collect appropriate information necessary to run
% filename to process
[name,path] = uigetfile('*.dat;*.mat','MultiSelect', 'on');

%% load data
re = [];
rre = [];
fe = [];
fre = [];

for filenum = 1:length(name)
    filepath = fullfile(path, name{filenum});
    
    % preprocess
    [sig, sta, par] = load_bcidat(filepath);
    fs = par.SamplingRate.NumericValue;
    
    sig = double(sig);
    rsig = ReferenceCAR(NCHANS, [], sig);

    fsig = hilbAmp(sig, [70 110], fs);
    frsig = hilbAmp(rsig, [70 110], fs);
    
    [starts, ends] = getEpochs(sta.StimulusCode ~= 0, 1, true);
    starts = starts - 1.5*fs;
    starts = starts(2:end);
    ends = ends(2:end);
    
    re = cat(3, re, getEpochSignal(sig, starts, ends));
    rre = cat(3, rre, getEpochSignal(rsig, starts, ends));
    fe = cat(3, fe, getEpochSignal(fsig, starts, ends));
    fre = cat(3, fre, getEpochSignal(frsig, starts, ends));
end

%%

fw = 10:2:110;
t = ((1:size(fe, 1))/fs)-1.5;

figure
for chan = 1:size(fe,2)
    subplot(3,3,chan);
    [C, ~, ~, ~] = time_frequency_wavelet(squeeze(re(:,chan,:)), fw, fs, 1, 1, 'CPUtest');
    normC=normalize_plv(C',C(t>min(t)+0.75 & t<=0,:)');
    imagesc(t, fw, normC);
    axis xy;
    set_colormap_threshold(gcf, [-1 1], [-7 7], [1 1 1]);
    
    med = median(GaussianSmooth(squeeze(fe(:,chan,:)), fs*.25),2);
    hold on;
    plot(t, zscoreAgainstInterest(med, t> -.75 & t<=0, 1)*5+30, 'k', 'linew', 2);
%     vline(0, 'k:');
    
    title(sprintf('%d - raw', chan));    
end
%%
figure
for chan = 1:size(fe,2)
    subplot(3,3,chan);
    [C, ~, Call, ~] = time_frequency_wavelet(squeeze(rre(:,chan,:)), fw, fs, 1, 1, 'CPUtest');
%     C = median(abs(Call), 3);
    normC=normalize_plv(C',C(t>min(t)+0.75 & t<=0,:)');
    imagesc(t, fw, normC);
    axis xy;
    set_colormap_threshold(gcf, [-1 1], [-7 7], [1 1 1]);
    
    med = median(GaussianSmooth(squeeze(fre(:,chan,:)), fs*.25),2);
    hold on;
    plot(t, zscoreAgainstInterest(med, t> -.75 & t<=0, 1)*5+30, 'k', 'linew', 2);
%     vline(0, 'k:');
    title(sprintf('%d - CAR', chan));    
end


