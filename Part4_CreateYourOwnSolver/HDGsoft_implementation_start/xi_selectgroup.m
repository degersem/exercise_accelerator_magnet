function xi_selectgroup(groupno)

% function XI_SELECTGROUP(groupno)
% selects a group of objects in the model
%
% input parameters
%     groupno                   : group number

global xa_formulation;
switch xa_formulation.problemtype
  case 'magnetic'
    mi_selectgroup(groupno);
  case 'electric'
    ei_selectgroup(groupno);
  case 'thermal'
    hi_selectgroup(groupno);
  case 'electrokinetic'
    ci_selectgroup(groupno);
  otherwise
    error('Unknown problem type');
end
