function PlotElectrodes(subject, electrodeSubset, colors, plotNames, plotGridLines)



% subject = genPID(subject);

basedir = getSubjDir(subject);

if(~exist('colors', 'var') || isempty(colors))
    colors = [
        [1 0 0];
        [0 1 0];
        [0 0 1];
        [.5 .5 .5];
        [1 1 0];
        [1 0.5 0];
        [0 0.5 1];
        [1 0 0.5];
        [1 0.5 0.5];
        [0.5 1 0.5];
        [0.5 0.5 1];
    ];
end

if (~exist('plotNames', 'var'))
    plotNames = true;
end

% if (~exist('plotGridLines', 'var'))
%     plotGridLines = true;
% end
plotGridLines = false;

load([basedir 'trodes.mat']);

if ~exist('electrodeSubset','var')
    electrodeSubset = TrodeNames;
end

idx = 1;
for type = electrodeSubset
    % the two cases for type are: (ex.) Grid, Grid(a:b)
    % if Grid(a:b), need to change to Grid(a:b,:).
    tok = regexp(type{:}, '[A-Za-z0-9]+\((.*?)\)', 'tokens', 'once');
    if (~isempty(tok) && ~isempty(tok{:}))
        type = {strrep(type{:}, tok{:}, [tok{:} ', :'])};
    end
        
    eval(sprintf('trodes = %s;',type{:}));
        label_add(trodes,colors(idx,:),40,plotNames, plotGridLines);
%         label_add(trodes,colors(idx,:),40,plotNames, plotGridLines);
    idx = idx + 1;
end