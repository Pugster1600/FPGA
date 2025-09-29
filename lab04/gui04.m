function gui04
	% Comment out the next line, then uncomment the lines
	% related to your OS
	error('You must edit this file first!');

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
	h.fig=figure('Position',[300 300 350 125]);% X Y W H
	set(h.fig,'CloseRequestFcn',@closefig);

	h.gui_out=uicontrol('Style','edit',...
		'String','0',...
		'Units','pixels',...
		'Position',[25 75 300 25],...
		'FontUnits','pixels',...
		'FontSize',20);
	h.gui_in=uicontrol('Style','text',...
		'String','0',...
		'Units','pixels',...
		'Position',[25 25 300 25],...
		'FontUnits','pixels',...
		'FontSize',20);

	% Set units to normalized to make the window extensible
	set(h.gui_out,'Units','normalized');
	set(h.gui_out,'FontUnits','normalized');
	set(h.gui_in,'Units','normalized');
	set(h.gui_in,'FontUnits','normalized');

	% Main loop
	h.error='';
	while true
		% Check for a close figure request
		if (h.closefig==1)
			break;
		end

		% Convert data from display
		gui_out=sscanf(get(h.gui_out,'string'),'%g');
		if (isempty(gui_out)==1)
			gui_out=0;
			set(h.gui_out,'String',sprintf('%.0f',gui_out));
		end
		if (gui_out~=round(gui_out))
			gui_out=round(gui_out);
			set(h.gui_out,'String',sprintf('%.0f',gui_out));
		end
		if (gui_out<0)
			gui_out=0;
			set(h.gui_out,'String',sprintf('%.0f',gui_out));
		end
		if (gui_out>4398046511103)
			gui_out=4398046511103;
			set(h.gui_out,'String',sprintf('%.0f',gui_out));
		end

		% Pack data
		data_out(6)=bitand(bitshift(gui_out,-35),127);
		data_out(5)=bitand(bitshift(gui_out,-28),127);
		data_out(4)=bitand(bitshift(gui_out,-21),127);
		data_out(3)=bitand(bitshift(gui_out,-14),127);
		data_out(2)=bitand(bitshift(gui_out,-7),127);
		data_out(1)=128+bitand(bitshift(gui_out,0),127);

		% Write six bytes to FPGA
		write(h.port,data_out,'uint8');

		% Pause to prevent CPU saturation
		pause(0.02);

		% Read six bytes from FPGA
		if (get(h.port,'NumBytesAvailable')==0)
			data_in=[];
		else
			data_in=read(h.port,get(h.port,'NumBytesAvailable'),'uint8');
		end

		% Check data
		if (chk(data_in)~=true)
			% Check for too few bytes -- programing board?
			if (length(data_in)<6)
				wcnt=0;
				while true
					write(h.port,0,'uint8');
					wcnt=wcnt+1;
					pause(0.02);
					if (get(h.port,'NumBytesAvailable')~=0)
						break;
					end
					if (wcnt==100) % 2 seconds
						break;
					end
				end
			end
			% Out of sync, try recovery
			write(h.port,[0 0 0 0 0 0 128 0 0 0 0 0],'uint8');
			pause(0.1);
			if (get(h.port,'NumBytesAvailable')==0)
				h.error='No data from FPGA board.';
				break;
			end
			read(h.port,get(h.port,'NumBytesAvailable'),'uint8');
			% Try re-sending data
			write(h.port,data_out,'uint8');
			pause(0.02);
			if (get(h.port,'NumBytesAvailable')==0)
				h.error='No data from FPGA board.';
				break;
			end
			data_in=read(h.port,get(h.port,'NumBytesAvailable'),'uint8');
			% Check data
			if (chk(data_in)~=true)
				h.error='Unable to sync to FPGA board.';
				break;
			end
		end

		% Unpack data
		gui_in=((((data_in(6)*128+data_in(5))*128+data_in(4))*128+data_in(3))*128+data_in(2))*128+data_in(1)-128;

		% Convert data for display
		set(h.gui_in,'String',sprintf('%.0f',gui_in));

		% Update window
		drawnow;
	end

	% Clean up and exit
	clear h.port;
	delete(h.fig);
	if (~isempty(h.error))
		error(h.error);
	end

	% Callbacks
	function closefig(~,~)
		h.closefig=1;
	end
	% Helper functions
	function ok=chk(data)
		ok=false;
		if (length(data)~=6)
			return;
		end
		if (data(1)<128)
			return
		end
		if (data(2)>=128)
			return
		end
		if (data(3)>=128)
			return
		end
		if (data(4)>=128)
			return
		end
		if (data(5)>=128)
			return
		end
		if (data(6)>=128)
			return
		end
		ok=true;
	end
end
