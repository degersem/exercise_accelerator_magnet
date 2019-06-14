function [Brcff,lambda]=aperture_fieldquality(mesh,ufem,rref,tol,plotflag)

%% A. Parameter control
if ~exist('tol','var')
  tol=1e-3;                                                                % []     : relative tolerance for detecting nodes at the reference circle
end
if ~exist('plotflag','var')
  plotflag=0;
end
if isempty(tol)
  tol=1e-3;
end

%% B. Extract the field at the reference contour
[theta,r];                                  % XXX                          % [rad,m]: angles and radii of all mesh nodes
idx;                                        % XXX                          % []     : indices of all nodes at the reference circle
[theta,idx2];                               % XXX                          % [rad,] : sorted list of angles
idx;                                        % XXX                          % []     : sorted list of indices
Azref=ufem(idx)/mesh.lz;                                                   % [Tm]   : z-component of the magnetic vector potential along the reference circle
if plotflag
  figure(4); clf; plot(theta,Azref,'bx'); xlabel('angle (rad)'); ylabel('Az (Tm)'); title('magnetic vector potential along the reference circle');
end

%% C. Interpolate the field data
numpoint=16;                                                               % [#]    : number of interpolation points
thetaval=linspace(0,pi/2,numpoint+1)';                                     % [rad]  : new set of azimuthal coordinates
Azref;                                      % XXX                          % cubic spline interpolation of the characteristic

%% D. Extend to a full period
Azrefhalf;                                  % XXX
Azreffull;                                  % XXX                          % [Tm]   : complete periodic signal
numfft=length(Azreffull);                                                  % [#]    : number of harmonic components
thetafull;                                  % XXX                          % [rad]  : complete azimuthal axis

%% E. FFT and magnetic flux density
Azcff;                                      % XXX                          % [Tm]   : double-sided spectrum for the z-component of the magnetic vector potential
lambda=[[0:numfft/2]';[-numfft/2+1:-1]'];                                  % []     : harmonic orders
Brcff;                                      % XXX                          % [T]    : double-sided spectrum for the radial component of the magnetic flux density
if plotflag
  figure(4); hold on; plot(thetafull,Azreffull,'b-');
  figure(5); clf; bar(lambda,[real(Azcff) imag(Azcff)]); xlabel('harmonic order'); ylabel('Az (Tm)'); legend('normal','skew');
  figure(6); clf; bar(lambda,[real(Brcff) imag(Brcff)]); xlabel('harmonic order'); ylabel('Br (T)');  legend('normal','skew');
  Brcffharmonic=Brcff; Brcffharmonic(2)=0; Brcffharmonic(end)=0;
  figure(7); clf; bar(lambda,[real(Brcffharmonic) imag(Brcffharmonic)]); xlabel('harmonic order'); ylabel('Br (T)'); legend('normal','skew');
end
