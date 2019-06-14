function xi_addbhpoint(label,B,H)

% function xi_addbhpoint(label,B,H)
% defines a nonlinear curve in FEMM
%
% input parameters
%    label              : material label
%    B                  : [T]    : list of magnetic flux densities
%    H                  : [A/m]  : list of magnetic field strengths

global xa_formulation;
switch xa_formulation.problemtype
  case 'magnetic'
    for i=1:size(B,1)
      mi_addbhpoint(label,B(i,1),H(i,1));
    end
end
