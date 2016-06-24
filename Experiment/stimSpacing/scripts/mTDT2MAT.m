function mTDT2MAT(tankpath, blockname, outpath)

    tank = TTank;

    if (tank.openTank(tankpath) ~= true)
        delete(tank);
        error('could not open tank');
    end

    if (tank.selectBlock(blockname) ~= true)
        delete(tank);
        error('could not select block');
    end

    events = tank.getBlockInfo;

    eventnames = {events.name};
    eventtypes = {events.type};

    h = waitbar(0, 'loading in data from tank');

    keeps = true(size(eventnames));

    for i = 1:length(eventnames)
        waitbar((i-1) / length(eventnames), h);

        event = eventnames{i};
        type = eventtypes{i};

        switch (type)
            case 'Snip'
                % todo, possibly change, this currently treats the snips as
                % continuous waveform data and fills in the blanks with
                % zeros
                [tempdata, tempi] = tank.readWaveEvent(event);
                eval(sprintf('%s.data = tempdata;', event));
                eval(sprintf('%s.info = tempi;', event));       
            case 'Stream'            
                [tempdata, tempi] = tank.readWaveEvent(event);
                eval(sprintf('%s.data = tempdata;', event));
                eval(sprintf('%s.info = tempi;', event));       
            case 'Scalar'
                % todo, possibly change
                [tempdata, tempi] = tank.readWaveEvent(event);
                eval(sprintf('%s.data = tempdata;', event));
                eval(sprintf('%s.info = tempi;', event));       
            case 'Strobe+'
                [tempdata, tempi] = tank.readStrobeEvent(event);
                eval(sprintf('%s.data = tempdata;', event));
                eval(sprintf('%s.info = tempi;', event));                       
            otherwise
                warning('unknown type'); % todo error handling
                keeps(i) = false;
        end
    end

    close (h);
    clear tempdata tempi;

    eventnames(~keeps) = [];
    
    save(fullfile(outpath, [blockname '.mat']), '-v7.3', eventnames{:});

end