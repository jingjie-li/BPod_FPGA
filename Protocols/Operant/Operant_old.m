function  Operant_old(s)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%% sess init
%global s
fs = 44100;
addpath('/Users/apple/Documents/MATLAB/BPOD_FPGA/InternalFunctions');
StartSound = GenerateSineWave( 2000,0.5,fs );
HitSound = GenerateSineWave( 8,0.5,fs ).*GenerateSineWave( 2000,0.5,fs );
MissSound = GenerateSineWave(16, .5,fs) .* rand(size(GenerateSineWave(16, .5,fs))) - 1;
good_trials = 0;
n_done_trials = 0;
trials_in_this_stage=0;

stage = 2;
state = 'pre_init';
flushinput(s)
stop_flag=0;
while ~stop_flag
%% preparNextTrial
    event.timeout=[];
    event.preinit=[];
    target_port = 'MidC';
%% runFSM
hit_flag=0;
switch state
    case 'pre_init'
        fprintf('pre_init State\n')
        fwrite(s,bin2dec('00000000'));
        %pause(0.1);
        tic;
        stop_flag=0;
        action=0;
        while toc<2 && ~stop_flag && action==0
            flushinput(s)
            action = fread(s, 1);
            if action >100
                stop_flag=1;
                break;
            end
        end
        if action~=0 && ~stop_flag
            state = 'pre_init';
        elseif ~stop_flag
            if stage==1
                state = 'pre_reward_state';
            elseif stage==2
                state = 'wait_for_poke';
            end
            sound(StartSound,fs);
        else
            state = 'end_state';
        end
    case 'wait_for_poke'
        fprintf('Wait_for_Poke State\n')
        if strcmp(target_port,'MidC')
            fwrite(s,bin2dec('00110000')); %turn MidC light on
        elseif strcmp(target_port,'TopC')
            fwrite(s,bin2dec('11000000')); %turn TopC light on
        else
            fwrite(s,bin2dec('00001000')); %turn BotC light on
        end
        tic;
        action = 0;
        if strcmp(target_port,'MidC')
            tar_num = 2;
        elseif strcmp(target_port,'TopC')
            tar_num = 4;
        else
            tar_num = 1;
        end
        while toc<30 && action~=tar_num && ~stop_flag
            flushinput(s)
            action = fread(s, 1);
            pause(0.02);
            if action>100
                stop_flag = 1;
            end
        end
        if action==tar_num
            state = 'pre_reward_state';
        elseif toc>29
            state = 'timeout';
        else
            state = 'end_state';
        end
    case 'pre_reward_state'
        fprintf('Pre_Reward_State\n')
        fwrite(s,bin2dec('00001000')); %turn BotC light on
        tic;
        action = 0;
        while toc<30 && action~=1 && ~stop_flag
            flushinput(s)
            action = fread(s, 1);
            pause(0.02);
            if action>100
                stop_flag = 1;
            end
        end
        if action==1
            state = 'reward_state';
        elseif toc>29
        else
            state = 'end_state';
        end
    case 'reward_state'
        fprintf('Reward State\n')
        sound(HitSound,fs);
        fwrite(s,bin2dec('00001000')); %turn BotC light on
        reward_time=now;
        tic;
        action = 0;
        reward_stop=0;
        while toc<30 && ~stop_flag && ~reward_stop
            flushinput(s)
            action = fread(s, 1);
            pause(0.02);
            if isempty(action)
                action=0;
            end
            if action>100
                stop_flag = 1;
            elseif action==1
                if (now-reward_time)*24*60*60<1
                    fwrite(s,bin2dec('00000100')); %turn water on
                else
                    hit_flag=1;
                end
            elseif action==0
                if hit_flag
                    reward_stop=1;
                    fprintf('now go to ITI State\n')
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
        sound(MissSound,fs);
        state = 'ITI';
        tic;
        while toc<5 && ~stop_flag
            flushinput(s);
            action = fread(s, 1);
            if action>100
                stop_flag=1;
            end
        end
        fprintf('Re-enterning ITI\n')
    case 'ITI'
        fwrite(s,bin2dec('00000000'));
        ITI_duration=10;
        tic;
        while toc<ITI_duration && ~strcmp(state,'violation_state') && ~stop_flag
            flushinput(s);
            action = fread(s, 1);
            if isempty(action)
                action=0;
            end
            if (action~=0 && action < 10)
                state = 'violation_state';
                fprintf('Violation State\n')
            elseif action>100
                stop_flag = 1;
                break;
            end
        end
        if ~stop_flag && ~strcmp(state,'violation_state')
            state = 'pre_init';
        elseif ~strcmp(state,'violation_state')
            state = 'end_state';
        end
    case 'end_state'
        stop_flag=1;
        fwrite(s,bin2dec('00000011'));
end
end
fwrite(s,bin2dec('00000011'));
%% trialComplete
%% dataSave
end

