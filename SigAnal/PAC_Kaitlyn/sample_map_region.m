function erg=sample_map_region(map,fwa,fwb,func)


mm=permute((map(fwa,fwb,:)),[3 1 2]);
mm=mm(:,:)';
erg=eval(sprintf('%s(mm)',func));
