function config = GetDataServerConfig()
    files = dir([myGetenv('matlab_devel_dir') '\experiment\dataserver.mat']);

    if isempty(files) 
        config = CreateDataserverConfig();
        save([myGetenv('matlab_devel_dir') '\experiment\dataserver.mat'],'config')
    else
        load([myGetenv('matlab_devel_dir') '\experiment\dataserver.mat'],'config');
    end
end