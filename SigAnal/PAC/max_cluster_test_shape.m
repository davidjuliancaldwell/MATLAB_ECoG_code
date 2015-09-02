function
[torg,p,pmap,cmap,mxcluster_loc]=max_cluster_test_shape(map,ix,tr,np)

torg=compute_tstat(map(:,:,ix(:)>0),map(:,:,ix(:)<1));

cmap=zeros(size(map,1),size(map,2));
stats=regionprops(abs(torg)>tr,'Area');
cspo=cell2mat(struct2cell(stats));

csize_hist=zeros(np,1);
mxcluster_loc=zeros(np,2);
for i=1:np
    ix_alt=make_contiguous_index(ix);
    tperm=compute_tstat(map(:,:,ix_alt(:)>0),map(:,:,ix_alt(:)<1));
    stats=regionprops(abs(tperm)>tr,'Area');
    s=regionprops(abs(tperm)>tr,'Centroid');
    centroids = cat(1, s.Centroid);
    csp=cell2mat(struct2cell(stats));
    if ~isempty(csp)
        [csize_hist(i),ixm]=max(csp);
        co=centroids(ixm,:);
        mxcluster_loc(i,:)=co;
        co=floor(co);co(co<1)=1;
        cmap(co(2),co(1))=cmap(co(2),co(1))+1;
    end
end
[B,L,N]=bwboundaries(abs(torg)>tr,'noholes');

p=cspo;
pmap=ones(size(L));
for i=1:length(cspo)
    p(i)=1-sum(cspo(i)>csize_hist)/np;
    pmap(L==i)=p(i);
end

function t=compute_tstat(x,y)

n1=size(x,3);
n2=size(y,3);
s=sqrt(((n1-1)*var(x,0,3)+(n2-1)*var(y,0,3))/(n1+n2-2));

t=(mean(x,3)-mean(y,3))./s/sqrt(1/n1+1/n2);

function alt_ix=make_contiguous_index(ix)
alt_ix=ix;
for i=1:size(ix,2)
    n=sum(ix(:,i));
    a=zeros(8,8);
    if n>0
        x=randi(8);y=randi(8);
        a(x,y)=1;
        n=n-1;
        while n>0
           d=randi(4);
           switch d
               case 1
                   x1=x+1;y1=y;
               case 2
                   x1=x-1;y1=y;
               case 3
                   y1=y+1;x1=x;
               case 4
                   y1=y-1;x1=x;
           end
           if (x1>0 & x1<9 & y1>0 & y1<9)
               if a(x1,y1)==0
                   a(x1,y1)=1;
                   n=n-1;
               end
               ixx=find(a>0);
               [xn,yn]=ind2sub(size(a),ixx(randi(numel(ixx))));
               x=xn;y=yn;
           end
        end
    end
    alt_ix(:,i)=a(:);
end
