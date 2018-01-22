% load('71944e_gonogo_PAC')

[gomap_all_10_20, gomap_avg_10_20] = epochs_pac(epochSignal_raw_go,4:30,10:20,fs);

[gomap_all_21_30, gomap_avg_21_30] = epochs_pac(epochSignal_raw_go,4:30,21:30,fs);

[gomap_all_31_40, gomap_avg_31_40] = epochs_pac(epochSignal_raw_go,4:30,31:40,fs);

[gomap_all_41_50, gomap_avg_41_50] = epochs_pac(epochSignal_raw_go,4:30,41:50,fs);

[gomap_all_51_60, gomap_avg_51_60] = epochs_pac(epochSignal_raw_go,4:30,51:60,fs);

[gomap_all_61_70, gomap_avg_61_70] = epochs_pac(epochSignal_raw_go,4:30,61:70,fs);

[gomap_all_71_80, gomap_avg_71_80] = epochs_pac(epochSignal_raw_go,4:30,71:80,fs);

[gomap_all_81_90, gomap_avg_81_90] = epochs_pac(epochSignal_raw_go,4:30,81:90,fs);

[gomap_all_91_100, gomap_avg_91_100] = epochs_pac(epochSignal_raw_go,4:30,91:100,fs);

go_mapavg_extended = cat(4, gomap_avg_10_20, gomap_avg_21_30, gomap_avg_31_40, gomap_avg_41_50, gomap_avg_51_60, gomap_avg_61_70, gomap_avg_71_80, gomap_avg_81_90, gomap_avg_91_100);

clear gomap_avg_10_20 gomap_avg_21_30 gomap_avg_31_40 gomap_avg_41_50 gomap_avg_51_60 gomap_avg_61_70 gomap_avg_71_80 gomap_avg_81_90 gomap_avg_91_100

go_mapall_extended_alltrials_A = cat(4, gomap_all_10_20, gomap_all_21_30, gomap_all_31_40);
go_mapall_extended_alltrials_B = cat(4,gomap_all_41_50, gomap_all_51_60, gomap_all_61_70);
go_mapall_extended_alltrials_C = cat(4,gomap_all_71_80, gomap_all_81_90, gomap_all_91_100);

clear gomap_all_10_20 gomap_all_21_30 gomap_all_31_40 gomap_all_41_50 gomap_all_51_60 gomap_all_61_70 gomap_all_71_80 gomap_all_81_90 gomap_all_91_100

[nogomap_all_10_20, nogomap_avg_10_20] = epochs_pac(epochSignal_raw_nogo,4:30,10:20,fs);

[nogomap_all_21_30, nogomap_avg_21_30] = epochs_pac(epochSignal_raw_nogo,4:30,21:30,fs);

[nogomap_all_31_40, nogomap_avg_31_40] = epochs_pac(epochSignal_raw_nogo,4:30,31:40,fs);

[nogomap_all_41_50, nogomap_avg_41_50] = epochs_pac(epochSignal_raw_nogo,4:30,41:50,fs);

[nogomap_all_51_60, nogomap_avg_51_60] = epochs_pac(epochSignal_raw_nogo,4:30,51:60,fs);

[nogomap_all_61_70, nogomap_avg_61_70] = epochs_pac(epochSignal_raw_nogo,4:30,61:70,fs);

[nogomap_all_71_80, nogomap_avg_71_80] = epochs_pac(epochSignal_raw_nogo,4:30,71:80,fs);

[nogomap_all_81_90, nogomap_avg_81_90] = epochs_pac(epochSignal_raw_nogo,4:30,81:90,fs);

[nogomap_all_91_100, nogomap_avg_91_100] = epochs_pac(epochSignal_raw_nogo,4:30,91:100,fs);

nogo_mapavg_extended = cat(4, nogomap_avg_10_20, nogomap_avg_21_30, nogomap_avg_31_40, nogomap_avg_41_50, nogomap_avg_51_60, nogomap_avg_61_70, nogomap_avg_71_80, nogomap_avg_81_90, nogomap_avg_91_100);

clear nogomap_avg_10_20 nogomap_avg_21_30 nogomap_avg_31_40 nogomap_avg_41_50 nogomap_avg_51_60 nogomap_avg_61_70 nogomap_avg_71_80 nogomap_avg_81_90 nogomap_avg_91_100

nogo_mapavg_extended_alltrials_A = cat(4, nogomap_all_10_20, nogomap_all_21_30, nogomap_all_31_40);
nogo_mapavg_extended_alltrials_B = cat(4, nogomap_all_41_50, nogomap_all_51_60, nogomap_all_61_70);
nogo_mapavg_extended_alltrials_C = cat(4, nogomap_all_71_80, nogomap_all_81_90, nogomap_all_91_100);

clear nogomap_all_10_20 nogomap_all_21_30 nogomap_all_31_40 nogomap_all_41_50 nogomap_all_51_60 nogomap_all_61_70 nogomap_all_71_80 nogomap_all_81_90 nogomap_all_91_100

contrast_mapall = go_mapavg_extended - nogo_mapavg_extended;

numchan = size(epochSignal_raw_nogo{1},2);

replacement = NaN(numchan);
for i = 1:27;
    for j = 1:27;
        if i+3 >= j+9;
            contrast_mapall(:,:, i,j) = replacement;
        end
    end
end

% figure;
% imagesc([4:30], [10:100], squeeze(contrast_mapall(63,64,:,:))'); % numbers are channels of interst
% set(gca, 'YDir', 'normal'); %because imagesc is upside down

save('b93bb5_extendedPAC_allepochs', 'fs', 'go_mapavg_extended', 'go_mapall_extended_alltrials_A', 'go_mapall_extended_alltrials_B','go_mapall_extended_alltrials_C', 'nogo_mapavg_extended', 'nogo_mapavg_extended_alltrials_A', 'nogo_mapavg_extended_alltrials_B','nogo_mapavg_extended_alltrials_C','epochSignal_raw_go', 'epochSignal_raw_nogo', '-v7.3')