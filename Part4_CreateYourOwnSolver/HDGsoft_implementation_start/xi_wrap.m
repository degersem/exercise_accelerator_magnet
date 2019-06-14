function xi_wrap(str,varargin)

% function XI_WRAP(str,varargin)
% wraps a OctaveFEMM command by adding 'mi_' or 'ei_'
%
% input parameters
%     str                       : OctaveFEMM command
%     varargin                  : input parameters of the OctaveFEMM command
%
% output parameters
%     none

global xa_formulation;
switch xa_formulation.problemtype
  case 'magnetic'
    eval(['mi_' str '(varargin{:});']);
  case 'electric'
    eval(['ei_' str '(varargin{:});']);
  case 'thermal'
    eval(['hi_' str '(varargin{:});']);
  case 'electrokinetic'
    eval(['ci_' str '(varargin{:});']);
  otherwise
    error('Unknown problem type');
end
