%% Performs a group analysis within averages in 16 unique networks
% This primarily demonstrates the method fmri_data.ttest_table_and_lateralization_test
% 
% 16 unique networks are derived from large-sampe resting-state fMRI. Networks are split by
% hemipshere and analyzed within L and R hemispheres.  In addition, 
% lateralization (R - L hem) within each network is analyzed. 
%
% Currently hard-coded for the 17 networks mapped to Schaefer/Yeo et al. 2018
% Cer Ctx (one network appears to be empty/missing), but could be extended to any 
% symmetric parcellation, and to subcortical parcellations.
%
% The example uses the emotion regulation data provided with
% CANlab_Core_Tools. This dataset consists of a set of contrast images for 
% 30 subjects from a first level analysis. The contrast is [reappraise neg vs. look neg],
% reappraisal of negative images vs. looking at matched negative images. 
%
% These data were published in:
% Wager, T. D., Davidson, M. L., Hughes, B. L., Lindquist, M. A., 
% Ochsner, K. N.. (2008). Prefrontal-subcortical pathways mediating 
% successful emotion regulation. Neuron, 59, 1037-50.
%
% By the end of this example we will have regenerated the results of figure
% 2A of this paper.

%% Executive summary of the whole analysis
%
% As a summary, here is a complete set of commands to load the data and run
% the entire analysis:

    img_obj = load_image_set('emotionreg');         % Load a dataset
    t = ttest(img_obj);                             % Do a group t-test
    t = threshold(t, .05, 'fdr', 'k', 10);          % Threshold with FDR q < .05 and extent threshold of 10 contiguous voxels
 
    % Show regions and print a table with labeled regions:
    montage(t);  drawnow, snapnow;                  % Show results on a slice display
    r = region(t);                                  % Turn t-map into a region object with one element per contig region
    table(r);                                       % Print a table of results using new region names
 
% Now, let's walk through it step by step.

%% Load sample data

% We can load this data using load_image_set(), which produces an fmri_data
% object. Data loading exceeds the scope of this tutorial, but a more
% indepth demosntration may be provided by load_a_sample_dataset.m

[image_obj, networknames, imagenames] = load_image_set('emotionreg');

%% Do a t-test

% Voxel-wise tests estimate parameters for each voxel independently. The
% fmri_data/ttest function performs this just like the native matlab
% ttest() function, and similarly returns a p-value and t-stat. Unlike the
% matlab ttest() function, fmri_data/ttest performs this for every voxel in
% the fmri_data object. All voxels are evaluated independently, but all are
% evaluated nonetheless. A statistic_image is returned.

t = ttest(image_obj);

%% Visualize the results
% There are many options. See methods(statistic_image) and methods(region)

orthviews(t)
drawnow, snapnow; 

% As can be seen, the ttest() result is unthresholded. The threshold
% function can be used to apply a desired alpha level using any of a number
% of methods. Here FDR is used to control for alpha=0.05. Note that no
% information is erased when performing thresholding on a statistic_image.

t = threshold(t, .05, 'fdr');
orthviews(t)
drawnow, snapnow; 

% Many neuroimaging packages (e.g., SPM and FSL) do one-tailed tests 
% (with one-tailed p-values) and only show you positive effects 
% (i.e., relative activations, not relative deactivations).  
% All the CANlab tools do two-sided tests, report two-tailed p-values. 
% By default, hot colors (orange/yellow) will show activations, and cool
% colors (blues) show deactivations.

% We can also apply an "extent threshold" of > 10 contiguous voxels:

t = threshold(t, .05, 'fdr', 'k', 10);
orthviews(t)
drawnow, snapnow; 

% montage is another visualization method. This function may require a
% relatively large amount of memory, depending on the resolution of the 
% anatomical underlay image you use. We recommend around 8GB of free memory. 
%
create_figure('montage'); 
montage(t)
drawnow, snapnow; 

%% Print a table of results

% First, we'll have to convert to another object type, a "region object".
% This object groups voxels together into "blobs" (often of contiguous
% voxels). It does many things that other object types do, and inter-operates
% with them closely.  See methods(region) for more info.

% Create a region objecft called "r", with contiguous blobs from the
% thresholded t-map:

r = region(t);

% Print the table:

table(r);

% You can get help and options for any object method, like "table". But
% because the method names are simple and often overlap with other Matlab functions 
% and toolboxes (this is OK for objects!), you will often want to specify
% the object type as well, as follows:

help region.table

%% Write the t-map to disk

% Now we need to save our results. You can save the objects in your
% workspace or you can write your resulting thresholded map to an analyze
% file. The latter may be useful for generating surface projections using 
% Caret or FreeSurfer for instance.
%
% Thresholding did not actually eliminate nonsignificant voxels from our 
% statistic_image object (t). If we  simply write out that object, we will 
% get t-statistics for all voxels. 

t.fullpath = fullfile(pwd, 'example_t_image.nii');
write(t)

% If we use the 'thresh' option, we'll write thresholded values:
write(t, 'thresh')

t_reloaded = statistic_image(t.fullpath, 'type', 'generic');
orthviews(t_reloaded)