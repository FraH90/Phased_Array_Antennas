function a = dipole_tuner(d,f,fmin,fmax,s,t)
%DIPOLE_TUNER is used to optimize a dipole close to first resonance.
% A = DIPOLE_TUNER(D,F,S,T), returns an optimized dipole
% for operation near its first resonance, given the unoptimized dipole, D,
% the frequency of operation, the stopping criterion S and the trim factor
% T. The trim factor reduces the length of the antenna by a factor of (1-t)
% at each iteration.
% The DIPOLE_TUNER function is used for an internal example.
% Its behavior may change in subsequent releases, so it should not be
% relied upon for programming purposes.

% Copyright 2014 The MathWorks, Inc.


% Check inputs 
validateattributes(f,{'numeric'},{'vector','nonempty','real',     ...
                                        'finite','nonnan','positive',   ...
                                        'nonzero'});
                                    
validateattributes(s,{'numeric'},{'vector','nonempty',      ...
                                  'real','finite','nonnan','positive',  ...
                                  'nonzero'});
                                    
validateattributes(t,{'numeric'},{'vector','nonempty','real',  ...
                                        'finite','nonnan','positive',   ...
                                        'nonzero'});                                    
if ~isa(d,'dipole')                                  
    objClass = class(d);
    error(message('antenna:antennaerrors:InvalidValue','first argument d',...
                  'dipoleFolded or dipole rather',...
                   objClass));
end

dp              = d;
Z               = impedance(dp,f);
imagZ           = imag(Z);
iterCount       = 1;
while (abs(imagZ(end))>s)&&(sign(imagZ(end))==1)
    dp.Length           = dp.Length*(1-t);
    Z                   = impedance(dp,f);
    tempZ               = imag(Z);
    iterCount           = [iterCount iterCount(end)+1]; %#ok<AGROW>
    imagZ               = [imagZ tempZ]; %#ok<AGROW>
end
a   = d;

% Impedance plot
fsweep    = sort([linspace(fmin-(fmin*.25),fmax+(fmax*.25),201) f]);
Z         = impedance(dp,fsweep);
Xpos      = min(imag(Z(imag(Z)>0)));
fpos      = min(fsweep((imag(Z)>0)));
Xneg      = max(imag(Z(imag(Z)<=0)));
fneg      = max(fsweep(((imag(Z)<=0))));
if abs(Xpos)<abs(Xneg)
    f_res  = fpos;
else
    f_res  = fneg;
end
markerlim = [min(min(real(Z)),min(imag(Z))),max(max(real(Z)),max(imag(Z)))];
marker1    = linspace(markerlim(1),markerlim(2),21);
fig_zintuned = figure('Name', 'Impedance of the single tuned element');
impedance(dp,fsweep)
axis tight
hold on
plot(f_res.*ones(1,21)./1e9,marker1,'m-.','LineWidth',2)
textInfo = [ ' \leftarrow' num2str(f_res/1e9) 'GHz'];
text(f_res/1e9,0.95*markerlim(2),textInfo,'FontSize',11)
hold off
saveas(fig_zintuned, 'fig_zintuned.jpg')
end % of dipole_tuner
