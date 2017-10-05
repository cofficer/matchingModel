
function plot_figSugrue1bc()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%2017-10-04. New function for plotting figures 1b and 1c.
  %%Created using Atom and tunnelling. Made by Sanders, 2014-15.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %Load example participant

  setting.numParticipants        = 29; %need to remove JRu and MGo somehow.

  %Use simulated behavior or not.
  simulate = 0;

  bhpath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/';

  setting.bhpath          = bhpath;

  %
  [ PLA,ATM ] = loadSessions(setting);

  load(PLA{25})

 
  %Code die figuur 1B&C van sugrue et al maakt
  norewards=0
  count=0;
  cumuhoridth=0;
  cumuveridth=0;
  cumuhoridpr=0;
  cumuveridpr=0;
  cumuhoridres=0;
  cumuveridres=0;

  for blks=1:length(results.blocks) %run through all blocks
    probs(results.blocks{1,blks}.trlinfo(:,2))=results.blocks{1,blks}.probHor; %puts all the probabilities in a matrix


    for num=1:length(results.blocks{1,blks}.trlinfo(:,1)) %run through the trials of each block
      count=count+1; %counts the trial ur on at the moment

      % below code generates the slope of the vertical reward and
      % horizontal reward theoretically from probabilities
      cumuhoridth=cumuhoridth+results.blocks{1,blks}.probHor;
      if results.blocks{1,blks}.trlinfo(num,3)==0 && results.blocks{1,blks}.trlinfo(num,4)>0 || results.blocks{1,blks}.trlinfo(num,3)>0 && results.blocks{1,blks}.trlinfo(num,4)>0 || results.blocks{1,blks}.trlinfo(num,3)>0 && results.blocks{1,blks}.trlinfo(num,4)==0
        horidth(count+1)=0+cumuhoridth;
      elseif results.blocks{1,blks}.trlinfo(num,3)==0 && results.blocks{1,blks}.trlinfo(num,4)==0
        horidth(count+1)=NaN
      end
      cumuveridth=cumuveridth+(1-(results.blocks{1,blks}.probHor));
      if results.blocks{1,blks}.trlinfo(num,3)==0 && results.blocks{1,blks}.trlinfo(num,4)>0 || results.blocks{1,blks}.trlinfo(num,3)>0 && results.blocks{1,blks}.trlinfo(num,4)>0 || results.blocks{1,blks}.trlinfo(num,3)>0 && results.blocks{1,blks}.trlinfo(num,4)==0
        veridth(count+1)=0+cumuveridth;
      elseif results.blocks{1,blks}.trlinfo(num,3)==0 && results.blocks{1,blks}.trlinfo(num,4)==0
        veridth(count+1)=NaN
      end

      % below code generates the slope of the vertical reward and
      % horizontal reward as it is



      if results.blocks{1,blks}.trlinfo(num,3)>0
        cumuhoridpr=cumuhoridpr+1;
        %adding a one to indicate a reward was present horizontal, for fig 1C
        %rewards(count)=1;
      end

      if results.blocks{1,blks}.trlinfo(num,4)>0
        cumuveridpr=cumuveridpr+1;
        %adding a zero to indicate a reward wasn't present horizontal, for fig 1C
        %rewards(count)=0;
      end

      if results.blocks{1,blks}.trlinfo(num,3)==0 && results.blocks{1,blks}.trlinfo(num,4)>0 || results.blocks{1,blks}.trlinfo(num,3)>0 && results.blocks{1,blks}.trlinfo(num,4)>0 || results.blocks{1,blks}.trlinfo(num,3)>0 && results.blocks{1,blks}.trlinfo(num,4)==0
        horidpr(count+1)=0+cumuhoridpr;
      elseif results.blocks{1,blks}.trlinfo(num,3)==0 && results.blocks{1,blks}.trlinfo(num,4)==0
        horidpr(count+1)=NaN
      end

      if results.blocks{1,blks}.trlinfo(num,3)==0 && results.blocks{1,blks}.trlinfo(num,4)>0 || results.blocks{1,blks}.trlinfo(num,3)>0 && results.blocks{1,blks}.trlinfo(num,4)>0 || results.blocks{1,blks}.trlinfo(num,3)>0 && results.blocks{1,blks}.trlinfo(num,4)==0
        veridpr(count+1)=0+cumuveridpr;
      elseif results.blocks{1,blks}.trlinfo(num,3)==0 && results.blocks{1,blks}.trlinfo(num,4)==0
        veridpr(count+1)=NaN;
      end

      %Making slopes (90 degrees, 45 degrees or 0 degrees of figure 1)
      if results.blocks{1,blks}.trlinfo(num,3)==0 && results.blocks{1,blks}.trlinfo(num,4)>0
        rewards(count)=1;
      end
      if results.blocks{1,blks}.trlinfo(num,3)>0 && results.blocks{1,blks}.trlinfo(num,4)>0
        rewards(count)=0.5;
      end
      if results.blocks{1,blks}.trlinfo(num,3)>0 && results.blocks{1,blks}.trlinfo(num,4)== 0
        rewards(count)=0;
      end
      if results.blocks{1,blks}.trlinfo(num,3)==0 && results.blocks{1,blks}.trlinfo(num,4)==0
        rewards(count)=NaN;
        norewards=norewards+1
      end



      % below code generates the slope of the actual responses the
      % participant made

      if results.blocks{1,blks}.trlinfo(num,7)==1
        cumuhoridres=cumuhoridres+1;
        %adding a one to indicate horizontal was chosen, for fig 1C
        responses(count)=1;
      elseif results.blocks{1,blks}.trlinfo(num,7)==2 || results.blocks{1,blks}.trlinfo(num,7)==0
        cumuveridres=cumuveridres+1;
        %adding a zero to indicate horizontal wasn't chosen, for fig 1C
        responses(count)=0;
      end
      horidres(count+1)=0+cumuhoridres;
      veridres(count+1)=0+cumuveridres;
    end
    probsres(results.blocks{1,blks}.trlinfo(:,2))=mean(responses(results.blocks{1,blks}.trlinfo(:,2)));

  end

  %plots

  figure(1);
  subplot(3,2,3:6)
  plot(horidth,veridth,'r')
  hold on
  plot(horidpr,veridpr,'k')
  plot(horidres,veridres,'b')
  legend('Theoretical Reward Ratio', 'Actual Reward Ratio','Response Ratio')
  title('Adapted figure 1b (Sugrue 2004) Dynamic matching behavior')

  %save
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/TFGitAnlysis/figures')

  %Name of figure
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);

  namefigure = sprintf('Sugrue1b-%s','NSh');

  figurename = sprintf('%s_%s.pdf',todaystr,namefigure);
  saveas(gca,figurename,'pdf')


  figure(2);

  plot(responses,'b')
  hold on
  plot(rewards,'k')
  plot(probs,'linewidth',3,'color','k')
  plot(probsres,'linewidth',3,'color','b')
  legend('Choice Ratio', 'Income Ratio', 'Average Income', 'Average Choice')

  % Smoothing with half gaussian filter
  nfilter = 9; % filter width
  gaussFilter = gausswin(nfilter);
  gaussFilter(ceil(nfilter/2)+1:end)=0; % only taking the history into account
  gaussFilter = gaussFilter / sum(gaussFilter); % normalize the filter


  smoothed_responses = conv(responses, gaussFilter); % convolve repsonse data with filter
  smoothed_responses = smoothed_responses(1:length(responses));

  smoothed_rewards = conv(rewards, gaussFilter);
  smoothed_rewards = smoothed_rewards(1:length(rewards));

  figure(3),clf
  %subplot(3,2,1:2)
  plot(smoothed_responses,'color',[0 153/255 0])
  hold on
  plot(smoothed_rewards,'k')
  plot(probs,'linewidth',3,'color','k')
  plot(probsres,'linewidth',3,'color',[0 153/255 0])
  ylim([-1 2])

  legend('Choice Ratio', 'Income Ratio', 'Average Income', 'Average Choice')
  title('Adapted figure 1c (Sugrue 2004) Instantaneous Income Ratio')



  %%Code die Figuur 2f maakt
  count2=0;
  for blks=1:length(results.blocks) %run through all blocks
    for num=1:length(results.blocks{1,blks}.trlinfo(:,1))
      count2=count2+1;
      resps(count2)=results.blocks{1,blks}.trlinfo(num,7) %puts all the responses in a matrix
    end
  end

  ini=1;
  place=0
  for times=1:(length(resps)-1)
    if resps(times) == resps(times+1) %checks whether 2 same responses in a row occur
      ini=ini+1
    elseif resps(times) ~= resps(times+1)  %ifnot, it puts the amount of responses there were in a row as result in a matrix
      place=place+1
      keer(place)=ini
      ini=1
    end
  end

  %puts the last series of responses in the same matrix
  place=place+1;
  keer(place)=ini;

  %Count the amount of times each series is made (1x, 2x, 3x etc)
  sertotal=histc(keer,1:1:30);
  serrelative=(sertotal*100)/sum(sertotal);

  %plot results
  figure(4);
  bar(serrelative,1)
  xlabel('Stay duration (choices)')
  ylabel('Relative frequency (%)')


end
