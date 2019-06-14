function xi_addwire(cd,blockname,wirename,prp0,varargin)

% function XI_ADDWIRE(cd,blockname,prp0,varargin)
% adds labels and attaches properties to the labels
%
% input parameters
%    cd1               : [m,m]   : label coordinates
%    blockname         :         : block names
%    prp0              :         : properties independent of the problem type
%    varargin          :         : additional properties dependent on the problem type
%
% replacement for
%    mi_addblocklabel(x,y)
%        Add a new block label at (x,y)
%    ei_addblocklabel(x,y)
%        Add a new block label at (x,y)
% and
%    mi_setblockprop(blockname,automesh,hmesh,incircuit,magdir,groupno,turns)
%        Set the selected block labels to have the properties:
%        – Block property blockname
%        – automesh: 0 = mesher defers to mesh size constraint defined in meshsize,
%                    1 = mesher automatically chooses the mesh density.
%        – hmesh: size constraint on the mesh in the block marked by this label.
%        – Block is a member of the circuit named incircuit
%        – The magnetization is directed along an angle in measured in degrees denoted by the parameter magdir
%        – A member of group number groupno
%        – The number of turns associated with this label is denoted by turns.
%    ei_setblockprop(blockname,automesh,hmesh,groupno)
%        Set the selected block labels to have the properties:
%        - Block property blockname
%        - automesh: 0 = mesher defers to mesh size constraint defined in meshsize,
%                    1 = mesher automatically chooses the mesh density.
%        - hmesh: size constraint on the mesh in the block marked by this label.
%        - A member of group number group

if ~exist('prp0','var')
  prp0=[];
end
if isempty(prp0)
  prp0=struct;
end

global xa_formulation;
switch xa_formulation.problemtype
  case 'magnetic'
    switch xa_formulation.wire
      case 'LF'          % low-frequency approximation for wires
        mi_addcircprop(wirename,0,1);                                      % wire modelled by an impressed current
        prp0.incircuit=wirename;
        xi_addblocklabel(cd,blockname,prp0,varargin{:});
      case 'HF'          % high-frequency approximation for wires
        % B.1. Add boundary condition
        mi_addboundprop(wirename,0,0,0,0,0,0,0,0,0);                       % wire modelled by an impressed flux
        % B.2. Connect line segments
        prp=xa_gatherprop(struct('propname',0,'groupno',0,'hide',0),prp0,varargin{:});
        if isfield(prp,'hmesh')
          prp.automesh=0;
        else
          prp.automesh=1;
          prp.hmesh=0;
        end
        mi_selectgroup(prp.groupno); fprintf('HDG: werkt dit wel?');
        mi_setsegmentprop(wirename,prp.hmesh,prp.automesh,prp.hide,prp.groupno);
        mi_clearselected;
        % B.3. Connect arc segments
        prp=xa_gatherprop(struct('propname',0,'groupno',0,'hide',0,'maxsegdeg','30'),prp0,varargin{:});
        if isfield(prp,'hmesh')
          prp.magsegdeg=min(30,floor(prp.hmesh./R));
        end
        for asg=1:size(cd1,1)
      mi_addarc(cd1(asg,1),cd1(asg,2),cd2(asg,1),cd2(asg,2),angle(asg),max(2,round(angle/30)));
      mi_selectarcsegment(selcd(asg,1),selcd(asg,2));
      mi_setarcsegmentprop(prp.maxsegdeg,prp.propname,prp.hide,prp.groupno);
      mi_clearselected;
    end

        % B.4. Discard inner region
        xi_addlabel(cd,'<No Mesh>');
      case 'SIBC'        % wires considered by surface-impedance boundary conditions
        error('not yet implemented');
    end
  case 'electric'
    % C.1. Add conductor
    ei_addconductorprop(wirename,0,0,1);                                   % wire modelled by a equipotential surface
    % C.2. Connect line segments
    prp=xa_gatherprop(struct('propname',0,'groupno',0,'hide',0),prp0,varargin{:});
    if isfield(prp,'hmesh')
      prp.automesh=0;
    else
      prp.automesh=1;
      prp.hmesh=0;
    end
    ei_selectgroup(prp.segmentgroupno); fprintf('HDG: werkt dit wel?');
    % prp.propname=0;
    prp.inconductor=wirename;
    ei_setsegmentprop(prp.propname,prp.hmesh,prp.automesh,prp.hide,prp.groupno,prp.inconductor);
    ei_clearselected;
    % C.3. Connect arc segments
    prp=xa_gatherprop(struct('propname',0,'groupno',0,'hide',0,'maxsegdeg','30'),prp0,varargin{:});
    if isfield(prp,'hmesh')
      prp.magsegdeg=min(30,floor(prp.hmesh./R));
    end
    ei_selectgroup(prp.arcsegmentgroupno); fprintf('HDG: werkt dit wel?');
    % prp.propname=0;
    prp.inconductor=wirename;
    ei_setarcsegmentprop(prp.maxsegdeg,prp.propname,prp.hide,prp.groupno,prp.inconductor);
    ei_clearselected;
    % C.4. Discard inner region
    xi_addlabel(cd,'<No Mesh>');
  otherwise
    error('Unknown problem type');
end
