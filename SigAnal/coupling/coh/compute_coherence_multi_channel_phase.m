function [co,f]=compute_coherence_multi_channel_phase(data,nfft,fs)
%function [co,f]=compute_coherence_multi_channel(data,nfft,fs)

co=zeros(size(data,2),size(data,2),nfft/2);
nseg=floor(size(data,1)/nfft);
for i=1:size(data,2)
    for j=1:size(data,2)
        c1=reshape(data(1:nfft*nseg,i),nfft,nseg);
        c2=reshape(data(1:nseg*nfft,j),nfft,nseg);
        [coi,f]=coh_phase(c1,c2,nfft,fs);
        co(i,j,:)=coi;
    end
end