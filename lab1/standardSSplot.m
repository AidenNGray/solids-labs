function p = standardSSplot(strain, stress)
p = plot(strain,stress);
ylabel('Stress (MPa)')
xlabel('Strain (%)')
title('Annotated Stress-Strain Plot for Sample 17')

p.LineWidth = 1.5;
p.Color = 'blue';
end