function val = icalPR670CMD(pr,prCMD)
% Send a command to the PR 670.
% 
% Based on the modere modern serialport Matlab functions.
%

% Examples:
%{
   icalPR670CMD(pr,'quit');
   icalPR670CMD(pr,'remote');
   icalPR670CMD(pr,'measure');
%}
%{
   str = icalPR670CMD(pr,'read');
   nVals = numel(str) - 2;
   wave = zeros(nVals,1); energy = wave;
   for ii=3:numel(str)
     c = split(str(ii),',');
     wave(ii-2)  = str2num(c{1});
     energy(ii-2) = str2num(c{2});
   end
   ieNewGraphWin; plot(wave,energy);
%}
if notDefined('pr') || ~isa(pr,'internal.Serialport')
    error('Modern serial port required');
end

prCMD = ieParamFormat(prCMD);
val = '';

switch prCMD
    case 'quit'
        cmdStr = ['Q',char(13)];       % Quit remote mode
    case 'remote'
        cmdStr = ['PHOTO',char(13)];   % Enter remote mode
    case 'measure'
        cmdStr = ['M5',char(13)];      % Measure an SPD
    case 'read'
        % Loop to get all the lines
        val = '';
        tout = pr.Timeout;
        pr.Timeout = 5;
        for ii=1:202
            thisLine = pr.readline;
            if ii < 3, disp(thisLine), end
            pause(0.01);
            if isempty(thisLine)
                break;
            else
                val = [val; thisLine];
            end
        end
        pr.Timeout = tout;
        disp('Finished reading')
        return;
    otherwise
        error('Unknown pr command %s\n',prCMD)
end

for i = 1:length(cmdStr)
    pr.write(upper(cmdStr(i)),'char');
    pause(0.05)
end

end
