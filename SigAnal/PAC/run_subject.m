subj='S2';
[data,clist,control,fs,tr]=get_subject_data(subj,5,.5,300,4);
data=cheby_filter_notch(data,58,62,fs,4);
data=cheby_filter_notch(data,118,122,fs,4);
data=cheby_filter_notch(data,178,182,fs,4);

elsewhere=1:size(data,2);
elsewhere(clist)=[];

fwa=3:30;
fwb=40:170;
ff=fwa'*ones(1,length(fwb))+ones(length(fwa),1)*fwb;ff=ff';

data=resample(data,1,2);
fs=fs/2;
direction='outbound';

map_all=[];
maxd_all=[];
p_all=[];
for i=1:length(clist)
    tic
    %[map,maxd,~,p]=compute_bplv_cont(data(:,control),data(:,control),data(:
,clist(i)),fwb,fwa,fs,1,-1);
    switch direction
        case 'inbound'
            [map,maxd,~,p]=compute_bplv_cont(data(:,clist(i)),data(:,clist(i
)),data(:,control),fwb,fwa,fs,1,100,'GPU');
            pr=refine_pmap(p,data(:,clist(i)),data(:,clist(i)),data(:,contro
l),fwb,fwa,fs,10000);
        case 'outbound'
            [map,maxd,~,p]=compute_bplv_cont(data(:,control),data(:,control)
,data(:,clist(i)),fwb,fwa,fs,1,100,'GPU');
            pr=refine_pmap(p,data(:,control),data(:,control),data(:,clist(i)
),fwb,fwa,fs,10000);
    end

    map2=map;
    map2(ff>55 & ff<65)=0;
    map2(ff>115 & ff<125)=0;
    map2(ff>175 & ff<185)=0;
    figure
    contourf(fwa,fwb,map,15,'EdgeColor','none')
    caxis([0 0.04]);
    toc

    map_all{i}=map;
    maxd_all{i}=maxd;
    p_all{i}=p;
    pr_all{i}=pr;
end
save(fullfile(subj,sprintf('results_%s.mat',direction)),'fs','map_all','maxd
_all','control','clist','p_all','pr_all')


nl=length(clist);
a=ceil(sqrt(nl));
b=ceil(nl/a);

figure
for i=1:nl
    subplot(a,b,i)
    imagesc(fwa,fwb,-log10(pr_all{i}));caxis([0 4]);axis xy;

end
