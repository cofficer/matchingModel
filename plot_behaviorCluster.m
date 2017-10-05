%Plot behavior


%%


mean_sqAll=mean(mean_sq,3);
std_mean_sqAll = std(squeeze(mean_sq)')./sqrt(runs);

figure(3),clf
hold on
for ina=1:runs
semilogx(tau,mean_sq(1,:,ina))
title('Model fit of tau to behavioral data')
xlabel('Values of the single model parameter Tau')
ylabel('Mean squared error')
end
errorbar(tau,mean_sqAll,std_mean_sqAll, 'r', 'linewidth', 3);
set(gca, 'xscale', 'log')

%%
%Plot the average tau comparing atomoxetine and placebo. 

figure(1),clf
hold on;

%Each condition
at=squeeze(maxTauAll(:,2,:));
pl=squeeze(maxTauAll(:,1,:));

%Mean each condition
atAV=nanmean(at,2);
plAV=nanmean(pl,2);

bar([1 2],[nanmean(plAV) nanmean(atAV)]')

errorbar([1 2],[mean(plAV) mean(atAV)],[std(plAV) std(atAV)])

%barwitherr([std(atAV(1:end-1)) std(plAV)],[nanmean(atAV) nanmean(plAV)])


plot([1,2],[atAV plAV])
xlim([0.7 2.3])


%%
%Plot individually

%Struct with all the trial likelihoods calculated. 

%Placebo
plaMLE = allMLE.PLA;


tauAll=0;

tableTB     = zeros(size(plaMLE,3),size(plaMLE,2));

figure(2)

for eachBeta = 1:size(plaMLE,3)
    for eachTau = 1:size(plaMLE,2)
        for eachrun = 1:2%size(plaMLE,4)
            
            
            
            
            %Per beta and run, the product over all the different tau and
            %choosing the maximum.
            %[~,maxDis]=max(prod(plaMLE(:,eachTau,eachBeta,eachrun)));
            MLE = prod(plaMLE(:,eachTau,eachBeta,eachrun));

            tableTB(eachBeta,eachTau) = tableTB(eachBeta,eachTau)+MLE;
            
            %tauAll(eachrun,eachBeta)=tau(maxDis);
            
            %betaAll
            
        end
    end
    %tableTB(eachTau,eachBeta)=tableTB(eachTau,eachBeta)./10
end


x=linspace(2,10,20);%cfg1{1}.tau;
y=linspace(0,1,20);%cfg1{1}.beta;

imagesc(x,y,(tableTB)./20)
set(gca,'YDir','normal')
colorbar


%%
plot(prod((mean(plaMLE(:,:,10,:),4)),1),'r')

















