function cmdStr =  icalPR670Code(prCMD)
% Translate a photoresearch command into the pr670 code 
% 
% (based on the manual)
%
% See also
%   icalPR670*

prCMD = ieParamFormat(prCMD);

switch prCMD
    case 'local'
        % Controlled at the device
        cmdStr = ['Q',char(13)];       % Quit remote mode
    case 'remote'
        % Controlled at the computer
        cmdStr = ['PHOTO',char(13)];   % Enter remote mode
        
        % Multiple measurements could be returned.  All derived from the
        % SPD measurement.
    case 'measurespd'
        cmdStr = ['M5',char(13)];      % Measure an SPD
        disp('Measuring');
    case {'measureyxy'}
        cmdStr = ['M1',char(13)];      % Measure an SPD
        disp('Measuring');
    case 'measurexyz'
        cmdStr = ['M2',char(13)];      % Measure an SPD
    case 'measureyuv'
        % Y and u' and v'
        cmdStr = ['M3',char(13)];      % Measure an SPD
        
    case 'measurescotopicluminance'
        cmdStr = ['M11',char(13)];      % Measure an SPD
        disp('Measuring');
    
        
        % Set the aperture size
    case 'aperturereallytiny'
        % 0.124
        cmdStr = ['SF3',char(13)];
    case 'aperturetiny'
        % Does not work on our system
        % 0.25 deg
        warning('Not working on our PR 670');
        cmdStr = ['SF2',char(13)];
    case 'aperturesmall'
        % 0.5 deg
        cmdStr = ['SF1',char(13)];
    case 'aperturelarge'
        % 1.0 deg
        cmdStr = ['SF0',char(13)];
       
        % Untested (setting the exposure time xxxx
    case 'setexposuretime'
        % Set to 100 ms
        cmdStr = ['SE0100',char(13)];
    case 'parameters'
        % Reading 
        cmdStr = ['M13',char(13)];
        
    case {'clearerror','clearerrors'}
        cmdStr = ['C',char(13)]; 
        
    case {'measurecie'}
        % Returns status, units, Y, CIE 1931 x, y, CIE 1960 u, v
        % icalPR670write(pr,icalPR670Code('measure cie'));
        % val = pr.readline;
        cmdStr = ['M12',char(13)];
        
    otherwise
        cmdStr = 'unknown';
        % error('Unknown pr command %s\n',prCMD)
end
