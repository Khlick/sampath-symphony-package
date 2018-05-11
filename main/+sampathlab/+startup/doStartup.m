function theUser = doStartup( root, varargin )
if ~strcmpi(root,'')
  users = dir(root);
  users = { ...
            users(cellfun(@(x)isempty(strfind(x,'.')),...
                          {users.name},'unif',1) & ...
                  [users.isdir]...
                  ).name...
          };
  users = users(~ismember(users,'main'));
else
  userTemp = cellfun(@(x)cellstr(x),varargin,'uniformout',false);
  users = [userTemp{:}];
end
init = struct();
drawBox()
%%
  function drawBox()
    import appbox.*;

    init.pickUser = figure('NumberTitle', 'off', ...
                  'MenuBar', 'none', ...
                  'Toolbar', 'none', ...
                  'HandleVisibility', 'off', ...
                  'Visible', 'off', ...
                  'DockControls', 'off', ...
                  'Interruptible', 'off', ...
                  'Name', 'Pick User', ...
                  'Position', screenCenter(320, 100),...
                  'Color', [1,1,1]);
    
    set(init.pickUser, 'DefaultUicontrolFontName', 'Times New Roman');
    set(init.pickUser, 'DefaultUicontrolFontSize', 9);
    set(init.pickUser, 'DefaultUIControlBackgroundColor', [1,1,1]);
    set(init.pickUser, 'DefaultFigureColor', [1,1,1]);
    set(init.pickUser, 'DefaultAxesColor', [1,1,1]);
    % Create goButton
    init.goButton = uicontrol(init.pickUser, ...
      'Style', 'pushbutton', 'backgroundcolor', [1,1,1],...
      'units', 'normalized');
    init.goButton.FontName = 'Times New Roman';
    init.goButton.FontWeight = 'bold';
    init.goButton.FontSize = 12;
    init.goButton.Position = [227 43 58 30] ./ ...
      sampathlab.utils.rep([320,100],2,1,'byRow',true)';
    init.goButton.CData = ones(30,58,3);
    init.goButton.String = 'Go';
    init.goButton.Callback = @(src,evnt)...
      doChoseUser(src,evnt);
    
    % Create text01
    init.text01 = uicontrol(init.pickUser,...
      'Style', 'text', 'backgroundcolor', [1,1,1],...
      'units', 'normalized');
    init.text01.HorizontalAlignment = 'right';
    init.text01.FontName = 'Times New Roman';
    init.text01.Position = [30 72 75 15] ./ ...
      sampathlab.utils.rep([320,100],2,1,'byRow',true)';
    init.text01.String = 'Select User:';
    init.text01.HitTest = 'on';
    init.text01.ButtonDownFcn = @(src,evnt)...
        doInterrupt();

    % Create userDropdown
    init.userDropdown = uicontrol(init.pickUser,...
      'Style', 'popup', 'backgroundcolor', [1,1,1],...
      'units', 'normalized');
    init.userDropdown.String = users;
    init.userDropdown.FontName = 'Times New Roman';
    init.userDropdown.FontSize = 14;
    init.userDropdown.Position = [30 42 187 30] ./ ...
      sampathlab.utils.rep([320,100],2,1,'byRow',true)';
    init.userDropdown.Value = 1;

    init.pickUser.CloseRequestFcn = @(src,evnt)...
      closeFcn(src,init.userDropdown.String{init.userDropdown.Value});
    init.pickUser.Visible = 'on';
    init.pickUser.WindowStyle = 'modal';
    uiwait(init.pickUser);
    
  end

  function doChoseUser(~,~)
    theUser = init.userDropdown.String{init.userDropdown.Value};
    delete(init.pickUser);
  end

  function closeFcn(~,~)
    theUser = users{1};
    delete(init.pickUser)
  end

  function doInterrupt()
      import sampathlab.startup.*;
      savePrefs(init.userDropdown.String{init.userDropdown.Value},root);
  end


end


