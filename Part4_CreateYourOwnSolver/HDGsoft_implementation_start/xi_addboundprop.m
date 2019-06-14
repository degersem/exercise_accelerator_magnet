function xi_addboundprop(boundname,prp0,varargin)

% function XI_ADDBOUNDPROP(matname,prp0,varargin)
% adds a boundary to the model
%
% input parameters
%     boundname                 : boundary name
%     prp0                      : properties independent of the problem type
%     varargin                  : additional properties dependent on the problem type
%
% replacement for
%
%     mi_addboundprop(boundname, A0, A1, A2, Phi, Mu, Sig, c0, c1, BdryFormat)
%         – For a “Prescribed A” type boundary condition, set the A0, A1, A2 and Phi parameters
%           as required. Set all other parameters to zero.
%         – For a “Small Skin Depth” type boundary condtion, set the Mu to the desired relative
%           permeability and Sig to the desired conductivity in MS/m. Set BdryFormat to 1 and
%           all other parameters to zero.
%         – To obtain a “Mixed” type boundary condition, set C1 and C0 as required and BdryFormat
%           to 2. Set all other parameters to zero.
%         – For a “Strategic dual image” boundary, set BdryFormat to 3 and set all other parameters
%           to zero.
%         – For a “Periodic” boundary condition, set BdryFormat to 4 and set all other parameters
%           to zero.
%         – For an “Anti-Perodic” boundary condition, set BdryFormat to 5 set all other parameters
%           to zero.
%
%     ei_addboundprop(boundname, Vs, qs, c0, c1, BdryFormat) adds a new boundary
%         - For a “Fixed Voltage” type boundary condition, set the Vs parameter to the desired voltage
%           and all other parameters to zero.
%         - To obtain a “Mixed” type boundary condition, set C1 and C0 as required and BdryFormat to
%           1. Set all other parameters to zero.
%         - To obtain a prescribes surface charge density, set qs to the desired charge density in C/m2
%           and set BdryFormat to 2.
%         - For a “Periodic” boundary condition, set BdryFormat to 3 and set all other parameters to
%           zero.
%         - For an “Anti-Perodic” boundary condition, set BdryFormat to 4 set all other parameters to
%           zero.
%     hi_addboundprop(boundname, BdryFormat, Tset, qs, Tinf, h, beta) adds a new boundary
%         – For a “Fixed Temperature” type boundary condition, set the Tset parameter to the
%           desired temperature and all other parameters to zero.
%         – To obtain a “Heat Flux” type boundary condition, set qs to be the heat flux density and
%           BdryFormat to 1. Set all other parameters to zero.
%         – To obtain a convection boundary condition, set h to the desired heat transfer coefficient
%           and Tinf to the desired external temperature and set BdryFormat to 2.
%         – For a Radiation boundary condition, set beta equal to the desired emissivity and Tinf
%           to the desired external temperature and set BdryFormat to 3.
%         – For a “Periodic” boundary condition, set BdryFormat to 4 and set all other parameters
%           to zero.
%         – For an “Anti-Perodic” boundary condition, set BdryFormat to 5 set all other parameters
%           to zero.
%     ci_addboundprop(boundname, Vs, js, c0, c1, BdryFormat) adds a new boundary
%         - For a “Fixed Voltage” type boundary condition, set the Vs parameter to the desired voltage
%           and all other parameters to zero.
%         - To obtain a “Mixed” type boundary condition, set C1 and C0 as required and BdryFormat to
%           1. Set all other parameters to zero.
%         - To obtain a prescribes surface current density, set js to the desired current density in A/m2
%           and set BdryFormat to 2.
%         - For a “Periodic” boundary condition, set BdryFormat to 3 and set all other parameters to
%           zero.
%         - For an “Anti-Periodic” boundary condition, set BdryFormat to 4 set all other parameters to
%           zero.

global xa_formulation;
switch xa_formulation.problemtype
  case 'magnetic'
    prp=xa_gatherprop(struct('A0',0,'A1',0,'A2',0,'Phi',0,'Mu',0,'Sig',0,'c0',0,'c1',0,'BdryFormat',0),prp0,varargin{:});
    if ischar(boundname)
      mi_addboundprop(boundname,prp.A0,prp.A1,prp.A2,prp.Phi,prp.Mu,prp.Sig,prp.c0,prp.c1,prp.BdryFormat);
    elseif iscell(boundname)
      prp=xa_repprop(prp,length(boundname));
      for bd=1:length(boundname)
        mi_addboundprop(boundname{bd},prp.A0(bd),prp.A1(bd),prp.A2(bd),prp.Phi(bd),prp.Mu(bd),prp.Sig(bd),prp.c0(bd),prp.c1(bd),prp.BdryFormat(bd));
      end
    else
      error('unsuitable boundary name type');
    end
  case 'electric'
    prp=xa_gatherprop(struct('Vs',0,'qs',0,'c0',0,'c1',0,'BdryFormat',0),prp0,varargin{:});
    if ischar(boundname)
      ei_addboundprop(boundname,prp.Vs,prp.qs,prp.c0,prp.c1,prp.BdryFormat);
    elseif iscell(boundname)
      prp=xa_repprop(prp,length(boundname));
      for bd=1:length(boundname)
        ei_addboundprop(boundname{bd},prp.Vs(bd),prp.qs(bd),prp.c0(bd),prp.c1(bd),prp.BdryFormat(bd));
      end
    else
      error('unsuitable boundary name type');
    end
  case 'thermal'
    prp=xa_gatherprop(struct('BdryFormat',0,'Tset',0,'qs',0,'Tinf',0,'h',0,'beta',0),prp0,varargin{:});
    if ischar(boundname)
      hi_addboundprop(boundname,prp.BdryFormat,prp.Tset,prp.qs,prp.Tinf,prp.h,prp.beta);
    elseif iscell(boundname)
      prp=xa_repprop(prp,length(boundname));
      for bd=1:length(boundname)
        hi_addboundprop(boundname{bd},prp.BdryFormat(bd),prp.Tset(bd),prp.qs(bd),prp.Tinf(bd),prp.h(bd).prp.beta(bd));
      end
    else
      error('unsuitable boundary name type');
    end
  case 'electrokinetic'
    prp=xa_gatherprop(struct('Vs',0,'js',0,'c0',0,'c1',0,'BdryFormat',0),prp0,varargin{:});
    if ischar(boundname)
      ci_addboundprop(boundname,prp.Vs,prp.js,prp.c0,prp.c1,prp.BdryFormat);
    elseif iscell(boundname)
      prp=xa_repprop(prp,length(boundname));
      for bd=1:length(boundname)
        ci_addboundprop(boundname{bd},prp.Vs(bd),prp.js(bd),prp.c0(bd),prp.c1(bd),prp.BdryFormat(bd));
      end
    else
      error('unsuitable boundary name type');
    end
  otherwise
    error('Unknown problem type');
end
