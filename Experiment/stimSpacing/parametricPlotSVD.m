function [] = parametricPlotSVD(v,post_begin,post_end,fs,cycles)


if strcmp(cycles,'all')
    % look at the whole thing
    t = 0:size(v,1)-1;
    
    mode1 = v(:,1);
    mode2 = v(:,2);
    mode3 = v(:,3);
    
end

if strcmp(cycles,'1st')
    % look at one cycle
    numSampsCycle = size(v,1)/10;
    t = linspace(post_begin,post_end,numSampsCycle);
    sampsSelect = (1:length(t));
    
    mode1 = v(sampsSelect,1);
    mode2 = v(sampsSelect,2);
    mode3 = v(sampsSelect,3);
end


% maybe try one cycle

c = 1:numel(t);      %# colors

figure
h = surface([mode1(:), mode1(:)], [mode2(:), mode2(:)], [mode3(:), mode3(:)], ...
    [c(:), c(:)], 'EdgeColor','flat', 'FaceColor','none');
colormap( jet(numel(t)) )
xlabel('mode 1')
ylabel('mode 2')
zlabel('mode 3')
colorBar = colorbar;
colorBar.Label.String = 'Evolution in time';


end