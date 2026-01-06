function gui05c
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
	h.fig=figure('Position',[300 300 500 425]);% X Y W H
	set(h.fig,'CloseRequestFcn',@closefig);

	% 50 pixel margin on left and 25 on the right for legend
	h.axes=axes(...
		'Units','pixels',...
		'Position',[50 25 375 375]);
	h.slider=uicontrol('Style','slider',...
		'Min',0,...
		'Max',4095,...
		'Value',2047,...
		'SliderStep',[1/4096 10/4096],...
		'Units','pixels',...
		'Position',[450 25 25 375],...
		'FontUnits','pixels',...
		'FontSize',20);

	% Set units to normalized to make the window extensible
	set(h.axes,'Units','normalized');
	set(h.slider,'Units','normalized');
	set(h.slider,'FontUnits','normalized');

	% Set initial axes settings
	axis(h.axes,[0 samples-1 -0.1 3.4]);

	% Main loop
	h.error='';
	while true
		% Check for a close figure request
		if (h.closefig==1)
			break;
		end

		% Read threshold setting
		thresh=get(h.slider,'Value');
		if (thresh~=round(thresh))
			thresh=round(thresh);
			set(h.slider,'Value',thresh);
		end
		if (thresh<0)
			thresh=0;
			set(h.slider,'Value',thresh);
		end
		if (thresh>4095)
			thresh=4095;
			set(h.slider,'Value',thresh);
		end

		% Pack data
		data_out(2)=bitand(bitshift(thresh,-7),127);
		data_out(1)=128+bitand(bitshift(thresh,0),127);

		% Write two bytes to FPGA
		write(h.port,data_out,'uint8');

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
		plot(h.axes,(1:samples),data,'.-',...
			[1 samples],[3.3*thresh/4096 3.3*thresh/4096]);
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
