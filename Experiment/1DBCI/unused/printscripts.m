for c = 1:7
    figure(c);
    
    SaveFig('d:\research\code\output\remoteAreas\realfigs', [subjects{c} '_PrePostElectrodePower']);
    close;
end


strs = {'all','up','down'};

for c = 1:3
    figure(c);maximize;
    SaveFig('d:\research\code\output\remoteAreas\realfigs', ['tail_AllElectrodePower_' strs{c}]);
    close;
end