%% script to build data struct for examineTestBetaSig djc 5-16-2017
close all;clear all;clc
sid = input('what is the subject id ','s');
Z_Constants
SUB_DIR = fullfile(myGetenv('subject_dir'));

switch sid
    
    case 'd5cd55'
        tp = strcat(SUB_DIR,'\d5cd55\data\D8\d5cd55_BetaTriggeredStim');
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock('Block-49');
        
        [SMon.data(:,2), info] = tank.readWaveEvent('SMon', 2);
        
        chan = 53;
        
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d', grp+1);
        achan = chan - grp*16;
        
        [ECO4.data(:,achan), ECO1.info] = tank.readWaveEvent(ev, achan);
        
        [Wave.data(:,3), Wave.info] = tank.readWaveEvent('Wave',1);
        save('C:\Users\djcald.CSENETID\Data\ConvertedTDTfiles\d5cd55\betaStim_forBetaPhase.mat','ECO1','ECO4','Wave','SMon','-v7.3');
        
        % c91479 doesnt seem to have the data for beta, so use chunked one
    case 'c91479'
        tp = strcat(SUB_DIR,'\c91479\data\d7\c91479_BetaTriggeredStim');
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock('BetaPhase-14');
        [SMon.data(:,2), info] = tank.readWaveEvent('SMon', 2);
        
        chan = 64;
        
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d', grp+1);
        achan = chan - grp*16;
        
        [ECO4.data(:,achan), ECO1.info] = tank.readWaveEvent(ev, achan);
        
        [Wave.data(:,3), Wave.info] = tank.readWaveEvent('Blck',1);
        save('C:\Users\djcald.CSENETID\Data\ConvertedTDTfiles\c91479\betaStim_forBetaPhase.mat','ECO1','ECO4','Wave','SMon','-v7.3');
        
    case '9ab7ab'
        tp = strcat(SUB_DIR,'\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim');
        block = 'BetaPhase-3';
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock(block);
        
        [SMon.data(:,2), info] = tank.readWaveEvent('SMon', 2);
        
        chan = 51;
        
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d', grp+1);
        achan = chan - grp*16;
        
        [ECO4.data(:,achan), ECO1.info] = tank.readWaveEvent(ev, achan);
        
        [Wave.data(:,3), Wave.info] = tank.readWaveEvent('Wave',1);
        save('C:\Users\djcald.CSENETID\Data\ConvertedTDTfiles\9ab7ab\betaStim_forBetaPhase.mat','ECO1','ECO4','Wave','SMon','-v7.3');
        % 7dbdec doesnt seem to have the data for beta, so use chunked one
        
    case '7dbdec'
        tank = TTank;
        tp = strcat(SUB_DIR,'\7dbdec\data\d7\7dbdec_BetaTriggeredStim');
        
        tank.openTank(tp);
        
        
        block = 'BetaPhase-17';
        tank.selectBlock(block);
        
        [SMon.data(:,2), info] = tank.readWaveEvent('SMon', 2);
        
        chan = 4;
        
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d', grp+1);
        achan = chan - grp*16;
        
        [ECO1.data(:,achan), ECO1.info] = tank.readWaveEvent(ev, achan);
        
        [Wave.data(:,3), Wave.info] = tank.readWaveEvent('Blck',1);
        
        
        save('C:\Users\djcald.CSENETID\Data\ConvertedTDTfiles\7dbdec\betaStim_forBetaPhase.mat','ECO1','Wave','SMon','-v7.3');
    case 'ecb43e'
        tank = TTank;
        tp = strcat(SUB_DIR,'\ecb43e\data\d7\BetaStim');
        block = 'BetaPhase-3';
        tank.openTank(tp);
        
        
        tank.selectBlock(block);
        
        [SMon.data(:,2), info] = tank.readWaveEvent('SMon', 2);
        
        chan = 55;
        
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d', grp+1);
        achan = chan - grp*16;
        
        [ECO4.data(:,achan), ECO1.info] = tank.readWaveEvent(ev, achan);
        
        [Wave.data(:,3), Wave.info] = tank.readWaveEvent('Wave',3);
        figure
        plot(Wave.data(:,3))
        
        save('C:\Users\djcald.CSENETID\Data\ConvertedTDTfiles\ecb43e\betaStim_forBetaPhase.mat','ECO1','ECO4','Wave','SMon','-v7.3');
        
        
end

