function dispatch(obj,varargin)

    persistent name
    persistent sessid
    persistent saveload
    persistent stage
    persistent protocol
    persistent stop_flag
    persistent stage_name
    persistent test
    %persistent action
    
    stop_flag = 0;
    
    %% import data
    action = inputordefault('action','all',varargin);
    if strcmp(action,'all')
    test = inputordefault('test',false,varargin);
    stage = inputordefault('stage',1,varargin);
    name = inputordefault('name',1001,varargin);
    protocol = inputordefault('protocol','Operant',varargin);
    stage_name = inputordefault('stage_name','reward_train',varargin);
    end
    
    %% start the sesssion
    switch action
        case 'all'
            dispatch(obj,'action','init');
            dispatch(obj,'action','load_settings');
            dispatch(obj,'action','run');
            dispatch(obj,'action','end_session')
        case 'init'
            if ~test
                load('sess_table.mat');
                obj.settings.protocol = protocol;
                obj.settings.stage = stage_name;
                saveload.subjid = name;
                saveload.stage = stage;
                saveload.protocol = protocol;
                saveload.start_time = datestr(now,31);
                sessid = max(sess_table.sessid)+1;
            else
                obj.settings.protocol = protocol;
                obj.settings.stage = stage_name;
                saveload.subjid = [];
                saveload.stage = [];
                saveload.protocol = [];
                saveload.start_time = [];
                sessid =[];    
            end

            obj.saveload = saveload;
            obj.saveload.sessid = sessid;
            
            obj.protocol_init();
            obj.n_start_trials = 0;
            obj.n_done_trials = 0;
            obj.stop_flag = 0;
        case 'load_settings'
            try
                obj.useSettings();
            catch
                fprintf('Error in UseSettings\n')
            end
        case 'run'
            while ~stop_flag
                obj.n_start_trials = obj.n_start_trials + 1;
                dispatch(obj,'action','run_once')
                if obj.stop_flag
                    stop_flag = 1;
                end
            end
        case 'run_once'
            try
                obj.PreparNexrTrial();
            catch
                fprintf('Error Parsing Trial %d\n',obj.n_start_trials);
                fprintf('Someting Wrong in the PreparNexrTrial Section\n')
            end
            try
                obj.RunTrial();
            catch
                fprintf('Error Parsing Trial %d\n',obj.n_start_trials);
                fprintf('Someting Wrong in the RunTrial Section\n')
            end
            try
                if ~obj.stop_flag
                    obj.TrialComplete();
                    obj.n_done_trials = obj.n_done_trials + 1;
                end
            catch
                fprintf('Error Parsing Trial %d\n',obj.n_start_trials);
                fprintf('Someting Wrong in the TrialComplete Section\n')
            end
            try
                if ~obj.stop_flag && ~test
                    obj.saveTrial();
                end
            catch
                fprintf('Error Parsing Trial %d\n',obj.n_start_trials);
                fprintf('Someting Wrong in the saveTrial Section\n')
            end
            if obj.stop_flag
                stop_flag = 1;
            end
        case 'endsession'
            try
                 obj.saveSession();
            catch
                fprintf('Error in saveSession section \n')
            end
            try
                obj.saveSettings();
            catch
                fprintf('Error in saveSettings section \n')
            end
    end
end