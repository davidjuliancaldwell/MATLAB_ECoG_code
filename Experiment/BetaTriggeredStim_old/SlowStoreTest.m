%% Constants
Z_Constants;
addpath ./scripts;

%% Load in the trigger data

sid = SIDS{5};

if (strcmp(sid, '8adc5c'))
    tp = 'd:\research\subjects\8adc5c\data\d6\8adc5c_BetaTriggeredStim';
    block = 'Block-67';
elseif (strcmp(sid, 'd5cd55'))
    tp = 'd:\research\subjects\d5cd55\data\d8\d5cd55_BetaTriggeredStim';
    block = 'Block-49';
elseif (strcmp(sid, 'c91479'))    
    tp = 'd:\research\subjects\c91479\data\d7\c91479_BetaTriggeredStim';
    block = 'BetaPhase-14';
elseif (strcmp(sid, '7dbdec'))    
    tp = 'd:\research\subjects\7dbdec\data\d7\7dbdec_BetaTriggeredStim';
    block = 'BetaPhase-17';
elseif (strcmp(sid, '9ab7ab'))    
    tp = 'd:\research\subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
    block = 'BetaPhase-3';
else
    error('unknown sid entered');
end

% Para - 8 CH, 1Hz
%  . IsArmed
%  . HP
%  . LP
%  . BetaAmp
%  . rPulseDurUS
%  . MaxRateHZ
%  . PulseAmp
%  . TrigChannel

foo = [];
for c = 1:8
    fprintf('loading channel %d of %d\n', c, 8);
    [foo(c,:), fs] = tdt_loadStream(tp, block, 'Para', c);
end
close

% slow store only stores values on samples, or possibly I'm reading it
% wrong using the stream recall functions
idxs = find(foo(6,:)~=0);
foo2 = foo(:, idxs);

%%
figure
imagesc(foo2~=0);
title('nonzero values');
colorbar;
set(gca, 'yticklabel', {'IsArmed', 'HP', 'LP', 'BetaAmp', 'rPulseDurUS', 'MaxRateHZ', 'PulseAmp', 'TrigChannel'});