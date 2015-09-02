function [in,out]=generate_random_cluster(nx,ny,cs)

cmap=zeros(nx,ny);

dx=[1 -1 0 0  1 -1 1 -1];
dy=[0  0 1 -1 -1 1 1 -1];
cs0=cs;
nx0=randi([1 nx]);
ny0=randi([1 ny]);
cmap(nx0,ny0)=1;cs0=cs0-1;
while cs0>0
    dr=randi([1 8]);
    xx=nx0+dx(dr);
    yy=ny0+dy(dr);
    if xx>0 && xx<=nx && yy>0 && yy<=ny
        if cmap(xx,yy)==0
            cmap(xx,yy)=1;
            cs0=cs0-1;
        end
    end
     B = bwboundaries(cmap);
     b=B{randi([1 length(B)])};
     nx0=b(randi([1 size(b,1)]),1);
     ny0=b(randi([1 size(b,1)]),2);
end

in=find(cmap>0);
out=find(cmap<1);
