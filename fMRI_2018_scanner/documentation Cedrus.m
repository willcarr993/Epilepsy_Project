%*** open at the beginning
handle =  CedrusResponseBox('Open', 'COM1');

%Clear all queues, discard all pending data.
  CedrusResponseBox('ClearQueues', handle);


%*** collect responses
  evt = CedrusResponseBox('GetButtons', handle);
  
  - Return next queued button-press or button-release event from the box.
  Each time a button on the box is pressed or released, and each time the
  state of the accessory connector changes, an "event" data packet is sent
  from the box to the computer. The packet is timestamped with the time of
  the triggering event, as measured by the boxes reaction time timer.
 
  This function checks if such an event is available and returns its
  description in a 'evt' struct, if so. If no event is pending, it returns an
  empty 'evt', ie. isempty(evt) is true.
 
  'evt' for a real fetched event is a struct with the following fields:
 
  evt.raw     = "raw" byte that describes the event. Only for debugging.
 
  evt.port    = Number of the device port on which the event occured. Push
                buttons and scanner triggers are on port 0, the RJ-45 TTL
                connector is on port 1, port 2 is the voice-key (if any).
 
  evt.action  = Action that triggered the event:
                1 = Button press, 0 = Button release for pushbuttons.
                1 = TTL line high, 0 = TTL line low for RJ-45 I/O lines.
                1 = Voice onse, 0 = Voice offset/silence for Voicekey.
 
  evt.button  = Number of the button that was pressed or released (1 to 8)
                or the TTL line that was going high/low. Numbers vary by
                response box.
 
  evt.buttonID= Descriptive name string for pressed button, e.g., 'top' or
                'left'. Please note that this mapping is only meaningful
                for the RB-530 response box.
 
  evt.rawtime = Time of the event in secs since last reset of the reaction
                time timer, measured in msecs resolution. This value is
                always valid, but not directly comparable to any other
                timestamps or time measurements within Psychtoolbox.
 
 
  evt = CedrusResponseBox('WaitButtons', handle);
  % Queries and returns the same info as 'GetButtons', but waits for
  %events. If there isn't any event available, will wait until one becomes
  %available.
 
  evt = CedrusResponseBox('WaitButtonPress', handle);
  % Like WaitButtons, but will wait until the subject /presses/ a key -- the
  % signal that a key has been released is not acceptable -- Button release
  % events are simply discarded.
 
   
  

%*** at end to shut down
  CedrusResponseBox('Close', handle);
  % Close connection to response box. The 'handle' becomes invalid after
  %that command.
 
 
  CedrusResponseBox('CloseAll');
  % Close all connections to all response boxes. This is a convenience
  % function for quick shutdown.