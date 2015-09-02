%%TFA first
%wins = RvS.windows;
interestingElectrode = int32(52);
wins = RHvT.windows{1}(:, interestingElectrode,:);
ts = RHvT.ts;
restLength = RHvT.restLength;
fw = [1:3:200];
fs = pr.fs;
t = ts{1};
h = figure;
ax(1) = subplot(2,1,1);

[C, ~, ~, ~] = time_frequency_wavelet(squeeze(wins(:,1,:)), fw, fs, 1, 1, 'CPUtest');
normC=normalize_plv(C',C(t>min(t)+0.2*restLength/fs & t<-0.2*restLength/fs,:)');

imagesc(t,fw,normC);
axis xy;
set_colormap_threshold(gcf, [-2 2], [-6 6], [1 1 1]);  
ylabel (colorbar, 'Wavelet Coefficient Z-score', 'FontSize', 18)
ylabel('Frequency (Hz)', 'FontSize', 18)
set (gca, 'FontSize', 14)
%vline (0.0225, 'r')
%vline (-0.1558, 'b')
hline (166, 'r--' )
% hline (22, 'b--')
hline (25, 'b--')
set(gcf, 'units', 'inches', 'pos', [0 0 9 6.5]) %sets to size of ppt slide
% turn on color bar manually on plot first
%set (gca, 'CLim', [-6,6])
% title(trodeNameFromMontage(interesting(chanIdx),Montage)); 

%% Breakdown of TFA to plot by frequency band
% use when stopped in the TFA function after normC has been calculated
%figure; plot (fw)

% at electrode 52, subject 2 passive motion
% figure; plot(t, normC(56,:))
%mtit('electrode 52, 19 and 166 Hz')
% hold all
% plot(t, normC(7,:))

% figure; plot(t, normC(6:11,:))
% figure; plot(t, normC(24:67,:))
%figure; 
ax(2) = subplot(2,1,2);
%plot(t, normC(8,:), 'b-', 'LineWidth', 2)
plot(t, normC(9,:), 'b-', 'LineWidth', 2)
% mtit('Electrode 52 at 22 and 166 Hz', 'Passive Movement', 'FontSize', 24)
ylim(int16([-5 5]))
%legend ('Beta at 22 Hz', 'High-Gamma at 166 Hz', 'FontSize', 14)
%legend('location', 'SouthWest')
%legend ('boxoff')
xlabel('Time (sec)', 'FontSize', 18)
set (gca, 'FontSize', 14)
set(gcf, 'Color',[1 1 1])% sets background color
set(gcf, 'units', 'inches', 'pos', [0 0 9 6.5]) %sets to size of ppt slide

%% next plot
hold on
plot(t, normC(56,:), 'r-', 'LineWidth' , 2) %plots frequency bin at 166 Hz
%plot(t, normC(35,:), 'r-', 'LineWidth' , 2) %plots frequency bin at 103 Hz

%vline (0.0225, 'r')
%vline (-0.1558, 'b')

%ylim(int16([-10 5]))
%legend ('Beta at 22 Hz', 'High-Gamma at 166 Hz', 'FontSize', 12)
%legend('location', 'SouthWest')
%legend ('boxoff')
% vline(0)