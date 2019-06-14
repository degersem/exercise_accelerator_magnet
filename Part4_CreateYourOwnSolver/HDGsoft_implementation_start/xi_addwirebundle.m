function wr=xi_addwirebundle(layer,pie,r,d,cp,prp0,varargin)

% function XI_ADDWIREBUNDLE(layer,pie,r,d,cp,prp0,varargin)
%
% constructs a bundle of wires circular cross-section
% The bundle has an arbitrary number and position of layers
% arranged in an arbitrary number and position of pie pieces
%
% input parameters
%    layer              : a set of numbers larger than 0 indicating the layers that should be filled
%    pie                : a set of numbers between 1 and 6 indicating which pie pieces should be filled
%    r                  : wire radius
%    d                  : distance between two adjacent wires
%    cp                 : center point (optional; default: [0 0])
%    prp0              :         : 3 sets of properties independent of the problem type
%    varargin          :         : additional sets of properties dependent on the problem type
%
% output parameters
%    wr                 : number of wires in the bundle
%
% xa_formulation determines the way how the conductors are modelled
%
% example 1: a single wire
%    xi_addwirebundle([1],[1],0.5,0.2)
%
% example 2: two wires, horizontally arranged
%    xi_addwirebundle([2],[1 4],0.5,0.2)
%
% example 3: 19 wires, optimally arranged
%    xi_addwirebundle([1 2 3],[1 2 3 4 5 6],0.5,0.2)

if ~exist('cp','var')
  cp=[0 0];
end
if isempty(cp)
  cp=[0 0];
end
if ~exist('prp0','var')
  prp0=[];
end

% A. Geometry + boundaries (electric case) + circuits (magnetic case)
c=2*r+d;                     % [m?]   : distance between two center points
a=c*cos(pi/6);               % [m?]   : short edge
b=c*sin(pi/6);               % [m?]   : long edge
wr=0;                        % [#]    : counting the wires
if any(find(layer==1))
  wr=wr+1;
  [blockname,prpblock,prpsegment,prparcsegment]=xi_definewire('CU',sprintf('W%d',wr),prp0,varargin);
  xi_addcircle(cp,r,blockname,prpblock,prparcsegment);
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
      [blockname,prpblock,prpsegment,prparcsegment]=xi_definewire('CU',sprintf('W%d',wr),prp0,varargin);
      xi_addcircle(cd2,r,blockname,prpblock,prparcsegment);
    end
  end
end
