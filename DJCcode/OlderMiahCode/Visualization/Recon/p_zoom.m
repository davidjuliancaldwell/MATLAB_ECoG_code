function out_els=p_zoom(els, gs, index, checkdistance, ignoreTrodes)
%function out_els=p_zoom(els, gs, index);
% this function finds the minimum distance on a surface "gs" (pts x 3) that is
% closest for each electrode in "els" (N x 3)
% index indicates the number of point for calculation of norm, 0 if global
% checkdistance = 1 to indicate that electrodes within 3 mm of the surface
% are not projected

%use a local set of electrodes to determine the orthogonal direction of a
%given electrode? -- enter "0" for global, and number to use otherwise
%   Created by:
%   D. Hermes & K.J. Miller 
%   Dept of Neurology and Neurosurgery, University Medical Center Utrecht
%
%   Version 1.1.0, released 26-11-2009

if ~exist('ignoreTrodes','var')
    ignoreTrodes = [];
end

lcl_num=index;
checkdistance_dist=3; % 3 mm

if checkdistance==2
    disp('electrodes projected to closest point, no norm')
end
    
if mean(els(:,1))<0
    disp('left grid');
    % delete right hemisphere
    % gs=gs(gs(:,1)<=0,:);
else
    disp('right grid');
    % delete right hemisphere
    % gs=gs(gs(:,1)>=0,:);
end

if lcl_num==0 %global estimate of principal direction most orthogonal to array
    [v,d]=eig(cov(els)); %all vecs
    nm=v(:,find(diag(d)==min(diag(d)))); %vec we want
    nm=nm*sign(nm(1)*mean(els(:,1)));%check for left or rigth brain, invert nm if needed
end

out_ind=zeros(size(els,1),1);
out_ind_rev=zeros(size(els,1),1);
for k=1:size(els,1)
    
    if find(ignoreTrodes==k,1,'first')>0
        continue;
    end
    %sub array?
    if lcl_num>0, % get principal direction most orthogonal to sub-array
        [y,ind]=sort(dist(els,els(k,:)'),'ascend');%select closest for sub-array
        [v,d]=eig(cov(els(ind(1:lcl_num),:))); %all vecs
        nm=v(:,find(diag(d)==min(diag(d)))); %vec we want
        nm=nm*sign(nm(1)*mean(els(:,1)));%check for left or right brain, invert nm if needed
    end
    %
    npls=[gs(:,1)-els(k,1) gs(:,2)-els(k,2) gs(:,3)-els(k,3)]; %x,y,z lengths
    % calculate distance
    npls_dist=sqrt(sum((npls).^2,2));
    % check whether distance is < 3 mm
    distancesm2=0;
    if npls_dist(find(npls_dist==min(npls_dist)),:)<checkdistance_dist
        %disp(['distance < 3 mm electrode ' int2str(k) ]);
        distancesm2=1;
    end
    
    if checkdistance==1 && distancesm2==1 % electrode too close to surface to project
        out_ind(k)=find(npls_dist==min(npls_dist),1); %find minimum distance
    elseif checkdistance==2
        out_ind(k)=find(npls_dist==min(npls_dist),1); %find minimum distance
    else
        npls_unit=npls./repmat((sum(npls.^2,2).^.5),1,3); % normalize npls to get unit vector
        npdot=(npls_unit*nm); %distance along eigenvector direction (dot product)
        % only take gs within 2.5 cm distance
        npdot(npls_dist>25)=0;
        %npdotrev=(npls_unit*-nm); % distance in reverse eigenvector direction
        [a b] = find(abs(npdot)==max(max(abs(npdot))),1);
        out_ind(k)= a;%find minimum distance, max dot product
        %out_ind_rev(k)=find(npdotrev==max(npdotrev),1); %find minimum distance, max dot product
    end
end
out_ind(out_ind==0) = [];
out_els = els;
out_els(setdiff(1:size(els,1),ignoreTrodes),:)=gs(out_ind,:);
% out_els_rev=gs(out_ind_rev,:);
% % check distance to new electrodes
% out_els_dist=sqrt(sum((els-out_els).^2,2));
% out_els_rev_dist=sqrt(sum((els-out_els_rev).^2,2));

% plot on surface to check
figure
plot3(els(:,1),els(:,2),els(:,3),'r.','MarkerSize',20);
hold on;
plot3(out_els(:,1),out_els(:,2),out_els(:,3),'g.','MarkerSize',20);
plot3(gs(:,1),gs(:,2),gs(:,3),'k.','MarkerSize',1);
axis equal;

for i=1:size(els,1);
    el = els(i,:);
    text(el(1),el(2),el(3),sprintf('%i',i));
end