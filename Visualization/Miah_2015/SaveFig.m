function SaveFig(path,filename,filetype,opt)
% path - the path to the directory in which the generated file will be
% saved
% filename - the name of the file to be saved
% fileType - the type of file to be saved, valid options are png and eps

if(~exist('filetype','var'))
    filetype = 'png';
end

destFile = '';

if (lower(path(1)) == 'c'  || lower(path(1)) == 'd') && lower(path(2)) == ':'
    destFile = path;
else
    if path(end) ~= '/' && path(end) ~= '\'
        path(end+1) = '/';
    end
    destFile = ['c:/Tim/research/script/generated_figs/' path];
    TouchDir(destFile);
end
destFile = [destFile '/' filename '.'];

%should be in safe figure!
%setup temporary figure directory if it does not exist


% fileTypes = {'png'}; %removed jpeg for color problems, eps for speed
% fileTypes = {'eps'}; %removed jpeg for color problems, eps for speed

% title = strrep(title,' ','_');

% title = filename;

warning('off', 'MATLAB:print:adobecset:DeprecatedOption')

set(gcf,'PaperPositionMode','auto'); %generally want to do this anyway

% for fileType = fileTypes
%     fileType = fileType{:};
    if (exist('opt','var') && ~isempty(opt))
        switch (filetype)
            case 'jpg'
                print('-djpeg', '-noui','-cmyk', '-painters',[destFile filetype],opt);
            case 'png'
                print('-dpng', '-noui', '-painters',[destFile filetype],opt);
            case 'eps'
                print('-dpsc2', '-noui', '-painters',[destFile filetype],opt);
        end
    else
        switch (filetype)
            case 'jpg'
                print('-djpeg', '-noui','-cmyk', '-painters',[destFile filetype]);
            case 'png'
                print('-dpng', '-noui', '-painters',[destFile filetype]);
            case 'eps'
                print('-dpsc2', '-noui', '-painters',[destFile filetype]);            
        end
    end
% end