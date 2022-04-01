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
   icalPR670CMD(pr,'clear read buffer')
   icalPR670CMD(pr,'measure');
   val = icalPR670CMD(pr,'read');
   ieNewGraphWin; plot(val.wave,val.energy);
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

timeout = p.Results.timeout;

% Return default is empty
val = '';

%% Create the PR670 code command string
   
switch prCMD
    
    case 'readspd'        
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
        
    case 'measurereadspd'
        %
        icalPR670CMD(pr,'clear read buffer');
        icalPR670write(pr,icalPR670Code('measure'));
        mx = timeout;   %
        tic;
        while toc < mx && pr.NumBytesAvailable == 0
            % Wait up to 15 sec for num bytes to be positive
        end
        if pr.NumBytesAvailable > 0
            val = icalPR670CMD(pr,'read spd');
        else
            disp('Time out on the read');
        end
        return;
        
    case 'clearreadbuffer'
        tout = pr.Timeout;
        pr.Timeout = 0.5;
        thisLine = pr.readline;
        warning('off');
        while ~isempty(thisLine)
            thisLine = pr.readline;
        end
        warning('on');
        pr.Timeout = tout;
        return;
        
    otherwise
        % Just write the string to the device
        cmdStr = icalPR670Code(prCMD);
        if ~isempty(cmdStr)
            icalPR670write(pr,cmdStr);
        else
            error('Unknown command %s\n',prCMD);
        end
        
end


end
