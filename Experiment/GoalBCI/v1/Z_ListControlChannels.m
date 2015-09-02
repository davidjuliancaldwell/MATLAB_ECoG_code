SIDS = {'d6c834', '6cc87c', 'ada1ab', '6b68ef'};

for zid = SIDS
    sid = zid{:};
    
    bads = [];    
    files = goalDataFiles(sid);
    cchan = [];
    
    for file = files
        [~,~,par] = load_bcidat(file{:});
        
        if (par.SpatialFilterType.NumericValue ~= 3)
            error('CAR not used');
        end
        
        activeChannelIndex = par.SpatialFilterCAROutput.NumericValue;
        activeChannels = par.TransmitChList.NumericValue;
        activeChannel = activeChannels(activeChannelIndex);
        
        if (length(activeChannel) > 1)
            warning('more than one active channel, keeping first');
            activeChannel = activeChannel(1);
        end
        if (length(activeChannel) < 1)
            error('no active channels.');
        end
        
        if (isempty(cchan))
            cchan = activeChannel;
        elseif (cchan ~= activeChannel)
            warning('active channel (%d) was different than previous (%d)', activeChannel, cchan);
        end        
    end
    
    fprintf('%s\n  ', sid);
    fprintf('%d ', bads);
    fprintf('cchan: %d', cchan);
    fprintf('\n\n');
end