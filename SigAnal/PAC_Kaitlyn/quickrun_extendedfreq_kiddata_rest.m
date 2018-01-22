[avg_10_20] = compute_pac_amp_allchannels(sig,4:30,10:20,fs);

[avg_21_30] = compute_pac_amp_allchannels(sig,4:30,21:40,fs);

[avg_31_40] = compute_pac_amp_allchannels(sig,4:30,31:40,fs);

[avg_41_50] = compute_pac_amp_allchannels(sig,4:30,41:50,fs);

[avg_51_60] = compute_pac_amp_allchannels(sig,4:30,51:60,fs);

[avg_61_70] = compute_pac_amp_allchannels(sig,4:30,61:70,fs);

[avg_71_80] = compute_pac_amp_allchannels(sig,4:30,71:80,fs);

[avg_81_90] = compute_pac_amp_allchannels(sig,4:30,81:90,fs);

[avg_91_100] = compute_pac_amp_allchannels(sig,4:30,91:100,fs);

mapall_extended = cat(4, avg_10_20, avg_21_30, avg_31_40, avg_41_50, avg_51_60, avg_61_70, avg_71_80, avg_81_90, avg_91_100);

replacement = NaN(64);
for i = 1:27;
    for j = 1:27;
        if i+3 >= j+9;
            mapall_extended(:,:, i,j) = replacement;
        end
    end
end

figure;
imagesc([4:30], [10:100], squeeze(mapall_extended(63,64,:,:))'); % numbers are channels of interst
set(gca, 'YDir', 'normal'); %because imagesc is upside down
