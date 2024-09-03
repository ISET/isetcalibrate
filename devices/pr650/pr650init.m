function port = pr670init(id)

	% Creates a serial port object and sets default parameters for the PR715
	%
	% Usage
	%  port = pr715init(id)
	%   id - COM port number
	%
	% If initialization is succesful, this function will set the following
	% PR715 parameters:
	%
	% Primary lens      - MS55 (standard objective lens)
	% Add on 1          - no change; used for optical accesories
	% Add on 2          - no change; ditto
	% Aperture          - no change; for multiple aperture systems only
	% Photometric units - metric [0 - metric, 1 - english]
	% Detector Exposure - adaptive [0 - adaptive,
	% time              - integer values in (25,60000) secs.]
	% Capture mode      - single [0 - single, 1 - continuous]
	% # meas. average   - 3 [integer in (1,99)]
	% Power/energy      - power (divided by exposure time) [0 - pwr, 1 - enrgy]
	% Trigger mode      - internal (wait for valid M command)[0 - int, 1 - ext]
	% View Shutter      - closed [0 - open, 1 - closed]
	% CIE observer      - 2 deg [0 - CIE 1931 2 deg, 1 - CIE 1931 10 deg]
	
	% mp, Dec 2007
	
	% If COM port is not specified default to COM11
	if ~exist('id','var'), id = 11; end
	
	% If the COM port isn't open, open and initialize it
	comstr  = ['COM' num2str(id)];
	port    = serial(comstr);
	
	if (strcmpi(port.Status,'closed') == 1), fopen( port ); end
	
	set(port,'BaudRate',115200);
	set(port,'DataBits',8);
	set(port,'Parity','none');
	set(port,'StopBits',1);
	set(port,'Timeout',20);
	set(port,'Terminator','CR'); %% Changed from CR/LF
	set(port,'FlowControl','none'); % Manual wants this set to HARDWARE. We'll see
	set(port,'RequestToSend','on');
	pause(0.5);
	
	set(port,'RequestToSend','off');
	pause(0.5);
	set(port,'RequestToSend','on');
	pause(0.5);
	
	
	
	% Initial handshaking
% 	fprintf(port,'PR670');
	
	% Blink the backlight for visual indication (This is useful since I don't
	% know of any other way to find out if Matlab was really able to talk to
	% the PR715)
	
%     fprintf(port,'B3 \n'); pause(0.75);
%     fprintf(port,'B0 \n'); pause(0.75);
%     fprintf(port,'B1 \n');
      fprintf(port,'P');
      fprintf(port,'H');
      fprintf(port,'O');
      fprintf(port,'T');
      fprintf(port,'O');
      % quit
%       fprintf(ph,'Q\n');
    
    % Send a quick command to keep it in command mode.
% 	fprintf(port,'S,,,2\n');
	
	return
	