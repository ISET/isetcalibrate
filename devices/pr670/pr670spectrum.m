function [data, wavelengths, peak] = pr670spectrum(port)
	
	% Makes one measurement with the PR715 spectraphotometer. Returns the
	% spectrum, the wavelengths at which the spectrum was sampled and the
	% wavelength sample at which the peak of the SPD occurs.
	%
	% USAGE
	%  [data, wavelengths, peak] = pr715spectrum(id)
	%  port        - an open MATLAB serial port structure
	%  data        - measured spectrum
	%  wavelengths - vector with wavelength samples at which measurements are
	%                made. This is 380:4:1068 for the pr715
	%  peak        - The peak wavelength
	%
	%
	% EXAMPLE
	%  % Ensure pr715 is connected, and has finished POST and warmup
	%  [data, wavelengths, peak] = pr715spectrum(port)
	%
	% NOTE - PR715 reads data in the interval [380,1068] at every 4 nm for a
	% total of 173 samples
	%
	% mp, Dec 2007
	%
	% Initialize the pr715
	
	if ~exist('port','var'), port = pr670init(11); end
	
	% Get everything from the RS232 buffer
	bytes = port.BytesAvailable;
	
	% If there's data on the port, clean up
	while (bytes ~= 0)
	   fread(port,bytes);
	   pause(0.1);
	   bytes = get(port,'BytesAvailable');
	end
	
	timeout = get(port,'Timeout');
	set(port,'Timeout',10*60);
	
	% Send the measure command to the device.
    fprintf(port,'P\n');
    fprintf(port,'H\n');
    fprintf(port,'O\n');
    fprintf(port,'T\n');
    fprintf(port,'O\n');
    fprintf(port,'M5\n');
    fprintf(port,'\r');% M5 measures spectral data
	 
	% Retrieve the response.
	
	% Set wavelength sample locations and number
	nSamples    = 76;
	startSample = '400';
	stopSample  = '700';
	   
	wavelengths = zeros(nSamples,1);
	data        = zeros(nSamples,1);
	sampleIndex = 1;
	
	start  = 0;
	finish = 0;
	
	while(finish == 0)
	   
	    portOut= readStr
	
	   if ( start == 0 && ~isempty(findstr(portOut,'00000')) )
	        delim=findstr(portOut,',');
	        peak = str2num(portOut(delim(2)+1:delim(3)-1));
	   end
	   
	   if ( start == 0 && ~isempty(findstr(portOut,startSample)) )
	      start = 1;
	   end
	   
	   if (start == 1)
	        delim=findstr(portOut,',');
	        wavelengths(sampleIndex) = str2num(portOut(delim(5)+1:delim(6)-1));
	        data(sampleIndex) = str2num(portOut(delim+1:end));
	        sampleIndex = sampleIndex + 1;
	   end
	   
	   if (start == 1 & ~isempty(findstr(portOut,stopSample)) )
	      finish = 1;
	   end
	   
	end
	
	return
	
	