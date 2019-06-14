function xi_addnode(cd,prp0,varargin)

% function XI_ADDNODE(cd,prp0,varargin)
% creates nodes and attaches properties to the nodes
%
% input parameters
%    cd                : [m,m]   : coordinates
%    prp0              :         : properties independent of the problem type
%    varargin          :         : additional properties dependent on the problem type
%
% replacement for
%    mi_addnode(x,y) Add a new node at x,y
%    ei_addnode(x,y) Add a new node at x,y
%    hi_addnode(x,y) Add a new node at x,y
%    ci_addnode(x,y) Add a new node at x,y
% and
%    mi_setnodeprop(propname,groupno)
%        propname        : nodal property name
%        groupno         : group number
%    ei_setnodeprop(propname,groupno,inconductor)
%        propname        : nodal property name
%        groupno         : group number
%        inconductor     : conductor name
%    hi_setnodeprop(propname,groupno,inconductor)
%        propname        : nodal property name
%        groupno         : group number
%        inconductor     : conductor name
%    ci_setnodeprop(propname,groupno,inconductor)
%        propname        : nodal property name
%        groupno         : group number
%        inconductor     : conductor name

if ~exist('prp0','var')
  prp0=[];
end
global xa_formulation;
switch xa_formulation.problemtype
  case 'magnetic'
    for i=1:size(cd,1)
      mi_addnode(cd(i,1),cd(i,2));
      mi_selectnode(cd(i,1),cd(i,2));
    end
    prp=xa_gatherprop(struct('propname',0,'groupno',0),prp0,varargin{:});
    mi_setnodeprop(prp.propname,prp.groupno);
    mi_clearselected;
  case 'electric'
    for i=1:size(cd,1)
      ei_addnode(cd(i,1),cd(i,2));
      ei_selectnode(cd(i,1),cd(i,2));
    end
    prp=xa_gatherprop(struct('propname',0,'groupno',0,'inconductor',0),prp0,varargin{:});
    ei_setnodeprop(prp.propname,prp.groupno,prp.inconductor);
    ei_clearselected;
  case 'thermal'
    for i=1:size(cd,1)
      hi_addnode(cd(i,1),cd(i,2));
      hi_selectnode(cd(i,1),cd(i,2));
    end
    prp=xa_gatherprop(struct('propname',0,'groupno',0,'inconductor',0),prp0,varargin{:});
    hi_setnodeprop(prp.propname,prp.groupno,prp.inconductor);
    hi_clearselected;
  case 'electrokinetic'
    for i=1:size(cd,1)
      ci_addnode(cd(i,1),cd(i,2));
      ci_selectnode(cd(i,1),cd(i,2));
    end
    prp=xa_gatherprop(struct('propname',0,'groupno',0,'inconductor',0),prp0,varargin{:});
    ci_setnodeprop(prp.propname,prp.groupno,prp.inconductor);
    ci_clearselected;
  otherwise
    error('Unknown problem type');
end
