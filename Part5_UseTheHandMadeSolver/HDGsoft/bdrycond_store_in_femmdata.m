function BdryProps = bdrycond_store_in_femmdata(bdrycond,lz,frm)
% function BdryProps = bdrycond_store_in_femmdata(bdrycond,lz,frm)
%   initialises the boundary conditions after reading the FEMM data structure
%   this routine is independent from the FE mesh
%
% Inputs
%    bdrycond                : boundary-conditions data structure
%    lz                      : [m]  : model length
%    frm                     : formulation
%        frequency           : [Hz]  : frequency
 %
% Outputs
%    BdryProps               : boundary conditions (as in FEMM data)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

mu0=4*pi*1e-7;                                                             % [H/m]   : permeability of vacuum
BdryProps=repmat(struct('BdryName','"Z"','BdryType','0',...
  'A_0','0','A_1','0','A_2','0','Phi','0',...
  'c0','0','c0i','0','c1','0','c1i','0',...
  'Mu_ssd','0','Sigma_ssd','0'),1,length(bdrycond));                       % []      : default values
for bd=1:length(bdrycond)
  BdryProps(bd).BdryName=bdrycond(bd).name;
  switch bdrycond(bd).type
    case 'dirichlet'
      BdryProps(bd).BdryType='0';                % Prescribed A
      if frm.frequency==0.0
        BdryProps(bd).A_0=sprintf('%f',bdrycond(bd).value/lz);             % FACTOR 1/lz because FEMM stores magnetic vector potentials instead of line-integrated magnetic vector potentials
      else
        BdryProps(bd).A_0=sprintf('%f',bdrycond(bd).value/lz*sqrt(2));     % FACTOR sqrt(2) because FEMM uses peak values instead of rms values
      end
    case 'sibc'
      BdryProps(bd).BdryType='1';                % Small Skin Depth
      BdryProps(bd).Mu_ssd=sprintf('%f',bdrycond(bd).sibc.mu/mu0);
      BdryProps(bd).Sigma_ssd=sprintf('%f',bdrycond(bd).sibc.sigma/1e6);   % FACTOR 1e6 because FEMM calculates conductivities in MS/m
    case 'robin'
      BdryProps(bd).BdryType='2';                % Mixed
    case 'airgap'
      BdryProps(bd).BdryType='3';                % Strategic dual image (here use as the air-gap interface condition
    case 'periodic'
      BdryProps(bd).BdryType='4';                % Periodic boundary condition
    case 'antiperiodic'
      BdryProps(bd).BdryType='5';                % Anti-periodic boundary condition
    otherwise
      warning('Non-standard boundary-condition type %s, store in FEMM by a default Dirichlet boundary condition\n',bdrycond(bd).name);
  end
end

end
