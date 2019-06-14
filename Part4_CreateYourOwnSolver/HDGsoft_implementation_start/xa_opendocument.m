function xa_opendocument(modelname,problemtype,propertyset)

% function xa_opendocument(modelname,problemtype)
% opens an existing model and specifies the formulation
%
% input parameters
%    modelname            : model name
%    problemtype          : problem type ('magnetic'/'electric') (optional; default: 'magnetic')
%    propertyset          : number of the additional properties to be considered (optional; default: 0)

if ~exist('problemtype','var')
  problemtype='magnetic';
end
if ~exist('propertyset','var')
  propertyset=0;
end

global xa_formulation xa_propertyset;
xa_formulation.problemtype=problemtype;
xa_propertyset=propertyset;
switch problemtype
  case 'magnetic'
    opendocument([modelname '.fem']);
  case 'electric'
    opendocument([modelname '.fee']);
  case 'thermal'
    opendocument([modelname '.feh']);
  case 'electrokinetic'
    opendocument([modelname '.fec']);
  otherwise
    error('unknown problem type');
end
