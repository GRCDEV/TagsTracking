function [TagsFound,TagsNotFound] = Simulate_Airtags(Paths,Vt,TagsLost,c_radio,only_first, verbose)
% Using the location of all the nodes simulated the lost and found of the tags
% INPUT: (al values in m, s, and m/s.)
%    Paths: an array of structs with the location of all the nodes. 
%             The index of the array and the struct have two fields:
%             v_x: vector with the x-positions at time_step seconds.
%             v_y: the same for y-positions
%    Vt: vector with the time associated with the locations (with the time
%             step given)
%    TagsLost: The matrix contains the time when the AirTags are to be lost.
%              Three columns: [node who lose the Tags, time when it is lost, 
%                               time when the user is aware of its lost]
%    c_radio : detection radio (meters)
%    only_first: add to TagsFound only the fisrt contact.
% RETURNS:
%    TagsFound: Matrix of contacts with airtags [t, airtag_i, node_j, posx, posy]
%               t: time when it is found
%               airtag_i: index of the airtag (node who lost it)
%               node_j: node who has found it
%               posx, posy: coordinates where the airtag was found
%    TagsNotFound: Matrix of airtags not found [t, airtag_i, posx, posy]
%               t: time when it is lost
%               airtag_i: index of the airtag (node who lost it)
%               posx, posy: coordinates where the airtag was lost

    function d = dist_puntos(x1,y1,x2,y2)
        d = sqrt((x2-x1)^2+(y2-y1)^2);
    end

    if nargin<=5
        verbose = false;
    end
    if nargin<=4
        only_first = false;
    end
    
    Tam_vt = length(Vt);
    NumNodes = length(Paths);
    NumTags = size(TagsLost,1);
    

    % Create a matrix with the location of all tags lost
    %  Four columns: time, pos_x, pos_y
    PosTagsLost = ones(NumTags,3)*inf;
    % A vector that indicates if a tags has been found or not 
    FoundTagsLost = zeros(NumTags,1);    
    
    PosXYNodes = zeros(NumNodes,2);
    
    in_contact = zeros(NumNodes, NumTags);
    TagsFound = [];
    iContacts = 0;

    if ~verbose
        fprintf('       ');
    end
    for timeIndex = 1:Tam_vt
        if ~verbose
             if mod(timeIndex,100) == 0
                 fprintf('\b\b\b\b\b\b\b%6.2f%%',100*timeIndex/Tam_vt);
             end
        end
        t = Vt(timeIndex);
        %  First update position of nodes for time t
        for i = 1:NumNodes
            PosXYNodes(i,:) = [Paths(i).v_x(timeIndex), Paths(i).v_y(timeIndex)];  
        end

        % Second: check for new airtags lost
        for iTag = 1:NumTags
            iNode = TagsLost(iTag,1);
            if TagsLost(iTag,2)<=t && PosTagsLost(iTag,1)==inf
                if verbose
                    fprintf('%5.2f Airtag of node %d lost at (%5.2f,%5.2f)\n', t, iNode, PosXYNodes(iNode,1), PosXYNodes(iNode,2) );
                end             
                PosTagsLost(iTag,:)=[TagsLost(iTag,3),PosXYNodes(iNode,1), PosXYNodes(iNode,2)];
            end
        end

        % Third: detect the Airtags
        for i = 1:NumNodes
            pos_x = PosXYNodes(i,1);
            pos_y = PosXYNodes(i,2);           
            for iTag = 1:NumTags
                if only_first && ~FoundTagsLost(iTag)
                    j = TagsLost(iTag,1);  % j is the node who lost the tag
                    if  PosTagsLost(iTag,1) <= t && i ~= j
                        % Check if the node is near to 
                        pos_x2 = PosTagsLost(iTag,2);
                        pos_y2 = PosTagsLost(iTag,3);
                        dist = dist_puntos(pos_x, pos_y, pos_x2, pos_y2);   
                        if in_contact(i,iTag) > 0                      
                            if dist > c_radio 
                                in_contact(i,iTag) = 0;
                            end
                        elseif dist <= c_radio 
                            if verbose 
                                fprintf('%5.2f Detection of airtag %d by node %d at (%5.2f, %5.2f)\n', t, j, i, pos_x, pos_y);
                            end
                            in_contact(i,iTag) = t;
                            iContacts = iContacts + 1;
                            TagsFound(iContacts,:) = [ t, j, i, pos_x, pos_y];
                            FoundTagsLost(iTag) = true; 
                        end
                    end
                end
            end
        end
    end
    if ~verbose
        fprintf('\b\b\b\b\b\b\b');
    end
    
    TagsNotFound = [];
    for iTag = 1:NumTags
        if ~FoundTagsLost(iTag)
            TagsNotFound = [TagsNotFound; [ TagsLost(iTag,2), TagsLost(iTag,1), PosTagsLost(iTag,2), PosTagsLost(iTag,3)]];
        end
    end
end
