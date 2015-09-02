function fullCmd = BuildDataserverCommand(cmd)

    config = GetDataServerConfig();
    
    exedir = fullfile(myGetenv('matlab_devel_dir'), 'Visualization', 'Recon');
    configdir = fullfile(myGetenv('matlab_devel_dir'), 'Experiment');
    
    plinkpath = fullfile(exedir, 'plink.exe');
    puttyprivpath = fullfile(configdir, config.PrivateKeyFile);

    plinkpathsafe = strrep(plinkpath, '\', '\\');
    puttyprivpathsafe = strrep(puttyprivpath, '\', '\\');
    
    fullCmd = sprintf([plinkpathsafe ' %s@%s -i ' puttyprivpathsafe ' "%s"'], config.DataServerLoginName, ...
        config.DataServerUrl, ...
        cmd );
end