function [H,nu,nud,dnudB2,wmagn,wmagnco]=BH_Brauer(data,B,plotflag)

% function [H,nu,nud,dnudB2,Wmagn,Wmagnco]=BH_BRAUER(data,B,plotflag)
% evaluates a magnetisation curve defined by John R. Brauer
%
% John R. Brauer, "Simple Equations for the Magnetization and
% Reluctivity Curves of Steel", IEEE Transactions on Magnetics,
% Vol. 11, No. 1, January 1975, p. 81.
%
% Johan Gyselinck, "Twee-Dimensionale Dynamische Eindige-Elementenmodellering
% van Statische en Roterende Elektromagnetische Energieomzetters", PhD,
% Universiteit Gent, 2000.
%
% The magnetisation curve reads
%      H = (k1*exp(k2*B^2)+k3)*B
%
% Typical values are    k1 [m/H]     k2 [1/T^2]    k3 [m/H]
%        TEAM13         0.3774       2.970         388.33
%        VH800-65D      0.0596       3.504         122.87
%
% the output values can be used for linearisation in the operating point:
%      H = nu B                   (used e.g. for successive substitution)
%      H = Hc + nud * B           (used e.g. for Newton)
%
% input parameters
%       data        : data for the knee-point magnetisation curve
%           k1          : [m/H]   : parameter 1
%           k2          : [1/T^2] : parameter 2
%           k3          : [m/H]   : parameter 3
%       B           : abscis input value determine the working point
%       plotflag    : []       : 0: no plot; 1: plot with B-axis, 2: plot with H-axis
%
% output parameters
%       H           : [A/m]    : ordinate output value
%       nu          : [A/Tm]   : chord reluctivity        : slope between the (0,0) data point and the working point
%       nud         : [A/Tm]   : differential reluctivity : slope of the line tangential to the nonlinear characteristic at the working point
%       dnudB2      : [A/mT^3] : derivative of the reluctivity with respect to the square of the magnetic flux density
%       wmagn       : [J/m^3]  : magnetic energy density
%       wmagnco     : [J/m^3]  : magnetic energy density
%
% see also NONLINEAR, UPDATE_PROPERTY
%
% IMPORTANT: this implementation suffers from a wrong extrapolation for large B

%% A. Parameter control
if nargin<3
  plotflag=0;
end
mu0=4*pi*1e-7;                                 % [H/m]   : permeability of vacuum
nu0=1/mu0;                                     % [m/H]   : reluctivity of vacuum
if isempty(data)
  data=struct('k1',0.3774,'k2',2.970,'k3',388.33);     % TEAM13 material (J. Gyselinck)
  %data=struct('k1',0.0596,'k2',3.504,'k3',122.87);     % VH800-65D       (J. Gyselinck)
  %data=struct('k1',49.4,'k2',1.46,'k3',520.6);         % cast            (J. Brauer)
  %data=struct('k1',2.6,'k2',2.72,'k3',154.4);          % annealed        (J. Brauer)
  %data=struct('k1',3.8,'k2',2.17,'k3',396.2);          % cold rolled     (J. Brauer)
end
% Blimit=sqrt(log((nu0-data.k3)/data.k1)/data.k2);        % [T]   : limit magnetic flux density beyond which a linear extrapolation is used
Bm=[0:0.1:10]';
nud=data.k3+data.k1*exp(data.k2*Bm.^2).*(1+data.k2*2*Bm.^2);       % [m/H]   : differential reluctivity
Blimit=Inf;
%Blimit=Bm(min(find(nud>nu0))-1);
%Blimit=Bm(min(find(nud>nu0)));
Hlimit=(data.k1*exp(data.k2*Blimit^2)+data.k3)*Blimit;  % [A/m] : limit magnetic field strength   
Hclimit=Hlimit-nu0*Blimit;                              % [A/m] : coercitive field strength at the limit operation point
wmagnlimit=data.k1/(2*data.k2)*(exp(data.k2*Blimit^2)-1)+data.k3*Blimit^2/2;

%% B. Compute
% B.1. Sizes, dimensions and index sets
[num,dim]=size(B);                               % [#,#]   : number of material cells and dimension
[Bm,Bangle]=pyth(B);                             % [T,rad] : magnitude and angle of the magnetic flux density
idxleft=find(Bm<Blimit);                         % []      : indices of the points for which the Brauer curve should be used
idxright=find(Bm>=Blimit);                       % []      : indices for which a linear extrapolation is used
% B.2. Initialisation
Hm=zeros(num,1);                                 % [A/m]   : magnitude of the magnetic field strength
nu=zeros(num,1);                                 % [m/H]   : chord reluctivity
nud=zeros(num,1);                                % [m/H]   : differential reluctivity
% B.3. Before the limit operation point
nu(idxleft)=data.k1*exp(data.k2*Bm(idxleft).^2)+data.k3;  % [m/H]   : chord reluctivity
Hm(idxleft)=nu(idxleft).*Bm(idxleft);            % [A/m]   : magnitude of the magnetic field strength
nud(idxleft)=data.k3+data.k1*exp(data.k2*Bm(idxleft).^2).*(1+data.k2*2*Bm(idxleft).^2);       % [m/H]   : differential reluctivity
% B.4. Beyond the limit operation point
Hm(idxright)=Hclimit+nu0*Bm(idxright);           % [A/m]   : magnitude of the magnetic field strength
nu(idxright)=Hm(idxright)./Bm(idxright);         % [m/H]   : chord reluctivity
nud(idxright)=nu0;
% B.5. Magnetic field strength
H=Bangle.*(Hm*ones(1,dim));                      % [A/m]   : magnetic field strength
% B.4. Incremental reluctivity
if (nargout>=4) | plotflag
  dnudB2=savedivide(nud-nu,2*Bm.^2);             % [A/mT^3]: incremental reluctivity
end
% B.5. Magnetic energy density
if (nargout>=5) | plotflag
  wmagn=zeros(num,1);                            % [J/m^3] : magnetic energy density
  wmagn(idxleft)=data.k1/(2*data.k2)*(exp(data.k2*Bm(idxleft).^2)-1)+data.k3*Bm(idxleft).^2/2;
  wmagn(idxright)=wmagnlimit+conj(Hm(idxright)+Hlimit).*(Bm(idxright)-Blimit)/2;
end
% B.6. Magnetic co-energy density
if (nargout>=6) | plotflag
  wmagnco=conj(Hm).*Bm-wmagn;                    % [J/m^3] : magnetic co-energy density
end

%% C. Plots
%plot_materialcharacteristic(plotflag,B,H,nu,nud,dnudB2,wmagn,wmagnco);
