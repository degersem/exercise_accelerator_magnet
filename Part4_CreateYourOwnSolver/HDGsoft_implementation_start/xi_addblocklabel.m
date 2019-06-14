function xi_addblocklabel(cd,blockname,prp0,varargin)

% function XI_ADDBLOCKLABEL(cd,blockname,prp0,varargin)
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
%    hi_addblocklabel(x,y)
%        Add a new block label at (x,y)
%    ci_addblocklabel(x,y)
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
%    hi_setblockprop(blockname,automesh,hmesh,groupno)
%        Set the selected block labels to have the properties:
%        - Block property blockname
%        - automesh: 0 = mesher defers to mesh size constraint defined in meshsize,
%                    1 = mesher automatically chooses the mesh density.
%        - hmesh: size constraint on the mesh in the block marked by this label.
%        - A member of group number group
%    ci_setblockprop(blockname,automesh,hmesh,groupno)
%        Set the selected block labels to have the properties:
%        - Block property blockname
%        - automesh: 0 = mesher defers to mesh size constraint defined in meshsize,
%                    1 = mesher automatically chooses the mesh density.
%        - hmesh: size constraint on the mesh in the block marked by this label.
%        - A member of group number group

if size(cd,1)~=1 & ischar(blockname)
    for i=1:length(cd(:,1))
        xi_addblocklabel(cd(i,:),blockname,prp0,varargin);
    end
else
    if ~exist('prp0','var')
      prp0=[];
    end

    global xa_formulation;
    switch xa_formulation.problemtype
      case 'magnetic'
        prp=xa_gatherprop(struct('incircuit',0,'magdir',0,'groupno',0,'turns',1),prp0,varargin{:});
        if isfield(prp,'hmesh')
          prp.automesh=0;
        else
          prp.automesh=1;
          prp.hmesh=0;
        end
        if ischar(blockname)
          if size(cd,1)~=1
            error('Invalid number of block names and/or label coordinates');
          end
          mi_addblocklabel(cd(1,1),cd(1,2));
          mi_selectlabel(cd(1,1),cd(1,2));
          mi_setblockprop(blockname,prp.automesh,prp.hmesh,prp.incircuit,prp.magdir,prp.groupno,prp.turns);
          mi_clearselected;
        else
          if size(cd,1)~=length(blockname)
            error('Invalid number of block names and/or label coordinates');
          end
          prp=xa_repprop(prp,length(blockname));
          for bl=1:length(blockname)
            mi_addblocklabel(cd(bl,1),cd(bl,2));
            mi_selectlabel(cd(bl,1),cd(bl,2));
            mi_setblockprop(blockname{bl},prp.automesh(bl),prp.hmesh(bl),prp.incircuit{bl},prp.magdir(bl),prp.groupno(bl),prp.turns(bl));
            mi_clearselected;
          end
        end 
      case {'electric','thermal','electrokinetic'}
        prp=xa_gatherprop(struct('groupno',0),prp0,varargin{:});
        if isfield(prp,'hmesh')
          prp.automesh=0;
        else
          prp.automesh=1;
          prp.hmesh=0;
        end
        if ischar(blockname)
          if size(cd,1)~=1
            error('Invalid number of block names and/or label coordinates');
          end
          xi_wrap('addblocklabel',cd(1,1),cd(1,2));
          xi_wrap('selectlabel',cd(1,1),cd(1,2));
          xi_wrap('setblockprop',blockname,prp.automesh,prp.hmesh,prp.groupno);
          xi_clearselected;
        else
          if size(cd,1)~=length(blockname)
            error('Invalid number of block names and/or label coordinates');
          end
          prp=xa_repprop(prp,length(blockname));
          for bl=1:length(blockname)
            xi_wrap('addblocklabel',cd(bl,1),cd(bl,2));
            xi_selectlabel(cd(bl,1),cd(bl,2));
            xi_wrap('setblockprop',blockname{bl},prp.automesh(bl),prp.hmesh(bl),prp.groupno(bl));
            xi_clearselected;
          end
        end
      otherwise
        error('Unknown problem type');
    end
end

end
