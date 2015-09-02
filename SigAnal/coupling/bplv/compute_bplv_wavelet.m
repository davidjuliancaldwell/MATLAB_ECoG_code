function [bplv,fwb]=compute_bplv_wavelet(x,y,z,fwa,fs,pr,mode,varargin)
%[bplv,fwb]=compute_bplv_wavelet(x,y,z,fwa,fs,pr,mode)
wmode='fftGPU';wmode='CPUtest';
if nargin>7
[Cx,CS,Call,C0]=time_frequency_wavelet([x y],abs(fwa),fs,pr,1,wmode,varargin{1});
else
    [Cx,CS,Call,C0]=time_frequency_wavelet([x y],abs(fwa),fs,pr,1,wmode);

end
ifr=ones(size(fwa,2),1)*fwa+fwa'*ones(1,size(fwa,2));
[fwb,ixa,ixb]=unique(ifr(:));fwb=fwb';fwb=fwb(fwb>0);
if nargin>7
[Cz,CS,Callz,C0]=time_frequency_wavelet(z,fwb,fs,pr,1,wmode,varargin{1});
else
    [Cz,CS,Callz,C0]=time_frequency_wavelet(z,fwb,fs,pr,1,wmode);

end

Cx=Call(:,:,1:size(x,2));
Cx=Cx./abs(Cx);
Cy=Call(:,:,size(x,2)+1:size(x,2)+size(y,2));
Cy=Cy./abs(Cy);
Call=[];

Callz=Callz./abs(Callz);
Callz=conj(Callz);
if(fwa(1)<0)
    Cx=conj(Cx);
end
Cx=permute(Cx,[1 3 2]);
Cy=permute(Cy,[1 3 2]);
Callz=permute(Callz,[1 3 2]);
% Cx=single(Cx);
% Cy=single(Cy);
% Callz=single(Callz);
% bplv=single(bplv);
ix_map=zeros(length(fwa),length(fwa));
for i=1:length(fwa)
    for j=1:length(fwa)
        ix=find(fwa(i)+fwa(j)==fwb);
        if ~isempty(ix)
            ix_map(i,j)=ix;
        else
            ix_map(i,j)=-1
        end
    end
end
bplv=do_bplv_comp(Cx,Cy,Callz,ix_map,fwa,pr,mode);

function bplv=do_bplv_comp(Cx,Cy,Callz,ix_map,fwa,pr,mode)
bplv=zeros(size(Cx,1),length(fwa)*length(fwa));
if(strcmp(mode,'CPU') || strcmp(mode,'CPUtest'))
    if(pr)
        
    end
    for i=1:length(fwa)
        for j=1:i
            k=(i-1)*length(fwa)+j;
            ix=ix_map(j,i);
            if(ix>0)
                bplv(:,k)=mean(Cx(:,:,j).*Cy(:,:,i).*Callz(:,:,ix),2);
            end
            %k=k+1;
        end
    end
    if(pr)
        
    end
end
if(strcmp(mode,'mGPU'))
    if(pr)
        
    end
    nf=(length(fwa));
    g_Cx=gpuArray(single(Cx));
    g_Cy=gpuArray(single(Cy));
    g_bplv=gpuArray(single(bplv));
    g_Callz=gpuArray(single(Callz));
    gix_map=gpuArray(ix_map);
    for i=(1:nf)
        for j=(1:i)
            ix=gix_map(j,i);
            k=(i-1)*nf+j;
            if(ix>0)
                a=g_Cx(:,:,j);
                b=g_Cy(:,:,i);
                c=g_Callz(:,:,ix);
                g_bplv(:,k)=mean(a.*b.*c,2);
            end
        end
    end
    bplv=gather(g_bplv);
    if(pr)
        
    end
end
if(strcmp(mode,'GPU'))
    if(pr)
        
    end
    nf=gsingle(length(fwa));
    g_Cx=gsingle(Cx);
    g_Cy=gsingle(Cy);
    g_bplv=gsingle(bplv);
    g_Callz=gsingle(Callz);
    gix_map=gsingle(ix_map);
    for i=gsingle(1:nf)
        for j=gsingle(1:i)
            ix=gix_map(j,i);
            k=(i-1)*nf+j;
            if(ix>0)
                a=g_Cx(:,:,j);
                b=g_Cy(:,:,i);
                c=g_Callz(:,:,ix);
                g_bplv(:,k)=mean(a.*b.*c,2);
            end
        end
    end
    bplv=double(g_bplv);
    if(pr)
        
    end
end
bplv=reshape(bplv,size(bplv,1),length(fwa),length(fwa));