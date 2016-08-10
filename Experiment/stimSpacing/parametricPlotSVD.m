function [] = parametricPlotSVD(v,post_begin,post_end,fs,cycles, modes)

if length(modes)~=3
    error('you must select 3 modes to plot this in 3D');
end

if strcmp(cycles,'all')
    % look at the whole thing
    t = 0:size(v,1)-1;
    
    mode1 = v(:,modes(1));
    mode2 = v(:,modes(2));
    mode3 = v(:,modes(3));
    
end

if strcmp(cycles,'1st')
    % look at one cycle
    numSampsCycle = size(v,1)/10;
    t = linspace(post_begin,post_end,numSampsCycle);
    sampsSelect = (1:length(t));
    
    mode1 = v(sampsSelect,modes(1));
    mode2 = v(sampsSelect,modes(2));
    mode3 = v(sampsSelect,modes(3));
end


% maybe try one cycle

c = 1:numel(t);      %# colors

figure
h = surface([mode1(:), mode1(:)], [mode2(:), mode2(:)], [mode3(:), mode3(:)], ...
    [c(:), c(:)], 'EdgeColor','flat', 'FaceColor','none');
colormap( jet(numel(t)) )
xlabel(['mode ', num2str(modes(1))])
ylabel(['mode ', num2str(modes(2))])
zlabel(['mode ', num2str(modes(3))])
colorBar = colorbar;
colorBar.Label.String = 'Evolution in time';


end