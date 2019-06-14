function returnwirelayer=xi_wirelayerconstruction(slottoothshape,layerno,numwireparallelinslot,rwirelayer,rwire,dinsulwire,th,qq,numwire)

% function returnwirelayer=xi_wirelayer_parallelslot(layerno,numwireparallelinslot,rwirelayer,r,dinsulwire,th,qq,numwire)
% constructs the wires of a given layer in a parallel slot and assigns the specified material
%
% input parameters
%    layerno                : layer number
%    numwireparallelinslot  : number of wires parallel in the slot
%    rwirelayer             : radius to center of wirelayer (x of slot middle)
%    rwire                  : wire radius
%    dinsulwire             : wire insulation thickness
%    th                     : angle by which slot is rotated (depends on slot number)
%    qq                     : count for driver
%    numwire                : number of wires implemented

if strcmp(slottoothshape,'parallelslots')==0
  disp('For the time being, the winding is only designed for parallel slots!');
  returnwirelayer.numwire=numwire;
  returnwirelayer.qq=qq;
  return
end

switch slottoothshape
  case 'parallelslots'
    wiresinlayer=numwireparallelinslot-1+mod(layerno,2);    % (#¦¦ in slot) and (#¦¦ in slot)-1 alternate
    pitchwr=atan((rwire+dinsulwire)/rwirelayer);            % angle corresponding to rwire+dinsulwire at given radius
    thwr=-(wiresinlayer-1)*pitchwr;                         % angle for center of wire (slot not rotated), lowest wire
    for i=1:wiresinlayer
      qq=qq+1;
      [blockname,prpblock,prpsegment,prparcsegment]=xi_definewire('CU',sprintf('W%d',qq));
      xi_addcircle(rwirelayer*[cos(th-thwr) sin(th-thwr)],rwire,blockname,prpblock,prparcsegment);
      numwire=numwire+1;
      thwr=thwr+2*pitchwr;
    end
    %numwiretest=(floor(numwirelayers/2)*(2*numwireparallelinslot-1)+mod(numwirelayers,2)*numwireparallelinslot)*nummodslot;
  case 'bothtapered'
  case 'parallelteeth'
end
returnwirelayer.numwire=numwire;
returnwirelayer.qq=qq;
