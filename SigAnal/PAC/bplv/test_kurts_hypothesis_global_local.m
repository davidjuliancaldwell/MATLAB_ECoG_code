% test for specific in-vs out-of network PAC maps

load Fig6_electrodes
order=[1 3 4 2]; % reorder Kurt's order to Felix's file structure

Seed=Seed(order);
WithinGlobal=WithinGlobal(order);
WithinLocal=WithinLocal(order);
OutOFGlobal=OutOFGlobal(order);
OutOFLocal=OutOfLocal(order);
pac_WithinLocal=WithinLocal;
pac_WithinGlobal=WithinLocal;
pac_OutOFLocal=WithinLocal;
pac_OutOFGlobal=WithinLocal;

bplv_WithinLocal=WithinLocal;
bplv_WithinGlobal=WithinLocal;
bplv_OutOFLocal=WithinLocal;
bplv_OutOFGlobal=WithinLocal;

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

use_measure='median';
ztr=2;

basedir='figures_distance';
fname_pac=fullfile(basedir,sprintf('PAC_tr%i.fig',ztr));
fname_bplv=fullfile(basedir,sprintf('BPLV_tr%i.fig',ztr));

nperm=500;
tstat_permPAC=zeros(length(x),nperm,4);
tstat_permBPLV=zeros(length(x),nperm,4);
cmode=2; %1 - null hypothesis cluster formed from any pairs %2 null
hypothesis cluster formed with similar size/connectivity
ff1=1:10;ff2=1:10;
f1t=[ff1*2+7;ff1*2+9];
f2t=[ff2*5+65;ff2*5+70];
canonical_label_low={'alpha','beta','gamma'};
canonical_label_high={'high gamma'};

canonical_high=[70 115];
canonical_low=[[9 15];[15 25];[25 30]];

use_pac=[9 2];
use_bplv=[6 2];
%%
for s=1:4
        subj=sprintf('S%i',s+1);
        %direction=ddc{dc};
        load(fullfile(subj,sprintf('results_pac_norm_all.mat')));
        [data,clist,control,fs,tr]=get_subject_data(subj,ztr,.5,300,4,-1);

        f1=f1t(:,use_pac(2));
        f2=f2t(:,use_pac(1));
        f1p=mean(f1);
        f2p=mean(f2);
        fxa=find(fwa>f1(1) & fwa<f1(2));
        fxb=find(fwb>f2(1) & fwb<f2(2));

        pac_WithinLocal(s)=median(median(map(fxa,fxb,control,WithinLocal(s))
));
        pac_WithinGlobal(s)=median(median(map(fxa,fxb,control,WithinGlobal(s
))));
        pac_OutOFLocal(s)=median(median(map(fxa,fxb,control,OutOFLocal(s))))
;
        pac_OutOFGlobal(s)=median(median(map(fxa,fxb,control,OutOFGlobal(s))
));

        inn=[clist;control];
        out=1:size(map,3);out(inn)=[];
        %-----
        tic
        for u=1:nperm
        cperm=randperm(size(map,4));
        switch cmode
            case 1
                inr=cperm(1:length(inn));or=cperm(length(inn)+1:end);
            case 2
                [inr,or]=generate_random_cluster(8,8,numel(inn));
        end
        tstat=generate_tstat_from_allmap(map,inr,or,fxa,fxb,use_measure,xx);
        tstat_permPAC(:,u,s)=tstat;
        end
        toc
        %


        [map_inn,dst_in]=select_interaction_map(inn,map,[]);
        [map_out,dst_out]=select_interaction_map(out,map,[]);
        val_inn=sample_map_region(map_inn,fxa,fxb,use_measure);
        val_out=sample_map_region(map_out,fxa,fxb,use_measure);
        for i=1:8;
            yi(i,s)=mean(val_inn(dst_in>=xx(i) & dst_in<xx(i+1)));
            yo(i,s)=mean(val_out(dst_out>=xx(i) & dst_out<xx(i+1)));

            yis(i,s)=var(val_inn(dst_in>=xx(i) & dst_in<xx(i+1)));
            yos(i,s)=var(val_out(dst_out>=xx(i) & dst_out<xx(i+1)));

            ni(i,s)=sum(dst_in>=xx(i) & dst_in<xx(i+1));
            no(i,s)=sum(dst_out>=xx(i) & dst_out<xx(i+1));

        end



        load(fullfile(subj,sprintf('results_bplv_norm_all.mat')));
       %%
        f1=f1t(:,use_bplv(2));
        f2=f2t(:,use_bplv(1));

        f1b=mean(f1);
        f2b=mean(f2);

        fxa=find(fwa>f1(1) & fwa<f1(2));
        fxb=find(fwb>f2(1) & fwb<f2(2));
        bplv_WithinLocal(s)=median(median(map(fxa,fxb,control,WithinLocal(s)
)));
        bplv_WithinGlobal(s)=median(median(map(fxa,fxb,control,WithinGlobal(
s))));
        bplv_OutOFLocal(s)=median(median(map(fxa,fxb,control,OutOFLocal(s)))
);
        bplv_OutOFGlobal(s)=median(median(map(fxa,fxb,control,OutOFGlobal(s)
)));
         tic
         for u=1:nperm
             cperm=randperm(size(map,4));
             switch cmode
                 case 1
                     inr=cperm(1:length(inn));or=cperm(length(inn)+1:end);
                 case 2
                     [inr,or]=generate_random_cluster(8,8,numel(inn));
             end
             tstat=generate_tstat_from_allmap(map,inr,or,fxa,fxb,use_measure
,xx);
             tstat_permBPLV(:,u,s)=tstat;
         end
         toc

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
%%
pac_means=[mean(pac_WithinGlobal) mean(pac_OutOFGlobal)
mean(pac_WithinLocal) mean(pac_OutOFLocal)];
pac_em=[std(pac_WithinGlobal) std(pac_OutOFGlobal) std(pac_WithinLocal)
std(pac_OutOFLocal)]/sqrt(numel(pac_OutOFLocal));

bplv_means=[mean(bplv_WithinGlobal) mean(bplv_OutOFGlobal)
mean(bplv_WithinLocal) mean(bplv_OutOFLocal)];
bplv_em=[std(bplv_WithinGlobal) std(bplv_OutOFGlobal) std(bplv_WithinLocal)
std(bplv_OutOFLocal)]/sqrt(numel(bplv_OutOFLocal));


%%
if 0
figure
bb=bar(1:numel(pac_means),pac_means);
hold on
errorbar(1:numel(pac_means),pac_means,pac_em,'.k')
set(bb,'FaceColor',[0.8 .8 .8])
set(gca,'XTickLabel',{'within global','out of global','within local','out of
local'})
title('PAC')

figure
bb=bar(1:numel(bplv_means),bplv_means);
hold on
errorbar(1:numel(bplv_means),bplv_means,bplv_em,'.k')
set(bb,'FaceColor',[0.8 .8 .8])
set(gca,'XTickLabel',{'within global','out of global','within local','out of
local'})
title('BPLV')
end
if 0
%%
figure
for s=1:4
    subplot(2,2,s);
    plot(x,yi(:,s),'b');
    hold on
    plot(x,yo(:,s),'r');
    title(sprintf('PAC subject %i',s));
end

figure
for s=1:4
    subplot(2,2,s);
    plot(x,yib(:,s),'b');
    hold on
    plot(x,yob(:,s),'r');
    title(sprintf('bPLV subject %i',s));

end
end



%%


tPAC=(yi-yo)./sqrt(yis./ni+yos./no);
tBPLV=(yib-yob)./sqrt(yisb./nib+yosb./nob);

% figure
% plot(x,mean(tPAC,2));
% hold on
% plot(x,mean(tBPLV,2),'r');


ppBPLV=mean(tstat_permBPLV,3);

ppPAC=mean(tstat_permPAC,3);
figure

gaPAC=mean(tPAC,2);
bbc=bar(x,gaPAC,'FaceColor',[.7 .7 .7]);
hold on
lim=quantile(max(ppPAC),.95);
pP=1-sum(repmat(gaPAC(gaPAC>lim)',nperm,1)>repmat(max(ppPAC)',1,sum(gaPAC>li
m)))/nperm;
plot(x, lim*ones(size(x)),'k','LineWidth',3)
text(x(gaPAC>lim),gaPAC(gaPAC>lim)*1.05,'*','FontSize',20);

ix=find(gaPAC>lim);

for u=1:numel(pP)
    text(x(ix(u)),gaPAC(ix(u))*1.15,sprintf('p=%0.3f',pP(u)));
end

from=canonical_label_low{f1p<canonical_low(:,2) & f1p>canonical_low(:,1)};
to=canonical_label_high{f2p<canonical_high(:,2) & f2p>canonical_high(:,1)};
title(sprintf('PAC - cluster threshold Z>=%i %s -> %s',ztr,from,to));
xlabel('distance')
ylabel('tstat in-vs-out');
ylim([min(gaPAC) max(gaPAC)*1.3]);


saveas(gcf,fname_pac,'fig');

figure
gaBPLV=mean(tBPLV,2);
lim=quantile(max(ppBPLV),.95);
pP=1-sum(repmat(gaBPLV(gaBPLV>lim)',nperm,1)>repmat(max(ppBPLV)',1,sum(gaBPL
V>lim)))/nperm;

bbp=bar(x,gaBPLV,'FaceColor',[.7 .7 .7]);
hold on
text(x(gaBPLV>lim),gaBPLV(gaBPLV>lim)*1.05,'*','FontSize',20);

ix=find(gaBPLV>lim);

for u=1:numel(ix)
    text(x(ix(u)),gaBPLV(ix(u))*1.15,sprintf('p=%0.3f',pP(u)));
end
plot(x, lim*ones(size(x)),'k','LineWidth',3)
from=canonical_label_low{f1b<canonical_low(:,2) & f1b>canonical_low(:,1)};
to=canonical_label_high{f2b<canonical_high(:,2) & f2b>canonical_high(:,1)};

title(sprintf('BPLV - cluster threshold Z>=%i %s -> %s',ztr,from,to));
xlabel('distance')
ylabel('tstat in-vs-out');
ylim([min(gaBPLV) max(gaBPLV)*1.3]);
saveas(gcf,fname_bplv,'fig');
