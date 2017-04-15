function scatterPlotMatching( contrast, performance, l_switch )

%Function for handling all the scatter plots for the behavior and model
%fits of matching project.

%setting.numParticipants = length(l_switch)/2;
%[ PLA,ATM ] = loadSessions(setting);

% 
% %unpack structure paramFits
% tauATMfits          = paramFits.tauATMfits;
% tauPLAfits          = paramFits.tauPLAfits;
% 
% betaATMfits         = paramFits.betaATMfits;
% betaPLAfits         = paramFits.betaPLAfits;
% 
% colormat = zeros(size(performance, 2), 3);
% 
% colormat(1:2:end,:) = repmat([0,1,0],size( colormat(1:2:end,:),1),1);
% colormat(2:2:end,:) = repmat([1,0,0],size( colormat(1:2:end,:),1),1);

switch contrast
    
    %Plot the relationship between loose-switch and performance
    case 'lose-performance'
        h=figure;clf;
        hold on;box off;
        set(h,'position',[10 60 800 800 ],'Color','w');
        
        s=scatter(performance,l_switch,'filled');
        s.MarkerEdgeColor='black';
        s.MarkerFaceColor='black';
        
        %Plot the loose switch, performance plot

        %scatter(performance,l_switch,[],colormat)%colormat)

        
        title('Relationship between lose-switch and foraging efficiency')
        
        set(gca,'fontsize',14)
        
        xlabel('Performance')
        ylabel('Lose-Switch')
        %ylim([0 12])
        
        hold on;
        for isess = 1:length(betaPLAfits)
        
            plot([performance(isess*2) performance(isess*2-1)],[l_switch(isess*2) l_switch(isess*2-1)])
        
            txt1 = PLA{isess}(1:3);
            text(performance(isess*2),l_switch(isess*2),txt1)
            
        end
        
        
        
    case 'tau-performance'
        
        %Plot the relationship between tau parameter and performance
        
        
        h=figure;clf;
        hold on;box off;
        set(h,'position',[10 60 800 800 ],'Color','w');
        
        
        %plot(performance',l_switch','o')
        
        
        %This will not be properly matched.
        for g =1:length(betaPLAfits)
            ta(g*2)=squeeze(tauATMfits(g));
            
            ta(g*2-1)=squeeze(tauPLAfits(g));
            
        end
        
        %Plot performance against tau parameter fits.
        scatter(performance,ta,[],colormat)
        hold on
        for isess = 1:length(betaPLAfits)
        
            plot([performance(isess*2) performance(isess*2-1)],[ta(isess*2) ta(isess*2-1)])
        
        end
        %Plot the loose switch, performance plot
        %scatter(performance,l_switch)
        
        %plot loose switch and tau
        %scatter(l_switch,ta)
        
        title('Relationship between tau and foraging efficiency','fontsize',20)
        
        %set(gca,'fontsize',14)
        
        xlabel('Performance')
        ylabel('Tau parameter')
        %ylim([0 12])
        
    case 'tau-lose'
        %Plot the relationship between tau parameter and loose-switch
        
        
        h=figure;clf;
        hold on;box off;
        set(h,'position',[10 60 800 800 ],'Color','w');
        
        
        %plot(performance',l_switch','o')
        
        
        %This will not be properly matched.
        for g =1:length(betaPLAfits)
            ta(g*2)=squeeze(tauATMfits(g));
            
            ta(g*2-1)=squeeze(tauPLAfits(g));
            
        end
        
        %Plot performance against tau parameter fits.
        %scatter(performance,ta)
        
        %Plot the loose switch, performance plot
        %scatter(performance,l_switch)
        
        %plot loose switch and tau
        scatter(l_switch,ta,[],colormat)
        
        title('Relationship between lose-switch and tau parameter','fontsize',20)
        
        %set(gca,'fontsize',14)
        
        xlabel('lose-switch')
        ylabel('Tau parameter')
        ylim([0 12])
        
    case 'beta-performance'
        %Plot the relationship between beta parameter and performance
        
        
        h=figure;clf;
        hold on;box off;
        set(h,'position',[10 60 800 800 ],'Color','w');
        
        
        %plot(performance',l_switch','o')
        
        
        %This will not be properly matched.
        for g =1:length(betaPLAfits)
            ta(g*2)=squeeze(betaATMfits(g));
            
            ta(g*2-1)=squeeze(betaPLAfits(g));
            
        end
        
        %Plot performance against tau parameter fits.
        scatter(performance,ta,[],colormat)
        
        %Plot the loose switch, performance plot
        %scatter(performance,l_switch)
        
        %plot loose switch and tau
        %scatter(l_switch,ta)
        
        title('Relationship between beta and foraging efficiency','fontsize',20)
        
        %set(gca,'fontsize',14)
        
        xlabel('Performance')
        ylabel('Beta parameter')
       % ylim([0 1])
        
        
    case 'beta-lose'
        %Plot the relationship between beta parameter and loose-switch
        
        
        h=figure;clf;
        hold on;box off;
        set(h,'position',[10 60 800 800 ],'Color','w');
        
        
        %plot(performance',l_switch','o')
        
        
        %This will not be properly matched.
        for g =1:length(betaPLAfits)
            ta(g*2)=squeeze(betaATMfits(g));
            
            ta(g*2-1)=squeeze(betaPLAfits(g));
            
        end
        
        %Plot performance against tau parameter fits.
        %scatter(performance,ta)
        
        %Plot the loose switch, performance plot
        %scatter(performance,l_switch)
        
        %plot loose switch and tau
        scatter(l_switch,ta,[],colormat)
        
        title('Relationship between lose-switch and beta parameter','fontsize',20)
        
        %set(gca,'fontsize',14)
        
        xlabel('lose-switch')
        ylabel('Beta parameter')
        %ylim([0 1])
end
end

