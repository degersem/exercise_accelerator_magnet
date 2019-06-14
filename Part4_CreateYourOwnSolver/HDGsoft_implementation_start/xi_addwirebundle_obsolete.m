function wr=xi_addwirebundle(problemtype,layer,pie,r,d,cp)

% function XI_ADDWIREBUNDLE(problemtype,layer,pie,r,d,cp)
%
% constructs a bundle of wires circular cross-section
% The bundle has an arbitrary number and position of layers
% arranged in an arbitrary number and position of pie pieces
%
% input parameters
%    problemtype        : one of electric/magnetic
%    layer              : a set of numbers larger than 0 indicating the layers that should be filled
%    pie                : a set of numbers between 1 and 6 indicating which pie pieces should be filled
%    r                  : wire radius
%    d                  : distance between two adjacent wires
%    cp                 : center point (optional; default: [0 0])
%
% output parameters
%    wr                 : number of wires in the bundle
%
% example 1: a single wire
%    xi_addwirebundle('electric',[1],[1],0.5,0.2)
%
% example 2: two wires, horizontally arranged
%    xi_addwirebundle('magnetic',[2],[1 4],0.5,0.2)
%
% example 3: 19 wires, optimally arranged
%    xi_addwirebundle('electric',[1 2 3],[1 2 3 4 5 6],0.5,0.2)

if nargin<6
  cp=[0 0];
end

global xa_formulation;
switch problemtype
    case 'electric'
      xa_formulation.problemtype='electric';
    case {'magnetic','magnetic LF'}
      %hdg_mi_drawcircle(cp(1),cp(2),r);
      %hdg_mi_addwire(cp(1),cp(2),'CU',sprintf('W%d',wr));
      [blockname,prpblock,prpsegment,prparcsegment]=xi_definewire('CU',sprintf('W%d',wr));
      xi_addcircle(cp,r,blockname,prpblock,prparcsegment);
    case 'magnetic HF'
      %hdg_mi_addwireHF(cp(1),cp(2),r,sprintf('W%d',wr));
      [blockname,prpblock,prpsegment,prparcsegment]=xi_definewire('CU',sprintf('W%d',wr));
      xi_addcircle(cp,r,blockname,prpblock,prparcsegment);
    otherwise
      error('Unknown problem type');

switch xa_formulation.problemtype
  case 'magnetic'
    switch xa_formulation.wire
      case 'LF'          % low-frequency approximation for wires
        mi_addcircprop(wirename,0,1);                                      % wire modelled by an impressed current
        prpblock.incircuit=wirename;
      case 'HF'          % high-frequency approximation for wires
        mi_addboundprop(wirename,0,0,0,0,0,0,0,0,0);                       % wire modelled by an impressed flux
        prpsegment.propname=wirename;
        prparcsegment.propname=wirename;
        blockname='<No Mesh>';
      case 'SIBC'        % wires considered by surface-impedance boundary conditions
        error('not yet implemented');
    end

% A. Geometry + boundaries (electric case) + circuits (magnetic case)
c=2*r+d;                     % [m?]   : distance between two center points
a=c*cos(pi/6);               % [m?]   : short edge
b=c*sin(pi/6);               % [m?]   : long edge
wr=0;                        % [#]    : counting the wires
if any(find(layer==1))
  wr=wr+1;
  switch problemtype
    case 'electric'
      %hdg_ei_addconductor(cp(1),cp(2),r,sprintf('W%d',wr));
      [blockname,prpblock,prpsegment,prparcsegment]=xi_definewire('CU',sprintf('W%d',wr));
      xi_addcircle(cp,r,blockname,prpblock,prparcsegment);
    case {'magnetic','magnetic LF'}
      %hdg_mi_drawcircle(cp(1),cp(2),r);
      %hdg_mi_addwire(cp(1),cp(2),'CU',sprintf('W%d',wr));
      [blockname,prpblock,prpsegment,prparcsegment]=xi_definewire('CU',sprintf('W%d',wr));
      xi_addcircle(cp,r,blockname,prpblock,prparcsegment);
    case 'magnetic HF'
      %hdg_mi_addwireHF(cp(1),cp(2),r,sprintf('W%d',wr));
      [blockname,prpblock,prpsegment,prparcsegment]=xi_definewire('CU',sprintf('W%d',wr));
      xi_addcircle(cp,r,blockname,prpblock,prparcsegment);
    otherwise
      error('Unknown problem type');
  end
end
for ly=1:length(layer)
  numitem=layer(ly)-1;
  for p=1:length(pie)
    radius=(layer(ly)-1)*c;
    alpha=(pie(p)-1)*pi/3;
    cd1=cp+[radius*cos(alpha) radius*sin(alpha)];
    a2=alpha+2*pi/3;
    bd=[cos(a2) sin(a2)];
    for it=1:numitem
      wr=wr+1;
      cd2=cd1+(it-1)*c*bd;
      switch problemtype
        case 'electric'
          %hdg_ei_addconductor(cd2(1),cd2(2),r,sprintf('W%d',wr));
          [blockname,prpblock,prpsegment,prparcsegment]=xi_definewire('CU',sprintf('W%d',wr));
          xi_addcircle(cd2,r,blockname,prpblock,prparcsegment);
        case {'magnetic','magnetic LF'}
          %hdg_mi_drawcircle(cd2(1),cd2(2),r);
          %hdg_mi_addwire(cd2(1),cd2(2),'CU',sprintf('W%d',wr));
          [blockname,prpblock,prpsegment,prparcsegment]=xi_definewire('CU',sprintf('W%d',wr));
          xi_addcircle(cd2,r,blockname,prpblock,prparcsegment);
        case 'magnetic HF'
          %hdg_mi_addwireHF(cd2(1),cd2(2),r,sprintf('W%d',wr));
          [blockname,prpblock,prpsegment,prparcsegment]=xi_definewire('CU',sprintf('W%d',wr));
          xi_addcircle(cd2,r,blockname,prpblock,prparcsegment);
        otherwise
          error('Unknown problem type');
      end
    end
  end
end
