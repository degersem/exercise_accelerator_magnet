function xi_addmaterial(matname,prp0,varargin)

% function XI_ADDMATERIAL(matname,prp0,varargin)
% adds a material to the model
%
% input parameters
%     matname                   : material name
%     prp0                      : properties independent of the problem type
%     varargin                  : additional properties dependent on the problem type
%
% replacement for
%
%     mi_addmaterial(matname,mu_x,mu_y,H_c,J,Cduct,Lam_d,Phi_hmax,lam_fill,LamType,Phi_hx,Phi_hy,nstr,dwire)
%         matname               :          : material name
%         mu_x                  : []       : relative permeability in the x- or r-direction
%         mu_y                  : []       : relative permeability in the y- or z-direction
%         H_c                   : [A/m]    : permanent magnet coercivity
%         J           UNIT !!!  : [A/mm^2] : applied source current density (USE DEPRECIATED !!!)
%         Cduct       UNIT !!!  : [MS/m]   : electrical conductivity
%         Lam_d       UNIT !!!  : [mm]     : lamination thickness
%         Phi_hmax    UNIT !!!  : [deg]    : hysteresis lag angle, used for nonlinear BH curves
%         Lam_fill              : []       : fraction of the volume occupied per lamination that is actually filled with iron
%                               :          : (Note that this parameter defaults to 1 in the femm preprocessor dialog box
%                               :          : because, by default, iron completely fills the volume)
%         Lamtype               : []       : lamination type
%                               :          : 0 – Not laminated or laminated in plane
%                               :          : 1 – laminated x or r
%                               :          : 2 – laminated y or z
%                               :          : 3 – magnet wire
%                               :          : 4 – plain stranded wire
%                               :          : 5 – Litz wire
%                               :          : 6 – square wire
%         Phi_hx      UNIT !!!  : [deg]    : hysteresis lag in the x-direction for linear problems
%         Phi_hy      UNIT !!!  : [deg]    : hysteresis lag in the y-direction for linear problems
%         nstr                  : [#]      : number of strands in the wire build. Should be 1 for Magnet or Square wire
%         dwire       UNIT !!!  : [mm]     : diameter of each of the wire’s constituent strand
%
%     ei_addmaterial(matname, ex, ey, qv)
%         matname               :          : material name
%         ex                    : []       : relative permittivity in the x- or r-direction
%         ey                    : []       : relative permittivity in the y- or z-direction
%         qv                    : [C/m^3]  : volume charge density
%
%     hi_addmaterial(matname, kx, ky, qv, kt)
%         matname               :          : material name
%         kx                    : [W/(mK)] : thermal conductivity in the x- or r-direction
%         ky                    : [W/(mK)] : thermal conductivity in the y- or z-direction
%         qv                    : [W/m3]   : volume heat generation density
%         kt          UNIT !!!  : [MJ/(m3K)] : volumetric heat capacity
% 
%     ci_addmaterial(matname, ox, oy, ex, ey, ltx, lty)
%         matname               :          : material name
%         ox                    : [S/m]    : electrical conductivity in the x- or r-direction
%         oy                    : [S/m]    : electrical conductivity in the y- or z-direction
%         ex                    : []       : relative permittivity in the x- or r-direction
%         ey                    : []       : relative permittivity in the y- or z-direction
%         ltx                   : []       : dielectric loss tangent in the x- or r-direction
%         lty                   : []       : dielectric loss tangent in the y- or z-direction.

global xa_formulation;
switch xa_formulation.problemtype
  case 'magnetic'
    prp=xa_gatherprop(struct('mu_x',1,'mu_y',1,'H_c',0,'J',0,'Cduct',0,...
      'Lam_d',0,'Phi_hmax',0,'lam_fill',1,'LamType',0,'Phi_hx',0,'Phi_hy',0,'nstr',1,'dwire',0),prp0,varargin{:});
    if ischar(matname)
      mi_addmaterial(matname,prp.mu_x,prp.mu_y,prp.H_c,prp.J,prp.Cduct,...
        prp.Lam_d,prp.Phi_hmax,prp.lam_fill,prp.LamType,prp.Phi_hx,prp.Phi_hy,prp.nstr,prp.dwire);
    elseif iscell(matname)
      prp=xa_repprop(prp,length(matname));
      for mt=1:length(matname)
        mi_addmaterial(matname{mt},prp.mu_x(mt),prp.mu_y(mt),prp.H_c(mt),prp.J(mt),prp.Cduct(mt),...
          prp.Lam_d(mt),prp.Phi_hmax(mt),prp.lam_fill(mt),prp.LamType(mt),prp.Phi_hx(mt),prp.Phi_hy(mt),prp.nstr(mt),prp.dwire(mt));
      end
    else
      error('unsuitable material name type');
    end
  case 'electric'
    prp=xa_gatherprop(struct('ex',1,'ey',1,'qv',0),prp0,varargin{:});
    if ischar(matname)
      ei_addmaterial(matname,prp.ex,prp.ey,prp.qv);
    elseif iscell(matname)
      prp=xa_repprop(prp,length(matname));
      for mt=1:length(matname)
        ei_addmaterial(matname{mt},prp.ex(mt),prp.ey(mt),prp.qv(mt));
      end
    else
      error('unsuitable material name type');
    end
  case 'thermal'
    prp=xa_gatherprop(struct('kx',1,'ky',1,'qv',0,'kt',0),prp0,varargin{:});
    if ischar(matname)
      hi_addmaterial(matname,prp.kx,prp.ky,prp.qv,prp.kt);
    elseif iscell(matname)
      prp=xa_repprop(prp,length(matname));
      for mt=1:length(matname)
        hi_addmaterial(matname{mt},prp.kx(mt),prp.ky(mt),prp.qv(mt),prp.kt(mt));
      end
    else
      error('unsuitable material name type');
    end
  case 'electrokinetic'
    prp=xa_gatherprop(struct('ox',1,'oy',1,'ex',0,'ey',0,'ltx',0,'lty',0),prp0,varargin{:});
    if ischar(matname)
      ci_addmaterial(matname,prp.ox,prp.oy,prp.ex,prp.ey,prp.ltx,prp.lty);
    elseif iscell(matname)
      prp=xa_repprop(prp,length(matname));
      for mt=1:length(matname)
        ci_addmaterial(matname{mt},prp.ox(mt),prp.oy(mt),prp.ex(mt),prp.ey(mt),prp.ltx(mt),prp.lty(mt));
      end
    else
      error('unsuitable material name type');
    end
  
  otherwise
    error('Unknown problem type');
end
