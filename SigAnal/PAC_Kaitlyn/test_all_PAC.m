% test for specific in-vs out-of network PAC maps

load Fig6_electrodes
order=[1 3 4 2]; % reorder Kurt's order to Felix's file structure

Seed=Seed(order);
WithinGlobal=WithinGlobal(order);
WithinLocal=WithinLocal(order);
OutOFGlobal=OutOFGlobal(order);
OutOfLocal=OutOfLocal(order);
for s=1:4
        subj=sprintf('S%i',s+1);
        %direction=ddc{dc};
        [data,clist,control,fs,tr]=get_subject_data(subj,5,.5,300,4);
        load(fullfile(subj,sprintf('results_pac_norm_all.mat')))
        map=squeeze(map(:,:,Seed(s),:,:));
        nc=size(data,2);
        elsewhere=1:nc;
        elsewhere([clist;Seed(s)])=[];
        map_max=zeros(length(clist),length(elsewhere));
        map_min=map_max;
        for i=1:length(clist)
            for j=1:length(elsewhere)
                [org,pmax,pmin]=test_map_pairs(map,clist(i),elsewhere(j),0);
                map_max(i,j)=max(org(:));
                map_min(i,j)=min(org(:));
            end
        end

end
