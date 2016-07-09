function [] = timeFrequencyAnalWavelet(pre,post,t_pre,t_post,fs_data)

% frequencies to look at, resolution in middle ( 1 Hz bins now)
fw = [1:1:200];
% post and pre wavelet business 
[~,~,Cpost,~] = time_frequency_wavelet(post,fw,fs_data,0,1,'CPUtest');
[~,~,Cpre,~] = time_frequency_wavelet(pre,fw,fs_data,0,1,'CPUtest');

% look at absolute value 
CabsPost = abs(Cpost);
CabsPre = abs(Cpre);

% what to normalize against
nCPost = normalize_plv(CabsPost', CabsPre');
nCPre = normalize_plv(CabsPre', CabsPre');

%t = 0:length(nC)/fs;
subplot(2,1,1)
imagesc(t_pre, fw, nCPre); axis xy
xlabel('Time in ms')
ylabel('Frequency (Hz)')
colorbar
title('Wavelet analysis for Pre Stim') 

% set colormap using cbrewer
CT = cbrewer('div','RdBu',11);

% flip it so red is increase, blue is down
CT = flipud(CT);
colormap(CT);
set_colormap_threshold(gcf, [-3 3], [-10 10], [.5 .5 .5])


subplot(2,1,2)
imagesc(t_post, fw, nCPost); axis xy
xlabel('Time in ms')
ylabel('Frequency (Hz)')
colorbar
title('Wavelet analysis for Post Stim - Normalized to Pre') 
colormap(CT);
set_colormap_threshold(gcf, [-3 3], [-10 10], [.5 .5 .5])

end

