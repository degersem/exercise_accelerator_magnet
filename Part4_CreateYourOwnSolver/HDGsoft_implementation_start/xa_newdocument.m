function xa_newdocument(problemtype,propertyset)

% function xa_newdocument(problemtype,propertyset)
% opens a new model and specifies the formulation
%
% input parameters
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
    newdocument(0);
  case 'electric'
    newdocument(1);
  case 'thermal'
    newdocument(2);
  case 'electrokinetic'
    newdocument(3);
  otherwise
    error('unknown problem type');
end
