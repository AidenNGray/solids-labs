load("aidenData.mat","aidenData")

width_init = 12.61; %mm
depth_init = 3.08; %mm
width_fin = 9.39; %mm
depth_fin = 1.99; %mm

area_init = width_init * depth_init;
area_fin = width_fin * depth_fin;

stress = (aidenData.Force ./ area_init) .* 1000;

%% Basic Plotting

standardSSplot(aidenData.Strain1, stress);

%% Calculations
% Young's modulus
point1 = find(aidenData.Strain1 > .1, 1);
point2 = find(aidenData.Strain1 > .25, 1);
deltaStress = stress(point2) - stress(point1);
deltaStrain = aidenData.Strain1(point2) - aidenData.Strain1(point1);
youngs = deltaStress / deltaStrain;

% UTS
utsIndex = find(stress == max(stress));
utsStrain = aidenData.Strain1(utsIndex);
utsStress = stress(utsIndex);

% Yield stress: .2% method
xValues = linspace(.2,.4,100);
yValues = youngs * (xValues-.2);

yieldStrain = .38; % Estimated from plot
yieldIndex = find(aidenData.Strain1 >= yieldStrain, 1);
yieldStress = stress(yieldIndex);

% Failure
deltas = diff(stress);
failIndex = find(deltas <= -6,1); % Bound set by trial and error
failStrain = aidenData.Strain1(failIndex);
failStress = stress(failIndex);

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

title('Elastic Region of Stress-Strain Plot for Sample 17')
xlim([0 .75])
legend('Interpreter','latex','Location','southeast')

hold off;