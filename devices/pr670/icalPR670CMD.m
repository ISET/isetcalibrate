function val = icalPR670CMD(pr,prCMD,varargin)
% Send a command to the PR 670.
%
%  Synopsis
%      val = icalPR670CMD(pr,prCMD,varargin)
%
% Description:
%   Interacting with the 670, based on the modern serialport Matlab
%   functions. This replaces the older ioPort.mex4 functions in the
%   PsychToolbox.
%
% Inputs
%   pr:  The serial port returned by icalPR670Init;
%   prCMD:  The command you want to execute
%
%      local - Set PR670 for local control
%      remote - Set PR670 for control from computer
%      measure - Get a SPD data set
%      measure read spd
%      read spd   - Read a measured data set
%      clear errors - 
%
% Optional keyval
%      Aperture size, time, stuff like that
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
   val = icalPR670CMD(pr,'measure read spd');
   ieNewGraphWin; plot(val.wave,val.energy);

%}
%{
    val = icalPR670CMD(pr,'measure read XYZ');
%}
%{
   val = icalPR670CMD(pr,'measure read spd');
   ieNewGraphWin; plot(val.wave,val.energy);
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
  icalPR670CMD(pr,'aperture really tiny');
  icalPR670CMD(pr,'exposure time');
%}


%% Parse inputs

prCMD    = ieParamFormat(prCMD);
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('pr',@(x)(isa(pr,'internal.Serialport')));
p.addRequired('prCMD',@ischar);
p.addParameter('timeout',25,@isinteger);

p.parse(pr,prCMD,varargin{:});

% Return default is empty
val = '';

%% Create the PR670 code command string
   
switch prCMD
    
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
        %
        icalPR670CMD(pr,'clear read buffer');
        pause(0.1);
        icalPR670write(pr,icalPR670Code('measure spd'));
        icalPR670CMD(pr,'clear read buffer');

        tic;
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
        toc
        
        % Convert the SPD string return to numbers
        nVals = numel(str) - 2;
        val.wave = zeros(nVals,1); val.energy = val.wave;
        for ii=3:numel(str)
            c = split(str(ii),',');
            val.wave(ii-2)   = str2double(c{1});
            val.energy(ii-2) = str2double(c{2});
        end
        return;
        
    case 'measurereadxyz'
        nLines = 2;
        icalPR670CMD(pr,'clear read buffer');
        icalPR670write(pr,icalPR670Code('measure XYZ'));
        if icalPR670WaitForData(pr)
            val = icalPR670CMD(pr,'read','nlines',nLines);
        end
        c = split(val{2},',');
        val = [str2double(c(3)),str2double(c(4)),str2double(c(5))];
        return;

    case 'clearreadbuffer'
        tout = pr.Timeout;
        pr.Timeout = 0.5;
        warning('off');
        thisLine = pr.readline;
        while ~isempty(thisLine)
            thisLine = pr.readline;
        end
        warning('on');
        pr.Timeout = tout;
        return;
        
    otherwise
        % Try writing the CMD string to the device
        % The device should be in 'remote' mode.
        cmdStr = icalPR670Code(prCMD);
        if ~isempty(cmdStr)
            icalPR670write(pr,cmdStr);
        else
            error('Unknown command %s\n',prCMD);
        end
end


end
