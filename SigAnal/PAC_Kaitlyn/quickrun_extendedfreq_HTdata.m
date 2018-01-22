% load('71944e_gonogo_PAC')

[hmap_all_10_20, hmap_avg_10_20] = epochs_pac(epochSignal_hand,4:30,10:20,fs);

[hmap_all_21_30, hmap_avg_21_30] = epochs_pac(epochSignal_hand,4:30,21:30,fs);

[hmap_all_31_40, hmap_avg_31_40] = epochs_pac(epochSignal_hand,4:30,31:40,fs);

[hmap_all_41_50, hmap_avg_41_50] = epochs_pac(epochSignal_hand,4:30,41:50,fs);

[hmap_all_51_60, hmap_avg_51_60] = epochs_pac(epochSignal_hand,4:30,51:60,fs);

[hmap_all_61_70, hmap_avg_61_70] = epochs_pac(epochSignal_hand,4:30,61:70,fs);

% [hmap_all_71_80, hmap_avg_71_80] = epochs_pac(epochSignal_hand,4:30,71:80,fs);
% 
% [hmap_all_81_90, hmap_avg_81_90] = epochs_pac(epochSignal_hand,4:30,81:90,fs);
% 
% [hmap_all_91_100, hmap_avg_91_100] = epochs_pac(epochSignal_hand,4:30,91:100,fs);

hand_map_extended = cat(4, hmap_avg_10_20, hmap_avg_21_30, hmap_avg_31_40, hmap_avg_41_50, hmap_avg_51_60, hmap_avg_61_70);%, hmap_avg_71_80, hmap_avg_81_90, hmap_avg_91_100);

hand_map_extended_alltrials = cat(4, hmap_all_10_20, hmap_all_21_30, hmap_all_31_40, hmap_all_41_50, hmap_all_51_60, hmap_all_61_70); %, hmap_all_71_80, hmap_all_81_90, hmap_all_91_100);

clear hmap_all_10_20 hmap_all_21_30 hmap_all_31_40 hmap_all_41_50 hmap_all_51_60 hmap_all_61_70 % hmap_all_71_80 hmap_all_81_90 hmap_all_91_100 hmap_avg_10_20 hmap_avg_21_30 hmap_avg_31_40 hmap_avg_41_50 hmap_avg_51_60 hmap_avg_61_70 hmap_avg_71_80 hmap_avg_81_90 hmap_avg_91_100

[thmap_all_10_20, thmap_avg_10_20] = epochs_pac(epochSignal_ton,4:30,10:20,fs);

[thmap_all_21_30, thmap_avg_21_30] = epochs_pac(epochSignal_ton,4:30,21:30,fs);

[thmap_all_31_40, thmap_avg_31_40] = epochs_pac(epochSignal_ton,4:30,31:40,fs);

[thmap_all_41_50, thmap_avg_41_50] = epochs_pac(epochSignal_ton,4:30,41:50,fs);

[thmap_all_51_60, thmap_avg_51_60] = epochs_pac(epochSignal_ton,4:30,51:60,fs);

[thmap_all_61_70, thmap_avg_61_70] = epochs_pac(epochSignal_ton,4:30,61:70,fs);

% [thmap_all_71_80, thmap_avg_71_80] = epochs_pac(epochSignal_ton,4:30,71:80,fs);
% 
% [thmap_all_81_90, thmap_avg_81_90] = epochs_pac(epochSignal_ton,4:30,81:90,fs);
% 
% [thmap_all_91_100, thmap_avg_91_100] = epochs_pac(epochSignal_ton,4:30,91:100,fs);

tongue_map_extended = cat(4, thmap_avg_10_20, thmap_avg_21_30, thmap_avg_31_40, thmap_avg_41_50, thmap_avg_51_60, thmap_avg_61_70); %, thmap_avg_71_80, thmap_avg_81_90, thmap_avg_91_100);

tongue_map_extended_alltrials = cat(4, thmap_all_10_20, thmap_all_21_30, thmap_all_31_40, thmap_all_41_50, thmap_all_51_60, thmap_all_61_70); %, thmap_all_71_80, thmap_all_81_90, thmap_all_91_100);

clear thmap_avg_10_20 thmap_avg_21_30 thmap_avg_31_40 thmap_avg_41_50 thmap_avg_51_60 thmap_avg_61_70 % thmap_avg_71_80 thmap_avg_81_90 thmap_avg_91_100 thmap_all_10_20 thmap_all_21_30 thmap_all_31_40 thmap_all_41_50 thmap_all_51_60 thmap_all_61_70 thmap_all_71_80 thmap_all_81_90 thmap_all_91_100

[restmap_all_10_20, restmap_avg_10_20] = epochs_pac(epochSignal_rest,4:30,10:20,fs);

[restmap_all_21_30, restmap_avg_21_30] = epochs_pac(epochSignal_rest,4:30,21:30,fs);

[restmap_all_31_40, restmap_avg_31_40] = epochs_pac(epochSignal_rest,4:30,31:40,fs);

[restmap_all_41_50, restmap_avg_41_50] = epochs_pac(epochSignal_rest,4:30,41:50,fs);

[restmap_all_51_60, restmap_avg_51_60] = epochs_pac(epochSignal_rest,4:30,51:60,fs);

[restmap_all_61_70, restmap_avg_61_70] = epochs_pac(epochSignal_rest,4:30,61:70,fs);

% [restmap_all_71_80, restmap_avg_71_80] = epochs_pac(epochSignal_rest,4:30,71:80,fs);
% 
% [restmap_all_81_90, restmap_avg_81_90] = epochs_pac(epochSignal_rest,4:30,81:90,fs);
% 
% [restmap_all_91_100, restmap_avg_91_100] = epochs_pac(epochSignal_rest,4:30,91:100,fs);

rest_map_extended = cat(4, restmap_avg_10_20, restmap_avg_21_30, restmap_avg_31_40, restmap_avg_41_50, restmap_avg_51_60, restmap_avg_61_70); %, restmap_avg_71_80, restmap_avg_81_90, restmap_avg_91_100);

rest_map_extended_alltrials = cat(4, restmap_all_10_20, restmap_all_21_30, restmap_all_31_40, restmap_all_41_50, restmap_all_51_60, restmap_all_61_70); %, restmap_all_71_80, restmap_all_81_90, restmap_all_91_100);

clear restmap_all_10_20 restmap_all_21_30 restmap_all_31_40 restmap_all_41_50 restmap_all_51_60 restmap_all_61_70 % restmap_all_71_80 restmap_all_81_90 restmap_all_91_100 restmap_avg_10_20 restmap_avg_21_30 restmap_avg_31_40 restmap_avg_41_50 restmap_avg_51_60 restmap_avg_61_70 restmap_avg_71_80 restmap_avg_81_90 restmap_avg_91_100 

% figure;
% imagesc([4:30], [10:100], squeeze(contrast_mapall(63,64,:,:))'); % numbers are channels of interst
% set(gca, 'YDir', 'normal'); %because imagesc is upside down

 save('a9952e_extendedPAC_th', '-v7.3')