%% make the dataset for fc
d3base = fullfile(getSubjDir('fc9643'), 'D3');
ud_im = fullfile(d3base, 'fc9643_ud_im_t001', 'fc9643_ud_im_tS001R0');
ud_3targ = fullfile(d3base, 'fc9643_ud_3targ001', 'fc9643_ud_3targS001R0');
ud_5targ = fullfile(d3base, 'fc9643_ud_5targ001', 'fc9643_ud_5targS001R0');


files = { {[ud_im '1.dat'], [ud_im '2.dat'], [ud_im '3.dat'], [ud_im '4.dat'], [ud_im '5.dat']},...
    {[ud_3targ '1.dat'], [ud_3targ '2.dat'], [ud_3targ '3.dat']},...
    {[ud_5targ '1.dat'], [ud_5targ '2.dat'], [ud_5targ '3.dat'], [ud_5targ '4.dat'], [ud_5targ '5.dat']}};

%% let's look first at super slow hg oscillations

%% load a file
[sig, sta, par] = load_bcidat(files{1}{1});
load(strrep(files{1}{1}, '.dat', '_montage.mat'));

%% common average re-ref
sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, double(sig));

%% wavelet decompose
fw = 1:5:200;
fs = par.SamplingRate.NumericValue;

decomposedSig = zeros(size(sig,2), length(fw), size(sig,1));

for c = 1:size(sig,2)
    decomposedSig(c,:,:)=time_frequency_wavelet(sig(:,c),fw,fs,1,1,'CPUtest')';
end

%% look only at amplitude
%% whiten
%% recombine HG range
%% lowpass
%% visualize

% or instead of visualize
% downsample
% assign time values
% save and repeat

