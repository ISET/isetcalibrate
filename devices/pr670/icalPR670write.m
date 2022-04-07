function icalPR670write(pr,cmdStr,varargin)
% Write a command string the PR670
%
%  Synopsis
%     icalPR670write(pr,cmdStr,verbose (=false));
%
% See also
%   icalPR670code, icalPR670CMD
%

if isempty(varargin), verbose = false;
else, verbose = varargin{1};
end

if verbose, disp(cmdStr); end

for i = 1:length(cmdStr)
    pr.write(upper(cmdStr(i)),'char');
    pause(0.05)
end

end
