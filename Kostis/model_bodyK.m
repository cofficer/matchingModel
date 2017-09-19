function [ modelChoiceP,LocalFract,choiceStreamAll,rewardStreamAll] = model_bodyK( cfg1,results,choiceStreamAll,rewardStreamAll)
%Function does almost all model related calculations. Quite complicated,%Removed output resultsComp
%perhaps unnecessarily so.
%Takenout: mean_sq resultsComp

%%

if cfg1.simulate
  %Change block number to full length of session
  Totaltrials=525;
else
  Totaltrials=length(choiceStreamAll);
end
%Totalblocks=length(results.blocks);

if strcmp(cfg1.numparameter,'3')
    modelChoiceP = zeros(Totaltrials,length(cfg1.tau),length(cfg1.beta),length(cfg1.ls));
    LocalFract   = zeros(Totaltrials,length(cfg1.tau),length(cfg1.beta),length(cfg1.ls));
else
    modelChoiceP = zeros(Totaltrials,length(cfg1.tau),length(cfg1.beta));
    LocalFract = zeros(Totaltrials,length(cfg1.tau),length(cfg1.beta));
end

%Simulation of reward stream:

if cfg1.sim_task
    parameters.trlTotal     = 10000;  % total number of trials in session
    parameters.trlPause     = 100;   % insert a break every x trials.
    parameters.blocklength  = results.parameters.blocklength; % range of number of trial before next block switch

    parameters.COD          = 0;    % COD = change-over delay: this means that there is no reward available on the forst trial after switching, to ensure mathcing behavior
    parameters.toneCounterBalance = 1; % 1: reward = high, 2: reward = low
    parameters.probabilities = [7/8, 5/6, 3/4, 1/2, 1/2, 1/4, 1/6, 1/8];

    % pre-dermine the number of trials per block, and total number of blocks
    ntrls = 0;
    while sum(ntrls)<=parameters.trlTotal
        dum = round((parameters.blocklength(2)-parameters.blocklength(1)).*rand(1)+parameters.blocklength(1));
        ntrls = [ntrls, dum];
    end
    ntrls = ntrls(2:end);
    ntrls(end) = parameters.trlTotal-sum(ntrls(1:end-1));
    nblocks = length(ntrls);

    % pre-dermine the probability ratio of rewards
    probHor = 0;
    while length(probHor)<=nblocks
        dum = parameters.probabilities(randperm(length(parameters.probabilities)));%Shuffle(parameters.probabilities);
        probHor = [probHor, dum];
    end
    probHor = probHor(2:nblocks+1);

    % some things to pre-allocate
    trlCount = 0;
    Totalblocks=nblocks;
    Totaltrials=parameters.trlTotal ;



else
    resultsComp=[]; %Just to avoid output error
    nblocks=length(results.blocks);
end

%%
%Rest.

%Pre-allocating matrices for optimality.
modelChoiceVerComp=zeros(1,Totaltrials,length(cfg1.tau));
localIncome_HorComp=zeros(1,Totaltrials,length(cfg1.tau));
localIncome_VerComp=zeros(1,Totaltrials,length(cfg1.tau));

%Append all the possible rewards from session for model simulations.
if cfg1.simulate
    %Pre define reward vectors
    Hreward = [];
    Vreward = [];
    for blocks = 1:nblocks
        if cfg1.sim_task
            [HrewardB,VrewardB]=poissonReward(0.8, probHor(blocks), ntrls(blocks), 0);
            Hreward =[Hreward HrewardB];
            Vreward =[Vreward VrewardB];
        else

            Hreward = [Hreward results.blocks{blocks}.newrewardHor];
            Vreward = [Vreward results.blocks{blocks}.newrewardVer];
        end

    end


end

%Range of beta values in grid search.
for betaValue=1:length(cfg1.beta)

    for tauer=1:length(cfg1.tau)

        for lsValue =1:length(cfg1.ls)

            %Preset variables
            Horchoice = [];
            Verchoice = [];
            startModel = false;
            k=0.5;
            l=0.5;


            if cfg1.simulate

                %Define the value-target assignments
                rewardHor = 0;
                rewardVer = 0;

            end

            %%
            %Trial iteration

            for trialAll=1:Totaltrials

                %disp(Totaltrials)
                %Simulate the first choice of the model which is random.
                if cfg1.simulate

                    if trialAll == 1
                        choiceStreamAll(trialAll) = binornd(1,0.5);
                        modelChoiceP(trialAll,tauer,betaValue,lsValue)=0.5;

                    else
                        %choiceStreamAll(trialAll) = binornd(1,modelChoiceP(trialAll,tauer,betaValue,lsValue));

                        %Define the value-target assignments
                        rewardHor = rewardHor+Hreward(trialAll-1);
                        rewardVer = rewardVer+Vreward(trialAll-1);

                        %Calulating reward histories
                        %Check horizontal choice for reward
                        if rewardHor >0 && choiceStreamAll(trialAll-1) == 0
                            Horchoice = [Horchoice,1];
                            Verchoice = [Verchoice,NaN];

                            %Reset the value-target assignment since it was
                            %collected
                            rewardHor=0;
                            %If there was a reward then store it.
                            rewardStreamAll(trialAll-1)=1;

                            %Check horizontal choice for no reward
                        elseif rewardHor == 0 && choiceStreamAll(trialAll-1) == 0
                            Horchoice = [Horchoice,0];
                            Verchoice = [Verchoice,NaN];
                            rewardStreamAll(trialAll-1)=0;
                            %Check vertical choice for reward
                        elseif rewardVer > 0 && choiceStreamAll(trialAll-1) == 1
                            Verchoice = [Verchoice,1];
                            Horchoice = [Horchoice,NaN];
                            rewardStreamAll(trialAll-1)=1;

                            %Reset the value-target assignment since it was
                            %collected
                            rewardVer=0;

                            %Check vertical choice for no reward
                        elseif rewardVer == 0 && choiceStreamAll(trialAll-1) == 1
                            Verchoice = [Verchoice,0];
                            Horchoice = [Horchoice,NaN];
                            rewardStreamAll(trialAll-1)=0;
                        end


                        leak=1-exp(-1./cfg1.tau(tauer));

                        %Equivalent difference equation
                        if isnan(Verchoice(end))
                            k=(1-leak)*k+leak*Horchoice(end);

                        else
                            l=(1-leak)*l+leak*Verchoice(end);
                        end
                        localHor=k/(k+l);
                        localVer=l/(k+l);

                        %a,b are sens checking variables, for the localFI.
                        %a(trialAll)=k;
                        %b(trialAll)=l;

                        %The probability of choice should be submitted to a lose-switch
                        %function, which captures lose-switch tendencies.
                        if strcmp(cfg1.numparameter,'3') && trialAll > 1

                            LocalFract(trialAll,tauer,betaValue,lsValue) = localVer;
                            %Compute the noise level influene on LFI
                            probChoice=softmaxOwn([localVer, localHor],cfg1.beta(betaValue));

                            if rewardStreamAll(trialAll-1) == 0 && choiceStreamAll(trialAll-1) == 0 %choice horizontal

                                lsChoice = 1;

                                probChoice = (1-cfg1.ls(lsValue)) * probChoice + cfg1.ls(lsValue) * lsChoice;

                            elseif rewardStreamAll(trialAll-1) == 0 && choiceStreamAll(trialAll-1) == 1 %choice vertical

                                lsChoice = 0;
                                probChoice = (1-cfg1.ls(lsValue)) * probChoice + cfg1.ls(lsValue) * lsChoice;

                                %win-stay
                            elseif rewardStreamAll(trialAll-1) == 1 && choiceStreamAll(trialAll-1) == 1 %choice vertical

                                lsChoice = 1;
                                probChoice = (1-cfg1.ls(lsValue)) * probChoice + cfg1.ls(lsValue) * lsChoice;

                                %win-stay
                            elseif rewardStreamAll(trialAll-1) == 1 && choiceStreamAll(trialAll-1) == 0 %choice horizontal

                                lsChoice = 0;
                                probChoice = (1-cfg1.ls(lsValue)) * probChoice + cfg1.ls(lsValue) * lsChoice;

                            end

                            %Just to store the different lose-switch choices.
                            lsChoiceAll(trialAll)=lsChoice;

                            %Store the model prediction for the next trial
                            %which the next choice is based on.
                            modelChoiceP(trialAll,tauer,betaValue,lsValue) = probChoice;%localIncome_VerComp(1,trialAll,tauer);
                            %Make the model choice
                            choiceStreamAll(trialAll) = binornd(1,modelChoiceP(trialAll,tauer,betaValue,lsValue));

                        elseif strcmp(cfg1.numparameter,'1')
                            modelChoiceP(trialAll,tauer,betaValue)=localVer/(localHor+localVer);
                            LocalFract(trialAll,tauer,betaValue,lsValue) = localVer;
                            choiceStreamAll(trialAll) = binornd(1,modelChoiceP(trialAll,tauer,betaValue));
                        elseif strcmp(cfg1.numparameter,'2')

                            localIncome_HorComp(1,trialAll-1,tauer) = localVer/(localHor+localVer);
                            LocalFract(trialAll,tauer,betaValue,lsValue) = localVer;
                            probChoice=softmaxOwn([localVer, localHor],cfg1.beta(betaValue));

                            %The probabiliy of choice per parameter pair and trial generated by the model
                            modelChoiceP(trialAll,tauer,betaValue) = probChoice;%localIncome_VerComp(1,trialAll,tauer);

                            if isnan(modelChoiceP(trialAll,tauer,betaValue))
                                aaa=1;
                            end
                            %The probability of choice should be submitted to a lose-switch
                            %function, which captures lose-switch tendencies.

                        end
                    end


                    %If the last trial, check for reward.
                    if trialAll==Totaltrials
                        rewardHor = rewardHor+Hreward(trialAll);
                        rewardVer = rewardVer+Vreward(trialAll);
                         if rewardHor >0 && choiceStreamAll(trialAll) == 0
                            rewardStreamAll(trialAll)=1;
                            %Check horizontal choice for no reward
                        elseif rewardHor == 0 && choiceStreamAll(trialAll) == 0
                            rewardStreamAll(trialAll)=0;
                            %Check vertical choice for reward
                        elseif rewardVer > 0 && choiceStreamAll(trialAll) == 1
                            rewardStreamAll(trialAll)=1;
                            %Check vertical choice for no reward
                        elseif rewardVer == 0 && choiceStreamAll(trialAll) == 1
                            rewardStreamAll(trialAll)=0;
                         end
                    end

                    %%                %Non simulated model

                else %if not simulate then use the old system for reward histories.

                    if trialAll == 1
                        %First model prediction must be random.
                        modelChoiceP(trialAll,tauer,betaValue,lsValue)=0.5;
                        LocalFract(trialAll,tauer,betaValue,lsValue) = 0.5;
                    else

                        if rewardStreamAll(trialAll-1) == 1 && choiceStreamAll(trialAll-1) == 0
                            Horchoice = [Horchoice,1];
                            Verchoice = [Verchoice,NaN];
                        elseif rewardStreamAll(trialAll-1) == 0 && choiceStreamAll(trialAll-1) == 0
                            Horchoice = [Horchoice,0];
                            Verchoice = [Verchoice,NaN];
                        elseif rewardStreamAll(trialAll-1) == 1 && choiceStreamAll(trialAll-1) == 1
                            Verchoice = [Verchoice,1];
                            Horchoice = [Horchoice,NaN];
                        elseif rewardStreamAll(trialAll-1) == 0 && choiceStreamAll(trialAll-1) == 1
                            Verchoice = [Verchoice,0];
                            Horchoice = [Horchoice,NaN];
                        end

                        leak=1-exp(-1./cfg1.tau(tauer));

                        %Equivalent difference equation
                        if isnan(Verchoice(end))
                            k=(1-leak)*k+leak*Horchoice(end);

                        else
                            l=(1-leak)*l+leak*Verchoice(end);
                        end
                        localHor=k/(k+l);
                        localVer=l/(k+l);

                        %a,b are sens checking variables, for the localFI.
                        a(trialAll)=k;
                        b(trialAll)=l;

                        if strcmp(cfg1.numparameter,'2')

                            localIncome_HorComp(1,trialAll-1,tauer) = localVer/(localHor+localVer);
                            LocalFract(trialAll,tauer,betaValue,lsValue) = localVer;
                            probChoice=softmaxOwn([localVer, localHor],cfg1.beta(betaValue));

                            %The probabiliy of choice per parameter pair and trial generated by the model
                            modelChoiceP(trialAll,tauer,betaValue) = probChoice;%localIncome_VerComp(1,trialAll,tauer);

                            if isnan(modelChoiceP(trialAll,tauer,betaValue))
                                aaa=1;
                            end
                            %The probability of choice should be submitted to a lose-switch
                            %function, which captures lose-switch tendencies.
                        elseif strcmp(cfg1.numparameter,'3') && trialAll > 1

                            %if the previous was

                            if lsValue==100
                                aa=1;
                            end


                            probChoice=softmaxOwn([localVer, localHor],cfg1.beta(betaValue));
                            LocalFract(trialAll,tauer,betaValue,lsValue) = localVer;


                            if rewardStreamAll(trialAll-1) == 0 && choiceStreamAll(trialAll-1) == 0 %choice horizontal

                                lsChoice = 1;

                                probChoice = (1-cfg1.ls(lsValue)) * probChoice + cfg1.ls(lsValue) * lsChoice;

                            elseif rewardStreamAll(trialAll-1) == 0 && choiceStreamAll(trialAll-1) == 1 %choice vertical

                                lsChoice = 0;
                                probChoice = (1-cfg1.ls(lsValue)) * probChoice + cfg1.ls(lsValue) * lsChoice;

                                %win-stay
                            elseif rewardStreamAll(trialAll-1) == 1 && choiceStreamAll(trialAll-1) == 1 %choice vertical

                                lsChoice = 1;
                                probChoice = (1-cfg1.ls(lsValue)) * probChoice + cfg1.ls(lsValue) * lsChoice;

                                %win-stay
                            elseif rewardStreamAll(trialAll-1) == 1 && choiceStreamAll(trialAll-1) == 0 %choice horizontal

                                lsChoice = 0;
                                probChoice = (1-cfg1.ls(lsValue)) * probChoice + cfg1.ls(lsValue) * lsChoice;

                            end

                            %Just to store the different lose-switch choices.
                            lsChoiceAll(trialAll)=lsChoice;

                            %The probabiliy of choice per parameter pair and trial generated by the model

                            modelChoiceP(trialAll,tauer,betaValue,lsValue) = probChoice;%localIncome_VerComp(1,trialAll,tauer);

                            %  end

                            %If only using 1 parameter model, only store the local
                            %fractional income.
                        elseif strcmp(cfg1.numparameter,'1')
                            modelChoiceP(trialAll,tauer,betaValue)=localVer/(localHor+localVer);
                            LocalFract(trialAll,tauer,betaValue,lsValue) = localVer;

                        else %parameter 3, since lose-switch is not compatible w/ t1.
                            LocalFract(trialAll,tauer,betaValue,lsValue) = localVer;

                            %this is for the first trial during the 3 parameter
                            %model.
                            localIncome_HorComp(1,trialAll,tauer) = localVer/(localHor+localVer);

                            probChoice=softmaxOwn([localVer, localHor],cfg1.beta(betaValue));

                            modelChoiceP(trialAll,tauer,betaValue) = probChoice;%localIncome_VerComp(1,trialAll,tauer);


                        end
                    end
                end


            end

            %                     %% THIS IS JUST SENSE CHECKING PLOTTING
            %                       close all;
            %                       plot(lsChoiceAll(~rewardStreamAll),'r');hold on;
            % % %
            %                       plot(choiceStreamAll(~rewardStreamAll));hold on;
            % % %                     plot(Verchoice-0.2,'r.');hold on;
            % % %                     plot(Horchoice-0.3,'k.');
            % % %                     plot(a,'k--');plot(b,'r--');
            %                       ylim([-1 2]);

            %        pause;

            %%

        end
    end
end
end
