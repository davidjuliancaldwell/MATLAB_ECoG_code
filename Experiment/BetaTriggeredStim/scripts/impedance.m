function impedance
% function impedance
%   Analysis of the galvanostatic, 2-electrode impedance spectrum
%   measurements made with the TDT IZ2 stimulator.

% parameters
block = 1; % tank data block
shunt = 1; % shunt off (0) or on (1)?
calib = 1; % calibration with known parallel RC network? (enter R and C in calibrate function below)

% extract data from tank
ttx = actxcontrol('TTank.X');
ttx.ConnectServer('Local','Me');
ttx.OpenTank('c:\tdt\openex\tnl\impedance\datatanks\datatanks','R');
ttx.SelectBlock(['Block-' num2str(block)]);
N = ttx.ReadEventsV(20000, 'ZDat', 1, 0, 0.0, 0.0, 'ALL');
freq = ttx.ParseEvV(0, N); % data (samples x blocks)
N = ttx.ReadEventsV(20000, 'ZDat', 2, 0, 0.0, 0.0, 'ALL');
Zamp = ttx.ParseEvV(0, N); % data (samples x blocks)
N = ttx.ReadEventsV(20000, 'ZDat', 3, 0, 0.0, 0.0, 'ALL');
ZampS = ttx.ParseEvV(0, N); % data (samples x blocks)
N = ttx.ReadEventsV(20000, 'ZDat', 4, 0, 0.0, 0.0, 'ALL');
Zphase = ttx.ParseEvV(0, N); % data (samples x blocks)
ttx.CloseTank
ttx.ReleaseServer

% statistics
ufreq = unique(freq);
Nfreq = length(ufreq);
uZamp = zeros(Nfreq,2);
uZampS = zeros(Nfreq,2);
uZphase = zeros(Nfreq,2);
Ncycles = zeros(Nfreq,1); 
Zphase = -1*Zphase*pi/180; % convert to radians and invert (phase lag is positive in TDT impedance program)
for i = 1:Nfreq
    ind = find(freq==ufreq(i)); 
    ind(1) = []; % remove first cycle of each frequency in sweep to deal with transition issues
    % TODO: robust statistics option?
    uZamp(i,:) = [mean(Zamp(ind)), std(Zamp(ind))];
    uZampS(i,:) = [mean(ZampS(ind)), std(ZampS(ind))];
    rho = mean(exp(sqrt(-1)*Zphase(ind))); % mean resultant vector
    uZphase(i,:) = [angle(rho)*180/pi, sqrt(-2*log(abs(rho)))];
    Ncycles(i) = length(ind);
end

% plot
figure('Name','impedance','NumberTitle','off','Units','normalized','Position',[1/4 1/8 1/2 3/4],'Color','w');
subplot(2,1,1); hold on;
if shunt, errorbar(ufreq,uZampS(:,1),uZampS(:,2),'k.'); else errorbar(ufreq,uZamp(:,1),uZamp(:,2),'k.'); end
set(gca,'Box','off','XScale','log','XLim',[min(ufreq) max(ufreq)]);
xlabel('Hz'); ylabel('k\Omega');
text(max(get(gca,'XLim')),max(get(gca,'YLim')),['N = ' num2str(median(Ncycles))],'HorizontalAlignment','right','VerticalAlignment','top');
subplot(2,1,2); hold on;
errorbar(ufreq,uZphase(:,1),uZphase(:,2),'k.'); 
set(gca,'Box','off','XScale','log','XLim',[min(ufreq) max(ufreq)]);
xlabel('Hz'); ylabel('deg');
if calib
    [Camp,Cphase] = calibrate(freq);
    subplot(2,1,1); plot(freq,Camp,'Color',[0.8 0.8 0.8]);
    subplot(2,1,2); plot(freq,Cphase,'Color',[0.8 0.8 0.8]);
end
end

function [Camp,Cphase] = calibrate(freq)
R = 15e3; % Ohms
C = 0.1e-6; % Farads
H = freqs(R,[R*C 1],2*pi*freq);
Camp = abs(H)/1e3; % kOhms
Cphase = angle(H)*180/pi; % deg
end