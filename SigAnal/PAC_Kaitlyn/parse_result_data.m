sub = 'S2';
figure_dir='figures_paper';

p0=0.05;
np=1000;
all_ixc=1;
nsu=4;nc=64;mxt=12;
seed_all=zeros(nsu,1);
tmap=zeros(nsu*nc,20);
dd=zeros(11,4);
for s=1:nsu
    sub=sprintf('S%i',s+1);
    threshold=1;
    di=dir(fullfile(sub,'*_seed_members*.mat'));

    if ~isempty(di)
        clear *Thresholds;
        load(fullfile(sub,di(1).name));
        a=whos('*Thresholds');
        if ~isempty(a)
            tt=eval(a.name);
            ixx=find(tt(1,:)>=threshold);
            ix=find(sum(tt(2:end,ixx),2)>0);
            ix(ix==seed)=[];
            seed_all(s)=seed;
        end
    end

    tmap((s-1)*64+1:s*64,1:size(tt,2))=tt(2:end,:);
    trlist=tt(1,:);
    cmap=tt(2:end,:);
    d=tt2dist(tt,2:12,seed,[8 8]);
    dd(:,s)=d;
    inbound=load(fullfile(sub,'results_max_inbound.mat'));

    outbound=load(fullfile(sub,'results_max_outbound.mat'));


    map_in=zeros(length(inbound.fwb),length(inbound.fwa),length(inbound.map_
all));
    map_out=map_in;
    for i=1:size(map_in,3)
        map_in(:,:,i)=inbound.map_all{i};
        map_out(:,:,i)=outbound.map_all{i};


    end

    if s==1
        map_out_all=zeros(size(map_in,1),size(map_in,2),64*nsu);
        map_in_all=zeros(size(map_in,1),size(map_in,2),64*nsu);
        ix_all_in=zeros(64*nsu,1);
        ix_all_out=ix_all_in;
    end

    fwa=inbound.fwa;
    fwb=inbound.fwb;

    ix_in=find(cellfun(@length,inbound.ff1_all)>0);
    ix_out=find(cellfun(@length,outbound.ff1_all)>0);


    nci=length(ix_in);
    nco=length(ix_out);
    nf=sum(cellfun(@length,inbound.ff1_all));
    f1i=zeros(nf,1);f2i=f1i;
    k=1;
    for i=1:length(ix_in)
        f1i(k:k-1+length(inbound.ff1_all{ix_in(i)}))=inbound.ff1_all{ix_in(i
)};
        f2i(k:k-1+length(inbound.ff2_all{ix_in(i)}))=inbound.ff2_all{ix_in(i
)};
        k=k+length(inbound.ff1_all{ix_in(i)});
    end

    nf=sum(cellfun(@length,outbound.ff1_all));
    f1o=zeros(nf,1);f2o=f1o;
    k=1;
    for i=1:length(ix_out)
        f1o(k:k-1+length(outbound.ff1_all{ix_out(i)}))=outbound.ff1_all{ix_o
ut(i)};
        f2o(k:k-1+length(outbound.ff2_all{ix_out(i)}))=outbound.ff2_all{ix_o
ut(i)};
        k=k+length(outbound.ff1_all{ix_out(i)});
    end

    ai=sum(cmap(ix_in,:),2);
    ao=sum(cmap(ix_out,:),2);

    sens_i=zeros(size(cmap,2),1);
    sens_o=sens_i;
    spec_i=sens_i;
    spec_o=sens_i;

    for i=1:size(cmap,2)
        sens_i(i)=sum(ai>=i)/sum(cmap(:,i),1);
        sens_o(i)=sum(ao>=i)/sum(cmap(:,i),1);
        spec_i(i)=sum(ai>=i)/length(ai);
        spec_o(i)=sum(ao>=i)/length(ao);

    end

    ccmap=sum(cmap)/64;
    pin=zeros(size(cmap,2),1);
    pout=pin;
    for i=1:length(ccmap);
        pout(i)=(ccmap(i)).^sum(ao>=i);
        pin(i)=(ccmap(i)).^sum(ai>=i);
    end

%     figure
%     plot(pin);
%     hold on
%     plot(pout,'r');
%     plot(1:size(cmap,2),ones(size(cmap,2),1)*.05,'k')
    map_in_all(:,:,(all_ixc-1)*64+1:all_ixc*64)=map_in;
    map_out_all(:,:,(all_ixc-1)*64+1:all_ixc*64)=map_out;
    ix_all_in((all_ixc-1)*64+ix_in)=1;
    ix_all_out((all_ixc-1)*64+ix_out)=1;

    all_ixc=all_ixc+1;

end
%%
sub='group';
    tr0=tinv(.99,254);

if 1
%figure
for u=1:mxt

    ne=sum(tmap(:,u));

    map1=map_out_all(:,:,tmap(:,u)>0);
    %map1=map_out_all(:,:,randperm(size(map_out_all,3),sum(tmap(:,u))));
    map2=map_out_all(:,:,tmap(:,u)<1);
    [torg,p,pmap,cmap,r]=max_cluster_test(map1,map2,tr0,np);
    %subplot(4,3,u);
    if sum((pmap(:)<p0))>0
        figure
        %imagesc(fwa,fwb,torg.*(pmap<p0));axis xy
        contourf(fwa,fwb,torg.*(pmap<p0),30,'EdgeColor','none');

        set_colormap_threshold(gcf,[-tr0 tr0],[-5 5],[1 1 1])
        %         if u<12
        %             title(sprintf('tr at %i #chan %i',u+1,ne))
        %         else
        %             title(sprintf('seed-> tr at %i #chan %i',u+1,ne))
        %
        %         end
        xlabel('phase frequency low [Hz]');
        ylabel('phase frequency high [Hz]');
        title(sprintf('seed-> tr at %i #chan %i',u+1,ne))
        grid
        colorbar;
        drawnow;
        fname=sprintf('%s_tr%i_bplv_out.fig',sub,u);
        saveas(gcf,fullfile(figure_dir,fname),'fig');
        close(gcf);
    end
end
%figure
for u=1:mxt
    figure
    ne=sum(tmap(:,u));
    map1=map_in_all(:,:,tmap(:,u)>0);
    map2=map_in_all(:,:,tmap(:,u)<1);
    %map2=map_in_all(:,:,randperm(size(map_in_all,3),sum(tmap(:,u))));

    [torg,p,pmap,cmap,r]=max_cluster_test(map1,map2,tr0,np);


    if sum((pmap(:)<p0))>0
        figure
        %subplot(4,3,u);
        %imagesc(fwa,fwb,torg.*(pmap<p0));axis xy
        contourf(fwa,fwb,torg.*(pmap<p0),30,'EdgeColor','none');

        set_colormap_threshold(gcf,[-tr0 tr0],[-5 5],[1 1 1])
        %     if u<12
        %         title(sprintf('tr at %i #chan %i',u+1,ne))
        %     else
        %         title(sprintf('seed<- tr at %i #chan %i',u+1,ne))
        %
        %     end

        title(sprintf('seed<- tr at %i #chan %i',u+1,ne))
        xlabel('phase frequency low [Hz]');
        ylabel('phase frequency high [Hz]');
        colorbar;
        grid
        drawnow;
        fname=sprintf('%s_tr%i_bplv_in.fig',sub,u);
        saveas(gcf,fullfile(figure_dir,fname),'fig');
        close(gcf);
    end
end
%%
end
%%
load all_4subjects_pac_map_norm
%figure
for u=1:mxt

    ne=sum(tmap(:,u));
    ixx=find(tmap(:,u)>0);ne=numel(ixx)
    map1=map_out(:,:,ixx);ixn=1:size(map_out,3);ixn(ixx)=[];
    %map1=map_out_all(:,:,randperm(size(map_out_all,3),sum(tmap(:,u))));
    map2=map_out(:,:,ixn);

    [torg,p,pmap,cmap,r]=max_cluster_test(map1,map2,tr0,np);
    if sum((pmap(:)<p0))>0
        figure
        %subplot(4,3,u);
        %imagesc(fwa,fwb,torg.*(pmap<p0));axis xy
        contourf(fwa,fwb,torg.*(pmap<p0),30,'EdgeColor','none');

        set_colormap_threshold(gcf,[-tr0 tr0],[-7 7],[1 1 1])
        %     subplot(4,3,u);
        %     imagesc(fwa,fwb,torg.*(pmap<p0));axis xy
        %     set_colormap_threshold(gcf,[-3 3],[-7 7],[.7 .7 .7])
        %     if u<12
        %         title(sprintf('tr at %i #chan %i',u+1,ne))
        %     else
        %         title(sprintf('PAC seed-> tr at %i #chan %i',u+1,ne))
        %
        %     end
        title(sprintf('PAC seed-> tr at %i #chan %i',u+1,ne))
        xlabel('phase frequency [Hz]');
        ylabel('amplitude frequency [Hz]');
        colorbar;
        grid
        drawnow;
        fname=sprintf('%s_tr%i_PAC_out.fig',sub,u);
        saveas(gcf,fullfile(figure_dir,fname),'fig');
                %close(gcf);

    end
end
pack;
%%
%figure
for u=1:mxt
    ne=sum(tmap(:,u));
    map1=map_in(:,:,tmap(:,u)>0);
    map2=map_in(:,:,tmap(:,u)<1);
    %map2=map_in_all(:,:,randperm(size(map_in_all,3),sum(tmap(:,u))));

    [torg,p,pmap,cmap,r]=max_cluster_test(map1,map2,tr0,np);
    if sum((pmap(:)<p0))>0
         figure
        %subplot(4,3,u);
        %imagesc(fwa,fwb,torg.*(pmap<p0));axis xy
        contourf(fwa,fwb,torg.*(pmap<p0),30,'EdgeColor','none');

        set_colormap_threshold(gcf,[-tr0 tr0],[-7 7],[1 1 1])
        %     subplot(4,3,u);
        %     imagesc(fwa,fwb,torg.*(pmap<p0));axis xy
        %     set_colormap_threshold(gcf,[-3 3],[-7 7],[.7 .7 .7])
        %     if u<12
        %         title(sprintf('tr at %i #chan %i',u+1,ne))
        %     else
        %         title(sprintf('PAC seed-> tr at %i #chan %i',u+1,ne))
        %
        %     end
        title(sprintf('PAC seed <- tr at %i #chan %i',u+1,ne))
        xlabel('phase frequency [Hz]');
        ylabel('amplitude frequency [Hz]');
        grid
        drawnow;
        colorbar;
        fname=sprintf('%s_tr%i_PAC_in.fig',sub,u);
        saveas(gcf,fullfile(figure_dir,fname),'fig');
        close(gcf);

    end
end


break

%%
figure
for u=1:mxt
    ne=sum(tmap(:,u));
    ix=tmap(:,u)>0;
    ix=reshape(ix,nc,nsu);
%     for j=1:length(seed_all)
%         ix(seed_all(j),j)=0;
%     end
%
    [torg,p,pmap,cmap,mxcluster_loc]=max_cluster_test_shape(map_in,ix,2,np);

    subplot(4,3,u);
    imagesc(fwa,fwb,torg.*(pmap<p0));axis xy
    set_colormap_threshold(gcf,[-3 3],[-7 7],[.7 .7 .7])
    if u<12
        title(sprintf('tr at %i #chan %i',u+1,ne))
    else
        title(sprintf('PAC seed<- tr at %i #chan %i',u+1,ne))

    end
    grid
    drawnow;


end
%%


figure
for u=1:mxt
    ne=sum(tmap(:,u));
    ix=tmap(:,u)>0;
    ix=reshape(ix,nc,nsu);
%     for j=1:length(seed_all)
%         ix(seed_all(j),j)=0;
%     end
%
    [torg,p,pmap,cmap,mxcluster_loc]=max_cluster_test_shape(map_in_all,ix,3,
np);

    subplot(4,3,u);
    mask=(pmap<p0);
    %mask=ones(size(mask));
    imagesc(fwa,fwb,torg.*mask);axis xy
    set_colormap_threshold(gcf,[-3 3],[-4 4],[.7 .7 .7])
    if u<12
        title(sprintf('tr at %i #chan %i',u+1,ne))
    else
        title(sprintf('bPLV seed<- tr at %i #chan %i',u+1,ne))

    end
    grid
    drawnow;


end


%%
figure
for u=1:mxt
    ne=sum(tmap(:,u));
    ix=tmap(:,u)>0;
    ix=reshape(ix,nc,nsu);
%     for j=1:length(seed_all)
%         ix(seed_all(j),j)=0;
%     end
%
    [torg,p,pmap,cmap,mxcluster_loc]=max_cluster_test_shape(map_out,ix,2,np)
;

    subplot(4,3,u);
    imagesc(fwa,fwb,torg.*(pmap<p0));axis xy
    set_colormap_threshold(gcf,[-3 3],[-7 7],[.7 .7 .7])
    if u<12
        title(sprintf('tr at %i #chan %i',u+1,ne))
    else
        title(sprintf('PAC seed-> tr at %i #chan %i',u+1,ne))

    end
    grid
    drawnow;


end
%%


figure
for u=1:mxt
    ne=sum(tmap(:,u));
    ix=tmap(:,u)>0;
    ix=reshape(ix,nc,nsu);
%     for j=1:length(seed_all)
%         ix(seed_all(j),j)=0;
%     end
%
    [torg,p,pmap,cmap,mxcluster_loc]=max_cluster_test_shape(map_out_all,ix,3
,np);

    subplot(4,3,u);
    mask=(pmap<p0);
    %mask=ones(size(mask));
    imagesc(fwa,fwb,torg.*mask);axis xy
    set_colormap_threshold(gcf,[-3 3],[-4 4],[.7 .7 .7])
    if u<12
        title(sprintf('tr at %i #chan %i',u+1,ne))
    else
        title(sprintf('bPLV seed-> tr at %i #chan %i',u+1,ne))

    end
    grid
    drawnow;


end
