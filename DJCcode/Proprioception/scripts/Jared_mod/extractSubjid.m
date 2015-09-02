%%This function extracts the subject ID from the file pathname, based on
%%the subject directory info. Orig JDW, mod JDO 8/2013. I think the reason that two
%%file separators are needed in the windows case relates to the way that
%%commands and wildcards are insterted into strings using matlab code, ie \
%%is the identifier for wildcards, etc in matlab, and also the file
%%separator in windows. / used in mac and linux is not the identifier for
%%wildcards. 



function id = extractSubjid(pathname)
    
    setupEnvironment;
    subjectDir = [myGetenv('subject_dir') filesep]; %this step adds a trailing file separator to the subject_dir path in case one is missing.
    subjectDirMod = strrep(subjectDir, [filesep, filesep], filesep); %taking out any double file separators
    pathnameMod = strrep(pathname, [filesep, filesep], filesep); %taking out any double file separators
   
    if ispc %code to run if the host machine is a PC
        id = regexpi(pathnameMod, [strrep(subjectDirMod, filesep, [filesep filesep]) '([a-zA-Z0-9]+)'], 'once', 'tokens'); % doubles ALL file separators, works on windows, not on mac...
    else %code to run if host machine is not a PC (ie mac, linux)
        id = regexpi(pathnameMod, [subjectDirMod '([a-zA-Z0-9]+)'], 'once', 'tokens'); % Works on Mac, but not on windows...not tested on Linux, but should work
    end 
    
    if (isempty(id))
        warning ('no subject id found');
    end
    
    id = id{1}; %returning only the first word from regexpi, which should be the subject ID. 
        
end



%prior iterations of code used:
%id = regexpi(pathname, [strrep(myGetenv('subject_dir'), '\', '\\') '([a-zA-Z0-9]+)'], 'once', 'tokens'); %searches for the first word in the file path that follows the subj directory string. file separators are for windows?
%id = regexpi(pathname, [strrep(subjectDir, filesep, doubleSep) '([a-zA-Z0-9]+)'], 'once', 'tokens'); %searches for the first word in the file path that follows the subj directory string. file separators are for windows?
%pathname = strrep(pathname, '\\', '\');
%id = regexp(pathname, [myGetenv('subject_dir') '(a-zA-Z0-9)'], 'once', 'tokens');