% % load the data fille
fname = 'D:\research\subjects\a9952e\data\d9\a9952e_mot_f_h001\a9952e_mot_f_hS001R01.dat';
[sig, sta, par] = load_bcidat(fname);
Montage = loadCorrespondingMontage(fname);
fs = 1200;
% % PlotCortex a9952e;
% % PlotElectrodes a9952e;
% 
sig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, double(sig));
bb = extractBroadband(sig, fs);

return
% 
% fw = [1:50 70:110 130:200];
% tic

tic

call = zeros(162, 657, 16);
overlap = 7*fs/8;

for chan = 1:16
    call(:,:,chan) = spectrogram(sig(:,chan), fs, overlap, fw, fs);
end

toc

    
% % [~,~,call,~] = time_frequency_wavelet(sig, fw, fs, 1, 1, 'CPUtest');
% 
%     temp = abs((call(:,:)));
%     tempn = normalize_plv(temp, temp);
%     [x,y,z] = mpca(tempn');            
% 
% bb = x(:,1);
% 
% hg = hilbAmp(sig(:,7), [70 200], 1200);
% L = round(length(hg)/length(bb));
% 
% hg = downsample(GaussianSmooth(hg, L), L);
% 
% code = downsample(sta.StimulusCode*10, L);
% 
% %%
% figure;
% % plot(bb-mean(bb));
% plot(zscoreAgainstInterest(bb(1:length(code)), code, 0));
% hold all;
% % plot(hg-mean(hg));
% plot(GaussianSmooth(zscoreAgainstInterest(hg(1:length(code)), code, 0),1));
% plot(code, 'k');