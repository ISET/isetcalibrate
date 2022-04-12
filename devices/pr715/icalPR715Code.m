function cmdStr =  icalPR715Code(prCMD)
% Translate a photoresearch command into the pr670 code 
% 
% (based on the manual)
%
% See also
%   icalPR715*

prCMD = ieParamFormat(prCMD);

switch prCMD
    case 'local'
        % This worked
        cmdStr = ['Q',char(13)];       % Quit remote mode
    case 'remote'
        % This worked
        cmdStr = ['PR715',char(13)];   % Enter remote mode
        
    case 'backlightfull'
        % We need a few of these with the number changed
        cmdStr = ['B3',char(13)];
    case 'backlightoff'
        cmdStr = ['B0',char(13)];
               
    case 'measurespd'
        cmdStr = ['M5',char(13)];      % Measure an SPD
        disp('Measuring')

    case 'aperturelarge'
        % 1 deg
        % 1 and 4 seem to change the aperture.  Not 0  2 or  3 
        cmdStr = ['S,,,4',char(13)];
    case 'aperturesmall'
        % 0.125 deg - Not sure about the true sizes.
        cmdStr = ['S,,,1',char(13)];
         
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
                   
    case {'measurecie'}
        % Returns status, units, Y, CIE 1931 x, y, CIE 1960 u, v
        % icalPR670write(pr,icalPR670Code('measure cie'));
        % val = pr.readline;
        cmdStr = ['M12',char(13)];
        
    otherwise
        cmdStr = 'unknown';
        % error('Unknown pr command %s\n',prCMD)
end
