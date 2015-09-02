%data [TxCxN] - time by channels by observations
function [co,f,nseg]=compute_coherence_multi_channel_phase_bci(data,nfft,fs)
%function [co,f]=compute_coherence_multi_channel(data,nfft,fs)

% build a coherence output matrix for all channel by channel interactions,
% with a third dimension allowing for a coherence value for each phase
co=zeros(size(data,2),size(data,2),nfft/2);

% how many segments are we chopping the data in to?
nseg=floor(size(data,1)/nfft);

% loop through all channels twice
for i=1:size(data,2)
    for j=1:size(data,2)
        c1=reshape(data(1:nfft*nseg,i),nfft,nseg);
        c2=reshape(data(1:nseg*nfft,j),nfft,nseg);
        [coi,f]=coh_phase(c1,c2,nfft,fs);
        co(i,j,:)=coi;
    end
end