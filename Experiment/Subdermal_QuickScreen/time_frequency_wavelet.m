function [C,CS,Call,C0]=time_frequency_wavelet(x,fw,fs,pr,opt,mode)
% function  [C,CS,Call,C0]=time_frequency_wavelet(x,fw,fs,pr,opt)
% x= signal
% fw = frequency vector
% fs = sampling rate
% bw = filter width
% fl = filter length
% pr = 0 dont show progress
% opt =0 dont output single trial maps
if(pr)
    hh=waitbar(0,'computing map');kk=0;
end
C=zeros(size(x,1),length(fw));
CS=C;
if(opt>0)
    Call=zeros(size(C,1),size(C,2),size(x,2));
else
    Call=[];
end
C2=C;
kk=1;
if(strcmp(mode,'GPUold'))
    C0=[];
    CS=[];
    scales=fs./fw*2;
    fall=cwt_felix(x,scales,'cmor1.5-2',mode);
    ix1=zeros(size(fall,2),1);
    ix2=ix1;
    for k=1:size(fall,2)
        la=fall(1,k);
        ix1(k)=1+floor((la-2)/2);
        ix2(k)=size(x,1)+(la-2)-ceil((la-2)/2);
    end
    % move data and parameters to GPU
    wav=gdouble(fall(3:end,:));
    wav_length=gsingle(fall(1,:)');
    scal=gsingle(fall(2,:)');
    ix1g=gsingle(ix1);
    ix2g=gsingle(ix2);
    xg=complex(gdouble(x));
    gopt=gsingle(opt);
    n=size(xg,2);
    nsc=size(wav,2);
    Cg=complex(gdouble(gzeros(size(xg,1),nsc)));
    if(gopt)
        Cgall=complex(gdouble(gzeros(size(xg,1),n,nsc)));
    end
    for k=1:nsc
        ll=wav_length(k);
        ff=(repmat(wav(1:ll,k),1,n));
        Z=gconv_gpu(xg,ff);
        Z=Z(2:end-1,:)-Z(1:end-2,:);geval(Z);
        fst=ix1g(k);lst=ix2g(k);
        if(gopt)
            Cgall(:,:,k)=-sqrt(scal(k))*Z(fst:lst,:);
        else
            Cg(:,k)=mean(abs(-sqrt(scal(k))*Z(fst:lst,:)),2);
        end
        geval(Cg);
    end
    if(gopt)
        Call=permute(double(Cgall),[1 3 2]);
        C=mean(abs(Call),3);
    else
        Call=[];
        C=abs(double(Cg));
    end

end
if(strcmp(mode,'GPU'))
    C0=[];
    CS=[];
    scales=fs./fw*2;
    fall=cwt_felix(x,scales,'cmor1.5-2',mode);
    ix1=zeros(size(fall,2),1);
    ix2=ix1;
    for k=1:size(fall,2)
        la=fall(1,k);
        ix1(k)=1+floor((la-2)/2);
        ix2(k)=size(x,1)+(la-2)-ceil((la-2)/2);
    end
    % move data and parameters to GPU
    wav=gdouble(fall(3:end,:));
    wav_length=gsingle(fall(1,:)');
    scal=gsingle(fall(2,:)');
    ix1g=gsingle(ix1);
    ix2g=gsingle(ix2);
    xg=complex(gdouble(x));
    gopt=gsingle(opt);
    n=size(xg,2);
    nsc=size(wav,2);
    Cg=complex(gdouble(gzeros(size(xg,1)+size(wav,1)-2,nsc)));
    if(gopt)
        Cgall=complex(gdouble(gzeros(size(xg,1),n,nsc)));
    end
    for k=1:nsc
        Z=gconv_gpu(xg,repmat(wav(:,k),1,size(xg,2)));
        Z=Z(2:end-1,:)-Z(1:end-2,:);
        Z=circshift(Z,-ix1(k)+1);
        if(gopt)
            Cgall(:,:,k)=-sqrt(scal(k))*Z(1:size(xg,1),:);
        else
            Cg(:,k)=mean(abs(-sqrt(scal(k))*Z),2);
        end
    end
    if(gopt)
        Call=permute(double(Cgall),[1 3 2]);
        C=mean(abs(Call),3);
    else
        Call=[];
        C=abs(double(Cg));
        C=C(1:size(x,1),:);
    end
end
if(strcmp(mode,'CPUtest'))
    scales=fs./fw*2;
%     fall=cwt_felix(x,scales,'cmor3-2','GPU');
    fall=cwt_felix(x,scales,'cmor1.5-2','GPU');
    ix1=zeros(size(fall,2),1);
    ix2=ix1;
    for k=1:size(fall,2)
        la=fall(1,k);
        ix1(k)=1+floor((la-2)/2);
        ix2(k)=size(x,1)+(la-2)-ceil((la-2)/2);
    end
    wav=fall(3:end,:);
    wav_length=fall(1,:);
    scal=fall(2,:);
    n=size(x,2);
    nsc=size(wav,2);
    Call=zeros(size(x,1),n,nsc);
    for k=1:nsc
        ll=wav_length(k);
        ff=repmat(wav(1:ll,k),1,n);
        
        % CPU VERSION
%         ff=wav(1:ll,:);
        %ff=ff(:,k)*complex(ones(1,n));
        Z=conv_cpu(x,ff);
        
        %Z=gzeros(size(xg,1)+size(ff,1),size(xg,2))+i-i;
        Z=Z(2:end,:)-Z(1:end-1,:);
        fst=ix1(k);lst=ix2(k);
        Call(:,:,k)=-sqrt(scal(k))*Z(fst:lst,:);
        if(pr)
        waitbar(k/nsc);
        end
    end
    %Call=abs(Call);
    C0=[];
    CS=[];
    if(length(size(Call))>2)
    Call=permute(Call,[1 3 2]);
    C=mean(abs(Call),3);
    else
        C=abs(Call);
    end
    
end
if(strcmp(mode,'mGPU'))
    scales=fs./fw*2;
    fall=cwt_felix(x,scales,'cmor3-2','GPU');
%     fall=cwt_felix(x,scales,'cmor1.5-2','GPU');
    ix1=zeros(size(fall,2),1);
    ix2=ix1;
    for k=1:size(fall,2)
        la=fall(1,k);
        ix1(k)=1+floor((la-2)/2);
        ix2(k)=size(x,1)+(la-2)-ceil((la-2)/2);
    end
    wav=fall(3:end,:);
    wav_length=fall(1,:);
    scal=fall(2,:);
    n=size(x,2);
    nsc=size(wav,2);
    Call=zeros(size(x,1),n,nsc);
    
    gx = cell(size(x, 2), 1);

    for zz = 1:size(x, 2)
        gx{zz} = gpuArray(x(:, zz));
    end
    
    for k=1:nsc
        ll=wav_length(k);
        
        % NEW GPU VERSION
        gff = gpuArray(wav(1:ll,k));        
        
        Z2 = cellfun(@(a) conv(a, gff), gx, 'UniformOutput', false);
        Z = zeros(length(Z2{1}), length(Z2));
        
        for zz = 1:size(x, 2)
            Z(:, zz) = gather(Z2{zz});
        end
        
        % end NEW GPU
        
        %Z=gzeros(size(xg,1)+size(ff,1),size(xg,2))+i-i;
        Z=Z(2:end,:)-Z(1:end-1,:);
        fst=ix1(k);lst=ix2(k);
        Call(:,:,k)=-sqrt(scal(k))*Z(fst:lst,:);
        if(pr)
        waitbar(k/nsc);
        end
    end
    %Call=abs(Call);
    C0=[];
    CS=[];
    if(length(size(Call))>2)
    Call=permute(Call,[1 3 2]);
    C=mean(abs(Call),3);
    else
        C=abs(Call);
    end
    
end
if(strcmp(mode,'MATLAB') || strcmp(mode,'CPU'))
    for j=1:size(x,2)
        [C0,tt,ff,Cs]=time_frequency(x(:,j),fs,fw/2,mode);
        C0=C0';
        C=C+C0/size(x,2);
        C2=C2+C0.^2/size(x,2);
        if(opt>0)
            Call(:,:,j)=Cs';
        end
        if(pr>0)
            kk=kk+1;
            if(kk>size(x,2)/100)
                waitbar(j/size(x,2));
                kk=1;
            end
        end
        
    end
    
    CS=sqrt(C2-C.^2);
end
if(pr)
    close(hh);
end
