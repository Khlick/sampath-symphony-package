function CustomShutdown()
  
  if strcmp(questdlg('Save current presets?', 'Ssve presets', 'Yes', 'No', 'Yes'),'Yes')
    fpath = fileparts(mfilename('fullpath'));
    oldDir = pwd;
    cd(fpath);
    
    % find the current user
    users = dir(fpath);
    users = { ...
              users(cellfun(@(x)~contains(x,'.'),...
                            {users.name},'unif',1) & ...
                    [users.isdir]...
                    ).name...
            };
    users = users(~ismember(users,'main'));
    isOnPath = ones(length(users),1); 
    ii = 0;
    for u = users
      ii = ii+1;
      isOnPath(ii) = any(cellfun(@(x)contains(x,u),split(path,';'),'uniformout',true));
    end

    theUser = users(logical(isOnPath));
    if length(theUser) > 1
      theUser = sampathlab.startup.doStartup('',theUser);
    end
    sampathlab.startup.savePrefs(theUser,fpath);
    cd(oldDir);
  end
  
  fprintf('\n Symphony 2 is shutting down!\n\n');
end