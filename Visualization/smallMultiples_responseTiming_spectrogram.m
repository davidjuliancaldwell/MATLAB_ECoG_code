function small_multiples_spectogram(signal,t,f,varargin)
%% DJC - 9-29-2017 small multiples plotting for response timing
% plot small mutliple plots - time x channels x trials


% defaults
type1 = [];
type2 = [];
average = 0;

for i=1:2:(length(varargin)-1)
    if ~ischar (varargin{i}),
        error (['Unknown type of optional parameter name (parameter' ...
            ' names must be strings).']);
    end
    % change the value of parameter
    switch lower (varargin{i})
        case 'type1'
            type1 = varargin{i+1};
        case 'type2'
            type2 = varargin{i+1};
        case 'average'
            average = varargin{i+1};
            
    end
end

%
totalFig = figure;
totalFig.Units = 'inches';
totalFig.Position = [   10.4097    3.4722   13.2708   10.4514];
CT = cbrewer('qual','Accent',8);
CT = flipud(CT);

p = numSubplots(size(signal,3));
%min_c = squeeze(min(min(min(signal))));
%max_c = squeeze(max(max(max(signal))));
minC = -10;
maxC = 10;
cmap=flipud(cbrewer('div', 'RdBu', 13));
colormap(cmap)

for idx=1:size(signal,3)
    %smplot(p(1),p(2),idx,'axis','on')
    smplot(p(1),p(2),idx,'axis','on')
    
    if ismember(idx,type1)
        surf(1e3*t,f,zeros(size(signal(:,:,idx))),'edgecolor','none');
        title([num2str(idx)],'Color',CT(3,:))
        
    elseif ismember(idx,type2)
        surf(1e3*t,f,signal(:,:,idx),'edgecolor','none');
        title([num2str(idx)],'Color',CT(2,:))
    else
        surf(1e3*t,f,signal(:,:,idx),'edgecolor','none');
        title([num2str(idx)],'color',CT(1,:))
    end
    view(0,90);
    axis tight;
    
    colormap(cmap);
    set_colormap_threshold(gcf, [-1 1], [minC maxC], [.5 .5 .5])
    
    %caxis([min_c max_c])
    axis off
    axis tight
    %xlim([-10 200])
    xlim([-200 1000])
    vline(0,'k')
    xlabel('time (ms)');
    ylabel('frequency (Hz)');
    %subtitle(['Baseline CCEPs by Channel']);
    
    %  colorbar()
    
end
%colorbar()

% obj = scalebar;
% obj.XLen = 500;              %X-Length, 10.
% obj.XUnit = 'ms';            %X-Unit, 'm'.
%  obj.YLen = 200;
%  obj.YUnit = 'Hz';
% %
% obj.Position = [-400,-400];
% obj.hTextX_Pos = [5,-50]; %move only the LABEL position
% obj.hTextY_Pos =  [-125,-40];
% % obj.hLineY(2).LineWidth = 5;
% % obj.hLineY(1).LineWidth = 5;
% obj.hLineX(2).LineWidth = 5;
% obj.hLineX(1).LineWidth = 5;
% obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'

end