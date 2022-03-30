function pr = icalPR670Init
% Open a serial port to the PR 670
%
% Seems to be COM3 on the Windows machine.
%
% To find the device, it must be plugged in and turned on.

prPort = serialportlist('available');
if isempty(prPort)
    disp('No port found');
    pr = '';
else
    fprintf('Found port %s\nOpening.\n',prPort);
    % Port properties are defined in pr670Init, line 28.
    % IOPort has above port settings 9600 baud, no parity, 8 data bits,
    % 1 stopbit, no handshake (aka FlowControl=none) already as
    % built-in defaults, so no need to pass them:
    pr = serialport(prPort,9600); 
    if isa(pr,'internal.Serialport')
        disp('Connected')
    else
        disp('Failed to open the port.');
    end
end

end
