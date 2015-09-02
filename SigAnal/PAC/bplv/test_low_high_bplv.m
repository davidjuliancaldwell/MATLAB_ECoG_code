
f1b=[11 15];
f2b=[85 95];

f1p=[6 10];
f2p=[74 84];
fwa=f1b(1):f1b(2);
fwb=f2b(1):f2b(2);
nperm=1000;


bPLV_out=[];
bPLV_in=[];
PAC_out=[];
PAC_in=[];


for s=1:4

    subj=sprintf('S%i',s+1);fprintf('working on subject %s\n',subj);
    [data,clist,control,fs,tr]=get_subject_data(subj,5,.5,300,4,1);
    data=cheby_filter_notch(data,58,62,fs,4);
    data=cheby_filter_notch(data,118,122,fs,4);
    data=cheby_filter_notch(data,178,182,fs,4);
    data=data-repmat(mean(data,2),1,size(data,2));
    pp_all=zeros(size(data,2),nperm);
    org=zeros(size(data,2),1);

    fwa=f1b(1):f1b(2);
    fwb=f2b(1):f2b(2);

    tic
    for j=1:size(data,2)
        [map,maxd,~,p,mapp]=compute_bplv_cont(data(:,control),data(:,control
),data(:,j),fwb,fwa,fs,0,nperm,'GPU');
        org(j)=median(map(:));
        pp=permute(mapp,[3 1 2]);
        pp=median(pp(:,:),2);
        pp_all(j,:)=pp';
    end
    toc
    bPLV_out{s}.org=org;
    bPLV_out{s}.pp_all=pp_all;

     tic
    for j=1:size(data,2)
        [map,maxd,~,p,mapp]=compute_bplv_cont(data(:,j),data(:,j),data(:,con
trol),fwb,fwa,fs,0,nperm,'GPU');
        org(j)=median(map(:));
        pp=permute(mapp,[3 1 2]);
        pp=median(pp(:,:),2);
        pp_all(j,:)=pp';
    end
    toc

    bPLV_in{s}.org=org;
    bPLV_in{s}.pp_all=pp_all;
    fwa=f1p(1):f1p(2);
    fwb=f2p(1):f2p(2);

     tic
    for j=1:size(data,2)
        [map,maxd,p,mapp]=compute_pac_amp_perm(data(:,control),data(:,j),fwa
,fwb,fs,nperm,'GPU');
        org(j)=median(map(:));
        pp=permute(mapp,[3 1 2]);
        pp=median(pp(:,:),2);
        pp_all(j,:)=pp';
    end
    toc
    PAC_out{s}.org=org;
    PAC_out{s}.pp_all=pp_all;

       tic
    for j=1:size(data,2)
        [map,maxd,p,mapp]=compute_pac_amp_perm(data(:,j),data(:,control),fwa
,fwb,fs,nperm,'GPU');
        org(j)=median(map(:));
        pp=permute(mapp,[3 1 2]);
        pp=median(pp(:,:),2);
        pp_all(j,:)=pp';
    end
    toc
    PAC_in{s}.org=org;
    PAC_in{s}.pp_all=pp_all;

end

save test_low_high_results bPLV_in bPLV_out PAC_out PAC_in
