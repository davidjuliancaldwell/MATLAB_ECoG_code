function output = generateBCIFeatures(datFile, montageFile)
    TEMP_PARAMETER_DIR = './temp_parameters';
    
    if (~exist(datFile, 'file'))
        error('dat file does not exist: %s', datFile);
    end
    
    if (nargin < 2)
        [~, montageFile] = loadCorrespondingMontage(datFile);
    end
    
    if (~exist(montageFile, 'file'))
        error('montage file does not exist: %s', montageFile);
    end
    
    %% load the montage and determine the total number of channels
    load(montageFile);
    nChans = max(cumsum(Montage.Montage));
    
    %% make sure we're passing all channels through from the source module    
    [~, par] = make_bciprm(datFile, 'TransmitChList', 1:nChans);
    
    %% modify to use the appropriate CAR matrix, per the montage and the bad channels
    [~, par] = make_bciprm(par, 'SpatialFilter', generateCARMatrix(nChans, Montage.BadChannels));
    [~, par] = make_bciprm(par, 'SpatialFilterType', 1);
    
    %% modify to use the appropriate LinearClassifier matrix
    nBins = length(par.FirstBinCenter.NumericValue:par.BinWidth.NumericValue:par.LastBinCenter.NumericValue);
    [parstr, par] = make_bciprm(par, 'Classifier', generateLinearClassifierMatrixPosthoc(nChans, nBins));
    
    %% modify to use the correct normalizer parameters
    [~, par] = make_bciprm(par, 'NormalizerGains', ones(nChans, 1));
    [~, par] = make_bciprm(par, 'NormalizerOffsets', zeros(nChans, 1));
    [parstr, par] = make_bciprm(par, 'Adaptation', zeros(nChans, 1));
    
%     %% modify the expression filter
%     [parstr, par] = make_bciprm(par, 'Expressions', eye(nChans));
    
    %% write out the parameter file to a temp directory
    mkdir(TEMP_PARAMETER_DIR);
    paramFile = fullfile(TEMP_PARAMETER_DIR, 'temp.prm');    
    handle = fopen(paramFile,'w');
    fwrite(handle, parstr);
    fclose(handle);    
    
    %% re-run the processing pipeline
    output = bci2000chain(datFile, 'TransmissionFilter|SpatialFilter|ARFilter|LinearClassifier|LPFilter|Normalizer', '-2', paramFile);
%     output = bci2000chain(datFile, 'ARSignalProcessing', '-2', paramFile);

    %% delete the temp parameter file and storage directory
    delete(paramFile);
    rmdir(TEMP_PARAMETER_DIR);
    
end