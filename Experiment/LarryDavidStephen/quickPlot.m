close all;clear all;clc
Z_ConstantsLarryDavidStephen;

%sid = input('what is the SID?\n','s');

for i = 2:length(SIDS)-2
    sid = SIDS{i};
    switch(sid)
        case 'd5cd55'
            stims = [54 62];
            goods = [35 36 37 44 45 46 52 53 55 60 61 63];
            betaChan = 53;
            
            % have to set t_min and t_max for each subject
            %t_min = 0.004833;
            t_min = 0.005;
            t_max = 0.05;
            
        case 'c91479'
            betaChan = 64;
            stims = [55 56];
            %goods = [38 39 40 46 47 48 62 64];
            goods = [38 39 48 62 64];
            
            t_min = 0.005;
            t_max = 0.035;
            
        case '7dbdec'
            stims = [11 12];
            goods = [4 5 13 21 22 23];
            betaChan = 4;
            t_min = 0.005;
            t_max = 0.05;
            
        case '9ab7ab'
            betaChan = 51;
            stims = [59 60];
            goods = [42 43 50 51 52 53 57 58];
            t_min = 0.005;
            t_max = 0.0425;
            
        case '702d24'
            betaChan = 5;
            stims = [13 14];
            goods = [4 5 6 12 20 21 22];
            bads = [23 27 28 29 30 32];
            t_min = 0.005;
            t_max = 0.0425;
            
        case 'ecb43e'
            betaChan = 55;
            stims = [56 64];
            goods = [55 63 54 46 47 48];
            t_min = 0.005;
            t_max = 0.05;
            
        case '0b5a2e'
            betaChan = 31;
            stims = [22 30];
            goods = [12 13 14 15 16 21 23 31 32 39 40];
            % goods = [14 21 23 31];
            bads = [20 24 28];
            t_min = 0.005;
            t_max = 0.05;
            
        case '0b5a2ePlayback'
            betaChan = 31;
            stims = [22 30];
            goods = [12 13 14 15 16 21 23 31 32 39 40];
            bads = [20 24 28];
            t_min = 0.005;
            t_max = 0.05;
    end
    load(fullfile(META_DIR, [sid '_StimulationAndCCEPs']));
    
    chans = goods;
    figure;
    subplot_dim = length(goods);

    i = 1;
    for chan = goods
        subplot(subplot_dim,1,i)
        plot(t(t>0.005 & t<0.05),ECoGDataAverage((t>0.005 & t<0.05),chan))
        title(['Channel ',num2str(chan)])
        ylim([-200e-6 200e-6])
        i = i +1;
        
    end
    subtitle(['sid ',sid])
    
    clearvars -except SIDS i META_DIR OUTPUT_DIR
    
end