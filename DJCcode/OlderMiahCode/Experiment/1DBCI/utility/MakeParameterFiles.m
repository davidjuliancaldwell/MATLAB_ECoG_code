%% this script generates parameter files if they don't already exist
clear;
fig_setup;

num = 5;

subjid = subjids{num};
id = ids{num};
% clear num;

[files, side, div] = getBCIFilesForSubjid(subjid);

fprintf('running analysis for %s\n', subjid);

for c = 1:length(files)
    
    fprintf('  processing file %d\n', c);

    file = files{c};
    [~, states, parameters] = load_bcidat(file);
    
    parameters.WindowLeft.NumericValue = 0;
    partext = convert_bciprm(parameters);
    
    ofile = strrep(file, '.dat', '.prm');
    fprintf('  writing %s\n', ofile);
    
    if (exist(ofile, 'file'))
        delete(ofile);
    end

    fhandle = fopen(ofile, 'w');

% Source:Playback:FilePlaybackADC string PlaybackFileName=
% D:/research/subjects/mg/day2/mg_ud_im_t001/mg_ud_im_tS001R01.dat // the path to the existing BCI2000 data file (inputfile)
% Source:Playback:FilePlaybackADC int PlaybackStartTime= 0s 0s % % // the start time of the file
% Source:Playback:FilePlaybackADC list PlaybackChList= 0 // a list of channels to acquire (empty for all). Use indices, or labels from the ChannelNames as they were recorded in the file.
% Source:Playback:FilePlaybackADC float PlaybackSpeed= 1 1 0 100 // a value indicating the factor by which the acquisition should be sped up
% Source:Playback:FilePlaybackADC int PlaybackStates= 1 0 0 1 // play back state variable values (except timestamps)? (boolean)
% Source:Playback:FilePlaybackADC int PlaybackLooped= 0 0 0 1 // loop playback at the end of the data file instead of suspending execution (boolean)
% Source:Playback:FilePlaybackADC int PlaybackReverseData= 0 0 0 1 // play the biosignal data backwards - does not affect state playback (boolean)

    partext{end+1} = sprintf('Source:Playback:FilePlaybackADC string PlaybackFileName= %s // the path to the existing BCI2000 data file (inputfile)', file);
    partext{end+1} = sprintf('Source:Playback:FilePlaybackADC int PlaybackStates= 1 0 0 1 // play back state variable values (except timestamps)? (boolean)');
    
    for c2 = 1:length(partext)
        if (~isempty(strfind(partext{c2}, 'Expressions')))
            partext{c2} = strrep(partext{c2}, 'Expressions= 1 1', 'Expressions= 1 0');
        end
        
        fprintf(fhandle, '%s\n',partext{c2});
    end
    
    fclose(fhandle);
    
end

