function xi_addpointprop(pointpropname,prp0,varargin)

% function XI_ADDPOINTPROP(pointpropname,prp0,varargin)
% adds a point property to the model
%
% input parameters
%     pointpropname             : point property name
%     prp0                      : properties independent of the problem type (none in this case)
%     varargin                  : additional properties dependent on the problem type
%
% replacement for
%
%     mi_addpointprop(’pointpropname’,a,j) adds a new point property of name ’pointpropname’
%         with either a specified potential a in units Webers/Meter or a point current j in units of Amps.
%         Set the unused parameter pairs to 0.
%
%     ei_addpointprop(’pointname’,Vp,qp) adds a new point property of name ’pointname’
%         with either a specified potential Vp a point charge density qp in units of C/m.
%
%     hi_addpointprop("pointpropname",Tp,qp) adds a new point property of name "pointpropname"
%         with either a specified temperature Tp or a point heat generation density qp in units of W/m.
%
%     ci_addpointprop("pointpropname",Vp,jp) adds a new point property of name "pointpropname"
%         with either a specified potential Vp a point current density jp in units of A/m.

global xa_formulation;
switch xa_formulation.problemtype
  case 'magnetic'
    prp=xa_gatherprop(struct('a',0,'j',0),prp0,varargin{:});
    if ischar(pointpropname)
      mi_addpointprop(pointpropname,prp.a,prp.j);
    elseif iscell(pointpropname)
      prp=xa_repprop(prp,length(pointpropname));
      for pp=1:length(pointpropname)
        mi_addpointprop(pointpropname{pp},prp.a(pp),prp.j(pp));
      end
    else
      error('unsuitable boundary name type');
    end
  case 'electric'
    prp=xa_gatherprop(struct('Vp',0,'qp',0),prp0,varargin{:});
    if ischar(pointpropname)
      ei_addpointprop(pointpropname,prp.Vp,prp.qp);
    elseif iscell(pointpropname)
      prp=xa_repprop(prp,length(pointpropname));
      for pp=1:length(pointpropname)
        ei_addpointprop(pointpropname{pp},prp.Vp(pp),prp.qp(pp));
      end
    else
      error('unsuitable boundary name type');
    end
  case 'thermal'
    prp=xa_gatherprop(struct('Tp',0,'qp',0),prp0,varargin{:});
    if ischar(pointpropname)
      hi_addpointprop(pointpropname,prp.Tp,prp.qp);
    elseif iscell(pointpropname)
      prp=xa_repprop(prp,length(pointpropname));
      for pp=1:length(pointpropname)
        hi_addpointprop(pointpropname{pp},prp.Tp(pp),prp.qp(pp));
      end
    else
      error('unsuitable boundary name type');
    end
  case 'electrokinetic'
    prp=xa_gatherprop(struct('Vp',0,'jp',0),prp0,varargin{:});
    if ischar(pointpropname)
      ci_addpointprop(pointpropname,prp.Vp,prp.jp);
    elseif iscell(pointpropname)
      prp=xa_repprop(prp,length(pointpropname));
      for pp=1:length(pointpropname)
        ci_addpointprop(pointpropname{pp},prp.Vp(pp),prp.jp(pp));
      end
    else
      error('unsuitable boundary name type');
    end
  otherwise
    error('Unknown problem type');
end
