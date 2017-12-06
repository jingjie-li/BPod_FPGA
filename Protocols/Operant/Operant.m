classdef Operant < DefaultObj
    
    % This protocol is a very general protocol that can be used to train animals to associate lights or sounds with reward.
    % Written by Jingjie li, 12/2017.
    
    properties
        n_pokes
        % on this trial, how many pokes does the rat have to make before they get reward. 0 means they poke directly in the reward port. Can be a function handle, with 0 arguments, if you want to use a random number.
        % e.g. 2
        poke_list
        % should be a cell array with n_pokes cell elements.  Each cell should be a list of pokes to use for that poke.
        % e.g. {{'TopC', 'Other'} {'BotC'}}
        poke_probs
        % a cell array the same size as poke_list with the ratios you want each poke selected
        % e.g. {[9, 1]] {1}}
        % The first poke will be 9/10 times TopC and 1/10 one of the other ports, the 2nd poke will always be to BotC.
        pokes
        % After using rand to select from the list, this will describe the pokes. A cell array with size n_pokes.
        % e.g. {'TopC', 'BotC'}
        Sounds
        ITI
        output
        good_trials=0;
        trials_in_this_stage=0;
        %reminding_good_trials=0;
        %RemindingStage=nan;
        %RemindingTrial=0;
        valve_time
    end
    
    methods
        function obj = protocol_init(obj)
            fs = 44100;
            obj.Sounds.StartSound = GenerateSineWave( 2000,0.5,fs );
            obj.Sounds.HitSound = GenerateSineWave( 8,0.5,fs ).*GenerateSineWave( 2000,0.5,fs );
            obj.Sounds.MissSound = GenerateSineWave(16, .5,fs) .* rand(size(GenerateSineWave(16, .5,fs))) - 1;
            obj.stop_flag = 0;
        end
        function obj=useSettings(obj)
            obj.settings.reward=20;
            %obj.settings.stage='reward_train';
        end
        function obj=PreparNexrTrial(obj)
            obj.ITI=10;
            obj.viol=0;
            obj.RT=0;
            switch obj.settings.stage{1}
                case 'reward_train'
                    obj.pokes = {'BotC'};
                case 'single_poke'
                    obj.pokes = pick_with_prob({'MidC','TopC'},[1, 1]);
                case 'double_poke'
                    obj.pokes = pick_with_prob({'MidC','TopC'},[1, 1]);
            end
        end
        function obj=RunTrial(obj)
            fs = 44100;
            global s
            %fprintf('RunTrial\n')
            event.timeout=[];
            event.preinit=[];
            %target_port = 'MidC';
            state = 'pre_init';
            obj.hit=0;
            trial_stop=0;
            %stage=obj.saveload.stage;
            while ~trial_stop && ~obj.stop_flag
                switch state
                    case 'pre_init'
                        %fprintf('pre_init State\n')
                        fwrite(s,bin2dec('00000000'));
                        %pause(0.1);
                        tic;
                        obj.stop_flag=0;
                        action=0;
                        while toc<2 && ~obj.stop_flag && action==0
                            flushinput(s)
                            action = fread(s, 1);
                            if action >100
                                obj.stop_flag=1;
                                break;
                            end
                        end
                        if action~=0 && ~obj.stop_flag
                            state = 'pre_init';
                        elseif ~obj.stop_flag
                            switch obj.settings.stage{1}
                                case 'reward_train'
                                    state = 'pre_reward_state';
                                case 'single_poke'
                                    state = 'wait_for_poke';
                            end
                            sound(obj.Sounds.StartSound,fs);
                        else
                            state = 'end_state';
                        end
                    case 'wait_for_poke'
                        obj.peh.wait_for_poke=[];
                        obj.peh.wait_for_poke=[obj.peh.wait_for_poke;now,nan];
                        %fprintf('Wait_for_Poke State\n')
                        if strcmp(obj.pokes,'MidC')
                            fwrite(s,bin2dec('00110000')); %turn MidC light on
                        elseif strcmp(obj.pokes,'TopC')
                            fwrite(s,bin2dec('11000000')); %turn TopC light on
                        else
                            fwrite(s,bin2dec('00001000')); %turn BotC light on
                        end
                        tic;
                        action = 0;
                        if strcmp(obj.pokes,'MidC')
                            tar_num = 2;
                        elseif strcmp(obj.pokes,'TopC')
                            tar_num = 4;
                        else
                            tar_num = 1;
                        end
                        while toc<30 && action~=tar_num && ~obj.stop_flag
                            flushinput(s)
                            action = fread(s, 1);
                            pause(0.02);
                            if action>100
                                obj.stop_flag = 1;
                            end
                        end
                        if action==tar_num
                            state = 'pre_reward_state';
                        elseif toc>29
                            state = 'timeout';
                        else
                            state = 'end_state';
                        end
                        obj.peh.wait_for_poke(end,end)=now;
                    case 'pre_reward_state'
                        %fprintf('Pre_Reward_State\n')
                        obj.peh.pre_reward_state=[];
                        obj.peh.pre_reward_state=[obj.peh.pre_reward_state;now,nan];
                        fwrite(s,bin2dec('00001000')); %turn BotC light on
                        sound(obj.Sounds.HitSound,fs);
                        tic;
                        action = 0;
                        while toc<30 && action~=1 && ~obj.stop_flag
                            flushinput(s)
                            action = fread(s, 1);
                            pause(0.02);
                            if action>100
                                obj.stop_flag = 1;
                            end
                        end
                        if action==1
                            state = 'reward_state';
                        elseif toc>29
                        else
                            state = 'end_state';
                        end
                        obj.peh.pre_reward_state(end,end)=now;
                    case 'reward_state'
                        %fprintf('Reward State\n')
                        fwrite(s,bin2dec('00001000')); %turn BotC light on
                        reward_time=now;
                        tic;
                        action = 0;
                        reward_stop=0;
                        while toc<30 && ~obj.stop_flag && ~reward_stop
                            flushinput(s)
                            action = fread(s, 1);
                            pause(0.02);
                            if isempty(action)
                                action=0;
                            end
                            if action>100
                                obj.stop_flag = 1;
                            elseif action==1
                                if (now-reward_time)*24*60*60<1
                                    fwrite(s,bin2dec('00000100')); %turn water on
                                else
                                    obj.hit=1;
                                    fwrite(s,bin2dec('00000000')); %turn water off
                                end
                            elseif action==0
                                if obj.hit
                                    reward_stop=1;
                                    %fprintf('now go to ITI State\n')
                                else
                                    fwrite(s,bin2dec('00001000')); %turn BotC light on
                                end
                            else
                                
                            end
                        end
                        if reward_stop
                            state = 'ITI';
                        end
                    case 'timeout'
                        state = 'ITI';
                        event.timeout=1;
                    case 'violation_state'
                        sound(obj.Sounds.MissSound,fs);
                        obj.viol=1;
                        state = 'ITI';
                        tic;
                        while toc<5 && ~obj.stop_flag
                            flushinput(s);
                            action = fread(s, 1);
                            if action>100
                                obj.stop_flag=1;
                            end
                        end
                        %fprintf('Re-enterning ITI\n')
                    case 'ITI'
                        fwrite(s,bin2dec('00000000'));
                        ITI_duration=obj.ITI;
                        tic;
                        while toc<ITI_duration && ~strcmp(state,'violation_state') && ~obj.stop_flag
                            flushinput(s);
                            action = fread(s, 1);
                            if isempty(action)
                                action=0;
                            end
                            if (action~=0 && action < 10)
                                state = 'violation_state';
                                %fprintf('Violation State\n')
                            elseif action>100
                                obj.stop_flag = 1;
                                break;
                            end
                        end
                        if ~obj.stop_flag && ~strcmp(state,'violation_state')
                            state = 'end_state';
                            %elseif ~strcmp(state,'violation_state')
                            %state = 'end_state';
                        end
                    case 'end_state'
                        trial_stop=1;
                        fwrite(s,bin2dec('00000011'));
                end
            end
            fwrite(s,bin2dec('00000011'));
        end
        function obj=TrialComplete(obj)
            if obj.hit
                obj.good_trials=obj.good_trials+1;
                obj.reward=1;
                obj.RT=(obj.peh.wait_for_poke(end,2)-obj.peh.wait_for_poke(end,2))*24*60*60;
            else
                obj.reward=0;
                obj.RT=nan;
            end
            obj.trials_in_this_stage = obj.trials_in_this_stage+1;
            obj.hit_history = [obj.hit_history,obj.hit];
            ndt = obj.n_done_trials;
            nts = obj.trials_in_this_stage;
            if nts>30
                pref_30=mean(obj.hit_history(end-30:end));
            else
                pref_30=0.01;
            end
            fprintf('Trials: %d, Stage: %d, GootTrials: %d Hit: %d, Perfmance: %.4f \n',ndt+1,obj.saveload.stage,obj.good_trials,obj.hit,pref_30)
            switch obj.settings.stage{1}
                case 'reward_train'
                    if pref_30>0.75
                        obj.settings.stage = 'single_poke';
                        obj.saveload.stage = obj.saveload.stage+1;
                        obj.trials_in_this_stage = 0;
                    end
                case 'single_poke'
                    if pref_30>0.75
                        obj.settings.stage = 'double_poke';
                        obj.saveload.stage = obj.saveload.stage+1;
                        obj.trials_in_this_stage = 0;
                    end
                case 'double_poke'
            end
        end
        function savedata = getProtoTrialData(obj)
            savedata.trials_in_this_stage=obj.trials_in_this_stage;
            savedata.trialtime=datestr(now,0);
            switch obj.settings.stage{1}
                case 'reward_train'
                    savedata.target_port_1='BotC';
                    savedata.target_port_2='';
                    if obj.hit
                        savedata.choice_port_1='BotC';
                    else
                        savedata.choice_port_1='';
                    end
                    savedata.choice_port_2='';
                case 'single_poke'
                    savedata.target_port_1=obj.pokes{1};
                    savedata.target_port_2='';
                    if obj.hit
                        savedata.choice_port_1=obj.pokes{1};
                    else
                        savedata.choice_port_1='';
                    end
                    savedata.choice_port_2='';
                case 'double_poke'
                    savedata.target_port_1='';
                    savedata.choice_port_1='';
                    savedata.target_port_2='';
                    savedata.choice_port_2='';
            end
        end
    end
    
end

