for s=4:4
        subj=sprintf('S%i',s+1);
        %direction=ddc{dc};
        [data,clist,control,fs,tr]=get_subject_data(subj,5,.5,300,4);
        load(fullfile(subj,sprintf('results_pac_norm_all.mat')))
        inn=[clist;control];
        out=1:size(data,2);out(inn)=[];
        [inn1,out1]=generate_random_cluster(8,8,numel(inn));

        [map_in,dist_in]=select_interaction_map(inn,map);
        [map_out,dist_out]=select_interaction_map(out,map);

end
