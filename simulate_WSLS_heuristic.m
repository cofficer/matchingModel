function [WSLS] = simulate_WSLS_heuristic(~)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Simulate the value space of input choice prob to output prob
%for different parameter values
%Created 2017-09-20
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Only shows the case where the current trial is a trial classified as
%influenced by the heuristic.

input_val = linspace(0,1,1000);
WSLS_val  = linspace(0,1,1000);

%Example case
ex_val=input_val(100);
ex_wsval=WSLS_val(100);

for


matrix_output = WSLS_val'+(1-WSLS_val')*input_val;


cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')

%plot the outputs
hf = figure(1),clf;
%set(hf,'DefaultFigureColormap',cbrewer('qual', 'YlOrBr', 400))
colormap(cbrewer('seq', 'YlOrBr', 200))
set(hf, 'Position', [0 0 500 500])
imagesc(matrix_output)
xticklabels = [0,0.5,1];
xticks = [1,500,1000];
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
yticklabels = [0,0.5,1];
yticks = [1,500,1000];
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels)
set(gca,'YDir','normal')

caxis([0 1])
colorbar
title('Simulated')
ylabel('Parameter values')
xlabel('Input choice probability')


formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = 'simulated_WSLS_heuristic';
figurefreqname = sprintf('%s_%s.eps',todaystr,namefigure);
saveas(gca,figurefreqname,'epsc')



end
