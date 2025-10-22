unit PCM.Calc;

interface
////////////////////////////////////////////////////////////////////////////////
// Deklaration                                                                //
////////////////////////////////////////////////////////////////////////////////
{$Region Deklaration}
// Functions
function GetBuchungsart(ATyp,AMitarbeiter: integer; AVon,ABis: TDate) : integer;
function GetFehltagSumKik(AFeiertag, ATyp, ABezahlt, ASoll,AMitarbeiter: integer;AVon,ABis:TDate) : double;
function GetFehltagSum(AFeiertag, ATyp, ABezahlt,AMitarbeiter: integer;AVon,ABis:TDate) : double;
function GetFehltagTage(AID_Fehltage,AMitarbeiter: integer) : double;
function GetFeiertage(AMitarbeiter: Integer;AVon,ABis: TDate): double;
function GetMehrarbeitVorMonat(AMitarbeiter,AJahr,AMonat: integer): integer;
function GetMonthName(AMonat: integer) : String;
function GetPersonalSollStunden(AMitarbeiter: Integer): double;
function GetResturlaub(AMitarbeiter,AJahr,AMonat: integer) : double;
function GetTimeValue(AValue: integer) : String;
function GetULAnspruch(AMitarbeiter: Integer): double;
function GetULVorjahr(AMitarbeiter,AJahr,AMonat: integer) : double;
function GetULVorMonat(AMitarbeiter,AJahr,AMonat: integer) : double;
// Proceduren
procedure BerechneMonat(AMonat,AJahr,AMitarbeiter: integer);
procedure BerechneMonate(AMitarbeiter: integer);
procedure BerechneTage(ATag,AMonat,AJahr,AMitarbeiter: integer);
procedure StartBooking(AMitarbeiter: integer;ACaption,AMessage,ALocation: String;AStart,AFinish: TDateTime; ACalCol,AFontCol: integer);
procedure WriteMonatswert(AMitarbeiter:Integer;ARest: Double;AaktGLZ,AMonat,AJahr,ASollzeit,AIStzeit,AMehrarbeit,APausen,AFeiertag: integer; AUrlaub_bezahlt,AUrlaub_unbezahlt,AKrank_bezahlt,AKrank_unbezahlt: double);
{$EndRegion Deklaration}
implementation

uses
{$Region Uses}
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Async,
  FireDAC.Stan.Error,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  PCM.Data,
  PCM.Functions.Synch.Wait,
  PCM.Strings,
  PCM.Main,
  System.Classes,
  System.DateUtils,
  System.Sysutils,
  System.Variants,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Menus,
  Vcl.StdCtrls,
  Winapi.Messages,
  Winapi.Windows;
{$EndRegion Uses}
// Functions
{$Region Functions}
function GetMonthName(AMonat: integer) : String;
begin
  case AMonat of
  1: result:= 'Januar';
  2: result:= 'Februar';
  3: result:= 'März';
  4: result:= 'April';
  5: result:= 'Mai';
  6: result:= 'Juni';
  7: result:= 'Juli';
  8: result:= 'August';
  9: result:= 'September';
  10: result:= 'Oktober';
  11: result:= 'November';
  12: result:= 'Dezember';
  end;
end;
function GetTimeValue(AValue: integer) : String;
var
  iHour,iMin: integer;
  sHour,sMin: String;
begin
  iHour:= AValue div 60;
  iMin:= AValue mod 60;
  sHour:= IntToStr(iHour);
  if iMin < 10 then
    sMin:= '0' + IntToStr(iMin)
  else
    sMin:= IntToStr(iMin);
  if Length(sHour) = 1 then
    sHour:= '0' + sHour;
  result:= sHour + ':' + sMin
end;
function GetBuchungsart(ATyp,AMitarbeiter: integer; AVon,ABis: TDate) : integer;
var
  qry_BA: TFDQuery;
  conn: TFDConnection;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    try
      qry_BA:= TFDQuery.Create(nil);
      qry_BA.Connection:= dm_PCM.con_PCM;

      qry_BA.SQL.Text:= 'SELECT Count(*) as Anzahl ' +
                        'FROM time_buchungen zeb ' +
                        'LEFT OUTER JOIN time_Fehltag zeft ON zeft.Kuerzel = zeb.Fehltag ' +
                        'WHERE Kommen <> ''00:00'' and  zeb.Datum >= :Von and zeb.Datum <= :Bis AND Buchungsart = :Typ and zeb.ID_Benutzer = :ID';
      qry_BA.ParamByName('Von').asDate:= AVon;
      qry_BA.ParamByName('Bis').asDate:= ABis;
      qry_BA.ParamByName('Typ').asInteger:= ATyp;
      qry_BA.ParamByName('ID').asInteger:= AMitarbeiter;
      qry_BA.open;
      Result:= qry_BA.FieldByName('Anzahl').AsInteger;
      qry_BA.close;
    finally
      qry_BA.free;
    end;
  finally
    conn.free;
  end;
end;
function GetFehltagSumKik(AFeiertag, ATyp, ABezahlt,ASoll,AMitarbeiter: integer;AVon,ABis:TDate) : double;
var
  qry_FTSumKik: TFDQuery;
  conn: TFDConnection;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    try
      qry_FTSumKik:= TFDQuery.Create(nil);
      qry_FTSumKik.Connection:= dm_PCM.con_PCM;
      qry_FTSumKik.SQL.Text:=  'SELECT Count(*) as Anzahl ' +
                         'FROM time_buchungen zeb ' +
                         'LEFT OUTER JOIN time_Fehltag zeft ON zeft.Kuerzel = zeb.Fehltag ' +
                         'WHERE  Zeb.ID_benutzer = :ID and zeb.Feiertag <> :Feiertag and zeb.Datum >= :Von and zeb.Datum <= :Bis AND zeft.Typ = :Typ AND zeft.Bezahlt = :Bezahlt AND zeft.SollAbziehen = :Soll';
      qry_FTSumKik.ParamByName('Von').asDate:= AVon;
      qry_FTSumKik.ParamByName('Bis').asDate:= ABis;
      qry_FTSumKik.ParamByName('Feiertag').AsInteger:= AFeiertag;
      qry_FTSumKik.ParamByName('Typ').AsInteger:= ATyp;
      qry_FTSumKik.ParamByName('Bezahlt').AsInteger:= ABezahlt;
      qry_FTSumKik.ParamByName('Soll').AsInteger:= ASoll;
      qry_FTSumKik.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_FTSumKik.open;
      result:= qry_FTSumKik.FieldByName('Anzahl').AsFloat;
      qry_FTSumKik.close;
    finally
      qry_FTSumKik.free;
    end;
  finally
    conn.free;
  end;
end;
function GetFehltagSum(AFeiertag, ATyp, ABezahlt,AMitarbeiter: integer;AVon,ABis:TDate) : double;
var
  qry_FTSum: TFDQuery;
  conn: TFDConnection;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    try
      qry_FTSum:= TFDQuery.Create(nil);
      qry_FTSum.Connection:= dm_PCM.con_PCM;
      qry_FTSum.SQL.Text:=  'SELECT Sum(Zeb.SollstundenI / zeft.faktor) / (HOUR(zzp.Sollzeit) * 60) + Minute(zzp.Sollzeit) as Anzahl  ' +
                       'FROM time_buchungen zeb ' +
                       'LEFT OUTER JOIN time_buchung zeb1 ON zeb1.ID = zeb.ID_Buchung ' +
                       'LEFT OUTER JOIN time_zeitplan zzp ON zzp.id = zeb1.ID_Tagesplan ' +
                       'LEFT OUTER JOIN time_Fehltag zeft ON zeft.Kuerzel = zeb.Fehltag ' +
                       'WHERE zeb.ID_Benutzer =:ID and zeb.Feiertag <> :Feiertag AND zzp.Sollzeit <> ''00:00'' AND zeb.Sollstunden = zzp.Sollzeit and zeb.Datum >= :Von and zeb.Datum <= :Bis AND zeft.Typ = :Typ AND zeft.Bezahlt = :Bezahlt';
      qry_FTSum.ParamByName('Von').asDate:= AVon;
      qry_FTSum.ParamByName('Bis').asDate:= ABis;
      qry_FTSum.ParamByName('Feiertag').AsInteger:= AFeiertag;
      qry_FTSum.ParamByName('Typ').AsInteger:= ATyp;
      qry_FTSum.ParamByName('Bezahlt').AsInteger:= ABezahlt;
      qry_FTSum.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_FTSum.open;
      result:= qry_FTSum.FieldByName('Anzahl').AsFloat;
      qry_FTSum.close;
    finally
      qry_FTSum.free;
    end;
  finally
    conn.free;
  end;
end;
function GetFehltagTage(AID_Fehltage,AMitarbeiter: integer) : double;
var
  qry_FTDay: TFDQuery;
  conn: TFDConnection;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    try
      qry_FTDay:= TFDQuery.Create(nil);
      qry_FTDay.Connection:= dm_PCM.con_PCM;
      qry_FTDay.SQL.Text:=  'Select Sum(TIMESTAMPDIFF(SECOND,''1970-01-01 00:00:00'',ADDTIME(CONVERT(''1970-01-01'', DATETIME), zeb.Sollstunden)) / 60 / ((HOUR(zzp.Sollzeit) * 60) + Minute(zzp.Sollzeit)) / zeft.Faktor) as Anzahl ' +
                         'FROM time_buchungen zeb ' +
                         'LEFT OUTER JOIN time_buchung zeb1 ON zeb1.ID = zeb.ID_Buchung ' +
                         'LEFT OUTER JOIN time_zeitplan zzp ON zzp.id = zeb1.ID_Tagesplan ' +
                         'LEFT OUTER JOIN time_Fehltag zeft ON zeft.Kuerzel = zeb.Fehltag ' +
                         'WHERE zeb.id_benutzer = :ID and zeb.Feiertag <> 1 AND zeb.Sollstunden = zzp.Sollzeit AND zzp.Sollzeit <> ''00:00'' and ID_Fehltage = :IDFT';
      qry_FTDay.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_FTDay.ParamByName('IDFT').AsInteger:= AID_Fehltage;
      qry_FTDay.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_FTDay.open;
      result:= qry_FTDay.FieldByName('Anzahl').AsFloat;
      qry_FTDay.close;
    finally
      qry_FTDay.free;
    end;
  finally
    conn.free;
  end;
end;
function GetFeiertage(AMitarbeiter: integer;AVon,ABis: TDate) : double;
var
  qry_Holiday: TFDQuery;
  conn: TFDConnection;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    try
      qry_Holiday:= TFDQuery.Create(nil);
      qry_Holiday.Connection:= dm_PCM.con_PCM;
      qry_Holiday.SQL.Text:= 'SELECT Sum(if(Feiertag = 2, 0.5,1)) AS Anzahl ' +
                        'FROM time_buchungen zeb ' +
                        'LEFT OUTER JOIN time_buchung zeb1 ON zeb1.ID = zeb.ID_Buchung ' +
                        'LEFT OUTER JOIN time_zeitplan zzp ON zzp.id = zeb1.ID_Tagesplan ' +
                        'WHERE zeb.ID_Benutzer = :ID AND zzp.Sollzeit <> ''00:00'' and zeb.Sollstunden = zzp.Sollzeit and zeb.Datum >= :Von and zeb.Datum <= :Bis AND zeb.feiertag > 0';
      qry_Holiday.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_Holiday.ParamByName('Von').asDate:= AVon;
      qry_Holiday.ParamByName('Bis').asDate:= ABis;
      qry_Holiday.open;
      Result:= qry_Holiday.FieldByName('Anzahl').AsFloat;
      qry_Holiday.close;
    finally
      qry_Holiday.free;
    end;
  finally
    conn.free;
  end;
end;
function GetMehrarbeitVorMonat(AMitarbeiter,AJahr,AMonat: integer): integer;
var
  qry_MA: TFDQuery;
  conn: TFDConnection;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    qry_MA:= TFDQuery.Create(nil);
    try
      qry_MA.Connection:= dm_PCM.con_PCM;
      qry_MA.SQL.Text:= 'Select aktuelleMehrarbeit From time_Monatswerte Where ID_Benutzer = :ID and Jahr = :Jahr and Monat = :Monat';
      qry_MA.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_MA.ParamByName('Jahr').AsInteger:= AJahr;
      qry_MA.ParamByName('Monat').AsInteger:= AMonat;
      qry_MA.open;
      result:= qry_MA.FieldByName('aktuelleMehrarbeit').AsInteger;
      qry_MA.close;
    finally
      qry_ma.Free;
    end;
  finally
    conn.free;
  end;
end;
function GetPersonalSollStunden(AMitarbeiter: Integer): double; //JA
var
  qry_Soll: TFDQuery;
  conn: TFDConnection;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    try
      qry_Soll:= TFDQuery.Create(nil);
      qry_Soll.Connection:= dm_PCM.con_PCM;
      qry_Soll.SQL.Text:= 'Select TIME_TO_SEC(SollStunden) / 3600 AS SollStunden From time_user Where ID = :ID';
      qry_Soll.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_Soll.open;
      result:= qry_Soll.FieldByName('Sollstunden').AsFloat;
      qry_Soll.close;
    finally
      qry_Soll.free;
    end;
  finally
    conn.free;
  end;
end;
function GetResturlaub(AMitarbeiter,AJahr,AMonat: integer) : double;
var
  qry_Rul: TFDQuery;
  conn: TFDConnection;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    try
      qry_Rul:= TFDQuery.Create(nil);
      qry_Rul.Connection:= dm_PCM.con_PCM;
      qry_Rul.SQL.Text:= 'Select Resturlaub From time_Monatswerte Where Monat = :Monat and Jahr = :Jahr and ID_Benutzer = :ID';
      qry_Rul.ParamByName('Jahr').AsInteger:= AJahr;
      qry_Rul.ParamByName('Monat').AsInteger:= AMonat;
      qry_Rul.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_Rul.open;
      result:= qry_Rul.FieldByName('Resturlaub').AsFloat;
      qry_Rul.close;
    finally
      qry_Rul.free;
    end;
  finally
    conn.free;
  end;
end;
function GetULAnspruch(AMitarbeiter: Integer): double;
var
  qry_UL: TFDQuery;
  conn: TFDConnection;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    try
      qry_UL:= TFDQuery.Create(nil);
      qry_UL.Connection:= dm_PCM.con_PCM;
      qry_UL.SQL.Text:= 'Select Urlaub From time_user Where ID = :ID';
      qry_UL.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_UL.open;
      result:= qry_UL.FieldByName('Urlaub').AsFloat;
      qry_UL.Close;
    finally
      qry_UL.free;
    end;
  finally
    conn.free;
  end;
end;
function GetULVorjahr(AMitarbeiter,AJahr,AMonat: integer) : double;
var
  qry_ULVJ: TFDQuery;
  qry_ULOff: TFDQuery;
  conn: TFDConnection;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    try
      qry_ULVJ:= TFDQuery.Create(nil);
      qry_ULVJ.Connection:= dm_PCM.con_PCM;
      qry_ULVJ.SQL.Text:= 'Select Resturlaub From time_Monatswerte Where ID_Benutzer = :ID and Jahr = :Jahr and Monat = :Monat';
      qry_ULVJ.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_ULVJ.ParamByName('Jahr').AsInteger:= AJahr;
      qry_ULVJ.ParamByName('Monat').AsInteger:= AMonat;
      qry_ULVJ.open;
      result:= qry_ULVJ.FieldByName('Resturlaub').AsFloat;
      qry_ULVJ.Close;
    finally
      qry_ULVJ.free;
    end;
    qry_ULOff:= TFDQuery.Create(nil);
    qry_ULOff.Connection:= dm_PCM.con_PCM;
    try
      qry_ULOff.SQL.Text:= 'SELECT OffsetResturlaubJahr,OffsetResturlaub From time_user where ID =:ID';
      qry_ULOff.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_ULOff.Open;
      var fOffsetResturlaub:= qry_ULOff.FieldByName('OffsetResturlaub').AsFloat;
      var iOffsetResturlaubJahr:= qry_ULOff.FieldByName('OffsetResturlaubJahr').AsInteger;
      qry_ULOff.Close;
      if (iOffsetResturlaubJahr = AJahr) and (AMonat = 12) then
      begin
        Result:= fOffsetResturlaub;
      end;
    finally
      qry_ULOff.free;
    end;
  finally
    conn.free
  end;
end;
function GetULVormonat(AMitarbeiter,AJahr,AMonat: integer) : double;
var
  qry_ULVM: TFDQuery;
  conn: TFDConnection;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    try
      qry_ULVM:= TFDQuery.Create(nil);
      qry_ULVM.Connection:= dm_PCM.con_PCM;
      qry_ULVM.SQL.Text:= 'Select Resturlaub From time_Monatswerte Where ID_Benutzer = :ID and Jahr = :Jahr and Monat = :Monat';
      qry_ULVM.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_ULVM.ParamByName('Jahr').AsInteger:= AJahr;
      qry_ULVM.ParamByName('Monat').AsInteger:= AMonat;
      qry_ULVM.open;
      result:= qry_ULVM.FieldByName('Resturlaub').AsFloat;
      qry_ULVM.Close;
    finally
      qry_ULVM.free;
    end;
  finally
    conn.free;
  end;
end;
{$EndRegion Functions}
// Proceduren
{$Region Procedures}
procedure BerechneTage(ATag,AMonat,AJahr,AMitarbeiter: integer);
var
  qry_work2: TFDQuery;
  qry_Calc: TFDQuery;
  dtFinish: TDateTime;
  dtStart: TDateTime;
  iArbeitszeit: integer;
  iBreakCalCol: integer;
  iBreakFontCol: integer;
  iFehltag: integer;
  iFeiertag: integer;
  iMehrarbeit,i: integer;
  iPause1: integer;
  iPause2: integer;
  iSollstunden: integer;
  iWorkCalCol: integer;
  iWorkFontCol: integer;
  sFehltag: String;
  sLastLine: String;
  tGehen: TTime;
  tkommen: TTime;
  tPause1Beginn: TTime;
  tPause1Ende: TTime;
  tPause2Beginn: TTime;
  tPause2Ende: TTime;
  conn: TFDConnection;
  qry_Personaldata: TFDQuery;
  qry_Delete: TFDQuery;
  qry_work: TFDQuery;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    qry_Personaldata:= TFDQuery.Create(nil);
    try
      qry_Personaldata.Connection:= conn;
      qry_Personaldata.SQL.Text:= 'Select ColFontWork,ColCalWork,ColFontBreak,ColCalBreak From time_user Where ID = :ID';
      qry_Personaldata.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_Personaldata.open;
      iWorkFontCol:= qry_Personaldata.FieldByName('ColFontWork').AsInteger;
      iWorkCalCol:= qry_Personaldata.FieldByName('ColCalWork').AsInteger;
      iBreakFontCol:= qry_Personaldata.FieldByName('ColFontBreak').AsInteger;
      iBreakCalCol:= qry_Personaldata.FieldByName('ColCalBreak').AsInteger;
      qry_Personaldata.close;
    finally
      qry_Personaldata.free;
    end;



    qry_Calc:= TFDQuery.Create(nil);
    qry_Calc.Connection:= conn;
    try
    if ATag > 0 then
    begin
      qry_Calc.SQL.Text:= 'SELECT ze_b.*, ze_FT.ID AS IDFT,  ze_FT.Kuerzel, ze_ft.Beschreibung, ze_ft.Typ, ze_ft.Faktor, ze_ft.Bezahlt, ze_ft.SollAbziehen, ze_ft.ColorFont, ze_ft.Color FROM time_buchungen ze_B ' +
                                 'LEFT OUTER  JOIN time_Fehltag ze_ft ON ze_ft.Kuerzel = ze_B.Fehltag ' +
                                 'WHERE ze_B.Datum = :Datum and ze_B.ID_Benutzer =:ID order by ze_B.Datum';
      qry_Calc.ParamByName('Datum').AsDate:= EncodeDate(AJahr,AMonat,ATag);
      qry_Calc.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_Calc.open;
    end
    else begin
      if AMonat > 0 then
      begin
        qry_Calc.SQL.Text:= 'SELECT ze_b.*, ze_FT.ID AS IDFT,  ze_FT.Kuerzel, ze_ft.Beschreibung, ze_ft.Typ, ze_ft.Faktor, ze_ft.Bezahlt, ze_ft.SollAbziehen, ze_ft.ColorFont, ze_ft.Color FROM time_buchungen ze_B ' +
                                   'LEFT OUTER  JOIN time_Fehltag ze_ft ON ze_ft.Kuerzel = ze_B.Fehltag ' +
                                   'WHERE MONTH(ze_B.Datum) = :monat and YEAR(ze_B.Datum) = :jahr and abgeschlossen is null and ze_B.ID_Benutzer =:ID order by ze_B.Datum';
        qry_Calc.ParamByName('monat').AsInteger:= AMonat;
        qry_Calc.ParamByName('jahr').AsInteger:= AJahr;
        qry_Calc.ParamByName('ID').AsInteger:= AMitarbeiter;
        qry_Calc.open;
      end
      else begin
        qry_Calc.SQL.Text:= 'SELECT ze_b.*, ze_FT.ID AS IDFT,  ze_FT.Kuerzel, ze_ft.Beschreibung, ze_ft.Typ, ze_ft.Faktor, ze_ft.Bezahlt, ze_ft.SollAbziehen, ze_ft.ColorFont, ze_ft.Color FROM time_buchungen ze_B ' +
                                   'LEFT OUTER  JOIN time_Fehltag ze_ft ON ze_ft.Kuerzel = ze_B.Fehltag ' +
                                   'WHERE ze_B.Datum >= :Von and ze_B.Datum <= :Bis and abgeschlossen is null and ze_B.ID_Benutzer =:ID order by ze_B.Datum';
        qry_Calc.ParamByName('Von').AsDate:= EncodeDate(AJahr,1,1);
        qry_Calc.ParamByName('Bis').AsDate:= EncodeDate(AJahr,12,31);
        qry_Calc.ParamByName('ID').AsInteger:= AMitarbeiter;
        qry_Calc.open;
      end;

    end;
    i:= 1;
    while not qry_Calc.eof do
    begin

      i:= i+1;
      iFehltag:= 0;
      iFeiertag:= 0;
      iSollstunden:= 0;
      if qry_Calc.FieldByName('Datum').asDateTime < Date then
      begin
        iSollstunden:= MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00'));
        if ((qry_Calc.FieldByName('Bezahlt').AsInteger = 1) and  (qry_Calc.FieldByName('Faktor').AsInteger = 1))  then
        begin
          iFehltag:= MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00'));
          if qry_Calc.FieldByName('SollAbziehen').AsInteger = 1 then
            iFehltag:= 0;

        end;

        if ((qry_Calc.FieldByName('Bezahlt').AsInteger = 0) and  (qry_Calc.FieldByName('SollAbziehen').AsInteger = 1))  then
          iSollstunden:= 0;

        if  ((qry_Calc.FieldByName('Bezahlt').AsInteger = 1) and  (qry_Calc.FieldByName('Faktor').AsInteger = 2)) then
          iFehltag:= Round(MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00')) / 2);
        if (qry_Calc.FieldByName('Feiertag').AsInteger = 2) then
          iFeiertag:= Round(MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00')) / 2);
        if (qry_Calc.FieldByName('Feiertag').AsInteger = 1) then
          iFeiertag:= MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00'));
        if (iFeiertag = iFehltag) and (iFeiertag = 480) then
          iFehltag := 0;
        iArbeitszeit:= MinutesBetween(qry_Calc.FieldByName('Gehen').asDateTime,qry_Calc.FieldByName('Kommen').asDateTime);
        iPause1:= MinutesBetween(qry_Calc.FieldByName('Pause1Ende').asDateTime,qry_Calc.FieldByName('Pause1Beginn').asDateTime);
        iPause2:= MinutesBetween(qry_Calc.FieldByName('Pause2Ende').asDateTime,qry_Calc.FieldByName('Pause2Beginn').asDateTime);
      end
      else begin
        if qry_Calc.FieldByName('Datum').asDateTime = Date then
        begin
          iSollstunden:= MinutesBetween(qry_Calc.FieldByName('Sollstunden').AsDateTime,StrToTime('00:00'));
          // Bezahlte Abwesenheit ganzer Tag
          if ((qry_Calc.FieldByName('Bezahlt').AsInteger = 1) and  (qry_Calc.FieldByName('Faktor').AsInteger = 1))  then
            iFehltag:= MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00'));
          // Bezahlte Abwesenheit halber Tag
          if  ((qry_Calc.FieldByName('Bezahlt').AsInteger = 1) and  (qry_Calc.FieldByName('Faktor').AsInteger = 2)) then
            iFehltag:= Round(MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00')) / 2);
          if (qry_Calc.FieldByName('Feiertag').AsInteger = 2) then
            iFeiertag:= Round(MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00')) / 2);
          if (qry_Calc.FieldByName('Feiertag').AsInteger = 1) then
            iFeiertag:= MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00'));
          if (iFeiertag = iFehltag) and (iFeiertag = 480) then
            iFehltag := 0;
        end;
        if (qry_Calc.FieldByName('Bezahlt').AsInteger > 0 ) or ((qry_Calc.FieldByName('Feiertag').AsInteger > 0 ) and (qry_Calc.FieldByName('Sollstunden').AsDateTime <> StrToTime('00:00:00'))) then
        begin
          iSollstunden:= MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00'));
          // Bezahlte Abwesenheit ganzer Tag
          if ((qry_Calc.FieldByName('Bezahlt').AsInteger = 1) and  (qry_Calc.FieldByName('Faktor').AsInteger = 1))  then
            iFehltag:= MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00'));
          // Bezahlte Abwesenheit halber Tag
          if  ((qry_Calc.FieldByName('Bezahlt').AsInteger = 1) and  (qry_Calc.FieldByName('Faktor').AsInteger = 2)) then
            iFehltag:= Round(MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00')) / 2);
          if (qry_Calc.FieldByName('Feiertag').AsInteger = 2) then
            iFeiertag:= Round(MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00')) / 2);
          if (qry_Calc.FieldByName('Feiertag').AsInteger = 1) then
            iFeiertag:= MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00'));
          if (iFeiertag = iFehltag) and (iFeiertag = 480) then
            iFehltag := 0;
        end;




        // Arbeitszeit
        if (qry_Calc.FieldByName('Kommen').asDateTime <> StrToTime('00:00:00')) and (qry_Calc.FieldByName('Gehen').asDateTime = StrToTime('00:00:00')) then
        begin
          iArbeitszeit:= MinutesBetween(TimeOf(Now),qry_Calc.FieldByName('Kommen').asDateTime);
        end
        else begin
          iArbeitszeit:= MinutesBetween(qry_Calc.FieldByName('Gehen').asDateTime,qry_Calc.FieldByName('Kommen').asDateTime);
        end;
        // Pause 1
        if (qry_Calc.FieldByName('Pause1Beginn').asDateTime <> StrToTime('00:00:00')) and (qry_Calc.FieldByName('Pause1Ende').asDateTime = StrToTime('00:00:00')) then
        begin
          iPause1:= 0
        end
        else begin
          iPause1:= MinutesBetween(qry_Calc.FieldByName('Pause1Ende').asDateTime,qry_Calc.FieldByName('Pause1Beginn').asDateTime);
        end;
        // Pause 2
        if (qry_Calc.FieldByName('Pause2Beginn').asDateTime <> StrToTime('00:00:00')) and (qry_Calc.FieldByName('Pause2Ende').asDateTime = StrToTime('00:00:00')) then
        begin
          iPause2:= 0
        end
        else begin
          iPause2:= MinutesBetween(qry_Calc.FieldByName('Pause2Ende').asDateTime,qry_Calc.FieldByName('Pause2Beginn').asDateTime);
        end;
      end;
      iMehrarbeit:= iArbeitszeit - iSollstunden - iPause1 - iPause2 + iFehltag + iFeiertag;
      qry_work2:= TFDQuery.Create(nil);
      try
        qry_work2.Connection:= conn;
        qry_Work2.SQL.Text:= 'Update time_buchungen set ' +
                                'SollstundenI = :SollstundenI,' +
                                'ArbeitszeitI = :ArbeitszeitI,' +
                                'Arbeitszeit = :Arbeitszeit,' +
                                'MehrarbeitI = :MehrarbeitI,' +
                                'Mehrarbeit = :Mehrarbeit,' +
                                'PausenI = :PausenI,' +
                                'FeiertagI = :FeiertagI ' +
                                'Where Datum = :Datum and ID_Benutzer =:ID';
        qry_Work2.ParamByname('SollstundenI').AsInteger:= iSollstunden; //MinutesBetween(qry_Calc.FieldByName('Sollstunden').asDateTime,StrToTime('00:00'));
        qry_Work2.ParamByname('ArbeitszeitI').AsInteger:= iArbeitszeit - iPause1 - iPause2 + iFehltag + iFeiertag;
        qry_Work2.ParamByname('Arbeitszeit').AsTime:= StrToTime(GetTimeValue(iArbeitszeit - iPause1 - iPause2 + iFehltag + iFeiertag));
        qry_Work2.ParamByname('MehrarbeitI').AsInteger:= iMehrarbeit;
        if iMehrarbeit < 0  then
          qry_Work2.ParamByname('Mehrarbeit').asString:= '-' + GetTimeValue(iMehrarbeit *-1)
        else
          qry_Work2.ParamByname('Mehrarbeit').asString:= GetTimeValue(iMehrarbeit);
        qry_Work2.ParamByname('PausenI').AsInteger:= iPause1 + iPause2;
        qry_Work2.ParamByname('FeiertagI').AsInteger:= iFeiertag;
        qry_Work2.ParamByname('Datum').AsDate:= qry_Calc.FieldByName('Datum').AsDateTime;
        qry_Work2.ParamByname('ID').asInteger:= AMitarbeiter;
        qry_Work2.execsql;
      finally
        qry_Work2.free;
      end;


      sLastLine:= 'Netto ohne Pausenabzug: ' +  FormatDateTime('hh:mm',IncMinute(StrToTime('00:00'),iArbeitszeit)) + slinebreak +
                  'Netto mit Pausenabzug: ' +  FormatDateTime('hh:mm',IncMinute(StrToTime('00:00'),iArbeitszeit - iPause1 - iPause2))+ slinebreak +
                  'Brutto mit Fehltag: ' +  FormatDateTime('hh:mm',IncMinute(StrToTime('00:00'),iArbeitszeit + iFehltag - iPause1 - iPause2))+ slinebreak +
                  'Feiertagsgutschrift: ' +  FormatDateTime('hh:mm',IncMinute(StrToTime('00:00'),iFeiertag))+ slinebreak +
                  'Pausen: ' +  FormatDateTime('hh:mm',IncMinute(StrToTime('00:00'),iPause1+iPause2))+ slinebreak +
                  'Mehrarbeit: ' +  GetTimeValue(iMehrarbeit);

      qry_Delete:= TFDQuery.Create(nil);
      qry_Delete.Connection:= conn;
      try
        qry_Delete.SQL.Text:= 'Delete FROM time_kalender WHERE DATE(START) = :Date and Kalendername = :Name and ID_Benutzer = :ID';
        qry_Delete.ParamByName('Date').AsDate := qry_Calc.FieldByName('Datum').AsDateTime;
        qry_Delete.ParamByName('Name').AsString := 'Buchungen';
        qry_Delete.ParamByName('ID').asInteger := AMitarbeiter;
        qry_Delete.ExecSQL;
      finally
        qry_Delete.free;
      end;
      tkommen:= qry_Calc.FieldByName('Kommen').asDateTime;
      tGehen:= qry_Calc.FieldByName('Gehen').asDateTime;
      tPause1Beginn:= qry_Calc.FieldByName('Pause1Beginn').asDateTime;
      tPause1Ende:= qry_Calc.FieldByName('Pause1Ende').asDateTime;
      tPause2Beginn:= qry_Calc.FieldByName('Pause2Beginn').asDateTime;
      tPause2Ende:= qry_Calc.FieldByName('Pause2Ende').asDateTime;
      sFehltag:= qry_Calc.FieldByName('Fehltag').AsString;
      // Kommen und Gehen vorhanden
      if (tkommen <> StrToTime('00:00')) and (tGehen <> StrToTime('00:00')) then
      begin
        // Pause 1 vorhanden
        if (tPause1Beginn <> StrToTime('00:00')) and (tPause1Ende <> StrToTime('00:00')) then
        begin
          // Pause 2 vorhanden
          if (tPause2Beginn <> StrToTime('00:00')) and (tPause2Ende <> StrToTime('00:00')) then
          begin
            dtStart:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tKommen));
            dtFinish:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tPause1Beginn));
            StartBooking(AMitarbeiter,'Arbeitszeit','','Buchungen',dtStart,dtFinish,iWorkCalCol,iWorkFontCol);

            dtStart:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tPause1Beginn));
            dtFinish:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tPause1Ende));
            StartBooking(AMitarbeiter,'Pause','','Buchungen',dtStart,dtFinish,iBreakCalCol,iBreakFontCol);

            dtStart:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tPause1Ende));
            dtFinish:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tPause2Beginn));
            StartBooking(AMitarbeiter,'Arbeitszeit','','Buchungen',dtStart,dtFinish,iWorkCalCol,iWorkFontCol);

            dtStart:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tPause2Beginn));
            dtFinish:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tPause2Ende));
            StartBooking(AMitarbeiter,'Pause','','Buchungen',dtStart,dtFinish,iBreakCalCol,iBreakFontCol);

            dtStart:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tPause2Ende));
            dtFinish:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tGehen));
            StartBooking(AMitarbeiter,'Arbeitszeit',sLastLine,'Buchungen',dtStart,dtFinish,iWorkCalCol,iWorkFontCol);
          end
          else begin
            dtStart:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tKommen));
            dtFinish:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tPause1Beginn));
            StartBooking(AMitarbeiter,'Arbeitszeit','','Buchungen',dtStart,dtFinish,iWorkCalCol,iWorkFontCol);

            dtStart:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tPause1Beginn));
            dtFinish:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tPause1Ende));
            StartBooking(AMitarbeiter,'Pause','','Buchungen',dtStart,dtFinish,iBreakCalCol,iBreakFontCol);

            dtStart:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tPause1Ende));
            dtFinish:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tGehen));
            StartBooking(AMitarbeiter,'Arbeitszeit',sLastLine,'Buchungen',dtStart,dtFinish,iWorkCalCol,iWorkFontCol);
          end;
        end
        else begin
          dtStart:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tKommen));
          dtFinish:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' ' + TimeToStr(tGehen));
          StartBooking(AMitarbeiter,'Arbeitszeit',sLastLine,'Buchungen',dtStart,dtFinish,iWorkCalCol,iWorkFontCol);
        end;
      end;
      // Wenn Fehltag vorahnden
      if sFehltag <> '' then
      begin
        qry_work:= TFDQuery.Create(nil);
        qry_work.Connection:= conn;
        try
          qry_work.SQL.Text:= 'Select Beschreibung, Color,ColorFont From time_Fehltag WHere Kuerzel = :Kuerzel';
          qry_work.ParamByName('Kuerzel').asString:= sFehltag;
          qry_work.open;
          var sFehltagDesc:= qry_work.Fieldbyname('Beschreibung').asString;
          var iCol:= qry_work.Fieldbyname('Color').AsInteger;
          var iColFont:= qry_work.Fieldbyname('ColorFont').AsInteger;
          qry_work.Close;
          if sFehltagDesc <> '' then
          begin
            dtStart:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' 08:00');
            dtFinish:= StrToDateTime(DateToStr(qry_Calc.FieldByName('Datum').AsDateTime) + ' 17:00' );
            StartBooking(AMitarbeiter,sFehltagDesc,sLastLine,'Fehltag',dtStart,dtFinish,iCol,iColFont);
          end;
        finally
          qry_work.free;
        end;
      end;
      qry_Calc.next;
    end;

    finally
      qry_Calc.close;
      qry_Calc.free;
    end;
  finally
    conn.free;
  end;
//  frm_ZE.qry_Buchungen.refresh;
end;
procedure BerechneMonat(AMonat,AJahr,AMitarbeiter: integer);
var
  iSollzeit: integer;
  iIStzeit: integer;
  iMehrarbeit: integer;
  iFeiertag: integer;
  iPausen: integer;
  iUrlaub_bezahlt: double;
  iUrlaub_unbezahlt: double;
  iKrank_bezahlt: double;
  iKrank_unbezahlt: double;
  fULges: double;
  fResturlaub: double;
  fULgen: double;
  fJahresAnspruch: double;
  iaktGLZ: integer;
  iVMonat: integer;
  ivJahr: integer;
  fOffsetResturlaub: double;
  iOffsetResturlaubJahr: integer;
  conn: TFDConnection;
  qry_Month: TFDQuery;
begin
  if AMonat = 0 then
  begin

  end
  else begin
    iVMonat := AMonat -1;
    iVJahr:= Ajahr;
    if iVMonat = 0 then
    begin
      iVMonat := 12;
      iVJahr:= Ajahr-1;
    end;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM'; // mit Pooled=True
      conn.Connected := True;
      qry_Month:= TFDQuery.Create(nil);
      try
        qry_Month.Connection:= conn;


        qry_Month.SQL.Text:= 'SELECT OffsetResturlaubJahr,OffsetResturlaub From time_user where ID =:ID';
        qry_Month.ParamByName('ID').AsInteger:= AMitarbeiter;
        qry_Month.Open;
        fOffsetResturlaub:= qry_Month.FieldByName('OffsetResturlaub').AsFloat;
        iOffsetResturlaubJahr:= qry_Month.FieldByName('OffsetResturlaubJahr').AsInteger;
        qry_Month.Close;
        fResturlaub:= GetULVorMonat(AMitarbeiter,iVJahr,iVMonat);
        if (iOffsetResturlaubJahr = iVJahr) and (iVMonat = 12) then
        begin
          fResturlaub:= fOffsetResturlaub;
        end;
        iaktGLZ:= GetMehrarbeitVorMonat(AMitarbeiter,iVJahr,iVMonat);
        fULgen:= GetFehltagSum(1,1,1,AMitarbeiter,StartOfAMonth(AJahr,AMonat) ,EndOfAMonth(AJahr,AMonat));
        fJahresAnspruch:= GetULAnspruch(AMitarbeiter);
        qry_Month.SQL.Text:= 'SELECT SUM(SollstundenI) AS Sollstunden, SUM(ArbeitszeitI) AS Arbeitszeit, SUM(MehrarbeitI) AS Mehrarbeit, SUM(PausenI) AS Pausen,SUM(FeiertagI) AS Feiertag ' +
                                      'FROM time_buchungen ' +
                                      'WHERE MONTH(Datum) = :monat ' +
                                      'and YEAR(Datum) = :jahr ' +
                                      'and ID_Benutzer = :ID ' +
                                      'GROUP BY MONTH(Datum),YEAR(Datum)';
        qry_Month.ParamByName('monat').AsInteger:= AMonat;
        qry_Month.ParamByName('jahr').AsInteger:= Ajahr;
        qry_Month.ParamByName('ID').AsInteger:= AMitarbeiter;
        qry_Month.Open;
        iSollzeit:= qry_Month.FieldByName('Sollstunden').AsInteger;
        iIStzeit:= qry_Month.FieldByName('Arbeitszeit').AsInteger;
        iMehrarbeit:= qry_Month.FieldByName('Mehrarbeit').AsInteger;
        iPausen:= qry_Month.FieldByName('Pausen').AsInteger;
        iFeiertag:= qry_Month.FieldByName('Feiertag').AsInteger;
        qry_Month.Close;
        iUrlaub_bezahlt:= GetFehltagSum(1,1,1,AMitarbeiter,StartOfAMonth(AJahr,AMonat) ,EndOfAMonth(AJahr,AMonat));
        iUrlaub_unbezahlt:= GetFehltagSum(1,1,2,AMitarbeiter,StartOfAMonth(AJahr,AMonat) ,EndOfAMonth(AJahr,AMonat));
        iKrank_bezahlt:= GetFehltagSum(1,2,1,AMitarbeiter,StartOfAMonth(AJahr,AMonat) ,EndOfAMonth(AJahr,AMonat));
        iKrank_unbezahlt:= GetFehltagSum(1,2,2,AMitarbeiter,StartOfAMonth(AJahr,AMonat) ,EndOfAMonth(AJahr,AMonat));
        qry_Month.close;
        if AMonat = 1 then
          fULges:=  fResturlaub - fULgen + fJahresAnspruch
        else
          fULges:=  fResturlaub - fULgen;
        WriteMonatswert(AMitarbeiter,fUlges,iaktGLZ, AMonat,AJahr,iSollzeit,iIStzeit,iMehrarbeit,iPausen,iFeiertag,iUrlaub_bezahlt,iUrlaub_unbezahlt,iKrank_bezahlt,iKrank_unbezahlt);
      finally
        qry_Month.free
      end;
    finally
      conn.Free;
    end;
  end;
end;
procedure BerechneMonate(AMitarbeiter: integer);
var
  fResturlaub: double;
  fULgen: double;
  fULges: double;
  iaktGLZ: integer;
  iBJahr: integer;
  iBMonat: integer;
  iFeiertag: integer;
  iIStzeit: integer;
  iJahresAnspruch: double;
  iKrank_bezahlt: integer;
  iKrank_unbezahlt: integer;
  iMehrarbeit: integer;
  iMonthCount: integer;
  iPausen: integer;
  iSollzeit: integer;
  iUrlaub_bezahlt: integer;
  iUrlaub_unbezahlt: integer;
  wJahr: Word;
  wMonat: Word;
  wTag: Word;
  conn: TFDConnection;
  qry_Month: TFDQuery;
begin
  DecodeDate(Date,wJahr,wMonat,wTag);
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    qry_Month:= TFDQuery.Create(nil);
    try
      qry_Month.Connection:= conn;
      qry_Month.SQL.Text:= 'SELECT MONTH(Datum) AS Monat,YEAR(Datum) AS Jahr FROM time_buchungen WHERE Abgeschlossen IS NULL and ID_Benutzer = :ID ' +
                                 'GROUP BY MONTH(Datum),YEAR(Datum)' +
                                 'Order by Year(Datum),MONTH(Datum)';
      qry_Month.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_Month.open;
      iMonthCount:= qry_Month.RecordCount;

      for var i := 1 to qry_Month.RecordCount do
      begin
        iBMonat:= qry_Month.FieldByName('Monat').AsInteger;
        iBJahr:= qry_Month.FieldByName('jahr').AsInteger;
        WaitFormSetText(rs_Function_Helper_BerechneMonatfuerMonat + GetMonthName(iBMonat) + rs_Function_Helper_BerechneYearEnd + IntToStr(iBJahr));
        WaitFormSetNewCount(iMonthCount);
        WaitFormPosition(i+1);
        var iVMonat := iBMonat -1;
        var iVJahr:= iBjahr;
        if iVMonat = 0 then
        begin
          iVMonat := 12;
          iVJahr:= iBjahr-1;
        end;
        BerechneTage(0,iBMonat,iBJahr,AMitarbeiter);
        BerechneMonat(iBMonat,iBJahr,AMitarbeiter);
        qry_Month.Next;
      end;
      qry_Month.close;


    finally
      qry_Month.Free;
    end;
  finally
    conn.free
  end;
end;
procedure StartBooking(AMitarbeiter: integer; ACaption,AMessage,ALocation: String;AStart,AFinish: TDateTime; ACalCol,AFontCol: integer);
var
  conn: TFDConnection;
  qry_Work: TFDQuery;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    qry_Work:= TFDQuery.Create(nil);
    try
      qry_Work.Connection:= conn;
      qry_Work.SQL.text := 'Insert into time_Kalender (Typ,EventType,Caption,Location,Message,'
                      + 'Start,Finish,Options,Parent_ID,RecurrenceIndex,RecurrenceInfo,Reminder,ReminderDate,'
                      + 'ReminderMinutesBeforeStart,LabelColor,FontColor,ID_Benutzer,Kalendername,CompleteDay) Values '
                      + '(2,:Eventtype,:SUMMARY,:Location,:Message,:DateBegin,:DateEnd,:Options,0,-1,:RecurrenceInfo,:Reminder,'
                      + 'NULL,0,:Color,:FontColor,:ID,:Kalender,:ganzerTag)';
      qry_Work.ParamByName('Message').asString := 'Test';
      qry_Work.ParamByName('Eventtype').asInteger := 0;
      qry_Work.ParamByName('Location').AsString := ALocation;
      qry_Work.ParamByName('Message').AsString := AMessage;
      qry_Work.ParamByName('Options').asInteger := 2;
      qry_Work.ParamByName('Reminder').AsString := 'False';
      qry_Work.ParamByName('RecurrenceInfo').AsString := '';
      qry_Work.ParamByName('Kalender').AsString := 'Buchungen';
      qry_Work.ParamByName('ganzerTag').AsString := 'false';
      qry_Work.ParamByName('ID').asInteger := AMitarbeiter;
      qry_Work.ParamByName('SUMMARY').AsString := ACaption;
      qry_Work.ParamByName('DateBegin').AsDateTime := AStart;
      qry_Work.ParamByName('DateEnd').AsDateTime := AFinish;
      qry_Work.ParamByName('Color').asInteger := ACalCol;
      qry_Work.ParamByName('FontColor').asInteger := AFontCol;
      qry_Work.ExecSQL;
    finally
      qry_Work.free;
    end;
  finally
    conn.free;
  end;
end;
procedure WriteMonatswert(AMitarbeiter:Integer;ARest: Double;AaktGLZ,AMonat,AJahr,ASollzeit,AIStzeit,AMehrarbeit,APausen,AFeiertag: integer; AUrlaub_bezahlt,AUrlaub_unbezahlt,AKrank_bezahlt,AKrank_unbezahlt: double);
var
  iAnzahl: integer;
  qry_Calc: TFDQuery;
  conn: TFDConnection;
begin
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM'; // mit Pooled=True
    conn.Connected := True;
    qry_Calc:= TFDQuery.Create(nil);
    try
      qry_Calc.Connection:= conn;
      qry_Calc.SQL.Text:= 'SELECT Count(*) as Anzahl From time_Monatswerte Where Monat = :Monat and Jahr = :Jahr and ID_Benutzer = :ID';
      qry_Calc.ParamByName('monat').AsInteger:= AMonat;
      qry_Calc.ParamByName('jahr').AsInteger:= AJahr;
      qry_Calc.ParamByName('ID').AsInteger:= AMitarbeiter;
      qry_Calc.open;
      iAnzahl:= qry_Calc.FieldByName('Anzahl').AsInteger;
      qry_Calc.Close;
      if iAnzahl > 0 then
      begin
        qry_Calc.SQL.Text:= 'Update time_Monatswerte ' +
                                    'Set Sollzeit = :Sollzeit, ' +
                                    'aktuelleMehrarbeit = :aktuelleMehrarbeit,'+
                                    'IStzeit = :IStzeit, ' +
                                    'Mehrarbeit = :Mehrarbeit, ' +
                                    'Pausen = :Pausen, ' +
                                    'Feiertag = :Feiertag, ' +
                                    'Urlaub_bezahlt = :Urlaub_bezahlt, ' +
                                    'Urlaub_unbezahlt = :Urlaub_unbezahlt, ' +
                                    'Krank_bezahlt = :Krank_bezahlt, ' +
                                    'Krank_unbezahlt = :Krank_unbezahlt, ' +
                                    'Resturlaub = :Resturlaub ' +
                                    'Where Monat = :Monat and Jahr = :Jahr and ID_Benutzer = :ID';
        qry_Calc.ParamByName('aktuelleMehrarbeit').AsInteger:= AaktGLZ + AMehrarbeit;
        qry_Calc.ParamByName('Sollzeit').AsInteger:= ASollzeit;
        qry_Calc.ParamByName('IStzeit').AsInteger:= AIStzeit;
        qry_Calc.ParamByName('Mehrarbeit').AsInteger:= AMehrarbeit;
        qry_Calc.ParamByName('Pausen').AsInteger:= APausen;
        qry_Calc.ParamByName('Feiertag').AsInteger:= AFeiertag;
        qry_Calc.ParamByName('Urlaub_bezahlt').AsFloat:= AUrlaub_bezahlt;
        qry_Calc.ParamByName('Urlaub_unbezahlt').AsFloat:= AUrlaub_unbezahlt;
        qry_Calc.ParamByName('Krank_bezahlt').AsFloat:= AKrank_bezahlt;
        qry_Calc.ParamByName('Krank_unbezahlt').AsFloat:= AKrank_unbezahlt;
        qry_Calc.ParamByName('Resturlaub').AsFloat:= ARest;
        qry_Calc.ParamByName('monat').AsInteger:= AMonat;
        qry_Calc.ParamByName('jahr').AsInteger:= AJahr;
        qry_Calc.ParamByName('ID').AsInteger:= AMitarbeiter;
        qry_Calc.ExecSQL;
      end
      else begin
        qry_Calc.SQL.Text:= 'Insert into time_Monatswerte ' +
                                    '(aktuelleMehrarbeit,Resturlaub,Sollzeit,IStzeit,Mehrarbeit,Pausen,Feiertag,Urlaub_bezahlt,Urlaub_unbezahlt,Krank_bezahlt,Krank_unbezahlt,Monat,Jahr,ID_Benutzer) Values ' +
                                    '(:aktuelleMehrarbeit,:Resturlaub,:Sollzeit,:IStzeit,:Mehrarbeit,:Pausen,:Feiertag,:Urlaub_bezahlt,:Urlaub_unbezahlt,:Krank_bezahlt,:Krank_unbezahlt,:Monat,:Jahr,:ID)';
        qry_Calc.ParamByName('aktuelleMehrarbeit').AsInteger:= AaktGLZ + AMehrarbeit;
        qry_Calc.ParamByName('Resturlaub').AsFloat:= ARest;
        qry_Calc.ParamByName('Sollzeit').AsInteger:= ASollzeit;
        qry_Calc.ParamByName('IStzeit').AsInteger:= AIStzeit;
        qry_Calc.ParamByName('Mehrarbeit').AsInteger:= AMehrarbeit;
        qry_Calc.ParamByName('Pausen').AsInteger:= APausen;
        qry_Calc.ParamByName('Feiertag').AsInteger:= AFeiertag;
        qry_Calc.ParamByName('Urlaub_bezahlt').AsFloat:= AUrlaub_bezahlt;
        qry_Calc.ParamByName('Urlaub_unbezahlt').AsFloat:= AUrlaub_unbezahlt;
        qry_Calc.ParamByName('Krank_bezahlt').AsFloat:= AKrank_bezahlt;
        qry_Calc.ParamByName('Krank_unbezahlt').AsFloat:= AKrank_unbezahlt;
        qry_Calc.ParamByName('monat').AsInteger:= AMonat;
        qry_Calc.ParamByName('jahr').AsInteger:= AJahr;
        qry_Calc.ParamByName('ID').AsInteger:= AMitarbeiter;
        qry_Calc.ExecSQL;
      end;
    finally
      qry_calc.Free;
    end;
  finally
    conn.Free;
  end;
end;
{$EndRegion Procedures}
end.
