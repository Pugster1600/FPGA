function gui05a
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
	h.fig=figure('Position',[300 300 225 75]);% X Y W H
	set(h.fig,'CloseRequestFcn',@closefig);

	h.data_in=uicontrol('Style','text',...
		'String','0',...
		'Units','pixels',...
		'Position',[25 25 175 25],...
		'FontUnits','pixels',...
		'FontSize',20);

	% Set units to normalized to make the window extensible
	set(h.data_in,'Units','normalized');
	set(h.data_in,'FontUnits','normalized');

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

		% Read two bytes from FPGA
		data_in=read(h.port,2,'uint8');
		if (length(data_in)~=2)
			h.error='Timeout reading from FPGA board.';
			break;
		end

		% Check synchronization
		if (bitget(data_in(1),8)~=1)||(bitget(data_in(2),8)~=0)
			h.error='Out of sync error.';
			break;
		end

		% Convert data for display
		data=data_in(2)*128+data_in(1)-128;
		set(h.data_in,'String',sprintf('%d',data));

		% Update window
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
