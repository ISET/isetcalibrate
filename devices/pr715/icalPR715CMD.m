function val = icalPR670CMD(pr,prCMD)
% Send a command to the PR 670.
%
%  Synopsis
%      val = icalPR670CMD(pr,prCMD)
%
% Description:
%   Interacting with the 670, based on the modern serialport Matlab
%   functions. This replaces the older ioPort.mex4 functions in the
%   PsychToolbox.
%
% Inputs
%   pr:  The serial port returned by icalPR670Init;
%   prCMD:  A string indicating what you want
%
%      local - Set PR670 for local control
%      remote - Set PR670 for control from computer
%      measure - Get a SPD data set
%      read    - Read a measured data set
%      clear errors - 
%      measure read - NYI
%
% See the Users Manual around page 112 for serial line commands
%      
%
% See also
%   icalPR670Init, icalPR670

% Examples:
%{
   pr = icalPR670Init;
   icalPR670CMD(pr,'local');
   icalPR670CMD(pr,'remote');
   icalPR670CMD(pr,'measure');
   val = icalPR670CMD(pr,'read');
   ieNewGraphWin; plot(val.wave,val.energy);
%}
%{
    val = icalPR670CMD(pr,'measure read');
%}
%{
   icalPR670CMD(pr,'clear error');
%}
%{
 icalPR670CMD(pr,'clear read buffer')
%}
%{
  icalPR670CMD(pr,'aperture large');
  icalPR670CMD(pr,'aperture small');
  icalPR670CMD(pr,'exposure time');
%}

%%
if notDefined('pr') || ~isa(pr,'internal.Serialport')
    error('Modern serial port required');
end

prCMD = ieParamFormat(prCMD);
val = '';

%%
switch prCMD
    case 'backlight'
        % We need a few of these with the number changed
        cmdStr = ['B3',char(13)];
    case 'local'
        % This worked
        cmdStr = ['Q',char(13)];       % Quit remote mode
    case 'remote'
        % This worked
        cmdStr = ['PR715',char(13)];   % Enter remote mode
    case 'measure'
        cmdStr = ['M5',char(13)];      % Measure an SPD
        disp('Measuring')

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
    case 'read'
        % Tell the PR670 what data we want to download
        icalPR670CMD(pr,'download');
        
        % Loop to read all the lines.  This 202 should probably be figured
        % out from the wave settings.  Once we figure out the wave
        % settings.  We think it might always be 380 to 780 in 2nm steps.
        
        str = '';
        disp('Reading');
        for ii=1:202
            thisLine = pr.readline;
            pause(0.005);
            if isempty(thisLine)
                break;
            else
                str = [str; thisLine]; %#ok<AGROW>
            end
        end
        disp('Finished reading');
        
        % Convert the string to numbers
        nVals = numel(str) - 2;
        wave = zeros(nVals,1); energy = wave;
        for ii=3:numel(str)
            c = split(str(ii),',');
            wave(ii-2)   = str2double(c{1});
            energy(ii-2) = str2double(c{2});
        end
        val.str    = str;
        val.wave   = wave; 
        val.energy = energy;
        return;
    case 'measureread'
        icalPR670CMD(pr,'measure');
        val = icalPR670CMD(pr,'read');
    case {'clearerror','clearerrors'}
        cmdStr = ['C',char(13)]; 
    case 'download'
        cmdStr = ['D5',char(13)];
    case 'clearreadbuffer'
        tout = pr.Timeout;
        pr.Timeout = 0.5;
        thisLine = pr.readline;
        while ~isempty(thisLine)
            thisLine = pr.readline;
        end
        pr.Timeout = tout;
        return;
    otherwise
        error('Unknown pr command %s\n',prCMD)
end

%% Push the command to the PR670
disp(cmdStr)
for i = 1:length(cmdStr)
    pr.write(upper(cmdStr(i)),'char');
    pause(0.05)
end

val = pr.readline;

end
