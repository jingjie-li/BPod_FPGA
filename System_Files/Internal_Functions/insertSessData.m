function insertSessData( sessid,subjid,species,rig,starttime,endtime,protocol,startstage,endstage,trials,profits,hits,viols,mass )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
current_add=pwd;
try
cd('/Users/apple/Documents/MATLAB/BPOD_FPGA/Data/Sess_Data')
load('sess_table.mat');
stage = mean([startstage,endstage]);
duration = (datenum(endtime)-datenum(starttime))*24*60;
colstrain={'sessid','subjid','species','rig','starttime','endtime','protocol','startstage','endstage','stage','duration','trials','profits','hits','viols','mass'};
new_data={sessid,subjid,species,rig,starttime,endtime,protocol,startstage,endstage,stage,duration,trials,profits,hits,viols,mass};
new_data=cell2table(new_data,'Variablename',colstrain);
sess_table=[sess_table;new_data];
save('sess_table.mat','sess_table');
catch
    fprintf('Error Parsing Saving Session Data\n')
end
cd(current_add);
end

