function map_all=compute_bplv_allchannels(data,fwa,fwb,fs)



map_all=zeros(length(fwa),length(fwb),size(data,2),size(data,2));
h=waitbar(0,'computing bPLV all channels');
tt=length(fwa)*length(fwb);
for i=1:length(fwa)
    for j=1:length(fwb)
        [~,~,pa,~]=time_frequency_wavelet(data,fwa(i),fs,0,1,'CPUtest');
        [~,~,pb,~]=time_frequency_wavelet(data,fwb(j),fs,0,1,'CPUtest');
        [~,~,pc,~]=time_frequency_wavelet(data,fwa(i)+fwb(j),fs,0,1,'CPUtest
');
        pa=pa./abs(pa);
        pb=pb./abs(pb);
        pc=pc./abs(pc);
        map=abs(((pa.*pb)'*pc))/size(pa,1);
        map_all(i,j,:,:)=map;
        waitbar(((i-1)*length(fwb)+j)/tt);
    end
end
close(h);






