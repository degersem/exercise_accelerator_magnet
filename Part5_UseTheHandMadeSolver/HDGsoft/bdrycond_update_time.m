function bdrycond = bdrycond_update_time(bdrycond,para,t,f,displacement)
% function bdrycond = bdrycond_update_time(bdrycond,para,t,f,displacement)
%   updates the boundary-condition information according to time (and possibly changing rotor position) (to be invoked in each time step) here, in practice, the values of non-homogeneous Dirichlet boundary conditions and the air-gap interface conditions are updated
%
% Inputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    para               :       : parameters   (optional; default: empty)
%    t                  : [s]   : time         (optional; default: 0)
%    f                  : [Hz]  : frequency    (optional; default: empty)
%    displacement       : [m]   : displacement (optional; default: empty)
%
% Outputs
%    bdrycond           :       : data for boundary conditions (BCs)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if ~exist('para','var')
  para=struct;
end
if ~exist('t','var')
  t=0;
end
if ~exist('f','var')
  f=[];
end
if ~exist('displacement','var')
  displacement=0;
end

for bd=1:length(bdrycond)
  switch bdrycond(bd).type
    case 'dirichlet'
      if depends_on(bdrycond(bd).expression,'t')
        % time-dependent Dirichlet boundary condition
        bdrycond(bd).para.t=t;
      end
      if ~isempty(bdrycond(bd).expression)
        bdrycond(bd).data=para_eval(bdrycond(bd).expression,bdrycond(bd).para,para); % [A] : recalculate Dirichlet data
      else
        bdrycond(bd).data=bdrycond(bd).value;
      end
      if length(bdrycond(bd).data)==1
        bdrycond(bd).data=bdrycond(bd).value*ones(length(bdrycond(bd).idx),1);
      end
    case 'sibc'
      if isempty(f)
        error('frequency needed to update SIBCs');
      end
      mu=bdrycond(bd).sibc.mu;                                             % [H/m]   : permeability
      sigma=bdrycond(bd).sibc.sigma;                                       % [S/m]   : conductivity
      bdrycond(bd).sibc.delta=1/sqrt(pi*f*mu*sigma);                       % [m]     : skin depth
    case 'robin'
    case 'airgap'
      if isempty(displacement)
        error('displacement needed to update air-gap interface condition');
      end
      bdrycond(bd).airgap=airgap_operators(bdrycond(bd).airgap,displacement,0);
    case {'periodic','antiperiodic'}
    case 'dummy'
    otherwise
      error('Unknown boundary condition %s\n',bdrycond(bd).type);
  end
end
