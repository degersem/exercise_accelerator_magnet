function bdrycond = bdrycond_initialise_from_femmdata(femmdata)
% function bdrycond = bdrycond_initialise_from_femmdata(femmdata)
%   initialises the boundary conditions after reading the FEMM data structure
%   this routine is independent from the FE mesh (except for the indication of the model length)
%
% Inputs
%    femmdata                : FEMM data
%
% Outputs
%    bdrycond                : boundary-conditions data structure
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

bdrycond=repmat(struct('type','none'),1,0);
if isfield(femmdata,'Frequency') & (sscanf(femmdata.Frequency,'%f')~=0)
  efffac=sqrt(2);
  warning('all Dirichlet values are divided by sqrt(2) (FEMM uses peak values, we use rms values)\n');
else
  efffac=1;
end
mu0=4*pi*1e-7;                                                             % [H/m]   : permeability of vacuum
for bd=1:length(femmdata.BdryProps)
  bdrycond(bd).name=femmdata.BdryProps(bd).BdryName;
  tpnum=sscanf(femmdata.BdryProps(bd).BdryType,'%d');
  switch tpnum
    case 0                % Prescribed A
      bdrycond(bd).type='dirichlet';
      bdrycond(bd).value=sscanf(femmdata.BdryProps(bd).A_0,'%f')*femmdata.Depth/efffac;
      bdrycond(bd).expression=[];
    case 1                % Small Skin Depth
      bdrycond(bd).type='sibc';
      bdrycond(bd).sibc=struct('mu',mu0*sscanf(femmdata.BdryProps(bd).Mu_ssd,'%f'),'sigma',sscanf(femmdata.BdryProps(bd).Sigma_ssd,'%f')*1e6); % FACTOR 1e6 because FEMM calculates conductivities in MS/m
    case 2                % Mixed
      bdrycond(bd).type='robin';
    case {3,4,5}          % (Anti-)periodic boundary conditions
      switch tpnum
        case 3              % Strategic dual image (here use as the air-gap interface condition
          % the air-gap cut is introduced before, hence, there are a number of arcs present in the geometry
          bdrycond(bd).type='airgap';
        case 4              % Periodic boundary condition
          bdrycond(bd).type='periodic';
          bdrycond(bd).X=1;
        case 5              % Anti-periodic boundary condition
          bdrycond(bd).type='antiperiodic';
          bdrycond(bd).X=-1;
      end
    case 6
      bdrycond(bd).type='dummy';
    otherwise
      error('Unknown type number %d for boundary condition %s\n',tpnum,bdrycond(bd).name);
  end
end

end
