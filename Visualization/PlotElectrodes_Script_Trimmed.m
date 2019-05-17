% subject ID - there needs to be a SUBJECT_DIR
sid = '822e26';
figure
PlotCortex(sid,'b',[],1)
hold on

% this plots a subset of electrodes based on those in a montage
%PlotElectrodes(sid,{'Grid'})

% this plots all the electrodes
PlotElectrodes(sid)

