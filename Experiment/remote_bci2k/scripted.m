%%

bci2kExePath = 'd:\research\code\new_bci2k\batch\';
startPath = pwd;
host = '127.0.0.1';
port = 3999;

%%
cd(bci2kExePath);
system('remote1.bat');
% eval('start Operator.exe --OnConnect "-LOAD PARAMETERFILE ..\\parms\\examples\\CursorTask_SignalGenerator.prm; SETCONFIG" --Telnet';
cd(startPath);

%%

sendCommandThroughSocket(sprintf('startup'), host, port, 20);

%%
cd(bci2kExePath);
system('remote2.bat');
% eval('start Operator.exe --OnConnect "-LOAD PARAMETERFILE ..\\parms\\examples\\CursorTask_SignalGenerator.prm; SETCONFIG" --Telnet';
cd(startPath);

%%
sendCommandThroughSocket(sprintf('start\n'), host, port, 20);