load("aidenData.mat")

width_init = 12.61; %mm
depth_init = 3.08; %mm
width_fin = 9.39; %mm
depth_fin = 1.99; %mm

area_init = width_init * depth_init;
area_fin = width_fin * depth_fin;

stress = (aidenData.Force ./ area_init) .* 1000;

%% Basic Plotting

p = plot(aidenData.Strain1,stress);
ylabel('Stress (MPa)')
xlabel('Strain (mm/mm)')
title('Stress-Strain Plot for Mystry Metal')

p.LineWidth = 1.5;
p.Color = 'red';

%% Calculations
point1 = find(aidenData.Strain1 > .3, 1);
point2 = find(aidenData.Strain1 > .4, 1);
deltaStress = stress(point2) - stress(point1);
deltaStrain = aidenData.Strain1(point2) - aidenData.Strain1(point1);
youngs = deltaStress / deltaStrain;

uts = max(stress);