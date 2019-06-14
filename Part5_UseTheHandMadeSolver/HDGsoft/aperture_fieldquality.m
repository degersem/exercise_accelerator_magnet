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
[theta,r]=cart2pol(mesh.node(:,1),mesh.node(:,2));                         % [rad,m]: angles and radii of all mesh nodes
idx=find(abs(r-rref)/rref<tol);                                            % []     : indices of all nodes at the reference circle
[theta,idx2]=sort(theta(idx));                                             % [rad,] : sorted list of angles
idx=idx(idx2);                                                             % []     : sorted list of indices
Azref=ufem(idx)/mesh.lz;                                                   % [Tm]   : z-component of the magnetic vector potential along the reference circle
if plotflag
  figure(4); clf; plot(theta,Azref,'bx'); xlabel('angle (rad)'); ylabel('Az (Tm)'); title('magnetic vector potential along the reference circle');
end

%% C. When not equidistant, interpolate
if 0                                                                       %        : check whether theta is equidistant
  toltheta=1e-3;                                                           % []     : relative tolerance for checking that theta is equidistant
  dtheta=mean(diff(theta));                                                % [rad]  : angular stride
  if any(abs(diff(theta)-dtheta)/dtheta>=toltheta)
    error('theta not equidistant');
  end
end
numpoint=16;
thetaval=linspace(0,pi/2,numpoint+1)';
Azref=ppval(spline(theta,Azref),thetaval);                                 % cubic spline interpolation of the characteristic

%% D. Extend to a full period
Azrefhalf=[Azref; -flipud(Azref(2:end-1))];
Azreffull=[Azrefhalf; -Azrefhalf];                                         % [Tm]   : periodic signal
numfft=length(Azreffull);                                                  % [#]    : number of harmonic components
% numfft=16;  % for testing
thetafull=linspace(0,2*pi,numfft+1)'; thetafull=thetafull(1:numfft,1);
% rref=25e-3; pp=1; Azreffull=30e-3*cos(pp*thetafull);

%% E. FFT and magnetic flux density
Azcff=fft(Azreffull)/numfft;                                               % [Tm]   : double-sided spectrum for the z-component of the magnetic vector potential
lambda=[[0:numfft/2]';[-numfft/2+1:-1]'];                                  % []     : harmonic orders
Brcff=sqrt(-1)*lambda.*Azcff/rref;                                         % [T]    : double-sided spectrum for the radial component of the magnetic flux density
if plotflag
  figure(4); hold on; plot(thetafull,Azreffull,'b-');
  figure(5); clf; bar(lambda,[real(Azcff) imag(Azcff)]); xlabel('harmonic order'); ylabel('Az (Tm)'); legend('normal','skew');
  figure(6); clf; bar(lambda,[real(Brcff) imag(Brcff)]); xlabel('harmonic order'); ylabel('Br (T)');  legend('normal','skew');
  Brcffharmonic=Brcff; Brcffharmonic(2)=0; Brcffharmonic(end)=0;
  figure(7); clf; bar(lambda,[real(Brcffharmonic) imag(Brcffharmonic)]); xlabel('harmonic order'); ylabel('Br (T)'); legend('normal','skew');
end
