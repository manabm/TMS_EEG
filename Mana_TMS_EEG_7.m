clear; close all; clc;

%##### STEP 7: Filter, Interpolate Channels, Split Intensities, Average Reference, Reference to Mastoids, Laplacian (takes longer time, might need to consider not running it with the re-referencing methods)#####

% IDs of participants to analyse
ID = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'019';'020';'021'};

pathOut = '/Volumes/BACKUP_HD/MANA_TMS_EEG/Analyzed/';
fileName = 'all_blocks_ds_reject_ICA1_clean_ICA2_clean.set';

% Define conditions
condition = {'high';'low'; 'control'};
%for IHI
%condition = {'spEEG'; 'control'};

eeglab;

for idx = 1:length(ID)
    
    % Makes a subject folder
    if ~isequal(exist([pathOut,ID{idx,1}], 'dir'),7)
        mkdir(pathOut,ID{idx,1});
    end
    
    %Load data
    EEG = pop_loadset('filepath',[pathOut,ID{idx,1},'/'],'filename', [ID{idx,1},'_', fileName]);
    
    %Interpolate missing channels
    EEG = pop_interp(EEG, EEG.allchan, 'spherical');
    
    for cond =  1:length(condition)
        
        %Extract the data from each condition
        EEG1 = pop_selectevent( EEG, 'type',condition{cond},'deleteevents','on','deleteepochs','on','invertepochs','off');
        
        % Reference each condition's data to common average and save
        EEG1av = pop_reref(EEG1, []);
        EEG1av = pop_saveset(EEG1av, 'filename', [ID{idx,1} '_FINAL_', condition{cond},'_avref'],'filepath', [pathOut ID{idx,1}]);
        
        % Reference each condition's data to average mastoids and save
        EEG1mast = pop_reref( EEG1, [29,30]);
        EEG1mast = pop_saveset( EEG1mast, 'filename', [ID{idx,1} '_FINAL_', condition{cond}, '_mastref'],'filepath', [pathOut ID{idx,1}]);
        
        % Compute and save laplacian of TEPs
        EEG1lap.data = double(mean(EEG1.data,3));
        EEG1lap.data = del2map(EEG1.data,EEG1.chanlocs);
        EEG1lap = pop_saveset(EEG1av, 'filename', [ID{idx,1} '_FINAL_', condition{cond},'_laplac'],'filepath', [pathOut ID{idx,1}]);
        
    end
    
end