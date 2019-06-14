function prp=xa_gatherprop(prp,prp0,varargin)

% function prp=XA_GATHERPROP(prp,prp0,varargin)
% extends the properties stored in prp by the properties stored in prp0 and
% the properties provided in one of the following parameters dependent on
% the property set to be included
%
% input parameters
%    prp               : structure with default properties
%    prp0              : structure with properties valid for all problem definitions (may be empty)
%    varargin          : additional structures with properties valid for different problem definitions (optional)
%
% output parameters
%    prp               : structure with refined properties

global xa_propertyset;
prp=dealstruct(prp,prp0);
if (xa_propertyset>0) & (xa_propertyset<=nargin-2)
  prp=dealstruct(prp,varargin{xa_propertyset});
end
