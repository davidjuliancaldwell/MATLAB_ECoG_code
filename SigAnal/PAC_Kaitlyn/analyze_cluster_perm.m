function [po,pt,pr]=analyze_cluster_perm(data,tr)


po=zeros(size(tr,2),1);
pr=po;
pt=po;

for j=1:size(tr,2)
    fmri_tr=tr(1,j);
    cluster=find(tr(2:end,j)>0);
    rest=find(tr(2:end,j)<1);
    org=data.org;
    prm=data.pp_all;

    po(j)=1-sum(mean(org(cluster))>mean(prm(cluster,:)))/size(prm,2);
    pr(j)=1-sum(mean(org(rest))>mean(prm(rest,:)))/size(prm,2);

    if numel(cluster)>2
        [h,p,c,stats]=ttest2(org(cluster,:),org(rest,:));
        torg=stats.tstat;
        [h,p,c,stats]=ttest2(prm(cluster,:),prm(rest,:));
        pt(j)=1-sum(torg>=stats.tstat)/size(prm,2);
    else
        pt(j)=1;
    end
end
np=size(prm,2);
po(po<1/np)=1/np;
pt(pt<1/np)=1/np;
pr(pr<1/np)=1/np;
