clear

pattern='.set'
dir_name='/Users/amandine_work/Documents/MATLAB/RBD/N23 files/'
%save_ext='SW detected'
save_ext='SS detected'

%[Output,Info]=swa_batchProcessing(dir_name,pattern,save_ext)

[Output,Info]=swa_batchProcessing_SS(dir_name,pattern,save_ext)



%%%%%

a=struct('wave_density',        Output.wave_density, ...
        'wavelength',           Output.wavelength, ...
        'amplitude',           Output.amplitude, ...
        'globality',           Output.globality, ...
        'topo_density',         Output.topo_density, ...
         'travel_angle',        Output.travel_angle, ...
        'slope',       Output.slope, ...
        'code', []);
    
      