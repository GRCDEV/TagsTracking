% A simple test program of the Simulate_Airtag function using the NCCU trace.
clear;

c_radio = 10;
Days = 2;
Dur_min = 10;
OneDay = 3600*24; 
dt = 1;
only_first = true;
verbose = false;

load('NCCU_trace_full.mat','ONETrace');

ONETrace(:,1) = ONETrace(:,1)-ONETrace(1,1);

% First day was Wednesday

% First: extract a portion of the trace (three days)
trace = ONETrace_extract_from_interval(ONETrace,0,OneDay*(Days));
trace(:,1) = trace(:,1)-trace(1,1);
    
% Second: generate paths from the trace
[Paths,Vt] = Generate_Paths_ONETrace(trace,dt);

NumTags = length(Paths); 
% Generate a vector with the nodes that are going to lose the AirTags.
% The vector contains the nodes, the lost and aware times when the AirTags are lost lost
% TagsLost = [1,1000; 2,10000; 5,30000];
for i=1:NumTags
    tl = randi([0,12*60*60]); % 0 to 12 hours
    ta = tl + randi([30,2*60*60]); % 30 min to 2 hours
    TagsLost(i,:) = [i,tl,ta];
end

% Fourth: simulate that a given number of Airtags are lost and when they are detected.
[TagsFound, TagsNotFound] = Simulate_Airtags(Paths,Vt,TagsLost,c_radio, only_first, verbose);

fprintf('NumTags: %d; Found: %d, NotFound: %d\n', NumTags, size(TagsFound,1), size(TagsNotFound,1));







