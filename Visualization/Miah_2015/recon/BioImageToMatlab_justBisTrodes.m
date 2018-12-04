function BioImageToMatlab_justBisTrodes(subjid)



fid = fopen(fullfile(myGetenv('subject_dir'), subjid, 'other', 'bis_trodes.txt'),'r');
line = fgetl(fid); % Gets # out of the way
line = fgetl(fid); % Gets title lines out of the way
line = fgetl(fid); % First real line

TrodeNames = {};
while line ~= -1
    c = textscan(line, '%s %s %f %f %f %f');
    trodeName = c{1}{1};
    pos = [c{3:5}];
    trodeIdx = str2double(c{2}{1}(length(trodeName)+1:end));
    if ~exist(['num' trodeName],'var')
        TrodeNames{size(TrodeNames,2)+1} = trodeName;
        eval(sprintf('num%s = 0;', trodeName));
        eval(sprintf('%s = [];', trodeName));
    end
    eval(sprintf('num%s = num%s + 1;', trodeName,trodeName));
    eval(sprintf('%s(%i,:) = [%f %f %f];', trodeName,trodeIdx,pos));
    line = fgetl(fid);
end
fclose(fid);

AllTrodes = [];
for name = TrodeNames
    name = name{1};
    eval(sprintf('AllTrodes = cat(1,AllTrodes,%s);', name));
end

cmd = ['save ' myGetenv('subject_dir') subjid '/bis_trodes.mat AllTrodes TrodeNames '];
cmd = ['save ' fullfile(myGetenv('subject_dir'), subjid, 'bis_trodes.mat') ' AllTrodes TrodeNames '];

for name = TrodeNames
    name = name{1};
    cmd = [cmd name ' '];
end

cmd = [cmd ';'];
eval(cmd);

% might need to modify x by 41 and z by 12 to directly match up with the
% SPM-created hulls, but it looks alright on the freesurfer hulls