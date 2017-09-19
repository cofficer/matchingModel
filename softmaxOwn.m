
function [output]=softmaxOwn(input,beta)
%%
%Softmax decision rule instead of matching law.
%Input the difference value based on the two local incomes.
% % %Output the


%%
%Plot the simulated softmax
plotsim = 0;
if plotsim == 1
  betas= [0.2];%[0.05,0.1,0.3,0.6,1,2];
  for ibeta=1:length(betas)
    beta=betas(ibeta);
    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
    h = figure(1),clf; %set(h,'position',[10 60 400 400 ],'Color','w');
    hold on; %box off;
    sofarB='';
    legendAll{ibeta}=num2str(beta);
    xval=linspace(0,1,100);
    %xval=rand(1,1000);
    %xval2=rand(1,1000);
    %  %
    % %output=1/(1+exp(-(input)*beta));
    % %
    % %

    for i =1:100
      x(i)=xval(i)-(1-xval(i));
      y(i)=exp(xval(i)/beta)/sum([exp((xval(i))/beta),exp((1-xval(i))/beta)]);
    end

    plot(x,y,'k')

    xlabel('Input value difference')
    ylabel('Output probability of choice')
    title('Softmax target selection for different beta values')
    legend(legendAll)
    saveas(h,sprintf('%s_softmaxTEST2.pdf',num2str(ibeta)))

    %Try a gramm plot instead.
    figure(2),clf
    clear g
    g=gramm('x',x,'y',y);
    g.geom_line()
    %g.stat_summary()
    g.set_names('column','Origin','x','Input value difference','y','Output probability of choice');
    g.set_text_options('base_size',23)
    g.set_line_options('base_size',5)
    g.set_color_options('chroma',1)

    g.draw();

    %name files
    formatOut = 'yyyy-mm-dd';
    todaystr = datestr(now,formatOut);
    namefigure = sprintf('soft_max');%fractionTrialsRemaining
    filetype    = 'svg';
    figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
    g.export('file_name',figurename,'file_type',filetype)
    %saveas(gca,figurename,'pdf')

  end
end


%%
%Actual softmax
output = (exp(input(1)/beta))/sum([exp((input(1))/beta),exp(input(2)/beta)]);


end
