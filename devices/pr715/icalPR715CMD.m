function val = icalPR715CMD(pr,prCMD)
% Send a command to the PR 670.
%
%  Synopsis
%      val = icalPR715CMD(pr,prCMD)
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
%      local - Set PR715 for local control
%      remote - Set PR715 for control from computer
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
   pr = icalPR715Init;
%}
%{
   icalPR715CMD(pr,'remote');
   icalPR715CMD(pr,'backlight full');
   pause(0.5);
   icalPR715CMD(pr,'backlight off');
   pause(0.5);
%}
%{
    val = icalPR715CMD(pr,'measure read spd');
    ieNewGraphWin;
    plot(val.wave,val.energy');
    grid on; xlabel('Wave (nm)'); ylabel('Energy');
%}
%{
   icalPR715CMD(pr,'local');
%}
%{
%  See how many apertures there are. A-49 in the Appendix
%  Number of accessories and number of apertures.
   icalPR715CMD(pr,'remote');
   cmdStr = ['D112',char(13)]
   for i = 1:length(cmdStr)
     pr.write(upper(cmdStr(i)),'char');
     pause(0.05)
   end
   val = icalPR715CMD(pr,'read')
%}
%{
   icalPR715CMD(pr,'remote');
   % 1 and 4 seem to change the aperture.  Not 0  2 or  3 
   cmdStr = ['S,,,4',char(13)];
   for i = 1:length(cmdStr)
     pr.write(upper(cmdStr(i)),'char');
     pause(0.05)
   end
%}
%{
   icalPR715CMD(pr,'measure');
   val = icalPR715CMD(pr,'read');
   ieNewGraphWin; plot(val.wave,val.energy);
%}
%{
   icalPR715CMD(pr,'clear error');
%}
%{
    icalPR715CMD(pr,'clear read buffer')
%}
%{
  icalPR715CMD(pr,'aperture large');
  icalPR715CMD(pr,'aperture small');
  icalPR715CMD(pr,'exposure time');
%}

%%
if notDefined('pr') || ~isa(pr,'internal.Serialport')
    error('Modern serial port required');
end

prCMD = ieParamFormat(prCMD);
val = '';

%%
switch prCMD
    case 'backlightfull'
        % We need a few of these with the number changed
        cmdStr = ['B3',char(13)];
    case 'backlightoff'
        cmdStr = ['B0',char(13)];
    case 'local'
        % This worked
        cmdStr = ['Q',char(13)];       % Quit remote mode
    case 'remote'
        % This worked
        cmdStr = ['PR715',char(13)];   % Enter remote mode
    case 'measurespd'
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
         % Loop to read all the lines.
        val = '';
        while pr.NumBytesAvailable > 0
            thisLine = pr.readline;
            pause(0.010);
            if isempty(thisLine), break;
            else,  val = [val; thisLine]; %#ok<AGROW>
            end
        end
        return;
    case 'measurereadspd'
        icalPR670CMD(pr,'clear read buffer');
        pause(0.1);
        icalPR670write(pr,icalPR670Code('measure spd'));
        icalPR670CMD(pr,'clear read buffer');
        
        disp('Waiting for data');
        if icalPR670WaitForData(pr)
            pause(0.1);  % Let the instrument finish putting the data in the buffer.
            str = icalPR670CMD(pr,'read');
            val.str = str;
        else
            disp('Measurement timed out.');
            return;
        end
        disp('Done reading');
        
        % Convert the SPD string return to numbers
        nVals = numel(str) - 2;
        val.wave = zeros(nVals,1); val.energy = val.wave;
        for ii=3:numel(str)
            c = split(str(ii),',');
            val.wave(ii-2)   = str2double(c{1});
            val.energy(ii-2) = str2double(c{2});
        end
        return;
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

%% Write the string to the PR6715
disp(cmdStr)
for i = 1:length(cmdStr)
    pr.write(upper(cmdStr(i)),'char');
    pause(0.05)
end

% val = pr.readline;

end
