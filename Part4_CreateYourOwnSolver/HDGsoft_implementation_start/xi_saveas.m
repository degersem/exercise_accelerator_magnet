function xi_saveas(modelname)

% function XI_SAVEAS(modelname)
% saves a model
%
% input parameters
%    modelname         : model name
%
% replacement for
%     mi_saveas(’filename’) saves the file with name ’filename’.
%     ei_saveas(’filename’) saves the file with name ’filename’.
%     hi_saveas("filename") saves the file with name "filename". Note if you use a path you must use two backslashes e.g. c:\\temp\\myfile.feh
%     ci saveas("filename") saves the file with name "filename". Note if you use a path you must use two backslashes e.g. c:\\temp\\myfemmfile.fee

global xa_formulation;
switch xa_formulation.problemtype
  case 'magnetic'
    mi_saveas([modelname '.fem']);
  case 'electric'
    ei_saveas([modelname '.fee']);
  case 'thermal'
    hi_saveas([modelname '.feh']);
  case 'electrokinetic'
    ci_saveas([modelname '.fec']);
  otherwise
    error('Unknown problem type');
end
