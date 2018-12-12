function stores = tdt_listStores(tankpath, block)
% function stream = tdt_listStores(tankpath, block)
%   list the data stores in a given block
%
%   ARGUMENTS
%   tankpath (string) is the absolute path to the data tank
%   block    (string) is the name of the block
%
%   RETURNS
%   stores (string {}) list of store names
%
%   EXAMPLE USAGE
%     tp = 'd:\research\subjects\d5cd55\data\d8\d5cd55_BetaTriggeredStim';
%     block = 'Block-49';
%
%     result = tdt_listStores(tp, block);
   
    ttx = actxcontrol('TTank.X');
    ttx.ConnectServer('Local','Me');
    res = ttx.OpenTank(tankpath,'R');
    
    if (res == 0)
        ttx.ReleaseServer;
        error('unable to open tank');
    end
    
    res = ttx.SelectBlock(block);
    
    if (res == 0)
        ttx.CloseTank;
        ttx.ReleaseServer;
        error('unable to locate block');
    end
    
    % check to make sure the event exists
    notes = parseTDTNotes(ttx.CurBlockNotes);
    stores = {notes.name};
    
    ttx.CloseTank;
    ttx.ReleaseServer;    
end
