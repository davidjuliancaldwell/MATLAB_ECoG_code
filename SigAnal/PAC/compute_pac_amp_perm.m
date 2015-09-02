function
[map,maxd,varargout]=compute_pac_amp_perm(x,y,fwx,fwy,fs,n,varargin)
% function compute_pac_amp(x,y,fwx,fwy,fs,n)
% amplitude phase locking

[~,~,Callx,~]=time_frequency_wavelet(x,fwx,fs,0,1,'CPUtest');
[~,~,Cally,~]=time_frequency_wavelet(y,fwy,fs,0,1,'CPUtest');
px=Callx./abs(Callx);
ay=abs(Cally);

ns=floor(size(px,1)/fs);
px=px(1:ns*fs,:);
ay=ay(1:ns*fs,:);
ixs=reshape(1:ns*fs,fs,ns);


map=abs(ay'*px)/size(px,1);
s=1./repmat(mean(ay)',1,size(map,2));
map=map.*s;
if nargout>3
    pmap=zeros(size(map,1),size(map,2),n);
else
    pmap=[];
end
if nargin>6
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

maxd=[];
if n>0
    if nargout>2
        p=zeros(size(map,1),size(map,2));
    end
    maxd=zeros(n,1);

    if gpu<1
        hh=waitbar(0,'running permnutation test');
        kk=1;
        for j=1:n
            ixp=randperm(ns);
            ixp=ixs(:,ixp);ixp=ixp(:);
            mapp=abs(ay'*px(ixp,:))/size(px,1).*s;
            p=p+double(mapp>map)/n;
            maxd(j)=max(mapp(:));kk=kk+1;
            if kk>n/100
                waitbar(j/n);
                kk=1;
            end
        end
        close(hh);
    else
        gmap=gpuArray(single(map));
        gns=gpuArray(single(ns));
        gmaxd=gpuArray(single(maxd));
        gpx=gpuArray(single(px));
        gay=gpuArray(single(ay));
        gp=gpuArray(single(p));
        gixs=gpuArray(single(ixs));
        gpmap=gpuArray(pmap);
        gs=gpuArray(single(s));

        for j=1:n
            ixp=randperm(ns);
            ixp=gixs(:,ixp);ixp=ixp(:);
            gmapp=abs(gay'*gpx(ixp,:))/size(gpx,1).*gs;
            gp=gp+single(gmapp>gmap)/n;
            gmaxd(j)=max(gmapp(:));
            gpmap(:,:,j)=gmapp;
        end
        p=gather(gp);
        maxd=gather(gmaxd);
        pmap=gather(gpmap);
    end
    varargout{1}=p;
    varargout{2}=pmap;
end
