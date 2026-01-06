function gui05b
	% Select the number of samples used in the FPGA
	samples=200;

	% Comment out the next line, then uncomment the lines
	% related to your OS
	%error('You must edit this file first!');

	% Use this line for Windows
	% Edit 'COM4' to match your port
	% (use serialportlist to list the serial ports visible from Matlab)
	h.port=serialport('COM7',921600);

	% Use this line for Linux
	% Edit '/dev/ttyUSB1' to match your port
	% (use serialportlist to list the serial ports visible from Matlab)
	% (also use "chmod 777 /dev/ttyUSB*" as root to enable access)
%	h.port=serialport('/dev/ttyUSB1',921600);

	% Use this line for Mac OS X
	% Edit '/dev/tty.usbserial-210376B5B9DC1' to match your port
	% (use serialportlist to list the serial ports visible from Matlab)
%	h.port=serialport('/dev/tty.usbserial-210376B5B9DC1',921600);

	% Initialize UIControls
	h.closefig=0;
	h.fig=figure('Position',[300 300 450 425]);% X Y W H
	set(h.fig,'CloseRequestFcn',@closefig);

	h.axes=axes(...
		'Units','pixels',...
		'Position',[50 25 375 375]);

	% Set units to normalized to make the window extensible
	set(h.axes,'Units','normalized');

	% Set initial axes settings
	axis(h.axes,[0 samples-1 -0.1 3.4]);

	% Main loop
	h.error='';
	while true
		% Check for a close figure request
		if (h.closefig==1)
			break;
		end

		% Send dummy data to FPGA
		write(h.port,0,'uint8');

		% Pause to prevent CPU saturation
		pause(0.01);

		% Read (2*samples) bytes from FPGA
		data_in=read(h.port,2*samples,'uint8');
		if (length(data_in)~=2*samples)
			h.error='Timeout reading from FPGA board.';
			break;
		end

		% Check synchronization
		if (~isequal(bitget(data_in(1:2:end-1),8),ones(1,samples))) ||...
				(~isequal(bitget(data_in(2:2:end),8),zeros(1,samples)))
			h.error='Out of sync error.';
			break;
		end
		% Convert data for display
		data=3.3*(data_in(2:2:end)*128+data_in(1:2:end-1)-128)/4096;

		% Save axes settings, plot, then restore axes settings
		a=axis(h.axes);
		plot(h.axes,data,'.-');
		axis(h.axes,a);

		% Update figure
		drawnow;
	end

	% Clean up and exit
	clear h.port
	delete(h.fig);
	if (~isempty(h.error))
		error(h.error);
	end

	% Callbacks
	function closefig(~,~)
		h.closefig=1;
	end
end
