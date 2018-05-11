function savePrefs( theUser, root )
%SAVEPREFS Summary of this function goes here
%   Detailed explanation goes here
oldRoot = pwd;
cd(root)
load('customStartup.sy2', '-mat', 'customStartup');
userStruct = customStartup.(theUser);%#ok
presets = symphonyui.app.Presets.getDefault();
names = presets.getAvailableProtocolPresetNames;
userStruct.presets = cellfun(@(x)presets.getProtocolPreset(x),names,'unif',0);
customStartup.(theUser) = userStruct;
save('customStartup.sy2','customStartup','-mat');
cd(oldRoot);
fprintf(2,'\nPresets from previous session stored for %s\n', theUser);
end

