## 1. VGA

An electorn beam is shot at something to create the picture
it goes left to right, top to bottom
the issue is that once it finishes the entire screen, it cant return back to the top left immedately
this means we need a sync to signal the next video

the portion of tim ebetween the end of the sync and the start of the video is the front porch
the portion of time between end of the video signal and start of sync is the back porch

VESA created in order to have a fixed standard of high=resolution display timings 
vga allowed differnet colors
- so this org was created to have a fixed standard

EDID aka internal information was created by grahpics card to create a list of resolutions ie 1080p aka number of pixels and refersh rates aka 60hz ie 60 electorn beam cycles a sceond
- graphic card basically does the vga work of dispaly the image

newer tech like hdmi and usb-c all can use the EDID stuff

look at the constraint file to see what kind of information you will need to send out

rgb signals and horizotnal sync and vertical sync signals

the intereface to the EDID is easily used
- but we need to interpret the data
- thus we will use the VESA timings for 640x480 @60hz

specs
clock is 25.175 mhz 
1/25.175mhz = 3.97e-8 s = 39.7 ns

each pixel lasts this long

front porch is 48 pixels long
- ie 39.7ns * 48

33 rows = 33 rows worth of pixels times

ask: what is a standard ie we have a bunch of choices but just choose this option
and then ask what is necessary ie we dont have options for

process(clkfx)
begin
  -- saying that when this is the current pixel, make obj1_red, obj1_grn etc
  if rising_edge(clkfx) then 
    --1. UPDATE PIXELS:  this means frame is done so we can update the pixels again
    if frame = '1' then
      -- basically if we hit a wall, we go the opposite way
      if ball_x = to_signed(1, 10) and ball_y = to_signed(1, 10) then -- moving north east
        if (ball_x + ball_radius) = ball_right then
          ball_dx <= -ball_dx;
        else
          ball_x <= ball_x + 1;
        end if;

        if (ball_y + ball_radius) = ball_top then
          ball_dy <= -ball_dy;
        else
          ball_y <= ball_y + 1;
        end if;

      else if ball_x = to_signed(1, 10) and ball_y = to_signed(-1, 10) then -- moving south east
        if (ball_x + ball_radius) = ball_right then
          ball_dx <= -ball_dx;
        else
          ball_x <= ball_x + 1;
        end if;

        if (ball_y - ball_radius) = ball_bottom then
          ball_dy <= -ball_dy;
        else
          ball_y <= ball_y - 1;
        end if;

      else if ball_x = to_signed(-1, 10) and ball_y = to_signed(1, 10) then -- moving north west
        if (ball_x - ball_radius) = ball_left then
          ball_dx <= -ball_dx;
        else
          ball_x <= ball_x - 1;
        end if;

        if (ball_y + ball_radius) = ball_top then
          ball_dy <= -ball_dy;
        else
          ball_y <= ball_y + 1;
        end if;
        

      else if ball_x = to_signed(-1, 10) and ball_y = to_signed(-1, 10) then -- moving south west
        if (ball_x - ball_radius) = ball_left then
          ball_dx <= -ball_dx;
        else
          ball_x <= ball_x - 1;
        end if;

        if (ball_y - ball_radius) = ball_bottom then
          ball_dy <= -ball_dy;
        else
          ball_y <= ball_y - 1;
        end if;
    end if;

    -- 2. if we are at the pixel we care about aka the ball then we draw the stuff
  end if;
end process;

---------------------------------------------------
## 2. button
need a saturation counter
a button is connected to a counter that counts up when the button is 1 and down when it is 0
- when it gets tot he upper or lower limit it just stops.

so it requires the button to be high for a certain amount of time
- this solves the bouncing issue kinda

however, when it is not at the lower or upper limit, it is in an undefined zone
- so we need to hold the last state of the button