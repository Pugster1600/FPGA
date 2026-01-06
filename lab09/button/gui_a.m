function gui_a
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
	h.fig=figure('Position',[300 300 425 75]);% X Y W H
	set(h.fig,'CloseRequestFcn',@closefig);

	h.red_in=uicontrol('Style','text',...
		'String','0',...
		'Units','pixels',...
		'Position',[25 25 75 25],...
		'FontUnits','pixels',...
		'FontSize',20);
	h.blue_in=uicontrol('Style','text',...
		'String','0',...
		'Units','pixels',...
		'Position',[125 25 75 25],...
		'FontUnits','pixels',...
		'FontSize',20);
	h.yellow_in=uicontrol('Style','text',...
		'String','0',...
		'Units','pixels',...
		'Position',[225 25 75 25],...
		'FontUnits','pixels',...
		'FontSize',20);
	h.green_in=uicontrol('Style','text',...
		'String','0',...
		'Units','pixels',...
		'Position',[325 25 75 25],...
		'FontUnits','pixels',...
		'FontSize',20);

	% Set units to normalized to make the window extensible
	set(h.red_in,'Units','normalized');
	set(h.red_in,'FontUnits','normalized');
	set(h.blue_in,'Units','normalized');
	set(h.blue_in,'FontUnits','normalized');
	set(h.yellow_in,'Units','normalized');
	set(h.yellow_in,'FontUnits','normalized');
	set(h.green_in,'Units','normalized');
	set(h.green_in,'FontUnits','normalized');

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

		% Read four bytes from FPGA
		tmp=read(h.port,4,'uint8');
		if (length(tmp)~=4)
			h.error='Timeout reading from FPGA board.';
			break;
		end

		% Check synchronization
		if (bitget(tmp(1),8)~=1)||(bitget(tmp(2),8)~=0)||(bitget(tmp(3),8)~=0)||(bitget(tmp(4),8)~=0)
			h.error='Out of sync error.';
			break;
		end
		% Convert data for display
		set(h.red_in,'String',sprintf('%d',tmp(1)-128));
		set(h.blue_in,'String',sprintf('%d',tmp(2)));
		set(h.yellow_in,'String',sprintf('%d',tmp(3)));
		set(h.green_in,'String',sprintf('%d',tmp(4)));

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
