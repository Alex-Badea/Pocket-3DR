function cfg = wbs_default_cfg()
%WBS_DEFAULT_CFG  Default configuration options for wide base stereo matcher.
%
%   cfg = wbs_default_cfg
%
%   Output:
%     cfg .. structure with options requred by WBS matcher functions.

% (c) 2010-09-01, Michal Perdoch
% Last change: $Date::                            $
%              $Revision$

cfg.detector = 7;
cfg.desc_factor = 3.0;
cfg.estimate_angle = 1;
cfg.output_format = 2;
cfg.threshold = 5;
cfg.compute_descriptor = 1;


cfg.min_margin = 10;
cfg.min_size = 30;
cfg.max_area = 0.01;

cfg.second_closest = 0.8;
cfg.max_distance = 300;
cfg.matching_strategy = 1;
