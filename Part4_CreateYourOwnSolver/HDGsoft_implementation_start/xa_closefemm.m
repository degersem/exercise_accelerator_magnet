function xa_openfemm(problemtype,propertyset)

% function XA_OPENFEMM(problemtype,propertyset)
% opens a FEMM problem and initialises global parameters
%
% input parameters
%    problemtype          : problem type ('magnetic'/'electric') (optional; default: 'magnetic')
%    propertyset          : number of the additional properties to be considered

global xa_formulation xa_property_set;
xa_propertyset=0;
closefemm;
