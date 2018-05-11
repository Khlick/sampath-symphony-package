%% Custom startup file for Symphony2.x
% Prompts for user name from dropdown and then sets options accordingly.
% Options intended to be set:
%   searchPatch: [folder string] for protocol and rig setup files
%   fileDefaultLocation: [Fcn] User path for h5 save.
%%%%

spRoot = mfilename('fullpath');
cd(fileparts(spRoot));

% add path to shared core files
addpath(fullfile(fileparts(spRoot),'main'));

%select current user
theUser = sampathlab.startup.doStartup(fileparts(spRoot));
%determine if first run
if ~exist('customStartup.sy2','file')
  customStartup = struct();
else
  load('customStartup.sy2','-mat','customStartup');
end
%determine if first user access
if ~isfield(customStartup,theUser)
  userStruct = struct(...
      'startupFile',spRoot,...
      'fileDefaultName',@()datestr(now,'yyyymmdd'),...
      'fileDefaultLocation', @()pwd,...
      'searchPath', '');
  %get save directory
  saveDir = uigetdir(...
    winqueryreg('HKEY_CURRENT_USER', ...
        'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders',...
        'Desktop'),...
    'Choose save directory');
  userStruct.fileDefaultLocation = @()saveDir;
  %set the search path
  userStruct.searchPath = strjoin( ...
          { ...
            fullfile(fileparts(spRoot),'main'); ... %shared
            fullfile(fileparts(spRoot),theUser) ... %private
          }, ...
          ';');
  customStartup.(theUser) = userStruct;
  save('customStartup.sy2','customStartup','-mat');
else
  userStruct = customStartup.(theUser);
end

%set options
options.fileDefaultLocation = userStruct.fileDefaultLocation;
options.searchPath = userStruct.searchPath;
options.searchPathExclude = 'sampathlab.core.Protocol';
%set presets
if isfield(userStruct,'presets')
    backsupPresets = cellfun(@(x)presets.getProtocolPreset(x),...
        presets.getAvailableProtocolPresetNames,'unif',0);
    %remove presets
    cellfun(@(x)presets.removeProtocolPreset(x.name),backsupPresets,'unif',0);
    %set user based presets
    try
        cellfun(@(x)presets.addProtocolPreset(x),userStruct.presets,'unif',0);
    catch
        cellfun(@(x)presets.addProtocolPreset(x),backsupPresets,'unif',0);
        disp('Presets failed to load, using previous session protocol presets.')
    end
end

cd(fullfile(fileparts(spRoot),theUser));