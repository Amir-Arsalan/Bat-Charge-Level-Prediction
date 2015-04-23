function interval = findTimeInterval(userBatSeqRecord, granularity)

%{

This function finds the interval of the time for one record of the user battery
sequences (userBatSeq) in accordance with a granularity

Input:
userBatSeqRecord: a record of userBatSeq with the size 1 x 7 where the
first three elements correspond to day, hour and minute respectively which
that record belong to
granularity: The time granularity (in minutes)

Output:
interval: a number indicating which interval the userBatSeqRec belongs to
%}

userBatSeqRecord = single(userBatSeqRecord);
interval = ceil(((userBatSeqRecord(1)-1) * 24 * 60 + userBatSeqRecord(2) * 60 + userBatSeqRecord(3)) / granularity);

end