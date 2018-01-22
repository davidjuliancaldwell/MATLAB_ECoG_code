function [map_all, map_avg] = epochs_pac(allEpochSig,fwx,fwy,fs)

numEpochs = size(allEpochSig,2);
numchan = size(allEpochSig{1},2);

map_all=zeros(numchan,numchan,numel(fwx),numel(fwy),numEpochs);

for i = 1:numEpochs;
    
    [~,~,px,~]=time_frequency_wavelet(allEpochSig{i},fwx,fs,1,1,'CPUtest');
    [~,~,ay,~]=time_frequency_wavelet(allEpochSig{i},fwy,fs,1,1,'CPUtest');
    
    px=px./abs(px);
    ay=abs(ay);
    
    epochlength = size(allEpochSig{i},1);
    
    for j=1:numchan
        for k=1:numchan
            ixs=(1:epochlength);
            
            pacmap=abs(px(ixs,:,j)'*ay(ixs,:,k));
            map_all(j,k,:,:,i)=pacmap;
            
        end
    end
    
end

map_avg = mean(map_all, 5);

end

