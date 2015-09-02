load (fullfile(pwd,'cache','tal-brod'));
load (fullfile(pwd,'cache','tal-hmat'));

% zero is default brain
PFC = 3;
M1S1 = -1;
PPC = 1;
PMv = 2;
PMd = -2;

areas = areas';
nareas = zeros(size(areas));
nareas(ismember(areas, [8 9 46])) = PFC;
nareas(ismember(areas, [7 40])) = PPC;

% final = zeros(size(areas));

% final = areas;
% final(areas == PFC) = PFC;
% final(areas == PPC) = PPC;
nareas(cdata == 1) = M1S1;
nareas(cdata == 3) = M1S1;
nareas(cdata == 9) = PMd;
nareas(cdata == 11) = PMv;


ctx.tri = cortex.faces;
ctx.vert = cortex.vertices;

tripatch(ctx, [], nareas);
shading interp;
% light;

load('recon_colormap');
colormap(cm);
set(gca,'CLim',[-3 3]);
view (90,0);

% lighting gouraud;
axis off;

ax(1) = gca;
