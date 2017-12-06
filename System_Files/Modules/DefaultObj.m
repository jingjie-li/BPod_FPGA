classdef (Abstract) DefaultObj < handle
    properties (SetAccess=public,GetAccess=public)
		settings % a struct with the protocol level settings. See useSettings method.
		n_done_trials = 0;
        n_start_trials = 0;
		hit_history = [];
		choice_history = {};
		violation_history = [];
		RT_history = [];
		peh
        hit
        reward
        choice
		saveload
		RT
        stop_flag
		% subjectname
		% sessiondate
		% sessionstart
		% sessionend
		% sessid
		% All of these will go into the session manager.
		
		% These are 
	end % 
    
    methods
        function obj = protocol_init(obj)
            
        end
        function obj=useSettings(obj)
            
        end
        function obj=PreparNexrTrial(obj)
        end
        function obj=RunTrial(obj)
        end
        function obj=TrialComplete(obj)
        end
        function obj=saveSession(obj)
        end
        function obj=saveSettings(obj)
        end
        
    end
end