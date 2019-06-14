function xi_probdef(units,prp0,varargin)

% function XI_PROBDEF(units,prp0,varargin)
% changes the problem definition
%
% input parameters
%    units             :         : units
%    prp0              :         : properties independent of the problem type
%    varargin          :         : additional properties dependent on the problem type
%
% replacement for
%    mi_probdef(freq,units,type,precision,depth,minangle,(acsolver)) changes the problem definition.
%        - freq              : [Hz]     : frequency
%        - units             :          : ’inches’/’millimeters’/’centimeters’/’mils’/’meters’/’micrometers’
%        - type              :          : ’planar’ for a 2-D planar problem or to ’axi’ for an axisymmetric problem
%        - precision         : []       : precision required by the solver. For example, entering 1E-8 requires the RMS of the residual to be less than 10?8.
%        - depth             : [units]  : depth of the problem in the into-the-page direction for 2-D planar problems.
%                                       : Specify the depth to be zero for axisymmetric problems
%        - minangle          : [deg]    : minimum angle constraint sent to the mesh generator
%                                       : 30 degrees is the usual choice for this parameter
%        - acsolver          :          : 0 for successive approximation, 1 for Newton
%    ei_probdef(units,type,precision,depth,minangle) changes the problem definition.
%        - units             :          : ’inches’/’millimeters’/’centimeters’/’mils’/’meters’/’micrometers’
%        - type              :          : ’planar’ for a 2-D planar problem or to ’axi’ for an axisymmetric problem
%        - precision         : []       : precision required by the solver. For example, entering 1E-8 requires the RMS of the residual to be less than 10?8.
%        - depth             : [units]  : depth of the problem in the into-the-page direction for 2-D planar problems.
%                                       : Specify the depth to be zero for axisymmetric problems
%        - minangle          : [deg]    : minimum angle constraint sent to the mesh generator
%                                       : 30 degrees is the usual choice for this parameter
%    hi_probdef(units,type,precision,(depth),(minangle)) changes the problem definition.
%        - units             :          : ’inches’/’millimeters’/’centimeters’/’mils’/’meters’/’micrometers’
%        - type              :          : ’planar’ for a 2-D planar problem or to ’axi’ for an axisymmetric problem
%        - precision         : []       : precision required by the solver. For example, entering 1E-8 requires the RMS of the residual to be less than 10?8.
%        - depth             : [units]  : depth of the problem in the into-the-page direction for 2-D planar problems.
%                                       : Specify the depth to be zero for axisymmetric problems
%        - minangle          : [deg]    : minimum angle constraint sent to the mesh generator
%                                       : 30 degrees is the usual choice for this parameter
%    ci_probdef(units,type,freq,precision,(depth),(minangle))
%        - units             :          : ’inches’/’millimeters’/’centimeters’/’mils’/’meters’/’micrometers’
%        - type              :          : ’planar’ for a 2-D planar problem or to ’axi’ for an axisymmetric problem
%        - freq              : [Hz]     : frequency
%        - precision         : []       : precision required by the solver. For example, entering 1E-8 requires the RMS of the residual to be less than 10?8.
%        - depth             : [units]  : depth of the problem in the into-the-page direction for 2-D planar problems.
%                                       : Specify the depth to be zero for axisymmetric problems
%        - minangle          : [deg]    : minimum angle constraint sent to the mesh generator
%                                       : 30 degrees is the usual choice for this parameter

if ~exist('prp0','var')
  prp0=[];
end
global xa_formulation;
switch xa_formulation.problemtype
  case 'magnetic'
    prp=xa_gatherprop(struct('freq',0,'type','planar','precision',1e-8,'depth',1.0,'minangle','30','acsolver',1),prp0,varargin{:});
    if ~isfield(prp,'type')
      warning('Type (planar/axi) not specified, planar used\n');
      prp.type='planar';
    end
    if strcmp(prp.type,'planar') & ~isfield(prp,'depth')
      warning('Model depth not specified, 1.0 used\n');
      prp.depth=1.0;
    end
    mi_probdef(prp.freq,units,prp.type,prp.precision,prp.depth,prp.minangle,prp.acsolver)
  case 'electric'
    prp=xa_gatherprop(struct('type','planar','precision',1e-8,'depth',1.0,'minangle','30'),prp0,varargin{:});
    if ~isfield(prp,'type')
      warning('Type (planar/axi) not specified, planar used\n');
      prp.type='planar';
    end
    if strcmp(prp.type,'planar') & ~isfield(prp,'depth')
      warning('Model depth not specified, 1.0 used\n');
      prp.depth=1.0;
    end
    ei_probdef(units,prp.type,prp.precision,prp.depth,prp.minangle);
  case 'thermal'
    prp=xa_gatherprop(struct('type','planar','precision',1e-8,'depth',1.0,'minangle','30'),prp0,varargin{:});
    if ~isfield(prp,'type')
      warning('Type (planar/axi) not specified, planar used\n');
      prp.type='planar';
    end
    if strcmp(prp.type,'planar') & ~isfield(prp,'depth')
      warning('Model depth not specified, 1.0 used\n');
      prp.depth=1.0;
    end
    hi_probdef(units,prp.type,prp.precision,prp.depth,prp.minangle);
  case 'electrokinetic'
    prp=xa_gatherprop(struct('freq',0,'type','planar','precision',1e-8,'depth',1.0,'minangle','30'),prp0,varargin{:});
    if ~isfield(prp,'type')
      warning('Type (planar/axi) not specified, planar used\n');
      prp.type='planar';
    end
    if strcmp(prp.type,'planar') & ~isfield(prp,'depth')
      warning('Model depth not specified, 1.0 used\n');
      prp.depth=1.0;
    end
    ci_probdef(units,prp.type,prp.freq,prp.precision,prp.depth,prp.minangle);
  otherwise
    error('Unknown problem type');
end
