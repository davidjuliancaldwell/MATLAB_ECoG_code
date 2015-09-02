[odir, hemi, bads, prefix, files] = RSInTaskDataFiles('38e116', 2);


ftemp = files{1};

% d3base = fullfile(getSubjDir('fc9643'), 'data', 'D3');
% ud_im = fullfile(d3base, 'fc9643_ud_im_t001', 'fc9643_ud_im_tS001R0');
% ud_3targ = fullfile(d3base, 'fc9643_ud_3targ001', 'fc9643_ud_3targS001R0');
% ud_5targ = fullfile(d3base, 'fc9643_ud_5targ001', 'fc9643_ud_5targS001R0');
% 
% 
% files = { {[ud_im '1.dat'], [ud_im '2.dat'], [ud_im '3.dat'], [ud_im '4.dat'], [ud_im '5.dat']},...
%     {[ud_3targ '1.dat'], [ud_3targ '2.dat'], [ud_3targ '3.dat']},...
%     {[ud_5targ '1.dat'], [ud_5targ '2.dat'], [ud_5targ '3.dat'], [ud_5targ '4.dat'], [ud_5targ '5.dat']}};
% 
% ftemp = cat(2, files{1}, files{2}, files{3});

%%
for mfile = ftemp

    ofile = strrep(mfile{:}, '.dat', '_work.mat');
    
    if (exist(ofile, 'file'))
        fprintf('skipping file %s\n', mfile{:});
    else
        fprintf('working file %s\n', mfile{:});
        
%         % TEMP
%         save(strrep(mfile{:}, '.dat', '_montage.mat'), 'Montage');
        
        %% load a file
        [sig, sta, par] = load_bcidat(mfile{:});
        load(strrep(mfile{:}, '.dat', '_montage.mat'));

        %% common average re-ref
        sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, double(sig));

        %% wavelet decompose
        fw = [70:15:200];
        fw(fw==120 | fw==180) = [];
        
        fs = par.SamplingRate.NumericValue;

        decomposedSig = zeros(size(sig,2), length(fw), size(sig,1));

        h = waitbar(0, 'performing wavelet decomposition');
        for c = 1:size(sig,2)
            if (mod(c,5) == 1)
                waitbar(c/size(sig,2), h);
            end

            decomposedSig(c,:,:)=time_frequency_wavelet(sig(:,c),fw,fs,0,1,'CPUtest')';
        end
        close(h);

        %% whiten
        means = mean(decomposedSig, 3);
%         ndecomp = decomposedSig ./ repmat(means, [1, 1, size(decomposedSig, 3)]);

        for c = 1:size(decomposedSig, 3)
            decomposedSig(:,:,c) = decomposedSig(:, :, c) ./ means;
        end
        
        %% recombine HG range
        hgs = squeeze(mean(decomposedSig(:, fw > 70 & fw < 200, :), 2));

        save(ofile, 'fw', 'fs', 'hgs', 'Montage');
    end
end

return;

%% not sure works below
%% quantify change from rest to HG
starts = find(diff(double(sta.TargetCode) ~= 0) == 1);
targets = sta.TargetCode(starts);

rstarts = starts - par.ITIDuration.NumericValue * par.SamplingRate.NumericValue;
rends = starts - 1;

fstarts = starts + par.PreFeedbackDuration.NumericValue * par.SamplingRate.NumericValue;
fends = starts + (par.PreFeedbackDuration.NumericValue + par.FeedbackDuration.NumericValue) * ...
    par.SamplingRate.NumericValue;

bi = rstarts < 1 | fends > length(sta.TargetCode);

starts(bi) = [];
targets(bi) = [];
rstarts(bi) = [];
rends(bi) = [];
fstarts(bi) = [];
fends(bi) = [];

%%
shifts = zeros (size(hgs, 1), length(rstarts));

for epoch = 1:length(rstarts)
    r = rstarts(epoch):rends(epoch);
    f = fstarts(epoch):fends(epoch);
    
    shifts(:, epoch) = mean(hgs(:, f), 2) - mean(hgs(:, r), 2);
end






