tempgo = squeeze(go_mapall_extended_alltrials(3,61,:,:,:));
tempnogo = squeeze(nogo_mapavg_extended_alltrials(3,61,:,:,:));

Zgo = zscore(tempgo);
Znogo = zscore(tempnogo);
Zdiff = mean(Zgo, 3) - mean(Znogo, 3);


figure;

imagesc([4:30], [10:100], Zdiff' ); % numbers are channels of interst
set(gca, 'YDir', 'normal'); %because imagesc is upside down
xlabel('phase frequency')
ylabel('amplitude frequency')
colorbar;


figure;

imagesc([4:30], [10:70], mean(Zgo,3)' ); % numbers are channels of interst
set(gca, 'YDir', 'normal'); %because imagesc is upside down
xlabel('phase frequency')
ylabel('amplitude frequency')
colorbar;


figure;

imagesc([4:30], [10:70], mean(Znogo,3)' ); % numbers are channels of interst
set(gca, 'YDir', 'normal'); %because imagesc is upside down
xlabel('phase frequency')
ylabel('amplitude frequency')
colorbar;

%%
temphand = squeeze(hand_map_extended_alltrials(64,3,:,:,:));
temprest = squeeze(rest_map_extended_alltrials(64,3,:,:,:));

temphand = permute(temphand, [3 1 2]);
Zhand = zscore(temphand);
temprest = permute(temprest, [3 1 2]);
Zrest = zscore(temprest);
Zhand = permute(Zhand, [2 3 1]);
Zrest = permute(Zrest, [2 3 1]);
Zdiff = mean(Zhand, 3) - mean(Zrest, 3);


figure;

imagesc([4:30], [10:100], Zdiff); 
set(gca, 'YDir', 'normal'); %because imagesc is upside down
xlabel('phase frequency')
ylabel('amplitude frequency')
colorbar
