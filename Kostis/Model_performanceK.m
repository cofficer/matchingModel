
function [allMLE,choiceStreamAll,rewardStreamAll]=Model_performanceK(cfg1)
  %Main function to run for the leaky integration model.
  %Model performance should be based on X trials with block conditions identical to those
  %made by the participant.
  %Needs to become a function to be ran per participant

  orig_cfg = cfg1;

  %Load the single session of interest.
  load(cfg1.path)
  partPath = cfg1.path;

  %If im using simulated model choices.
  if orig_cfg.modelchoices && orig_cfg.recover
    choiceStreamAll=o_choiceStream;
    rewardStreamAll=o_rewardStream;
  end

  %Simulate lose-switch strategy on the same task-structure as the
  %current session of interest. Or run the model on the participants.
  if cfg1.simulateLoseSwitch

    [choiceStream,rewardStream] = simulateLoseSwitch(partPath,allSessions,cfg1.AllPart);

  elseif orig_cfg.recover
    a=1; %if Im using simulated choices and want to recover the parameters then choices are already loaded.
    clear allMLE
  else

    %Get the history of choices and rewards, 0 is horizontal and 1 is vertical
    [choiceStreamAll,rewardStreamAll] = global_matchingK(results);
    choiceStreamAll=choiceStreamAll';
    rewardStreamAll=rewardStreamAll';

  end

  %Create matrix for all choice and model predictions for number of runs.
  %Could use runs for each parameter pair.
  for irun = 1:cfg1.runs
    %disp(irun)
    %If the loaded cfg1 is overwritten, check if original did not want
    %to simulate, in that case use all the parameter space from
    %orig_cfg
    if orig_cfg.simulate
      cfg1.beta = orig_cfg.beta(irun);
      cfg1.tau  = orig_cfg.tau(irun);
      cfg1.ls   = orig_cfg.ls(irun);
      %Only intput the first choice/reward stream. It will not be
      %used anyway since I'm simulating model responses. However, the
      %output choice and reward should be only one stream this way

      if cfg1.sim_task && irun==1
        choiceStreamAll=[];
        rewardStreamAll=[];
        [modelChoiceP,LocalFract,choiceStreamC,rewardStreamC] = model_bodyK( cfg1,results,choiceStreamAll,rewardStreamAll);
      else
        [modelChoiceP,LocalFract,choiceStreamC,rewardStreamC] = model_bodyK( cfg1,results,choiceStreamAll(:,1),rewardStreamAll(:,1));

      end
      rewardStreamCAll(:,irun)=rewardStreamC;

      choiceStreamCAll(:,irun)=choiceStreamC;

      allCMLE (:,irun)= modelChoiceP;

    else
      cfg1.beta = orig_cfg.beta;
      cfg1.tau  = orig_cfg.tau;
      cfg1.ls   = orig_cfg.ls;


      %Remove lose-switch if only 2 parameters, which is tau/beta.
      if cfg1.numparameter=='2'
        cfg1.ls   =0;
      elseif cfg1.numparameter=='1'
        cfg1.ls   =0;
        cfg1.beta =0.0015; %Set to min but should not be used anyway
      end

      cfg1.simulate = 0;
      %Create dummy results variable, it is only used if simulating
      if cfg1.modelchoices
        results = [];
      end

      [modelChoiceP,choiceStreamC,rewardStreamC] = model_bodyK( cfg1,results,choiceStreamAll(:,irun)',rewardStreamAll(:,irun)');

      %Remove the unnecessay third dimension from allMLE.
      if cfg1.numparameter=='2'
        allMLE(:,:,:,irun)= modelChoiceP;
      elseif cfg1.numparameter=='1'
        allMLE(:,:,irun)= modelChoiceP;
      else
        allMLE(:,:,:,:,irun)= modelChoiceP;
      end
    end
  end

  cfg1 = orig_cfg;

if cfg1.simulate
  rewardStreamAll = rewardStreamCAll;
  choiceStreamAll = choiceStreamCAll;
  allMLE = allCMLE;
end

end
