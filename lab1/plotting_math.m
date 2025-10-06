load("aidenData.mat","aidenData")

width_init = 12.61; %mm
depth_init = 3.08; %mm
len_init = 80.5; %mm
width_fin = 9.39; %mm
depth_fin = 1.99; %mm

area_init = width_init * depth_init;
area_fin = width_fin * depth_fin;

stress = (aidenData.Force ./ area_init) .* 1000;

%% Basic Plotting

standardSSplot(aidenData.Strain1, stress);

%% Calculations
% Young's modulus
point1 = find(aidenData.Strain1 > .175, 1);
point2 = find(aidenData.Strain1 > .25, 1);
deltaStress = stress(point2) - stress(point1);
deltaStrain = aidenData.Strain1(point2) - aidenData.Strain1(point1);
youngs = deltaStress / (deltaStrain / 100);

bottom1 = [aidenData.Strain1(point1) stress(point1)];
bottom2 = [aidenData.Strain1(point2) stress(point1)];
top = [aidenData.Strain1(point2) stress(point2)];

% UTS
utsIndex = find(stress == max(stress));
utsStrain = aidenData.Strain1(utsIndex);
utsStress = stress(utsIndex);

% Yield stress: .2% method
xValues = linspace(.2,.55,100);
yValues = (youngs/100) * (xValues-.2);

yieldStrain = .497; % Estimated from plot
yieldIndex = find(aidenData.Strain1 >= yieldStrain, 1);
yieldStress = stress(yieldIndex);

% Failure
deltas = diff(stress);
failIndex = find(deltas <= -6,1); % Bound set by trial and error
failStrain = aidenData.Strain1(failIndex);
failStress = stress(failIndex);

% Percent Area Reduction
aReduction = (area_fin - area_init) / area_init * 100;

% Percent elongation
lReduction = aidenData.Displacement(end) / len_init * 100;

% Modulus of resilience
mResilience = yieldStress^2 / (2 * youngs);

% Toughness
dStrain = diff(aidenData.Strain1);
integrand = stress(2:end) .* (dStrain/100);
toughness = sum(integrand); % Riemann sum estimation

%% Annotated plotting: entire plot

figure;
mainPlot = standardSSplot(aidenData.Strain1, stress);
mainPlot.DisplayName = 'Test Data';
hold on;

% Plotting yield stress
yieldMark = scatter(yieldStrain,yieldStress);
yieldMark.Marker = 'o';
yieldMark.MarkerFaceColor = 'green';
yieldMark.MarkerEdgeColor = 'black';
yieldMark.DisplayName = '$\sigma_{yield}$';

% Plotting UTS
utsMark = scatter(utsStrain,utsStress);
utsMark.Marker = 'o';
utsMark.MarkerFaceColor = 'yellow';
utsMark.MarkerEdgeColor = 'black';
utsMark.DisplayName = '$\sigma_{UTS}$';

% Plotting failure
failMark = scatter(failStrain,failStress);
failMark.Marker = 'o';
failMark.MarkerFaceColor = 'red';
failMark.MarkerEdgeColor = 'black';
failMark.DisplayName = '$\sigma_{fail}$';

legend('Interpreter','latex','Location','southeast')

hold off;

%% Annotated plotting: elastic region

figure;
mainPlot = standardSSplot(aidenData.Strain1, stress);
mainPlot.DisplayName = 'Test Data';
hold on;

% Plotting .2% method and yield stress
yieldEst = plot(xValues,yValues);
yieldEst.Color = 'black';
yieldEst.LineStyle = '--';
yieldEst.DisplayName = '.2\% Rule Estimation';

yieldMark = scatter(yieldStrain,yieldStress);
yieldMark.Marker = 'o';
yieldMark.MarkerFaceColor = 'green';
yieldMark.MarkerEdgeColor = 'black';
yieldMark.DisplayName = '$\sigma_{yield}$';

% Plotting youngs modulus
e = plot([bottom1(1) bottom2(1) top(1)], ...
    [bottom1(2) bottom2(2) top(2)]);
e.DisplayName = "Young's Modulus Estimation";

txt = sprintf('E = %.1f GPa \\rightarrow ',youngs/1000);
text((bottom1(1)+bottom2(1))/2,(bottom2(2)+top(2))/2, ...
    txt,'HorizontalAlignment','right')

title('Elastic Region of Stress-Strain Plot for Sample 17')
xlim([0 .75])
legend('Interpreter','latex','Location','southeast')

hold off;