function pr=refine_pmap(p,x,y,z,fwa,fwb,fs,nn)
% function pr=refine_pmap(p,x,y,z,fwa,fwb,fs,1,n)
% refines the existing p-map for the low pvalues
pr=p;
[~,l,n]=bwboundaries(p<eps);

for i=1:n
    ix=find(l(:)==i);
    [ixx,iyy]=ind2sub(size(p),ix);
    fwx=min(fwa(ixx)):max(fwa(ixx));
    fwy=min(fwb(iyy)):max(fwb(iyy));
    [~,~,~,pl]=compute_bplv_cont(x,y,z,fwx,fwy,fs,0,nn,'GPU');
    pr(min(ixx):max(ixx),min(iyy):max(iyy))=pl;
end

