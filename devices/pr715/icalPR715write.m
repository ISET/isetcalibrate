function icalPR715write(pr,cmdStr,varargin)
% Write a command string the PR715
%
%  Synopsis
%     icalPR715write(pr,cmdStr,verbose (=false));
%
% See also
%   icalPR715code, icalPR715CMD
%

if isempty(varargin), verbose = false;
else, verbose = varargin{1};
end

if verbose, disp(cmdStr); end

for ii = 1:length(cmdStr)
    pr.write(upper(cmdStr(ii)),'char');
    pause(0.05)
end

end
