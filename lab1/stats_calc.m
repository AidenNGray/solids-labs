load("aidenData.mat","aidenData")

width_init = 12.61; %mm
depth_init = 3.08; %mm
width_fin = 9.39; %mm
depth_fin = 1.99; %mm

area_init = width_init * depth_init;
area_fin = width_fin * depth_fin;

stress = (aidenData.Force ./ area_init) .* 1000;

%% Percent Area Reduction

aReduction = (area_fin - area_init) / area_init * 100;