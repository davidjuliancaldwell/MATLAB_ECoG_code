function show_map(val,cluster)

cemb=zeros(size(cluster,1)+2,size(cluster,2)+2);
vemb=cemb;
cemb(2:end-1,2:end-1)=cluster;
vemb(2:end-1,2:end-1)=reshape(val,size(cluster))';

imagesc(vemb);
hold on
[c,h]=contour(cemb*max(vemb(:)),max(vemb(:))*.5,'Color','k','LineWidth',2);
c=get(h,'Children');
for i=1:length(c)
    set(c,'FaceColor','none');
end
set_colormap_threshold(gcf,[-min(val)-eps quantile(val,.2)],[min(val)
max(val)],[1 1 1])
