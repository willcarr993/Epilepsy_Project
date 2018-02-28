function GenerateStimSets (subject)
%1-64 = Set1
%65-128 = Set2
%129-192 = Set3

global Parm;

Set1 = 1:64; Set1_Offset = 0;
Set2 = 65:128; Set2_Offset = 64;
Set3 = 129:192; Set3_Offset = 128;

NPerList = 64;
%         Study    R,L,F
% Group1: S=1,2  T=1,2,3;
% Group2: S=1,2  T=2,1,3;
% Group3: S=1,3  T=1,3,2;
% Group4: S=1,3  T=3,1,2;
% Group5: S=2,3  T=2,3,1;
% Group6: S=2,3  T=3,2,1;

group = mod(subject-1,6) + 1;

Parm.Group = group;
Parm.Subjnum = subject;

% Setup study lists for each group

if ((group == 1) || (group == 2)) % Group1: S=1,2  % Group2: S=1,2
    for (i=Set1)
        Parm.StudyList(i - Set1_Offset) = cellstr(sprintf('%.3d',i));
    end
    for (i=Set2)
        Parm.StudyList(i - Set2_Offset + NPerList) = cellstr(sprintf('%.3d',i));
    end
end
if ((group == 3) || (group == 4)) % Group3: S=1,3  % Group4: S=1,3
    for (i=Set1)
        Parm.StudyList(i - Set1_Offset) = cellstr(sprintf('%.3d',i));
    end
    for (i=Set3)
        Parm.StudyList(i - Set3_Offset + NPerList) = cellstr(sprintf('%.3d',i));
    end
end
if ((group == 5) || (group == 6)) % Group5: S=2,3  % Group6: S=2,3
    for (i=Set2)
        Parm.StudyList(i-Set2_Offset) = cellstr(sprintf('%.3d',i));
    end
    for (i=Set3)
        Parm.StudyList(i-Set3_Offset+NPerList) = cellstr(sprintf('%.3d',i));
    end
end

% Now we set up target lists for testing in each group

if (group == 1) % Group1: T=1,2,3;
    for (i=Set1)
        Parm.TargetList(i - Set1_Offset) = cellstr(sprintf('%.3d',i)); % repeat
    end
    for (i=Set2)
        Parm.LureList(i - Set2_Offset) = cellstr(sprintf('%.3d',i)); % lure
    end
    for (i=Set3)
        Parm.FoilList(i - Set3_Offset) = cellstr(sprintf('%.3d',i)); % new
    end
end
if (group == 2) % Group2:  T=2,1,3;
    for (i=Set2)
        Parm.TargetList(i - Set2_Offset) = cellstr(sprintf('%.3d',i)); 
    end
    for (i=Set1)
        Parm.LureList(i - Set1_Offset) = cellstr(sprintf('%.3d',i)); 
    end
    for (i=Set3)
        Parm.FoilList(i - Set3_Offset) = cellstr(sprintf('%.3d',i)); 
    end
end
if (group == 3) % Group3: T=1,3,2;
    for (i=Set1)
        Parm.TargetList(i - Set1_Offset) = cellstr(sprintf('%.3d',i));
    end
    for (i=Set3)
        Parm.LureList(i - Set3_Offset) = cellstr(sprintf('%.3d',i));
    end
    for (i=Set2)
        Parm.FoilList(i - Set2_Offset) = cellstr(sprintf('%.3d',i));
    end
end
if (group == 4) % Group4: T=3,1,2;
    for (i=Set3)
        Parm.TargetList(i - Set3_Offset) = cellstr(sprintf('%.3d',i));
    end
    for (i=Set1)
        Parm.LureList(i - Set1_Offset) = cellstr(sprintf('%.3d',i));
    end
    for (i=Set2)
        Parm.FoilList(i - Set2_Offset) = cellstr(sprintf('%.3d',i));
    end
end
if (group == 5) % Group5: T=2,3,1;
    for (i=Set2)
        Parm.TargetList(i - Set2_Offset) = cellstr(sprintf('%.3d',i));
    end
    for (i=Set3)
        Parm.LureList(i - Set3_Offset) = cellstr(sprintf('%.3d',i));
    end
    for (i=Set1)
        Parm.FoilList(i - Set1_Offset) = cellstr(sprintf('%.3d',i));
    end
end
if (group == 6) % Group6: T=3,2,1;
    for (i=Set3)
        Parm.TargetList(i - Set3_Offset) = cellstr(sprintf('%.3d',i));
    end
    for (i=Set2)
        Parm.LureList(i - Set2_Offset) = cellstr(sprintf('%.3d',i));
    end
    for (i=Set1)
        Parm.FoilList(i - Set1_Offset) = cellstr(sprintf('%.3d',i));
    end
end


