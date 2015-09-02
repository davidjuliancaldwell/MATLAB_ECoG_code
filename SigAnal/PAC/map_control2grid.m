xx=0:8;
x=0:7;
yi=zeros(8,4);
yo=yi;
yis=yi;
yos=yi;

yib=zeros(8,4);
yob=yi;
yisb=yi;
yosb=yi;

ni=yi;
no=yo;
nib=ni;
nob=no;
ztr=5;
use_measure='median';

f1=[6 10];
f2=[74 84];

%%
PAC_out=[];
PAC_in=[];
BPLV_out=[];
BPLV_in=[];

cPAC_out=[];
cPAC_in=[];
cBPLV_out=[];
cBPLV_in=[];
k=1;
    for s=1:4
        subj=sprintf('S%i',s+1);
        load(fullfile(subj,sprintf('results_pac_norm_all.mat')));
        [data,clist,control,fs,tr]=get_subject_data(subj,ztr,.5,300,4,-1);
        inn=[clist;control];
        out=1:size(map,3);
        out(inn)=[];
        cluster=zeros(size(map,3),1);
        cluster(inn)=1;
        cluster(control)=1;
        cluster=reshape(cluster,8,8)';

        cl{s}=cluster;
        [c,r]=ind2sub([8 8],control);

        f1=[6 10];
        f2=[74 84];
        fxa=find(fwa>f1(1) & fwa<f1(2));
        fxb=find(fwb>f2(1) & fwb<f2(2));
        mp=permute(squeeze(map(fxa,fxb,control,:)),[3 1 2]);
        val=median(mp(:,:),2)';

        PAC_out{s}=val;
        gval=val;
        gval(inn)=median(val(inn));
        gval(out)=median(val(out));

        cPAC_out{s}=gval;

        mp=permute(squeeze(map(fxa,fxb,:,control)),[3 1 2]);
        val=median(mp(:,:),2)';
        PAC_in{s}=val;

        gval=val;
        gval(inn)=median(val(inn));
        gval(out)=median(val(out));

        cPAC_in{s}=gval;

        load(fullfile(subj,sprintf('results_bplv_norm_all.mat')));

        f1=[11 15];
        f2=[85 95];
        fxa=find(fwa>f1(1) & fwa<f1(2));
        fxb=find(fwb>f2(1) & fwb<f2(2));
        mp=permute(squeeze(map(fxa,fxb,control,:)),[3 1 2]);
        val=median(mp(:,:),2)';
        BPLV_out{s}=val;

        gval=val;
        gval(inn)=median(val(inn));
        gval(out)=median(val(out));

        cBPLV_out{s}=gval;
        mp=permute(squeeze(map(fxa,fxb,:,control)),[3 1 2]);
        val=median(mp(:,:),2)';
        BPLV_in{s}=val;
        gval=val;
        gval(inn)=median(val(inn));
        gval(out)=median(val(out));

        cBPLV_in{s}=gval;
    end


%%


figure
for i=1:4;
    subplot(2,2,i);
    show_map(BPLV_out{i},cl{i});
end
title('BPLV out');


figure
for i=1:4;
    subplot(2,2,i);
    show_map(BPLV_in{i},cl{i});
end
title('BPLV in');

figure
for i=1:4;
    subplot(2,2,i);
    show_map(PAC_out{i},cl{i});
end
title('PAC out');


figure
for i=1:4;
    subplot(2,2,i);
    show_map(PAC_in{i},cl{i});
end
title('PAC in');
