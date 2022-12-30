function [vs_node,v_t] = Generate_Paths_ONETrace(ONE_trace,time_step)
% From a ONE's simulator position trace , generate the location of all the 
% nodes using interpoletion with a resolution of time_step seconds
% INPUT: (al values in m, s, and m/s.)
%    ONE_trace: Trace is in the following format :
%        Time in seconds, ID, Latitude (m), Longitude (m)
%    time_step : time step used to generate the points in s.
% RETURNS:
%    vs_node: an array of structs with the location of all the nodes. 
%             The index of the array and the struct has two fields:
%             v_x: vector with the x-positions at time_step seconds.
%             v_y: the same for y-positions
%    v_t: vector with the time associated with the locations (with the time
%             step given)


    ONE_trace = sortrows(ONE_trace,2);   % Sort by node number
    Sim_time = max(ONE_trace(:,1)); 
    
    nodeIndex = 0;
    i_start = 1;
    nodeID = ONE_trace(1,2);
    num_points = length(ONE_trace); 

    v_t = 0:time_step:Sim_time;
    
    for i = 1:num_points
        if nodeID ~= ONE_trace(i,2) || i == num_points
            try
                nodeIndex = nodeIndex + 1;
                V_TIME = ONE_trace(i_start:i-1,1);
                V_POSITION_Y = ONE_trace(i_start:i-1,3);
                V_POSITION_X = ONE_trace(i_start:i-1,4);
                % Assure that first and last time has position
                if V_TIME(1) > 0
                    V_TIME = [0; V_TIME; ]; 
                    V_POSITION_Y = [V_POSITION_Y(1); V_POSITION_Y];
                    V_POSITION_X = [V_POSITION_X(1); V_POSITION_X];
                end

                if V_TIME(end) < Sim_time
                    V_TIME = [V_TIME; Sim_time]; 
                    V_POSITION_Y = [V_POSITION_Y; V_POSITION_Y(end)];
                    V_POSITION_X = [V_POSITION_X; V_POSITION_X(end)];
                end

                %Simple interpolation (linear) to get the position, anytime.
                %Remember that "interp1" is the matlab function to use in order to
                %get nodes' position at any continuous time.
                vs_node(nodeIndex).v_x = interp1(V_TIME,V_POSITION_X,v_t);
                vs_node(nodeIndex).v_y = interp1(V_TIME,V_POSITION_Y,v_t);   

                nodeID = ONE_trace(i,2);
                i_start = i;
                             
            catch 
                fprintf('Exception nodeIndex = %u\n', nodeIndex);
            end

        end

    end
end
