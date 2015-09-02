load test_low_high_results

p0=.95;
for i=1:length(PAC_in)
    subj=sprintf('S%i',i+1);fprintf('working on subject %s\n',subj);
    [data,clist,control,fs,tr]=get_subject_data(subj,5,.5,300,4,-1);



    pac_in_tr=quantile(max(PAC_in{i}.pp_all),p0);
%pac_in_tr=quantile(PAC_in{i}.pp_all(:),p0);
    pac_out_tr=quantile(max(PAC_out{i}.pp_all),p0);%pac_out_tr=quantile(PAC_
out{i}.pp_all(:),p0);
    bplv_in_tr=quantile(max(bPLV_in{i}.pp_all),p0);%pac_in_tr=quantile(bPLV_
in{i}.pp_all(:),p0);
    bplv_out_tr=quantile(max(bPLV_out{i}.pp_all),p0);%pac_in_tr=quantile(bPL
V_out{i}.pp_all(:),p0);

    fprintf('PAC in treshold =%f\n',pac_in_tr)
    fprintf('PAC out treshold =%f\n',pac_out_tr)
    fprintf('BPLV in treshold =%f\n',bplv_in_tr)
    fprintf('BPLV out treshold =%f\n',bplv_out_tr)


    figure
    subplot(2,2,1);
    org=PAC_in{i}.org;
    plot(sort(org),'LineWidth',2);
    hold on
    plot(1:length(org), pac_in_tr*ones(size(org)),'r','LineWidth',2)
    title(sprintf('subject %i PAC in',i));

    subplot(2,2,2);

    org=PAC_out{i}.org;
    plot(sort(org),'LineWidth',2);
    hold on
    plot(1:length(org), pac_out_tr*ones(size(org)),'r','LineWidth',2)
    title(sprintf('subject %i PAC out',i));

    subplot(2,2,3);
    org=bPLV_in{i}.org;
    plot(sort(org),'LineWidth',2);
    hold on
    plot(1:length(org), bplv_in_tr*ones(size(org)),'r','LineWidth',2)
    title(sprintf('subject %i BPLV in',i));

    subplot(2,2,4);

    org=bPLV_out{i}.org;
    plot(sort(org),'LineWidth',2);
    hold on
    plot(1:length(org), bplv_out_tr*ones(size(org)),'r','LineWidth',2)
    title(sprintf('subject %i BPLV out',i));



end
%%
for i=1:length(PAC_in)

    subj=sprintf('S%i',i+1);fprintf('working on subject %s\n',subj);
    [data,clist,control,fs,tr]=get_subject_data(subj,5,.5,300,4,-1);

    [po,pt,pr]=analyze_cluster_perm(PAC_in{i},tr);
    erg=pt;
    figure
    subplot(2,2,1);
    bar(tr(1,:),-log10(erg))
    hold on
    plot(tr(1,:),-log10(0.05)*ones(size(tr,2),1),'r','LineWidth',2);
    title(sprintf('subject %i PAC in',i));
    xlabel('fMRI threshold');


    [po,pt,pr]=analyze_cluster_perm(PAC_out{i},tr);
    erg=pt;
    subplot(2,2,2);
    bar(tr(1,:),-log10(erg))
    hold on
    plot(tr(1,:),-log10(0.05)*ones(size(tr,2),1),'r','LineWidth',2);
    title(sprintf('subject %i PAC Out',i));
    xlabel('fMRI threshold');
    [po,pt,pr]=analyze_cluster_perm(bPLV_in{i},tr);

    erg=pt;
    subplot(2,2,3);
    bar(tr(1,:),-log10(erg))
    hold on
    plot(tr(1,:),-log10(0.05)*ones(size(tr,2),1),'r','LineWidth',2);
    title(sprintf('subject %i bPLV in',i));
    xlabel('fMRI threshold');


    [po,pt,pr]=analyze_cluster_perm(bPLV_out{i},tr);
    erg=pt;
    subplot(2,2,4);
    bar(tr(1,:),-log10(erg))
    hold on
    plot(tr(1,:),-log10(0.05)*ones(size(tr,2),1),'r','LineWidth',2);
    title(sprintf('subject %i bPLV Out',i));
    xlabel('fMRI threshold');
end




