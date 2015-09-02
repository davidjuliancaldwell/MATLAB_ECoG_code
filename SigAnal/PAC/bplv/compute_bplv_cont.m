function
[map,maxd,fwb,varargout]=compute_bplv_cont(x,y,z,fwa,fwb,fs,pr,n,varargin)
% function
[map,maxd,fwb,varargout]=compute_bplv_cont(x,y,z,fwa,fwb,fs,pr,n,varargin)

ifr=ones(size(fwa,2),1)*fwb+fwa'*ones(1,size(fwb,2));
[fwc,ixa,ixb]=unique(ifr(:));fwc=fwc';fwc=fwc(fwc>0);

[~,~,Callx,~]=time_frequency_wavelet(x,fwa,fs,pr,1,'CPUtest');
[~,~,Cally,~]=time_frequency_wavelet(y,fwb,fs,pr,1,'CPUtest');
[~,~,Callz,~]=time_frequency_wavelet(z,fwc,fs,pr,1,'CPUtest');

px=Callx./abs(Callx);
py=Cally./abs(Cally);
pz=conj(Callz./abs(Callz));

map=zeros(length(fwa),length(fwb));
mapp=map;
%
% tic
% for i=1:length(fwa)
%     for j=1:length(fwb)
%         ix=ixb(sub2ind(size(ifr),i,j));
%         map(i,j)=abs(mean(px(:,i).*py(:,j).*pz(:,ix)));
%     end
% end
% toc

ns=floor(size(px,1)/fs);
px=px(1:ns*fs,:);
py=py(1:ns*fs,:);
pz=pz(1:ns*fs,:);
ixs=reshape(1:ns*fs,fs,ns);
ff=fwa'*ones(1,length(fwb))+ones(length(fwa),1)*fwb;ff=ff';

if nargin>8
    mode=varargin{1};
else
    mode='';
end
switch mode
    case 'GPU'
        gpu=1;
    otherwise
        gpu=0;
end

for i=1:length(fwa)
    ix=ixb(sub2ind(size(ifr),repmat(i,1,length(fwb)),1:length(fwb)));
    map(i,:)=abs(mean(repmat(px(:,i),1,length(fwb)).*py.*pz(:,ix)));
end
maxd=[];
p=[];
pmap=[];
if n>0
    if nargout>3
        p=zeros(size(map,1),size(map,2));
    end
    if nargout>4
        pmap=zeros(size(map,1),size(map,2),n);
    else
        pmap=[];
    end
    maxd=zeros(n,1);

    if gpu<1
        hh=waitbar(0,'running permnutation test');
        kk=1;
        for j=1:n
            ixp=randperm(ns);
            ixp=ixs(:,ixp);ixp=ixp(:);
            for i=1:length(fwa)
                ix=ixb(sub2ind(size(ifr),repmat(i,1,length(fwb)),1:length(fw
b)));
                mapp(i,:)=abs(mean(repmat(px(:,i),1,length(fwb)).*py.*pz(ixp
,ix)));
            end
            if ~isempty(pmap)
                pmap(:,:,j)=mapp;
            end
            p=p+double(mapp>map)/n;
            mapp(ff>55 & ff<65)=0;
            mapp(ff>115 & ff<125)=0;
            mapp(ff>175 & ff<185)=0;
            maxd(j)=max(mapp(:));kk=kk+1;
            if kk>n/100
                waitbar(j/n);
                kk=1;
            end
        end
        close(hh);
    else
        gpmap=gpuArray(pmap);
        gmap=gpuArray(single(map));
        gmaxd=gpuArray(single(maxd));
        gpx=gpuArray(single(px));
        gpy=gpuArray(single(py));
        gpz=gpuArray(single(pz));
        gp=gpuArray(single(p));
        gmapp=gmap;
        gixs=gpuArray(single(ixs));
        gff=gpuArray(ff);
        for j=1:n
            ixp=randperm(ns);
            ixp=gixs(:,ixp);ixp=ixp(:);
            for i=1:length(fwa)
                ix=ixb(sub2ind(size(ifr),repmat(i,1,length(fwb)),1:length(fw
b)));
                gmapp(i,:)=abs(mean(repmat(gpx(:,i),1,length(fwb)).*gpy.*gpz
(ixp,ix)));
            end
            if ~isempty(gpmap)
            gpmap(:,:,j)=gmapp;
            end
            gp=gp+single(gmapp>gmap)/n;

            gmapp(gff>55 & gff<65)=0;
            gmapp(gff>115 & gff<125)=0;
            gmapp(gff>175 & gff<185)=0;

            gmaxd(j)=max(gmapp(:));
        end
        p=gather(gp);
        maxd=gather(gmaxd);
        if ~isempty(gpmap)
        pmap=gather(gpmap);
        end
    end

end

if nargout>4
    varargout{2}=pmap;
end
if nargout>3
    varargout{1}=p;
end
