function [F,M] = eggshell(mesh,gamma,B,xy0)

% function [F,M] = eggshell(mesh,gamma,B,xy0)
% calculates the force and the torque using the eggshell method
%
% input parameters
%    mesh            : 2D FE mesh
%    gamma           : level-set function (one value per mesh node)
%                    :     between 0 and 1
%                    :     1 for the domain on which the force and the torque are exerted
%                    :     0 for the standstill domain
%    B               : [T]   : magnetic flux density
%    xy0             : [m]   : rotation axis (optional; default: [ 0 0 ])
%
% output parameters
%    F               : [N]   : force
%    M               : [Nm]  : torque

if ~exist('xy0','var'), xy0 = [ 0 0 ]; end

if isa(gamma,'function_handle')
  gamma = gamma(mesh.node(:,1),mesh.node(:,2));
end

mu0 = 4*pi*1e-7;                                                           % [H/m]   : permeability of air
xym = (mesh.node(mesh.elem(:,1),1:2)+mesh.node(mesh.elem(:,2),1:2)+mesh.node(mesh.elem(:,3),1:2))/3 ...
  -ones(size(mesh.elem,1),1)*xy0;                                          % [m]     : coordinates of the element centre points
Ng = grad(mesh,gamma);                                                     % [1/m]   : gradient of the level-set function
xm = xym(:,1);    Ngx = Ng(:,1);    Bx = B(:,1);                           % shortcuts
ym = xym(:,2);    Ngy = Ng(:,2);    By = B(:,2);                           % shortcuts
fx = -((Bx.^2-By.^2)/2.*Ngx+By.*Bx.*Ngy)/mu0;                              % [N/m^3] : force density in x-direction
fy = -(Bx.*By.*Ngx+(By.^2-Bx.^2)/2.*Ngy)/mu0;                              % [N/m^3] : force density in y-direction
F = mesh.lz*sum(mesh.area*[ 1 1 ].*[ fx fy ],1);                           % [N]     : force
M = mesh.lz*sum(mesh.area.*(xm.*fy-ym.*fx),1);                             % [Nm]    : torque
