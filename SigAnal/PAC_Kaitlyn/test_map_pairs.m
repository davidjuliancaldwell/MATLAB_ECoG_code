function [org,pmax,pmin,varargout]=test_map_pairs(map,ix,iy,nperm)
% function [org,pmax,pmin,varargout]=test_map_pairs(map,ix,iy,nperm)
% tests significance between channel pair interactions

if ndims(map)>4
mapx=squeeze(map(:,:,ix(1),ix(2),:));
mapy=squeeze(map(:,:,iy(1),iy(2),:));
end
if ndims(map)>3
    mapx=squeeze(map(:,:,ix,:));
    mapy=squeeze(map(:,:,iy,:));
end
if ismatrix(map)
    mapx=ix;
    mapy=iy;
end
equal_sample=size(mapx,3)==size(mapy,3);

sc=std(cat(3,mapx,mapy),0,3);
if equal_sample
org=(mean(mapx,3)-mean(mapy,3))./sc;
else
    org=ctstat(mapx,mapy);
end

perm=cat(3,mapx,mapy);
n=size(mapx,3);

pmax=zeros(size(org));
pmin=pmax;

hist_max=zeros(nperm,1);
hist_min=hist_max;

for i=1:nperm
    ixp=randperm(size(perm,3));
    if equal_sample
        d=(mean(perm(:,:,ixp(1:n)),3)-mean(perm(:,:,ixp(n+1:end)),3))./sc;
    else
        d=ctstat(perm(:,:,ixp(1:n)),perm(:,:,ixp(n+1:end)));
    end
    mxd=max(d(:));
    mnd=min(d(:));
    pmax=pmax+(mxd>org)/nperm;
    pmin=pmin+(mnd<org)/nperm;
    hist_max(i)=mxd;
    hist_min(i)=mnd;
end
if nargout>3
    varargout{1}=hist_max;
end
if nargout>4
    varargout{2}=hist_min;
end


function res=ctstat(x,y)

d=mean(x,3)-mean(y,3);
n1=size(x,3);n2=size(y,3);
s1=var(x,0,3)/n1;s2=var(y,0,3)/n2;
res=d./(sqrt(s1+s2));
