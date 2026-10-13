unit PCM.ReminderRules;

interface

uses System.SysUtils;

function FindDueOccurrence(const AStart, ANow: TDateTime; AMinutesBefore: Integer;
  const ARule: string; out AOccurrence: TDateTime): Boolean;

implementation

uses System.DateUtils, System.StrUtils;

function RuleValue(const Rule, Key: string): string;
var Part: string;
begin
  Result := '';
  for Part in Rule.Split([';']) do
    if StartsText(Key + '=', Part) then
      Exit(Copy(Part, Length(Key) + 2, MaxInt));
end;

function InNumbers(const List: string; Value, MaxValue: Integer): Boolean;
var Part: string; N: Integer;
begin
  Result := List = '';
  for Part in List.Split([',']) do
  begin
    if not TryStrToInt(Part, N) then
      raise Exception.Create('Ungueltiger Wiederholungswert: ' + Part);
    if N < 0 then N := MaxValue + N + 1;
    if N = Value then Exit(True);
  end;
end;

function MatchesDay(const List: string; Day: TDateTime): Boolean;
const Names: array[1..7] of string = ('MO','TU','WE','TH','FR','SA','SU');
var Part, Name, Prefix: string; Ordinal: Integer;
begin
  Result := List = '';
  for Part in List.Split([',']) do
  begin
    if Length(Part) < 2 then raise Exception.Create('Ungueltiger BYDAY-Wert');
    Name := RightStr(Part, 2);
    if Name <> Names[DayOfTheWeek(Day)] then Continue;
    Prefix := LeftStr(Part, Length(Part) - 2);
    if Prefix = '' then Exit(True);
    if not TryStrToInt(Prefix, Ordinal) or (Ordinal = 0) then
      raise Exception.Create('Ungueltiger BYDAY-Index');
    if (Ordinal > 0) and (((DayOf(Day) - 1) div 7) + 1 = Ordinal) then Exit(True);
    if (Ordinal < 0) and (-((DaysInMonth(Day) - DayOf(Day)) div 7) - 1 = Ordinal) then Exit(True);
  end;
end;

function MatchesPosition(const Positions, Freq, ByDay, ByMonth, ByMonthDay: string;
  Start, Candidate: TDateTime; WeekStart: Integer): Boolean;
var FirstDay, LastDay, Day: TDateTime;
    Total, Position: Integer; Match: Boolean;
begin
  if Positions = '' then Exit(True);
  FirstDay := Candidate; LastDay := Candidate;
  if Freq = 'WEEKLY' then
  begin
    FirstDay := DateOf(Candidate) - ((DayOfTheWeek(Candidate)-WeekStart+7) mod 7);
    LastDay := IncDay(FirstDay,6);
  end;
  if Freq = 'MONTHLY' then begin FirstDay := StartOfTheMonth(Candidate); LastDay := DateOf(EndOfTheMonth(Candidate)); end;
  if Freq = 'YEARLY' then begin FirstDay := StartOfTheYear(Candidate); LastDay := DateOf(EndOfTheYear(Candidate)); end;
  Day := FirstDay; Total := 0; Position := 0;
  while Day <= LastDay do
  begin
    Match := InNumbers(ByMonth,MonthOf(Day),12) and
      InNumbers(ByMonthDay,DayOf(Day),DaysInMonth(Day)) and MatchesDay(ByDay,Day);
    if Freq = 'WEEKLY' then Match := Match and ((ByDay <> '') or (DayOfTheWeek(Day) = DayOfTheWeek(Start)));
    if Freq = 'MONTHLY' then Match := Match and ((ByDay <> '') or (ByMonthDay <> '') or (DayOf(Day) = DayOf(Start)));
    if Freq = 'YEARLY' then Match := Match and ((ByMonth <> '') or (MonthOf(Day) = MonthOf(Start))) and
      ((ByDay <> '') or (ByMonthDay <> '') or (DayOf(Day) = DayOf(Start)));
    if Match then
    begin
      Inc(Total);
      if DateOf(Day) = DateOf(Candidate) then Position := Total;
    end;
    Day := IncDay(Day);
  end;
  Result := (Position > 0) and InNumbers(Positions,Position,Total);
end;
function UntilDate(const Text: string): TDateTime;
var Y, M, D, H, N, S: Word;
begin
  if not (Length(Text) in [8,15,16]) then raise Exception.Create('Ungueltiger UNTIL-Wert');
  Y := StrToInt(Copy(Text,1,4)); M := StrToInt(Copy(Text,5,2)); D := StrToInt(Copy(Text,7,2));
  Result := EncodeDate(Y,M,D);
  if Length(Text) = 8 then Exit(EndOfTheDay(Result));
  H := StrToInt(Copy(Text,10,2)); N := StrToInt(Copy(Text,12,2)); S := StrToInt(Copy(Text,14,2));
  Result := Result + EncodeTime(H,N,S,0);
  if RightStr(Text,1) = 'Z' then Result := TTimeZone.Local.ToLocalTime(Result);
end;

function FindDueOccurrence(const AStart, ANow: TDateTime; AMinutesBefore: Integer;
  const ARule: string; out AOccurrence: TDateTime): Boolean;
var
  Rule, Freq, ByDay, ByMonth, ByMonthDay, Part, Key, Text: string;
  Interval, CountLimit, Count, Days, Months, Weeks, WeekStart: Integer;
  FirstDay, LastDay, Day, Occurrence, Due, Limit, BaseWeek, CandidateWeek: TDateTime;
  Match: Boolean;
begin
  Result := False;
  AOccurrence := 0;
  if (AMinutesBefore < 0) or (AMinutesBefore > 525600) then
    raise Exception.Create('Ungueltiger Erinnerungsvorlauf');
  Rule := UpperCase(Trim(ARule));
  if StartsText('RRULE:', Rule) then Delete(Rule,1,6);
  if Rule = '' then
  begin
    Due := IncMinute(AStart, -AMinutesBefore);
    Result := (Due <= ANow) and (Due >= IncMinute(ANow,-15));
    if Result then AOccurrence := AStart;
    Exit;
  end;
  for Part in Rule.Split([';']) do
  begin
    if Trim(Part) = '' then Continue;
    Key := Copy(Part,1,Pos('=',Part)-1);
    if not MatchText(Key,['FREQ','INTERVAL','BYDAY','BYMONTH','BYMONTHDAY','COUNT','UNTIL','WKST','BYSETPOS']) then
      raise Exception.Create('Nicht unterstuetzte Terminwiederholung: ' + Part);
  end;
  Freq := RuleValue(Rule,'FREQ');
  if not MatchText(Freq,['DAILY','WEEKLY','MONTHLY','YEARLY']) then
    raise Exception.Create('Nicht unterstuetzte Wiederholungsfrequenz: ' + Freq);
  Interval := 1; Text := RuleValue(Rule,'INTERVAL');
  if Text <> '' then Interval := StrToInt(Text);
  if Interval < 1 then raise Exception.Create('INTERVAL muss positiv sein');
  CountLimit := MaxInt; Text := RuleValue(Rule,'COUNT');
  if Text <> '' then CountLimit := StrToInt(Text);
  if CountLimit < 1 then raise Exception.Create('COUNT muss positiv sein');
  Limit := MaxDateTime; Text := RuleValue(Rule,'UNTIL');
  if Text <> '' then Limit := UntilDate(Text);
  ByDay := RuleValue(Rule,'BYDAY'); ByMonth := RuleValue(Rule,'BYMONTH');
  ByMonthDay := RuleValue(Rule,'BYMONTHDAY');
  WeekStart := 1;
  Text := RuleValue(Rule,'WKST');
  if Text = 'SU' then WeekStart := 7
  else if (Text <> '') and (Text <> 'MO') then raise Exception.Create('WKST wird nur fuer MO und SU unterstuetzt');
  FirstDay := DateOf(IncMinute(ANow, AMinutesBefore - 15));
  if CountLimit <> MaxInt then FirstDay := DateOf(AStart);
  if FirstDay < DateOf(AStart) then FirstDay := DateOf(AStart);
  LastDay := DateOf(IncMinute(ANow, AMinutesBefore));
  if LastDay - FirstDay > 73050 then raise Exception.Create('Terminserie liegt mehr als 200 Jahre zurueck');
  BaseWeek := DateOf(AStart) - ((DayOfTheWeek(AStart) - WeekStart + 7) mod 7);
  Count := 0;
  Day := FirstDay;
  while Day <= LastDay do
  begin
    Days := Trunc(Day) - Trunc(AStart);
    Months := (YearOf(Day)-YearOf(AStart))*12 + MonthOf(Day)-MonthOf(AStart);
    CandidateWeek := Day - ((DayOfTheWeek(Day)-WeekStart+7) mod 7);
    Weeks := Trunc((CandidateWeek-BaseWeek)/7);
    Match := False;
    if Freq = 'DAILY' then Match := Days mod Interval = 0;
    if Freq = 'WEEKLY' then
      Match := (Weeks mod Interval = 0) and ((ByDay <> '') or (DayOfTheWeek(Day) = DayOfTheWeek(AStart)));
    if Freq = 'MONTHLY' then
      Match := (Months mod Interval = 0) and ((ByDay <> '') or (ByMonthDay <> '') or (DayOf(Day) = DayOf(AStart)));
    if Freq = 'YEARLY' then
      Match := ((YearOf(Day)-YearOf(AStart)) mod Interval = 0) and
        ((ByMonth <> '') or (MonthOf(Day) = MonthOf(AStart))) and
        ((ByDay <> '') or (ByMonthDay <> '') or (DayOf(Day) = DayOf(AStart)));
    Match := Match and InNumbers(ByMonth,MonthOf(Day),12) and
      InNumbers(ByMonthDay,DayOf(Day),DaysInMonth(Day)) and MatchesDay(ByDay,Day);
    if Match then Match := MatchesPosition(RuleValue(Rule,'BYSETPOS'),Freq,ByDay,ByMonth,ByMonthDay,AStart,Day,WeekStart);
    Occurrence := Day + TimeOf(AStart);
    if Match and (Occurrence >= AStart) and (Occurrence <= Limit) then
    begin
      Inc(Count);
      if Count > CountLimit then Exit;
      Due := IncMinute(Occurrence,-AMinutesBefore);
      if (Due <= ANow) and (Due >= IncMinute(ANow,-15)) then
      begin
        AOccurrence := Occurrence;
        Exit(True);
      end;
    end;
    Day := IncDay(Day);
  end;
end;

end.