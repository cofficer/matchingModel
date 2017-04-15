
function [output]=softmaxOwn(input,beta) 
%%
%Softmax decision rule instead of matching law.
%Input the difference value based on the two local incomes.
% % %Output the


%%
%Plot the simulated softmax
plotsim = 1;
if plotsim == 1
    betas= [0.05,0.1,0.3,0.6,1,2];
    for ibeta=1:length(betas)
        beta=betas(ibeta);
    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')
    h = figure(1); %set(h,'position',[10 60 400 400 ],'Color','w');
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
    
    plot(x,y)
    
    xlabel('Input value difference')
    ylabel('Output probability of choice')
    title('Softmax target selection for different beta values')
    legend(legendAll)
    saveas(h,sprintf('%s_softmax.pdf',num2str(ibeta)))
    end
end


%%
%Actual softmax
output = (exp(input(1)/beta))/sum([exp((input(1))/beta),exp(input(2)/beta)]);


end
