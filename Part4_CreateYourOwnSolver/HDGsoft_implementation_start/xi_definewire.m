function [blockname,prpblock,prpsegment,prparcsegment]=xi_definewire(blockname,wirename,prp0,varargin)

% function XI_DEFINEWIRE(wirename,prp0,varargin)
% defines a wire (circuit or boundary condition) and adapts block, line-segment and arc-segment properties
%
% input parameters
%    blockname         :         : block name
%    wirename          :         : wire name
%    prp0              :         : 3 sets of properties independent of the problem type
%    varargin          :         : additional sets of properties dependent on the problem type

if ~exist('prp0','var')
  prp0=[];
end
if isempty(prp0)
  prp0=struct;
end
switch length(prp0)
  case 1
    prp0=repmat(prp0,3,1);
  case 3
  otherwise
    error('1 or 3 sets of properties required');
end

global xa_property_set;
if (xa_property_set>0) & (xa_property_set<=nargin-2)
  switch length(varargin{xa_property_set})
    case 1
      for pp=1:3
        prp0(pp)=dealstruct(prp0(pp),varargin{xa_property_set});
      end
    case 3
      for pp=1:3
        prp0(pp)=dealstruct(prp0(pp),varargin{xa_property_set}(pp));
      end
    otherwise
      error('1 or 3 sets of properties required');
  end
end
prpblock=prp0(1);
prpsegment=prp0(2);
prparcsegment=prp0(3);

global xa_formulation;
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
  case 'electric'
    ei_addconductorprop(wirename,0,0,1);                                   % wire modelled by a equipotential surface
    prpsegment.propname=0;
    prpsegment.inconductor=wirename;
    prparcsegment.propname=0;
    prparcsegment.inconductor=wirename;
    blockname='<No Mesh>';
  otherwise
    error('Unknown problem type');
end
