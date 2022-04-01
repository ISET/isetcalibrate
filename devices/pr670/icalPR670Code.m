function cmdStr =  icalPR670Code(prCMD)
% Translate a pr command into the pr670 code (based on the manual)

switch prCMD
    case 'local'
        cmdStr = ['Q',char(13)];       % Quit remote mode
    case 'remote'
        cmdStr = ['PHOTO',char(13)];   % Enter remote mode
    case 'measure'
        cmdStr = ['M5',char(13)];      % Measure an SPD
        disp('Measuring');
        
    case 'aperturereallytiny'
        % 0.124
        cmdStr = ['SF3',char(13)];
    case 'aperturetiny'
        % 0.25 deg
        cmdStr = ['SF2',char(13)];
    case 'aperturesmall'
        % 0.5 deg
        cmdStr = ['SF1',char(13)];
    case 'aperturelarge'
        % 1.0 deg
        cmdStr = ['SF0',char(13)];
        
    case 'exposuretime'
        % Set to 100 ms
        cmdStr = ['SE0100',char(13)];
    
    case {'clearerror','clearerrors'}
        cmdStr = ['C',char(13)]; 
    case 'download'
        cmdStr = ['D5',char(13)];
    otherwise
        cmdStr = 'unknown';
        % error('Unknown pr command %s\n',prCMD)
end
