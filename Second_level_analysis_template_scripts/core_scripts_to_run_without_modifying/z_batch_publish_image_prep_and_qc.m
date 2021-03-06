% Runs batch analyses and publishes HTML report with figures and stats to 
% results/published_output in local study-specific analysis directory.

% Run this from the main base directory (basedir)

close all
clear all

% ------------------------------------------------------------------------
% Set paths based on local study-specific base analysis directory.
% Add the study-specific scripts to the top of the path.
% Load saved data.

scriptname = fullfile(pwd, 'scripts', 'a_set_up_paths_always_run_first.m');

if ~exist(scriptname, 'file')
    error('Run from base directory (basedir) of 2nd-level analysis folder.');
else
    run(scriptname)
end

% Reload all saved data - but assume this has not been created yet, so re-run...
% b_reload_saved_matfiles           % done in indivdidual scripts to save output info in html, but re-run here so vars are available

% ------------------------------------------------------------------------


pubdir = fullfile(resultsdir, 'published_output');
if ~exist(pubdir, 'dir'), mkdir(pubdir), end

% ------------------------------------------------------------------------
pubfilename = ['data_prep_' scn_get_datetime];

p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 1600, ...
    'format', 'html', 'outputDir', fullfile(pubdir, pubfilename), 'showCode', false);

publish('z_batch_load_and_prep.m', p)