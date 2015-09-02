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
figure; 
plot(t, normC(56,:), 'r-')
% mtit('Electrode 52 at 22 and 166 Hz', 'Passive Movement', 'FontSize', 24)
ylim(int16([-10 5]))
legend ('High-Gamma at 166 Hz', 'FontSize', 14)
legend('location', 'SouthWest')
legend ('boxoff')
ylabel('Wavelet Coefficient Z-score', 'FontSize', 20)
xlabel('Time (sec)', 'FontSize', 20)
set (gca, 'FontSize', 18)
set(gcf, 'Color',[1 1 1])% sets background color
set(gcf, 'units', 'inches', 'pos', [0 0 9 6.5]) %sets to size of ppt slide

%% next plot
hold on
plot(t, normC(8,:), 'b-')
%ylim(int16([-10 5]))
legend ('High-Gamma at 166 Hz', 'Beta at 22 Hz', 'FontSize', 12)
legend('location', 'SouthWest')
legend ('boxoff')
% vline(0)