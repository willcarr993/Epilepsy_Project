%:::::::::::::::::: now record data
fid = fopen (datafile,'a');
for i=1:nScript
    fprintf (fid, '%3d %7d   %2d   %3d %3d   %3d     ', subject);
    fprintf (fid, ' %.0f', scriptID(i,1));
    fprintf (fid, ' %.0f', scriptCond(i,1));
    for j=1:onsetsPerScript
        fprintf (fid, ' %7.3f', onsetTimesTot(i,j));
    end
    fprintf(fid,'   ');
    for j=1:respPerScript
        fprintf (fid, ' %7.3f', kpTot(i,j));
    end
    fprintf(fid,'   ');
    for j=1:respPerScript
        fprintf (fid, ' %3d', responsesTot(i,j));
    end
    fprintf (fid,'\n');
end
fclose(fid);