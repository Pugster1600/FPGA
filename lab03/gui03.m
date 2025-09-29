function gui03
	% Comment out the next line, then uncomment the lines
	% related to your OS
	%error('You must edit this file first!');

	% Use this line for Windows
	% Edit 'COM4' to match your port1
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
	h.fig=figure('Position',[300 300 400 125]);% X Y W H
	set(h.fig,'CloseRequestFcn',@closefig);

	h.hr_out=uicontrol('Style','edit',...
		'String','0',...
		'Units','pixels',...
		'Position',[25 75 75 25],...
		'FontUnits','pixels',...
		'FontSize',20);
	h.mn_out=uicontrol('Style','edit',...
		'String','0',...
		'Units','pixels',...
		'Position',[125 75 75 25],...
		'FontUnits','pixels',...
		'FontSize',20);
	h.sc_out=uicontrol('Style','edit',...
		'String','0',...
		'Units','pixels',...
		'Position',[225 75 75 25],...
		'FontUnits','pixels',...
		'FontSize',20);
	h.tn_out=uicontrol('Style','edit',...
		'String','0',...
		'Units','pixels',...
		'Position',[325 75 50 25],...
		'FontUnits','pixels',...
		'FontSize',20);
	h.hr_in=uicontrol('Style','text',...
		'String','0',...
		'Units','pixels',...
		'Position',[25 25 75 25],...
		'FontUnits','pixels',...
		'FontSize',20);
	h.mn_in=uicontrol('Style','text',...
		'String','0',...
		'Units','pixels',...
		'Position',[125 25 75 25],...
		'FontUnits','pixels',...
		'FontSize',20);
	h.sc_in=uicontrol('Style','text',...
		'String','0',...
		'Units','pixels',...
		'Position',[225 25 75 25],...
		'FontUnits','pixels',...
		'FontSize',20);
	h.tn_in=uicontrol('Style','text',...
		'String','0',...
		'Units','pixels',...
		'Position',[325 25 50 25],...
		'FontUnits','pixels',...
		'FontSize',20);

	% Set units to normalized to make the window extensible
	set(h.hr_out,'Units','normalized');
	set(h.hr_out,'FontUnits','normalized');
	set(h.mn_out,'Units','normalized');
	set(h.mn_out,'FontUnits','normalized');
	set(h.sc_out,'Units','normalized');
	set(h.sc_out,'FontUnits','normalized');
	set(h.tn_out,'Units','normalized');
	set(h.tn_out,'FontUnits','normalized');
	set(h.hr_in,'Units','normalized');
	set(h.hr_in,'FontUnits','normalized');
	set(h.mn_in,'Units','normalized');
	set(h.mn_in,'FontUnits','normalized');
	set(h.sc_in,'Units','normalized');
	set(h.sc_in,'FontUnits','normalized');
	set(h.tn_in,'Units','normalized');
	set(h.tn_in,'FontUnits','normalized');

	% Main loop
	h.error='';
	while true
		% Check for a close figure request
		if (h.closefig==1)
			break;
		end

		% Convert hours
		hr_out=sscanf(get(h.hr_out,'string'),'%x');
		if (isempty(hr_out)==1)
			hr_out=0;
			set(h.hr_out,'String',sprintf('%X',hr_out));
		end
		if (hr_out~=round(hr_out))
			hr_out=round(hr_out);
			set(h.hr_out,'String',sprintf('%X',hr_out));
		end
		if (hr_out<0)
			hr_out=0;
			set(h.hr_out,'String',sprintf('%X',hr_out));
		end
		if (hr_out>255)
			hr_out=255;
			set(h.hr_out,'String',sprintf('%X',hr_out));
		end
		% Convert minutes
		mn_out=sscanf(get(h.mn_out,'string'),'%x');
		if (isempty(mn_out)==1)
			mn_out=0;
			set(h.mn_out,'String',sprintf('%X',mn_out));
		end
		if (mn_out~=round(mn_out))
			mn_out=round(mn_out);
			set(h.mn_out,'String',sprintf('%X',mn_out));
		end
		if (mn_out<0)
			mn_out=0;
			set(h.mn_out,'String',sprintf('%X',mn_out));
		end
		if (mn_out>255)
			mn_out=255;
			set(h.mn_out,'String',sprintf('%X',mn_out));
		end
		% Convert seconds
		sc_out=sscanf(get(h.sc_out,'string'),'%x');
		if (isempty(sc_out)==1)
			sc_out=0;
			set(h.sc_out,'String',sprintf('%X',sc_out));
		end
		if (sc_out~=round(sc_out))
			sc_out=round(sc_out);
			set(h.sc_out,'String',sprintf('%X',sc_out));
		end
		if (sc_out<0)
			sc_out=0;
			set(h.sc_out,'String',sprintf('%X',sc_out));
		end
		if (sc_out>255)
			sc_out=255;
			set(h.sc_out,'String',sprintf('%X',sc_out));
		end
		% Convert tenths
		tn_out=sscanf(get(h.tn_out,'string'),'%x');
		if (isempty(tn_out)==1)
			tn_out=0;
			set(h.tn_out,'String',sprintf('%X',tn_out));
		end
		if (tn_out~=round(tn_out))
			tn_out=round(tn_out);
			set(h.tn_out,'String',sprintf('%X',tn_out));
		end
		if (tn_out<0)
			tn_out=0;
			set(h.tn_out,'String',sprintf('%X',tn_out));
		end
		if (tn_out>15)
			tn_out=15;
			set(h.tn_out,'String',sprintf('%X',tn_out));
		end

		% Pack data
		tmp=((hr_out*256+mn_out)*256+sc_out)*16+tn_out;
		data_out(1)=128+bitand(bitshift(tmp,0),127);
		data_out(2)=bitand(bitshift(tmp,-7),127);
		data_out(3)=bitand(bitshift(tmp,-14),127);
		data_out(4)=bitand(bitshift(tmp,-21),127);

		% Write four bytes to FPGA
		write(h.port,data_out,'uint8');

		% Pause to prevent CPU saturation
		pause(0.02);

		% Read four bytes from FPGA
		if (get(h.port,'NumBytesAvailable')==0)
			data_in=[];
		else
			data_in=read(h.port,get(h.port,'NumBytesAvailable'),'uint8');
		end

		% Check data
		if (chk(data_in)~=true)
			% Check for too few bytes -- programing board?
			if (length(data_in)<4)
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
			write(h.port,[0 0 0 0 128 0 0 0],'uint8');
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
		tmp=((data_in(4)*128+data_in(3))*128+data_in(2))*128+data_in(1)-128;
		hr_in=bitand(bitshift(tmp,-20),255);
		mn_in=bitand(bitshift(tmp,-12),255);
		sc_in=bitand(bitshift(tmp,-4),255);
		tn_in=bitand(bitshift(tmp,0),15);

		% Convert
		set(h.hr_in,'String',sprintf('%X',hr_in));
		set(h.mn_in,'String',sprintf('%X',mn_in));
		set(h.sc_in,'String',sprintf('%X',sc_in));
		set(h.tn_in,'String',sprintf('%X',tn_in));

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
		if (length(data)~=4)
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
		ok=true;
	end
end
