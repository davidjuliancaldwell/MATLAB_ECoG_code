load('ArtificialDataset.mat')
data1=wavtf(:,:,class1trials); data2=wavtf(:,:,class2trials);

[p_circWW, p_POS, p_zPOS] = PhaseOpposition(data1, data2);

figure; 
% p_circWW
subplot(1,3,1); surf(wavtimes/1000+times(1),wavfreqs,-log10(p_circWW)); hold on; set(gcf,'renderer','zbuffer');
title('circWW (-log10(p-values))'); shading interp; view(0,90); axis tight;
colormap('hot'); clim = get(gca,'clim'); colorbar; set(gca,'clim',[0 clim(2)]); 
plot3([0 0],[2 50],[clim(2) clim(2)],'w--'); xlabel('time (s)'); ylabel('frequency (hz)');

% p_POS
subplot(1,3,2); surf(wavtimes/1000+times(1),wavfreqs,-log10(p_POS)); hold on; set(gcf,'renderer','zbuffer');
title('POS (-log10(p-values) from perm.)'); shading interp; view(0,90); axis tight;
colormap('hot'); clim = get(gca,'clim'); colorbar; set(gca,'clim',[0 clim(2)]); 
plot3([0 0],[2 50],[clim(2) clim(2)],'w--'); xlabel('time (s)'); ylabel('frequency (hz)');

% p_zPOS
subplot(1,3,3); surf(wavtimes/1000+times(1),wavfreqs,-log10(p_zPOS)); hold on; set(gcf,'renderer','zbuffer');
title('POS (-log10(p-values) from zscore.)'); shading interp; view(0,90); axis tight;
colormap('hot'); clim = get(gca,'clim'); colorbar; set(gca,'clim',[0 clim(2)]); 
plot3([0 0],[2 50],[clim(2) clim(2)],'w--'); xlabel('time (s)'); ylabel('frequency (hz)');