classdef ChirpGenerator < symphonyui.core.StimulusGenerator
  %Generate a chirp
  properties
    preTime     % Leading duration (ms)
    stimTime    % Sine wave duration (ms)
    tailTime    % Trailing duration (ms)
    stimDelay   % Leadin time at oscillation center
    followDelay % Trailing time at oscillation center
    amplitude   % Chirp amplitude (units)
    freqStart   % Initial frequency (Hz)
    freqStop    % Final frequency (Hz)
    phase = 0   % Phase offset (radians)
    center      % oscillation center
    sampleRate  % Sample rate of generated stimulus (Hz) 
    units       % Units of generated stimulus
    type        % "Linear" or "Quadratic"
    isIncreasing = true % set to false to reverse frequency
  end
  
  properties (Dependent)
    order
  end
  
  methods
        
    function obj = ChirpGenerator(map)
      if nargin < 1
        map = containers.Map();
      end
      obj@symphonyui.core.StimulusGenerator(map);
    end
        
  end
    
  methods (Access = protected)
    
    function s = generateStimulus(obj)
      import Symphony.Core.*;
      
      timeToPts = @(t)(round(t / 1e3 * obj.sampleRate));
      
      prePts = timeToPts(obj.preTime);
      stepPts = timeToPts(obj.stimDelay);
      stimPts = timeToPts(obj.stimTime);
      followPts = timeToPts(obj.followDelay);
      tailPts = timeToPts(obj.tailTime);
      
      data = [...
        zeros(1,prePts), ...
        ones(1, stepPts + stimPts + followPts) .* obj.center, ...
        zeros(1,tailPts) ...
        ];
      
      time = (0:(stimPts-1)) ./ obj.sampleRate;
      
      p= obj.order;
      beta = (obj.freqStop - obj.freqStart).*((obj.stimTime/1e3).^(-p));
      
      theChirp = obj.amplitude .* cos(...
        2*pi * ( beta./(1+p).*(time.^(1+p)) + ...
          obj.freqStart.*time + obj.phase/(2*pi) ...
          ) ...
        ) + obj.center;
      if ~obj.isIncreasing
        theChirp = fliplr(theChirp);
      end
      
      data(prePts + stepPts + (1:stimPts)) = theChirp;
      
      parameters = obj.dictionaryFromMap(obj.propertyMap);
      measurements = Measurement.FromArray(data, obj.units);
      rate = Measurement(obj.sampleRate, 'Hz');
      output = OutputData(measurements, rate);

      cobj = RenderedStimulus(class(obj), parameters, output);
      s = symphonyui.core.Stimulus(cobj);
    end
    
  end
  
  methods
    
    function p = get.order(obj)
      chirpType = validatestring(obj.type, {'Linear', 'Quadratic'});
      switch chirpType
        case 'Linear'
          p = 1;
        case 'Quadtratic'
          p = 2;
        otherwise
          p = 1;
      end
    end
    
  end
  
  
end

