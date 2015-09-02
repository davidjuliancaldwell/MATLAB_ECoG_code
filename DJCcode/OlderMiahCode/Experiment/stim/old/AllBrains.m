% all brains
outdir = fullfile(myGetenv('output_dir'), 'stim');    

for subj = 1:4
    set = {'Grid(1:64)'};
    w = zeros([1 64]);
    
    switch(subj)
        case 1
            % for 7ee6bc
            stim = [47 55];
            subjid = '7ee6bc';
            type = 'EMG';
            side = 'r';
            % end 7ee6bc
        case 2    
            % for ebffea
            stim = [38 46];
            subjid = 'ebffea';
            type = 'EMG';
            side = 'r';
            % end ebffea
        case 3    
            % for d74850
            stim = [1 9];     
            subjid = 'd74850';
            type = 'ECoG';
            side = 'l';
            set = {'Grid(1:48)'};
            w = zeros([1 48]);
            % end d74850
        case 4
            % for 3b787d
            stim = [7 8];
            subjid = '3b787d';
            type = 'ECoG';
            side = 'r';
            % end 3b787d
    end

    figure;
    w(stim) = 1;
    
    PlotDots(subjid, set, w, side, [0 1], 15, 'recon_colormap');
    title(sprintf('S%d (%s) - %s-triggered', subj, subjid, type));
    
    SaveFig(outdir, sprintf('%s-covg.png',subjid), 'png');
    close;
end
    