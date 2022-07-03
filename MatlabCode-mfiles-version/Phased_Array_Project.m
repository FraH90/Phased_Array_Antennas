% INIT WORKSPACE AND COMMAND WINDOW
clear;
clc;
%%
% SET WORK FREQUENCY AND OTHER PARAMETERS
f0 = 2.4*10^9;                  % Standard WiFi, Bluetooth, etc frequency
WLratio = 0.05;                 % Ratio Width/Length of the single dipole element
BWrel = 0.05;                   % Bandwidth percentual relative to center freq f0
numelem = 20;                   % Number of elements that compose the antenna array
dspacingrel = 0.25;             % Spacing between each element of the array, in 
                                % wavelengths units

%%
% EVALUATE WAVELENGTH, SINGLE ELEMENT PARAMETERS AND OTHER STUFF
c = physconst('lightspeed');
lambda0 = c/f0;
ldip = lambda0/2;
wdip = WLratio*ldip;
fmin = f0 - BWrel*f0/2;
fmax = f0 + BWrel*f0/2;

alpha_broadside = 0;            % Parameter that controls the maximum direction in 
                                % the broadside configuration
alpha_backfire = rad2deg( (2*pi)*(dspacingrel) );
alpha_endfire = - alpha_backfire;

indexvect = (0:1:(numelem -1));
phasevector_broad = indexvect*alpha_broadside;
phasevector_efire = indexvect*alpha_endfire;
phasevector_bfire = indexvect*alpha_backfire;
%%
% CREATE A STRIP DIPOLE ELEMENT, AND TUNE IT TO THE SPECIFIED BANDWIDTH RANGE; 
% THEN SHOW RADIATION PATTERN AND CURRENT DISTRIBUTION ON THE SINGLE ELEMENT
dip_elem = dipole('Length', ldip, 'Width', wdip)

fig_1a_dipshow = figure('Name','Single Element');
dip_elem.show;
axis tight
title('Single Element');

fig_1b_zin = figure('Name', 'Impedance of the single element');
impedance(dip_elem, linspace(1e9,3e9,101) );
title('Impedance of the single element');

fig_1c_zintun = figure('Name', 'Impedance of the single tuned element');
dip_elem = dipole_tuner(dip_elem, f0, fmin, fmax, 0.01, 0.001)
title('Impedance of the single tuned element');

fig_1d_curr = figure('Name', 'Current Distribution on the single element');
current(dip_elem,f0);
title('Current Distribution on the single element');

fig_1e_ptrndip = figure('Name', 'Radiation Pattern of the single element');
pattern(dip_elem,f0);
title('Radiation Pattern of the single element');

fig_1f_azptrndip = figure('Name', 'Azimuthal radiation pattern of the single element');
patternAzimuth(dip_elem,f0);
title('Azimuthal radiation pattern of the single element');

fig_1g_elptrndip = figure('Name', 'Elevation radiation pattern of the single element');
patternElevation(dip_elem,f0);
title('Elevation radiation pattern of the single element');

fig_1h_bmwdip = figure('Name', 'Beamwidth of the single element');
beamwidth(dip_elem, f0, 0, 1:0.1:360);
title('Beamwidth of the single element');
%%
% CREATE AN ANTENNA ARRAY OF N ELEMENTARY DIPOLE, AND CONFIGURE IT AS BROADSIDE
AntArray = linearArray('Element', dip_elem, 'NumElements', numelem);
AntArray.ElementSpacing = dspacingrel*lambda0;
AntArray.AmplitudeTaper = 1;

fig_2a_brsarr = figure('Name', 'Antenna Array Structure');
AntArray.show();
title('Antenna Array Structure');

fig_2b_brsarrlt = figure('Name', 'Array Layout');
AntArray.layout();
title('Array Layout');

fig_2c_brsarrptrn = figure('Name', 'Array Broadside radiation pattern');
AntArray.pattern(f0);
title('Array Broadside radiation pattern');

fig_2d_brsarrazptrn = figure('Name', 'Array Broadside radiation azimuth-plane pattern');
patternAzimuth(AntArray, f0);
title('Array Broadside radiation azimuth-plane pattern');

fig_2e_brsrectptrn = figure('Name', 'Array Broadside rect radiation pattern');
azimuth = 0:0.25:180;
pattern(AntArray, f0, azimuth, 0, 'CoordinateSystem', 'rectangular');
axis([0 180 -20 20]);
%%
% RECONFIGURE THE PREVIOUS ARRAY AS ENDFIRE
AntArray.PhaseShift = phasevector_efire;

fig_3a_efptrn = figure('Name', 'Array Endfire radiation pattern');
AntArray.pattern(f0);
title('Array Endfire radiation pattern');

fig_3b_efazptrn = figure('Name', 'Array Endfire Azimuth-plane radiation pattern');
AntArray.patternAzimuth(f0);
title('Array Endfire Azimuth-plane radiation pattern');

fig_3c_efrectptrn = figure('Name', 'Array Endfire rect radiation pattern');
azimuth = -180:0.25:180;
pattern(AntArray, f0, azimuth, 0, 'CoordinateSystem', 'rectangular');
axis([-180 180 -20 20]);
%%
% RECONFIGURE THE PREVIOUS ARRAY AS BACKFIRE AND PLOT PATTERNS
AntArray.PhaseShift = phasevector_bfire;

fig_4a_bckfptrn = figure('Name', 'Array Backfire radiation pattern');
AntArray.pattern(f0);
title('Array Backfire radiation pattern');

fig_4b_bckfazptrn = figure('Name', 'Array Backfire Azimuth-plane radiation pattern');
AntArray.patternAzimuth(f0);
title('Array Backfire Azimuth-plane radiation pattern');

fig_4c_bckfrectptrn = figure('Name', 'Array Backfire rect radiation pattern');
azimuth = 0:0.25:360;
pattern(AntArray, f0, azimuth, 0, 'CoordinateSystem', 'rectangular');
axis([0 360 -20 20]);
%%
% ARRAY SCAN: ALPHA FROM -beta*dspacing TO beta*dspacing (FROM ENDFIRE TO BROADSIDE TO
% BACKFIRE)

% Creating vectors with elements from one vector to another spaced by 5 deg
NumSteps = 50;
delta = 180/NumSteps;
alpha_scan = alpha_endfire:delta:alpha_backfire;
phasevector_scan = phasevector_efire;
azimuth = 0:0.25:360;

fig_temp_a = figure('visible', 'off');
fig_temp_b = figure('visible', 'off');
fig_temp_c = figure('visible', 'off');

gif_3dview = 'phased_array_scan_3dview.gif';
gif_polar_azimuth = 'phased_array_scan_polar.gif';
gif_cartesian_azimuth = 'phased_array_scan_cartesian.gif';


for i = 1:(NumSteps+1)
    
    % plot the azimuth-plane pattern for the current phasevector_scan
    phasevector_scan = indexvect*alpha_scan(1,i);
    AntArray.PhaseShift = phasevector_scan;
    
    % Draw azimuth polar pattern
    figure(fig_temp_a);
    AntArray.patternAzimuth(f0);
    
    % get the image file from the plot; convert it to proper format for gif
    drawnow
    frame_pol = getframe(fig_temp_a);
    img_pol = frame2im(frame_pol);
    [imind_pol,cm_pol] = rgb2ind(img_pol,256);
    
    % Write to the GIF File 
      if i == 1 
          imwrite(imind_pol,cm_pol,gif_polar_azimuth,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind_pol,cm_pol,gif_polar_azimuth,'gif','WriteMode','append'); 
      end
      
      
    % draw 3d view pattern
    figure(fig_temp_b);
    AntArray.pattern(f0);
    
    % get the image file from the plot; convert it to proper format for gif
    drawnow
    frame_3dv = getframe(fig_temp_b);
    img_3dv = frame2im(frame_3dv);
    [imind_3dv,cm_3dv] = rgb2ind(img_3dv,256);
    
    % Write to the GIF File 
      if i == 1 
          imwrite(imind_3dv,cm_3dv,gif_3dview,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind_3dv,cm_3dv,gif_3dview,'gif','WriteMode','append'); 
      end
      
    
    % cartesian directivity pattern
    figure(fig_temp_c);
    pattern(AntArray, f0, azimuth, 0, 'CoordinateSystem', 'rectangular');
    axis([0 360 -20 20]);
    
    % get the image file from the plot; convert it to proper format for gif
    drawnow
    frame_cart = getframe(fig_temp_c);
    img_cart = frame2im(frame_cart);
    [imind_cart,cm_cart] = rgb2ind(img_cart,256);
    
    % Write to the GIF File 
      if i == 1 
          imwrite(imind_cart,cm_cart,gif_cartesian_azimuth,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind_cart,cm_cart,gif_cartesian_azimuth,'gif','WriteMode','append'); 
      end
end