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
ztr=10;
use_measure='median';
%%
all_scan=zeros(8,10,10);
for ff1=1:10
    for ff2=1:10
        tic
        for s=1:4
            subj=sprintf('S%i',s+1);
            load(fullfile(subj,sprintf('results_pac_norm_all.mat')));
            [data,clist,control,fs,tr]=get_subject_data(subj,ztr,.5,300,4,-1
);

            f1=[11 13];
            f2=[85 95];
            f1=[ff1*2+7 ff1*2+9];
            f2=[ff2*5+65 ff2*5+70];
            fxa=find(fwa>f1(1) & fwa<f1(2));
            fxb=find(fwb>f2(1) & fwb<f2(2));
            inn=[clist;control];

            out=1:size(map,3);out(inn)=[];
            %direction=ddc{dc};
            [map_inn,dst_in]=select_interaction_map(inn,map,[]);
            [map_out,dst_out]=select_interaction_map(out,map,[]);
            val_inn=sample_map_region(map_inn,fxa,fxb,use_measure);
            val_out=sample_map_region(map_out,fxa,fxb,use_measure);
            for i=1:8;
                yib(i,s)=mean(val_inn(dst_in>=xx(i) & dst_in<xx(i+1)));
                yob(i,s)=mean(val_out(dst_out>=xx(i) & dst_out<xx(i+1)));

                yisb(i,s)=var(val_inn(dst_in>=xx(i) & dst_in<xx(i+1)));
                yosb(i,s)=var(val_out(dst_out>=xx(i) & dst_out<xx(i+1)));
                nib(i,s)=sum(dst_in>=xx(i) & dst_in<xx(i+1));
                nob(i,s)=sum(dst_out>=xx(i) & dst_out<xx(i+1));
            end
        end
        tBPLV=(yib-yob)./sqrt(yisb./nib+yosb./nob);
        val=mean(tBPLV,2);
        all_scan(:,ff1,ff2)=val;
        toc
    end
end
figure
for i=1:8;subplot(4,2,i); imagesc(squeeze(all_scan(i,:,:)));caxis([-3
3]);end
