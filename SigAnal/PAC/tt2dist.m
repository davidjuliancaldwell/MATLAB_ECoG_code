function d=tt2dist(tt,tlist,seed,grid_dim)

[x0,y0]=ind2sub(grid_dim,seed);
d=zeros(numel(tlist),1);
for i=1:length(tlist)
    ix=find(tt(1,:)==tlist(i));
    a=tt(2:end,ix);
    [x,y]=ind2sub(grid_dim,find(a>0));
    r=[x-x0 y-y0];

%     u=reshape(a,grid_dim);
%     B=bwtraceboundary(u',[x0 y0],'W');
%     if ~isempty(B)
%     B(:,1)=B(:,1)-x0;
%     B(:,2)=B(:,2)-y0;
%     else
%         B=[0,0];
%     end
    dd=sqrt(sum(r.^2,2));
    d(i)=max(dd);
end
