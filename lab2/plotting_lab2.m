%% Importing data
files = dir("lab2\data\*.csv");
metafiles = dir("lab2\metadata\*.xlsx");
lab2Data = struct;

for i = 1:length(files)
    lab2Data(i).testData = importfile(files(i).name);
end
for i = 1:length(metafiles)
    for j = 1:3
        structIndex = 3 * (i-1) + j;
        lab2Data(structIndex).metaData = importMeta(metafiles(i).name,"Sheet1",[j+1 j+1]);
    end
end

%% Loading data

load("lab2Data.mat","lab2Data")

%% Parameters

for i = 1:length(lab2Data)
    area_init = lab2Data(i).metaData.Width * lab2Data(i).metaData.Depth;

    if i == 4
        trunc = 5001;
        lab2Data(i).stress = (lab2Data(i).testData.Force(1:trunc) ./ area_init) .* 1000;
        lab2Data(i).strain = lab2Data(i).testData.Strain1(1:trunc);
        aidenData = lab2Data(i);
    else
        lab2Data(i).stress = (lab2Data(i).testData.Force ./ area_init) .* 1000;
        lab2Data(i).strain = lab2Data(i).testData.Strain1;
    end
end

width_fin = 6.1; %mm
depth_fin = 1; %mm

area_init = aidenData.metaData.Width * aidenData.metaData.Depth;
area_fin = width_fin * depth_fin;
% 
% stress = (aidenData.Force ./ area_init) .* 1000;

%% Basic Plotting

for i = 1:length(lab2Data)
    p = standardSSplot(lab2Data(i).strain,lab2Data(i).stress);
    sampleName = num2str(lab2Data(i).metaData.SampleNumber);
    hold on;
    p.DisplayName = sampleName;
end
legend;
hold off;

figure;
standardSSplot(aidenData.strain,aidenData.stress);

%% Calculations
% Young's modulus
point1 = find(aidenData.strain > .1, 1); % Picked from linear region
point2 = find(aidenData.strain > .2, 1);
deltaStress = aidenData.stress(point2) - aidenData.stress(point1);
deltaStrain = aidenData.strain(point2) - aidenData.strain(point1);
youngs = deltaStress / (deltaStrain / 100);

bottom1 = [aidenData.strain(point1) aidenData.stress(point1)];
bottom2 = [aidenData.strain(point2) aidenData.stress(point1)];
top = [aidenData.strain(point2) aidenData.stress(point2)];

% UTS
utsIndex = find(aidenData.stress == max(aidenData.stress));
utsStrain = aidenData.strain(utsIndex);
utsStress = aidenData.stress(utsIndex);

% Yield stress: .2% method
xValues = linspace(.2,2,1000);
yValues = (youngs/100) * (xValues-.2);

yieldStrain = 1.07; % Estimated from plot
yieldIndex = find(aidenData.strain >= yieldStrain, 1);
yieldStress = aidenData.stress(yieldIndex);

% Failure
deltas = diff(aidenData.stress);
failIndex = find(deltas <= -6,1); % Bound set by trial and error
failStrain = aidenData.strain(failIndex);
failStress = aidenData.stress(failIndex);

% Percent Area Reduction
aReduction = (area_fin - area_init) / area_init * 100;

% Percent elongation
lReduction = aidenData.testData.Displacement(end) / aidenData.metaData.GaugeLength * 100;

% Modulus of resilience
mResilience = yieldStress^2 / (2 * youngs);

% Toughness
dStrain = diff(aidenData.strain);
integrand = aidenData.stress(2:end) .* (dStrain/100);
toughness = sum(integrand); % Riemann sum estimation

%% Annotated plotting: entire plot, all samples

figure;
hold on;
for i = 1:length(lab2Data)
    if i ~= 4
        p = plot(lab2Data(i).strain,lab2Data(i).stress);
    else
        p = plot(aidenData.strain,aidenData.stress);
    end
    label = "Specimen " + num2str(i);
    p.DisplayName = label;
    p.LineWidth = 1.5;
end
legend;
xlabel("Strain (%)")
ylabel("Stress (MPa)")
title("Full \sigma-\epsilon Plot for All Specimens",'Interpreter','tex')
xlim([0 max(aidenData.strain)+5])
ylim([0 650])
hold off;

%% Plotting: metallic samples

figure;
hold on;
for i = 1:3
    p = plot(lab2Data(i).strain,lab2Data(i).stress);
    label = "Specimen " + num2str(i);
    p.DisplayName = label;
    p.LineWidth = 1.5;
end
legend;
xlabel("Strain (%)")
ylabel("Stress (MPa)")
title("Full \sigma-\epsilon Plot for Metallic Specimens",'Interpreter','tex')
ylim([0 650])
hold off;

%% Plotting: polymer samples

figure;
hold on;
colors = lines(6);
for i = 4:6
    p = plot(lab2Data(i).strain,lab2Data(i).stress);
    label = "Specimen " + num2str(i);
    p.DisplayName = label;
    p.LineWidth = 1.5;
    p.Color = colors(i,:);
end
legend;
xlabel("Strain (%)")
ylabel("Stress (MPa)")
title("Full \sigma-\epsilon Plot for Polymer Specimens",'Interpreter','tex')
ylim([0 40])
xlim([0 100])

xDash = [aidenData.strain(end) aidenData.strain(end)+10];
yDash = [aidenData.stress(end) aidenData.stress(end)];
plot(xDash,yDash,'Color',colors(4,:),'LineStyle',':','LineWidth',1.5,'HandleVisibility','off')

hold off;
%% Plotting: elastic region, metallic samples

figure;
hold on;
for i = 1:3
    p = plot(lab2Data(i).strain,lab2Data(i).stress);
    label = "Specimen " + num2str(i);
    p.DisplayName = label;
    p.LineWidth = 1.5;
end
legend('Location','southeast');
xlabel("Strain (%)")
ylabel("Stress (MPa)")
title("Elastic Region of the \sigma-\epsilon Plot for Metallic Specimens",'Interpreter','tex')
ylim([0 650])
xlim([0 .7])
hold off;

%% Plotting: elastic region, polymer samples

figure;
hold on;
colors = lines(6);
for i = 4:6
    p = plot(lab2Data(i).strain,lab2Data(i).stress);
    label = "Specimen " + num2str(i);
    p.DisplayName = label;
    p.LineWidth = 1.5;
    p.Color = colors(i,:);
end
legend('location', 'southeast');
xlabel("Strain (%)")
ylabel("Stress (MPa)")
title("Elastic Region of the \sigma-\epsilon Plot for Polymer Specimens",'Interpreter','tex')
ylim([0 27.5])
xlim([0 2])

hold off;