function CursorTrajectories(subject,targetFiles,controlModality)
% 
%%DEBUG ONLY
% TwoTargFiles = {...
% 'C:\Research\Cache\octb09\D2\octb09_ud_mot_t001\octb09_ud_mot_tS001R02.mat',...
% 'C:\Research\Cache\octb09\D2\octb09_ud_mot_t001\octb09_ud_mot_tS001R03.mat',...
% 'C:\Research\Cache\octb09\D3\octb09_ud_mot_t001\octb09_ud_mot_tS001R01.mat',...
% 'C:\Research\Cache\octb09\D3\octb09_ud_mot_t001\octb09_ud_mot_tS001R02.mat'...
% };
% targetFiles = TwoTargFiles;
% subject = 'octb09';
% target = subject;
% controlModality = 'overt';
% % 
% addpath ../analysis
% %%global vars
% 
% tc1 = 1;
% tc2 = 2;

%% load and process files based on stimuli

% 
epochs = Get1DEpochs(targetFiles);
cursorPosY = GetSmoothedCursorPos(targetFiles,1);

NumChannels = GetNumChannels(targetFiles);
NumStimTypes = length(unique([epochs(:).TargetCode]));

%%
feedbackCursorPos = {};
for epoch=epochs
    feedbackCursorPos{epoch.IndexNumber} = cursorPosY(epoch.AbsoluteFeedbackBegin:epoch.AbsoluteFeedbackEnd,1);
end

% Unclamped position plots
fileNums = unique([epochs(:).FileNumber]);
for i=fileNums
    f = figure;
    colors = 'br';
    for tc = 1:2
        
        fileEpochs = SelectEpochs(epochs,'FileNumber',i,'TargetCode',tc);
        hold on;
        for epoch = fileEpochs
            plot(feedbackCursorPos{epoch.IndexNumber},[colors(tc) '-']);
        end
    end
    runLength = length(epochs(1).AbsoluteFeedbackBegin:epochs(1).AbsoluteFeedbackEnd);
    plot([0 runLength], [768 768],'k--');
    plot([0 runLength], [0 0],'k--');
    set(gca,'xlim',[0 runLength]);
    set(gca,'ylim',[-800 (768+800)]);
    title(sprintf('%s Unclamped Traces (Position) - %s %i',subject,controlModality,i));
    SaveFig(['Strategy\'],sprintf('%s Unclamped Traces (Position) - %s %i',subject,controlModality,i));
    close(f);
end
% 
% % Derivative Plots
% fileNums = unique([epochs(:).FileNumber]);
% for i=fileNums
%     f = figure;
%     colors = 'br';
%     for tc = 1:2
%         
%         fileEpochs = SelectEpochs(epochs,'FileNumber',i,'TargetCode',tc);
%         hold on;
%         for epoch = fileEpochs
%             plot(diff(feedbackCursorPos{epoch.IndexNumber}),[colors(tc) '-']);
%         end
%     end
%     set(gca,'ylim',[-1 1]);
%     title(sprintf('%s (Derivative) - %s %i',subject,controlModality,i));
%     SaveFig(['Learning\'],sprintf('%s Traces (Derivative) - %s %i',subject,controlModality,i));
%     close(f);
% end
