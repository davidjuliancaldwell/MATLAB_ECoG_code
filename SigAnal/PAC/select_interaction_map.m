function
[map_out,dst]=select_interaction_map(electrode_list,all_map,varargin)


if nargin<3
    electrode_list1=electrode_list;
    electrode_list2=electrode_list;
end

if nargin>2
    if ~isempty(varargin{1})
        electrode_list1=varargin{1};
        electrode_list2=electrode_list;
    else
        electrode_list1=electrode_list;
        electrode_list2=electrode_list;
    end

end
nc_total=numel(electrode_list1)*numel(electrode_list2);
map_out=zeros(size(all_map,1),size(all_map,2),nc_total);
dst=zeros(nc_total,1);
k=1;
for i=1:numel(electrode_list1)
    for j=1:numel(electrode_list2)
        map_out(:,:,k)=squeeze(all_map(:,:,electrode_list(i),electrode_list(
j)));
        [x1,y1]=ind2sub([8,8],electrode_list(i));
        [x2,y2]=ind2sub([8,8],electrode_list(j));

        dst(k)=norm([x1 y1]-[x2 y2]);
        k=k+1;
    end
end
