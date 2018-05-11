classdef Protocol < symphonyui.core.Protocol
  %PROTOCOL A middleman to add common methods to symphonyui.core.Protocol
  
  methods
    %Set property categories
    function d = getPropertyDescriptor(obj, name)
      d = getPropertyDescriptor@symphonyui.core.Protocol(obj, name);
      switch name
        case { ...
              'amp', 'holdPotentialOverride','ampHold','holdingCommand' ...
            }
          d.category = '1. Amplifier Control';
          %%%
        case { ...
              'asFamily','familyIncrement','familyMaxAmplitude','finalPulse',     ...
              'finalRampAmplitude','firstLightAmplitude','firstPulse',            ...
              'incrementPerPulse','initRampAmplitude','led','led1',               ...
              'led1Background','led1InitialAmplitude','led1InterstepIntervals',   ...
              'led2','led2Background','led2InitialAmplitude','lightBackground',   ...
              'rampTotalAmplitude','stepAmplitudes','stepsAsFamily',              ...
              'led1PulsesInFamily','led2PulsesInFamily','led1AsFamily',           ...
              'led2AsFamily','led2Amplitudes', 'lightAmplitude','phaseShift',     ...
              'oscillationCenter', 'led1Amplitudes' ...
            }
          d.category = '2. Stimulus Control';
          %%%
        case { ...
              'delayBetweenEpochs','interpulseInterval','interstepIntervals',     ...
              'led1Durations','preTime','rampDelay','sampleRate','stimDurations', ...
              'stimTime','tailTime','totalEpochTime','led1Delay','led1Duration',  ...
              'led1Tail','led2Delay','led2Duration','led2Tail',                   ...
              'stimulationFrequency', 'stimulationPeriod' ...
             }
          d.category = '3. Temporal Controls';
          %%%
        case {'numberOfAverages','pulsesInFamily','familyFirst','familyAsLinear'}
          d.category = '4. Repetition Control';
          %%%
        otherwise
          d.category = '5. Other';
          %%%
      end
          
    end
    
    function prepareRun(obj)
      prepareRun@symphonyui.core.Protocol(obj);
      
    end
    
    
    function prepareEpoch(obj,epoch)
      prepareEpoch@symphonyui.core.Protocol(obj,epoch);
      c = clock;
      epoch.addParameter('epochDateString', ...
        datestr(c, 'yyyymmmdd_HH:MM:SS.FFF'));
      %{
        identifier = 'config.ledChirp'
        displayName = 'LED Chirp'
      %}
      % get identifier and displayName from protocol
      
      for cnst = {'identifier', 'displayName'}
        try
          epoch.addParameter(cnst{1}, obj.(cnst{1}));
        catch
          fprintf('%s has no property %s.\n', ...
            class(obj), cnst{1});
        end
      end
      
    end
    
    function completeEpoch(obj, epoch)
      completeEpoch@symphonyui.core.Protocol(obj,epoch);
      
      %look for temperature
      props = properties(obj);
      if ismember('temp', props)
        responseData = epoch.getResponse(obj.rig.getDevice(obj.temp)).getData;
        epoch.addParameter('meanTemperature', mean(responseData));
        epoch.addParameter('varTemperature', var(responseData));
        epoch.removeResponse(obj.rig.getDevice(obj.temp));
      end
      %look for amplifier holding potential (background/return)
      if ismember('amp',props)
        ampBg = obj.rig.getDevice(obj.amp).background;
        ampHold = sprintf('%2.3g%s', ...
            ampBg.quantity,...
            ampBg.displayUnits);
        epoch.addParameter('amplifierHoldingPotential', ampHold);
      end
    end
    
    function completeRun(obj)
      completeRun@symphonyui.core.Protocol(obj);
      
      p = properties(obj);
      % set LED backgrounds to 0 if present.
      p = p(cellfun(@(x)~isempty(regexpi(x,'^led.*$', 'once')),p,'unif',1));
      if ~isempty(p)
        devices = obj.rig.getDevices('LED');
        for d = 1:length(devices)
          device = devices{d};
          device.background = symphonyui.core.Measurement(...
            0,device.background.displayUnits);
          device.applyBackground();
        end
      end
    end
  end
end