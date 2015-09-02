% [sig, sta, par] = load_bcidatUI(pwd);
data = double(sig(:,12));
t = (0:(length(data)-1))/1200;

% raw
plot(t, data); xlim([11 21]);
axis off;
SaveFig('D:\Dropbox\documents\presentations\Supervisory Committee Meeting 4.29.14', 'raw_ex', 'eps');

% delta
plot(t, hilbAmp(data, [1 4], 1200)); xlim([11 21]);
axis off;
SaveFig('D:\Dropbox\documents\presentations\Supervisory Committee Meeting 4.29.14', 'delta_ex', 'eps');

% theta
plot(t, hilbAmp(data, [4 7], 1200)); xlim([11 21]);
axis off;
SaveFig('D:\Dropbox\documents\presentations\Supervisory Committee Meeting 4.29.14', 'theta_ex', 'eps');

% alpha
plot(t, hilbAmp(data, [8 12], 1200)); xlim([11 21]);
axis off;
SaveFig('D:\Dropbox\documents\presentations\Supervisory Committee Meeting 4.29.14', 'alpha_ex', 'eps');

% beta
plot(t, hilbAmp(data, [12 24], 1200)); xlim([11 21]);
axis off;
SaveFig('D:\Dropbox\documents\presentations\Supervisory Committee Meeting 4.29.14', 'beta_ex', 'eps');

% beta
plot(t, hilbAmp(data, [70 200], 1200)); xlim([11 21]);
axis off;
SaveFig('D:\Dropbox\documents\presentations\Supervisory Committee Meeting 4.29.14', 'gamma_ex', 'eps');
