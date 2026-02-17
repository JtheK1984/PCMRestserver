unit PCMService.API.Methods;

interface

uses
  {$Region Uses}
  Data.db,
  Data.DBXPlatform,
  Datasnap.DSSession,
  FireDAC.Comp.Client,
  FireDac.Stan.Param,
  System.Classes,
  System.Dateutils,
  System.JSON,
  System.NetEncoding,
  System.StrUtils,
  System.SysUtils,
  Vcl.Graphics,
  Winapi.Windows;
  {$EndRegion Uses}
// Deklarationen
  {$Region Declare}
  //////////////////////////////////////////////////////////////////////////////
  // Hilfsfunktionen                                                          //
  //////////////////////////////////////////////////////////////////////////////
  {$Region Hilfsfunktionen}
  function BadRequest: TJSONObject;
  function GetIDFromTable(ATable,AValue: String) : Integer;
  function CheckTokenGueltig(sToken: String): Boolean;
  function CheckUser: boolean;
  function CheckUserWeb: boolean;
  function CheckUserApp: boolean;
  function AddZeros(AValue: String; ACount: integer): string;
  function FormatDateTimeToStr(ADate: TDateTime): String;
  procedure UpdateFieldValues_String(AField, ATable, AValue: String; AID:Integer);Overload;
  procedure UpdateFieldValues_Ansistring(AField, ATable: String; AValue: Ansistring; AID:Integer);Overload
  procedure UpdateFieldValues_TDateTime(AField, ATable: String; AValue: TDateTime; AID:Integer);Overload
  procedure UpdateFieldValues_TDate(AField, ATable: String; AValue: TDate; AID:Integer);Overload
  procedure UpdateFieldValues_Boolean(AField, ATable: String; AValue: Boolean; AID:Integer);Overload
  procedure UpdateFieldValues_Integer(AField, ATable: String; AValue: Integer; AID:Integer);Overload
  procedure UpdateFieldValues_Float(AField, ATable: String; AValue: Double; AID:Integer);Overload
  {$EndRegion Hilfsfunktionen}
  //////////////////////////////////////////////////////////////////////////////
  // Web_API_PCM                                                              //
  //////////////////////////////////////////////////////////////////////////////
  {$Region Web_API_PCM}
  function CreateToken_Intern: TJSONObject;
  function RefreshToken_Intern(const AJSONObject: TJSONObject): TJSONObject;
  function DeleteToken_Intern(const sToken: String;iProg: Integer): TJSONObject;
  function CreateBackup_Intern(const sToken, sPath: String): TJSONObject;
  function GetKalenderConfig_Intern(const AJSONObject: TJSONObject): TJSONObject;
  {$EndRegion Web_API_PCM}
  //////////////////////////////////////////////////////////////////////////////
  // Time_APP_API_PCM                                                         //
  //////////////////////////////////////////////////////////////////////////////
  {$Region Time_API_PCM}
  function GetContactsZE_Intern(AID_Benutzer: string): TJSONObject;
  function GetLastBooking_Intern(AID_Benutzer: string): TJSONObject;
  function SetLastBooking_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  function GetBookingYear_Intern(AID_Benutzer,AJahr: string): TJSONObject;
  function GetAbsenceconfig_Intern(AID_Benutzer: string): TJSONObject;
  function GetAbsence_Intern(AID_Benutzer: string): TJSONObject;
  function SetOnlineBooking_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  function GetMonthValues_Intern(AID_Benutzer: Integer): TDataset;
  {$EndRegion Time_API_PCM}
  //////////////////////////////////////////////////////////////////////////////
  // WebAPP_API_PCM                                                           //
  //////////////////////////////////////////////////////////////////////////////
  // Prüfen ob Login erlaubt
  {$Region WebAPP_API_PCM}
  function GetLoginWeb_Intern: TJSONObject;
  function GetPersonalWeb_intern(AID_Benutzer: string): TJSONObject;
  function GetBookinDataWeb_intern(AID_Benutzer: string): TJSONObject;
  function GetMonthYearValuesWeb_intern(AID_Benutzer: string; AMonat, AJahr: integer): TJSONObject;
  function GetFehltageWeb_intern(AID_Benutzer: string): TJSONObject;
  function GetFeiertageWeb_intern(AID_Benutzer: string): TJSONObject;
  function GetLastBookingWeb_Intern(AID_Benutzer: string): TJSONObject;
  function SetLastBookingWeb_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  function GetBookingWeb_Intern(AID_Benutzer: string): TJSONObject;
  function SetOnlineBookingWeb_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  function CalcBookingWeb_Intern(AID_Benutzer: string; AMonat, AJahr: integer): TJSONObject;
  function GetAbsenceWeb_intern(AID_Benutzer: string; AMonat, AJahr: integer): TJSONObject;
  {$EndRegion WebAPP_API_PCM}
  //////////////////////////////////////////////////////////////////////////////
  // APPAPI - PCM                                                             //
  //////////////////////////////////////////////////////////////////////////////
  {$Region APP_API_PCM}
  function Checkserver_Intern: TJSONObject;
  function CheckLogin_Intern: TJSONObject;
  function CheckLoginTime_Intern: TJSONObject;
  function SetDeviceID_Intern(const AJSONObject: TJSONObject): TJSONObject;
  function GetKontakte_Intern(AID_Benutzer:   string): TJSONObject;
  function SetKontakte_Intern(AID_Benutzer:   string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  function GetKalender_Intern(AID_Benutzer:   string): TJSONObject;
  function SetKalender_Intern(AID_Benutzer:   string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  function GetPasswoerter_Intern(AID_Benutzer:string): TJSONObject;
  function SetPasswoerter_Intern(AID_Benutzer:string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  function GetSerials_Intern(AID_Benutzer:    string): TJSONObject;
  function SetSerials_Intern(AID_Benutzer:    string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  function GetEinnahmen_Intern(AID_Benutzer:  string): TJSONObject;
  function SetEinnahmen_Intern(AID_Benutzer:  string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  function GetAusgaben_Intern(AID_Benutzer:   string): TJSONObject;
  function SetAusgaben_Intern(AID_Benutzer:   string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  function GetVouchers_Intern(AID_Benutzer:   string): TJSONObject;
  function SetVouchers_Intern(AID_Benutzer:   string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  function GetGiftCards_Intern(AID_Benutzer:  string): TJSONObject;
  function SetGiftCards_Intern(AID_Benutzer:  string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  {$EndRegion Declare}
var
  {$Region Var}
  joResponseJSON: TJSONObject;
  joResponseJSONData: TJSONObject;
  jaDetails: TJSonArray;
//  JSonValue: TJSonValue;
  iZaehler: integer;
  iAnzahl: integer;
  {$EndRegion Var}
implementation

uses
  {$Region Uses}
  PCm.Calc,
  PCM.Data,
  PCM.Main,
  PCM.Restserver.Strings;
  {$EndRegion Uses}
////////////////////////////////////////////////////////////////////////////////
// Hilfsfunktionen                                                            //
////////////////////////////////////////////////////////////////////////////////
{$Region Hilfsfunktionen}
function AddZeros(AValue: String; ACount: integer): string;
begin
  if Length(AValue) > Acount then
  begin
    // die letzten count Stellen kopieren
    AValue := Copy(AValue, Length(AValue) - Acount + 1, Acount);
  end
  else begin
    // '0'-en hinzufügen
    while Length(AValue) < Acount do
      AValue := '0' + AValue;
  end;
  result:= AValue;
end;
function FormatDateTimeToStr(ADate: TDateTime): String ;
var
  wJahr,wMonat,wTag,wStunde,wMinute,wSekunde,wMSek: word;
begin
  Result := '';
  DecodeDateTime(ADate,wJahr,wMonat,wTag,wStunde,wMinute,wSekunde,wMSek);
  Result:= IntToStr(wJahr) + '-' + AddZeros(IntToStr(wMonat), 2) + '-' + AddZeros(IntToStr(wTag), 2) + ' ' +
           AddZeros(IntToStr(wStunde), 2) + ':' + AddZeros(IntToStr(wMinute), 2) +':' + AddZeros(IntToStr(wSekunde), 2)
end;
function BadRequest: TJSONObject;
var
  sUser, sPass: String;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'BadRequest wird ausgeführt',0);
  Result := nil;
  joResponseJSON := TJSONObject.Create;
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry_Work := TFDQuery.Create(nil);
    try
      try
        sUser := TDSSessionManager.GetThreadSession.GetData('Username');
        sPass := TDSSessionManager.GetThreadSession.GetData('Password');
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.SQL.Text := 'SELECT ID,Benutzer, Passwort, RestApi FROM Benutzer WHERE Benutzer = :User';
        qry_Work.ParamByName('User').AsString := sUser;
        qry_Work.Open;

        if qry_Work.RecordCount > 0 then
        begin
          if sPass <> qry_Work.FieldByName('Passwort').AsString then
          begin
            joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
            joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(2));
            joResponseJSON.AddPair('Errormessage', TJSONString.Create('falsches Passwort'));
          end
          else if not qry_Work.FieldByName('RestAPI').AsBoolean then
          begin
            joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
            joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(4));
            joResponseJSON.AddPair('Errormessage', TJSONString.Create('Benutzer nicht berechtigt'));
          end;
        end
        else
        begin
          joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
          joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(2));
          joResponseJSON.AddPair('Errormessage', TJSONString.Create('Benutzer nicht gefunden'));
        end;

        Result := joResponseJSON;
      except
        on E: Exception do
        begin
          joResponseJSON.Free;
          Result := TJSONObject.Create;
          Result.AddPair('HasError', TJSONBool.Create(true));
          Result.AddPair('ErrorCode', TJSONNumber.Create(99));
          Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
          WriteLog(PCM_Logname,'BadRequest exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry_Work.Free;
    end;
  finally
    conn.free;
  end;
end;
function GetIDFromTable(ATable, AValue: String): Integer;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetIDFromTable wird ausgeführt',0);
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry_Work := TFDQuery.Create(nil);
    try
      try
        qry_Work.Connection := conn;  // Achte auf gepoolte Verbindung
        qry_Work.SQL.Text := 'SELECT ID FROM ' + ATable + ' WHERE Bezeichnung = :Bezeichnung';
        qry_Work.ParamByName('Bezeichnung').AsString := AValue;
        qry_Work.Open;

        if qry_Work.RecordCount = 0 then
        begin
          qry_Work.Close;
          qry_Work.SQL.Text := 'INSERT INTO ' + ATable + ' (Bezeichnung) VALUES (:Bezeichnung)';
          qry_Work.ParamByName('Bezeichnung').AsString := AValue;
          qry_Work.ExecSQL;

          qry_Work.SQL.Text := 'SELECT ID FROM ' + ATable + ' WHERE Bezeichnung = :Bezeichnung';
          qry_Work.ParamByName('Bezeichnung').AsString := AValue;
          qry_Work.Open;
        end;

        Result := qry_Work.FieldByName('ID').AsInteger;
      except
        on E: Exception do
        begin
          WriteLog(PCM_Logname,'GetIDFromTable exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry_Work.Free;
    end;
  finally
    conn.free;
  end;
end;
function CheckTokenGueltig(sToken: String): Boolean;
var
  qry: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'CheckTokenGueltig wird ausgeführt',0);
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry := TFDQuery.Create(nil);
    try
      try
        qry.Connection := conn; // Sollte gepoolt und threadsicher sein
        qry.SQL.Text := 'SELECT Gueltig_Bis FROM Benutzer WHERE Token = :Token and Gueltig_Bis >= :Jetzt';
        qry.ParamByName('Token').AsString := sToken;
        qry.ParamByName('Jetzt').AsDateTime := Now;
        qry.Open;
        Result := qry.RecordCount > 0;
      except
      on E: Exception do
        begin
          WriteLog(PCM_Logname,'CheckTokenGueltig exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry.Free;
    end;
  finally
    conn.free;
  end;
end;
function CheckUser: boolean;
var
  sUser, sPass: String;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'CheckUser wird ausgeführt',0);
  Result := false;
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry_Work := TFDQuery.Create(nil);
    try
      sUser := TDSSessionManager.GetThreadSession.GetData('Username');
      sPass := TDSSessionManager.GetThreadSession.GetData('Password');
      WriteLog(PCM_Logname,'User: ' + sUser,0);
      WriteLog(PCM_Logname,'Pass: ' + sPass,0);
      try
        qry_Work.Connection := conn; // Sollte gepoolt sein
        qry_Work.SQL.Text := 'SELECT ID,Benutzer, Passwort, RestApi FROM Benutzer WHERE Benutzer = :User';
        qry_Work.ParamByName('User').AsString := sUser;
        qry_Work.Open;

        if qry_Work.RecordCount > 0 then
          if (sPass = qry_Work.FieldByName('Passwort').AsString) and (qry_Work.FieldByName('RestAPI').AsBoolean) then
            Result := true;
      except
        on E: Exception do
        begin
          WriteLog(PCM_Logname,'CheckUser exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry_Work.Free;
    end;
  finally
    conn.free;
  end;
end;
function CheckUserApp: boolean;
var
  sUser, sPass: String;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'CheckUser wird ausgeführt',0);
  Result := false;
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry_Work := TFDQuery.Create(nil);
    try
      sUser := TDSSessionManager.GetThreadSession.GetData('Username');
      sPass := TDSSessionManager.GetThreadSession.GetData('Password');
      try
        qry_Work.Connection := conn; // Sollte gepoolt sein
//        qry_Work.SQL.Text := 'SELECT ID,Benutzer, Passwort, RestApi FROM Benutzer WHERE Benutzer = :User';
        qry_Work.SQL.Text := 'SELECT ID, Benutzer, Passwort, Zugriff_App FROM time_user WHERE Benutzer = :User';
        qry_Work.ParamByName('User').AsString := sUser;
        qry_Work.Open;

        if qry_Work.RecordCount > 0 then
          if (sPass = qry_Work.FieldByName('Passwort').AsString) and (qry_Work.FieldByName('Zugriff_App').AsBoolean) then
            Result := true;
      except
        on E: Exception do
        begin
          WriteLog(PCM_Logname,'CheckUser exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry_Work.Free;
    end;
  finally
    conn.free;
  end;
end;
function CheckUserWeb: boolean;
var
  sUser, sPass: String;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'CheckUser wird ausgeführt',0);
  Result := false;
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry_Work := TFDQuery.Create(nil);
    try
      sUser := TDSSessionManager.GetThreadSession.GetData('Username');
      sPass := TDSSessionManager.GetThreadSession.GetData('Password');
      try
        qry_Work.Connection := conn; // Sollte gepoolt sein
//        qry_Work.SQL.Text := 'SELECT ID,Benutzer, Passwort, RestApi FROM Benutzer WHERE Benutzer = :User';
        qry_Work.SQL.Text := 'SELECT ID, Benutzer, Passwort, Zurgiff_Web FROM time_user WHERE Benutzer = :User';
        qry_Work.ParamByName('User').AsString := sUser;
        qry_Work.Open;

        if qry_Work.RecordCount > 0 then
          if (sPass = qry_Work.FieldByName('Passwort').AsString) and (qry_Work.FieldByName('Zurgiff_Web').AsBoolean) then
            Result := true;
      except
        on E: Exception do
        begin
          WriteLog(PCM_Logname,'CheckUser exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry_Work.Free;
    end;
  finally
    conn.free;
  end;
end;
procedure UpdateFieldValues_String(AField, ATable, AValue: String; AID: Integer); Overload;
var
  conn: TFDConnection;
  qry_Update: TFDQuery;
begin
  WriteLog(PCM_Logname,'UpdateFieldValues_String wird ausgeführt',0);
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry_Update := TFDQuery.Create(nil);
    try
      try
        qry_Update.Connection := conn;
        qry_Update.SQL.Text := 'UPDATE ' + ATable + ' SET ' + AField + ' = :AValue WHERE ID = :ID';
        qry_Update.ParamByName('AValue').AsString := AValue;
        qry_Update.ParamByName('ID').AsInteger := AID;
        qry_Update.ExecSQL;
      except
        on E: Exception do
        begin
          WriteLog(PCM_Logname,'UpdateFieldValues_String exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry_Update.Free;
    end;
  finally
    conn.free;
  end;
end;
procedure UpdateFieldValues_Ansistring(AField, ATable: String; AValue: Ansistring; AID:Integer);Overload;
var
  conn: TFDConnection;
  qry_Update: TFDQuery;
begin
  WriteLog(PCM_Logname,'UpdateFieldValues_Ansistring wird ausgeführt',0);
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry_Update := TFDQuery.Create(nil);
    try
      try
        qry_Update.Connection := conn;
        qry_Update.SQL.Text := 'UPDATE ' + ATable + ' SET ' + AField + ' = :AValue WHERE ID = :ID';
        qry_Update.ParamByName('AValue').AsMemo := AValue;
        qry_Update.ParamByName('ID').AsInteger := AID;
        qry_Update.ExecSQL;
      except
        on E: Exception do
        begin
          WriteLog(PCM_Logname,'UpdateFieldValues_Ansistring exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry_Update.Free;
    end;
  finally
    conn.free;
  end;
end;
procedure UpdateFieldValues_TDateTime(AField, ATable: String; AValue: TDateTime; AID:Integer);Overload;
var
  conn: TFDConnection;
  qry_Update: TFDQuery;
begin
  WriteLog(PCM_Logname,'UpdateFieldValues_TDateTime wird ausgeführt',0);
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry_Update := TFDQuery.Create(nil);
    try
      try
        qry_Update.Connection := conn;
        qry_Update.SQL.Text := 'UPDATE ' + ATable + ' SET ' + AField + ' = :AValue WHERE ID = :ID';
        qry_Update.ParamByName('AValue').AsDateTime := AValue;
        qry_Update.ParamByName('ID').AsInteger := AID;
        qry_Update.ExecSQL;
      except
        on E: Exception do
        begin
          WriteLog(PCM_Logname,'UpdateFieldValues_TDateTime exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry_Update.Free;
    end;
  finally
    conn.free;
  end;
end;
procedure UpdateFieldValues_TDate(AField, ATable: String; AValue: TDate; AID:Integer);Overload;
var
  conn: TFDConnection;
  qry_Update: TFDQuery;
begin
  WriteLog(PCM_Logname,'UpdateFieldValues_TDate wird ausgeführt',0);
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry_Update:= TFDQuery.Create(nil);
    try
      try
        qry_Update.Connection:= conn;
        qry_Update.SQL.Text:= 'Update ' + ATable + ' Set ' + AField + '=:AValue Where ID = :ID';
        qry_Update.ParamByName('Avalue').AsDate:= AValue;
        qry_Update.ParamByName('ID').AsInteger:= AID;
        qry_Update.ExecSQL;
      except
        on E: Exception do
        begin
          WriteLog(PCM_Logname,'UpdateFieldValues_TDate exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry_Update.Free;
    end;
  finally
    conn.free;
  end;
end;
procedure UpdateFieldValues_Boolean(AField, ATable: String; AValue: Boolean; AID:Integer);Overload;
var
  conn: TFDConnection;
  qry_Update: TFDQuery;
begin
  WriteLog(PCM_Logname,'UpdateFieldValues_Boolean wird ausgeführt',0);
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry_Update:= TFDQuery.Create(nil);
    try
      try
        qry_Update.Connection:= conn;
        qry_Update.SQL.Text:= 'Update ' + ATable + ' Set ' + AField + '=:AValue Where ID = :ID';
        qry_Update.ParamByName('Avalue').AsBoolean:= AValue;
        qry_Update.ParamByName('ID').AsInteger:= AID;
        qry_Update.ExecSQL;
      except
        on E: Exception do
        begin
          WriteLog(PCM_Logname,'UpdateFieldValues_Boolean exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry_Update.Free;
    end;
  finally
    conn.free;
  end;
end;
procedure UpdateFieldValues_Integer(AField, ATable: String; AValue: Integer; AID:Integer);Overload;
var
  conn: TFDConnection;
  qry_Update: TFDQuery;
begin
  WriteLog(PCM_Logname,'UpdateFieldValues_Integer wird ausgeführt',0);
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry_Update:= TFDQuery.Create(nil);
    try
      try
        qry_Update.Connection:= conn;
        qry_Update.SQL.Text:= 'Update ' + ATable + ' Set ' + AField + '=:AValue Where ID = :ID';
        qry_Update.ParamByName('Avalue').AsInteger:= AValue;
        qry_Update.ParamByName('ID').AsInteger:= AID;
        qry_Update.ExecSQL;
      except
        on E: Exception do
        begin
          WriteLog(PCM_Logname,'UpdateFieldValues_Integer exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry_Update.Free;
    end;
  finally
    conn.free;
  end;
end;
procedure UpdateFieldValues_Float(AField, ATable: String; AValue: Double; AID:Integer);Overload;
var
  conn: TFDConnection;
  qry_Update: TFDQuery;
begin
  WriteLog(PCM_Logname,'UpdateFieldValues_Float wird ausgeführt',0);
  conn := TFDConnection.Create(nil);
  try
    conn.ConnectionDefName := 'PCM';
    conn.Connected := True;
    qry_Update:= TFDQuery.Create(nil);
    try
      try
        qry_Update.Connection:= conn;
        qry_Update.SQL.Text:= 'Update ' + ATable + ' Set ' + AField + '=:AValue Where ID = :ID';
        qry_Update.ParamByName('Avalue').AsFloat:= AValue;
        qry_Update.ParamByName('ID').AsInteger:= AID;
        qry_Update.ExecSQL;
      except
        on E: Exception do
        begin
          WriteLog(PCM_Logname,'UpdateFieldValues_Float exception: ' + E.Message, 3);
        end;
      end;
    finally
      qry_Update.Free;
    end;
  finally
    conn.free;
  end;
end;
{$EndRegion Hilfsfunktionen}
////////////////////////////////////////////////////////////////////////////////
// Web_API_PCM                                                                //
////////////////////////////////////////////////////////////////////////////////
{$Region Webapi}
function CreateToken_Intern: TJSONObject;
  function RandomString(strlength: integer): string;
  var
    temp : integer;
  begin
    randomize;
    repeat
      temp := random(122);
      if temp in [48..57{0-1}, 65..90{A-Z}, 97..122{a-z}] then
        result := result + Chr(temp);
    until length(result) = strlength;
  end;
var
  sUser, sPass, sToken: String;
  iID_MA_Stammdaten: Integer;
  bRestAPI: boolean;
  conn: TFDConnection;
  qry_Work: TFDQuery;
begin
  WriteLog(PCM_Logname,'CreateToken_Intern wird ausgeführt', 0);
  Result:= nil;
  joResponseJSON:= nil;
  try
    sUser := TDSSessionManager.GetThreadSession.GetData('Username');
    sPass := TDSSessionManager.GetThreadSession.GetData('Password');
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;

    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.Sql.Text := 'SELECT ID, RestAPI FROM Benutzer WHERE Benutzer =:Username AND Passwort=:Password';
        qry_Work.ParamByName('Username').AsString := sUser;
        qry_Work.ParamByName('Password').AsString := sPass;
        qry_Work.Open;
        if qry_Work.RecordCount > 0 then
        begin
          iID_MA_Stammdaten := qry_Work.FieldByName('ID').AsInteger;
          bRestAPI:= qry_Work.FieldByName('RestAPI').asBoolean;
          if bRestAPI then
          begin
            sToken := RandomString(70);
            qry_Work.Sql.Text := 'Update Benutzer Set Token = :Token, Gueltig_Bis = :Gueltig_Bis Where ID = :ID';
            qry_Work.ParamByName('Token').AsString := sToken;
            qry_Work.ParamByName('Gueltig_Bis').AsDateTime := IncMinute(Now, PCM_Restserver.RESTServerConfig.TokenTimeout);
            qry_Work.ParamByName('ID').AsInteger := iID_MA_Stammdaten;
            qry_Work.ExecSQL;
            iCode:= 200;
            sMessage:= 'OK';
            joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
            joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
            joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
            joResponseJSON.AddPair(TJSONPair.Create('Token', sToken));
            joResponseJSON.AddPair(TJSONPair.Create('User', sUser));
            joResponseJSON.AddPair(TJSONPair.Create('ID_User', iID_MA_Stammdaten));
          end
          else begin
            iCode:= 403;
            sMessage:= 'Forbidden';
            joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
            joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(4)));
            joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Benutzer ' + sUSer + ' nicht berechtigt.')));
          end;
        end else
        begin
          iCode:= 401;
          sMessage:= 'Unauthorized';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Benutzer ' + sUSer + ' nicht gefunden oder falsches Passwort')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(3)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'CreateToken_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function RefreshToken_Intern(const AJSONObject: TJSONObject): TJSONObject;
var
  sToken: string;
  conn: TFDConnection;
  qry_work: TFDQuery;
begin
  WriteLog(PCM_Logname,'RefreshToken_Intern wird ausgeführt', 0);
  Result:= nil;
  joResponseJSON:= nil;
  sToken:= AJSONObject.GetValue<String>('Token');
  try
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        if CheckTokenGueltig(sToken) then
        begin
          qry_Work.Sql.Text := 'Update Benutzer Set Gueltig_Bis = :Gueltig_Bis Where Token = :Token';
          qry_Work.ParamByName('Token').AsString := sToken;
          qry_Work.ParamByName('Gueltig_Bis').AsDateTime := IncMinute(Now, PCM_Restserver.RESTServerConfig.TokenTimeout);
          qry_Work.ExecSQL;
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        end
        else begin
          iCode:= 401;
          sMessage:= 'Unauthorized';
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Token ungültig oder abgelaufen')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(3)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'RefreshToken_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function DeleteToken_Intern(const sToken: String;iProg: Integer): TJSONObject;
var
  conn: TFDConnection;
  qry_work: TFDQuery;
begin
  WriteLog(PCM_Logname,'DeleteToken_Intern wird ausgeführt', 0);
  Result:= nil;
  joResponseJSON:= nil;
  try
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        if CheckTokenGueltig(sToken) then
        begin
            qry_Work.Sql.Text := 'Update Benutzer Set Token = '''' Where Token = :Token';
            qry_Work.ParamByName('Token').AsString := sToken;
            qry_Work.ExecSQL;
            iCode:= 200;
            sMessage:= 'OK';
            joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
            joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        end
        else begin
          iCode:= 401;
          sMessage:= 'Unauthorized';
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Token ungültig oder abgelaufen')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(3)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'DeleteToken_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function CreateBackup_Intern(const sToken, sPath: String): TJSONObject;
var
  conn: TFDConnection;
  qry: TFDQuery;
begin
  WriteLog(PCM_Logname,'CreateBackup_Intern wird ausgeführt', 0);
  try
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    if CheckTokenGueltig(sToken) then
    begin
  //    ExecuteAndWaitFor(AnsiString(ExtractFilePath(ParamStr(0)) + 'PCMBackup\PCMBackupService.exe /' + sPath));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    end
    else begin
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Token ungültig oder abgelaufen')));
    end;
    result:= joResponseJSON;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(3)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'CreateBackup_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function GetKalenderConfig_Intern(const AJSONObject: TJSONObject): TJSONObject;
var
  conn: TFDConnection;
  qry_Work: TFDQuery;

  iID_Benutzer: integer;
  sToken: string;
begin
  WriteLog(PCM_Logname,'GetKalenderConfig_Intern wird ausgeführt', 0);
  result:= nil;
  try
    iID_Benutzer := AJSONObject.GetValue<Integer>('ID_Benutzer');
    sToken := AJSONObject.GetValue<String>('Token');
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        if CheckTokenGueltig(sToken) then
        begin
          qry_Work.SQL.Text := 'SELECT Kalender,Link,Benutzer,Passwort,Erinnerung,ErinnerungVor,LabelColor,FontColor FROM manager_kalender_config WHERE ID_Benutzer = :ID_Benutzer';
          qry_Work.ParamByName('ID_Benutzer').AsInteger := iID_Benutzer;
          qry_Work.Open;
          if qry_Work.RecordCount > 0 then
          begin
            while not qry_Work.Eof do
            begin
              joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
              joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
              joResponseJSON.AddPair(TJSONPair.Create('Kalender', qry_Work.FieldByName('Link').AsString));
              joResponseJSON.AddPair(TJSONPair.Create('Link', qry_Work.FieldByName('Link').AsString));
              joResponseJSON.AddPair(TJSONPair.Create('Benutzer', qry_Work.FieldByName('Benutzer').AsString));
              joResponseJSON.AddPair(TJSONPair.Create('Passwort', qry_Work.FieldByName('Passwort').AsString));
              joResponseJSON.AddPair(TJSONPair.Create('Erinnerung', TJSONBool.Create(qry_Work.FieldByName('Erinnerung').AsBoolean)));
              joResponseJSON.AddPair(TJSONPair.Create('ErinnerungVor', TJSONNumber.Create(qry_Work.FieldByName('ErinnerungVor').AsInteger)));
              joResponseJSON.AddPair(TJSONPair.Create('LabelColor', TJSONNumber.Create(qry_Work.FieldByName('LabelColor').AsInteger)));
              joResponseJSON.AddPair(TJSONPair.Create('FontColor', TJSONNumber.Create(qry_Work.FieldByName('FontColor').AsInteger)));
    //          iCount := iCount + 1;
              qry_Work.Next;
            end;
            qry_Work.Close;
          end else
          begin
            joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(6)));
            joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Kein Datensatz vorhanden')));
          end;

        end else
        begin
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(5)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Token ungültig oder abgelaufen')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(3)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'GetKalenderConfig_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
{$EndRegion Webapi}
////////////////////////////////////////////////////////////////////////////////
// Man_APP_API_PCM                                                            //
////////////////////////////////////////////////////////////////////////////////
{$Region APPapi}
{$Region Server_Login}
function Checkserver_intern: TJSONObject;
begin
  WriteLog(PCM_Logname,'Checkserver_intern wird ausgeführt', 0);
  Result:= nil;
  try
    joResponseJSON:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    Result := joResponseJSON;
  except
    on e:Exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(3)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'Checkserver_intern exception: ' + E.Message, 3);
    end;
  end;
end;
function CheckLogin_Intern: TJSONObject;
var
  sUser, sPass: String;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'CheckLogin_Intern wird ausgeführt', 0);
  Result:= nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    sUser := TDSSessionManager.GetThreadSession.GetData('Username');
    sPass := TDSSessionManager.GetThreadSession.GetData('Password');
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.sql.text:= 'SELECT ID,Benutzer, Passwort, RestApi FROM Benutzer WHERE Benutzer = :User';
        qry_Work.ParamByName('User').AsString := sUser;
        qry_Work.Open;
        if qry_Work.RecordCount > 0 then
        begin
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          if not Assigned(joResponseJSONData) then
            joResponseJSONData := TJSONObject.Create;
          if (sPass = qry_Work.FieldByName('Passwort').AsString) AND (qry_Work.FieldByName('RestAPI').AsBoolean = True) then
          begin
            iCode:= 200;
            sMessage:= 'OK';
            joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
            joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
            joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
            joResponseJSONData.AddPair(TJSONPair.Create('Allowed', TJSONBool.Create(True)));
            joResponseJSONData.AddPair(TJSONPair.Create('ID_User', TJSONNumber.Create(qry_Work.FieldByName('ID').asInteger)));
            joResponseJSON.AddPair(TJSONPair.Create('User', sUser));
            joResponseJSON.AddPair(TJSONPair.Create('Password', sPass));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
          end else
          begin
            iCode:= 401;
            sMessage:= 'Unauthorized';
            joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
            joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
            joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Benutzer ' + sUSer + ' nicht berechtigt')));
            joResponseJSONData.AddPair(TJSONPair.Create('Allowed', TJSONBool.Create(False)));
            joResponseJSONData.AddPair(TJSONPair.Create('ID_User', TJSONNumber.Create(qry_Work.FieldByName('ID').asInteger)));
            joResponseJSON.AddPair(TJSONPair.Create('User', sUser));
            joResponseJSON.AddPair(TJSONPair.Create('Password', sPass));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Login', jaDetails));
        end
        else begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'CheckLogin_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function CheckLoginTime_Intern: TJSONObject;
var
  sUser, sPass: String;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'CheckLogin_Intern wird ausgeführt', 0);
  Result:= nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    sUser := TDSSessionManager.GetThreadSession.GetData('Username');
    sPass := TDSSessionManager.GetThreadSession.GetData('Password');
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.sql.text:= 'SELECT ID,Benutzer, Passwort, Zugriff_app FROM time_user WHERE Benutzer = :User';
        qry_Work.ParamByName('User').AsString := sUser;
        qry_Work.Open;
        if qry_Work.RecordCount > 0 then
        begin
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          if not Assigned(joResponseJSONData) then
            joResponseJSONData := TJSONObject.Create;
          if (sPass = qry_Work.FieldByName('Passwort').AsString) AND (qry_Work.FieldByName('Zugriff_app').AsBoolean = True) then
          begin
            iCode:= 200;
            sMessage:= 'OK';
            joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
            joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
            joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
            joResponseJSONData.AddPair(TJSONPair.Create('Allowed', TJSONBool.Create(True)));
            joResponseJSONData.AddPair(TJSONPair.Create('ID_User', TJSONNumber.Create(qry_Work.FieldByName('ID').asInteger)));
            joResponseJSON.AddPair(TJSONPair.Create('User', sUser));
            joResponseJSON.AddPair(TJSONPair.Create('Password', sPass));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
          end else
          begin
            iCode:= 401;
            sMessage:= 'Unauthorized';
            joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
            joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
            joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Benutzer ' + sUSer + ' nicht berechtigt')));
            joResponseJSONData.AddPair(TJSONPair.Create('Allowed', TJSONBool.Create(False)));
            joResponseJSONData.AddPair(TJSONPair.Create('ID_User', TJSONNumber.Create(qry_Work.FieldByName('ID').asInteger)));
            joResponseJSON.AddPair(TJSONPair.Create('User', sUser));
            joResponseJSON.AddPair(TJSONPair.Create('Password', sPass));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Login', jaDetails));
        end
        else begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'CheckLogin_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function SetDeviceID_Intern(const AJSONObject: TJSONObject): TJSONObject;
var
  iID_Benutzer: Integer;
  sToken: string;
  sDeviceID: string;
  iDeviceType: integer;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'SetDeviceID_Intern wird ausgeführt', 0);
  Result:= nil;
  try
    iZaehler:= 0;
    joResponseJSON := nil;
    jaDetails := nil;
    jaDetails :=  AJSONObject.GetValue<TJSONArray>('Device');
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection:= conn;
        for var JSonValue in jaDetails do
        begin
          JSonValue.TryGetValue<string>('DeviceToken',sToken);
          JSonValue.TryGetValue<string>('DeviceID',sDeviceID);
          JSonValue.TryGetValue<integer>('DeviceType',iDeviceType);
          JSonValue.TryGetValue<integer>('ID_Benutzer',iID_Benutzer);

          qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_devices ' +
                                      'WHERE ID_Benutzer = :ID_Benutzer and DeviceID = :DeviceID and DeviceType = :DeviceType';
          qry_Work.ParamByName('ID_Benutzer').asInteger := iID_Benutzer;
          qry_Work.ParamByName('DeviceID').asString := sDeviceID;
          qry_Work.ParamByName('DeviceType').asInteger := iDeviceType;
          qry_Work.Open;
          iAnzahl:= qry_Work.FieldByName('Anzahl').asInteger;
          qry_Work.Close;
          if iAnzahl = 0 then
          begin
            qry_Work.SQL.Text:=  'INSERT INTO manager_devices (ID_Benutzer,DeviceToken,DeviceID,DeviceType' +
                                                    ') Values (:ID_Benutzer,:DeviceToken,:DeviceID,:DeviceType)';
            qry_Work.ParamByName('ID_Benutzer').asInteger := iID_Benutzer;
            qry_Work.ParamByName('DeviceToken').asString := sToken;
            qry_Work.ParamByName('DeviceID').asString := sDeviceID;
            qry_Work.ParamByName('DeviceType').asInteger := iDeviceType;
            qry_Work.ExecSQL;
          end
          else begin
            qry_Work.SQL.Text:=  'Update manager_devices SET DeviceToken= :DeviceToken ' +
                                        'WHERE ID_Benutzer = :ID_Benutzer and DeviceID = :DeviceID and DeviceType = :DeviceType';
            qry_Work.ParamByName('ID_Benutzer').asInteger := iID_Benutzer;
            qry_Work.ParamByName('DeviceToken').asString := sToken;
            qry_Work.ParamByName('DeviceID').asString := sDeviceID;
            qry_Work.ParamByName('DeviceType').asInteger := iDeviceType;
            qry_Work.ExecSQL;
          end;
        end;
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        WriteLog(PCM_Logname,rs_PCMAPPServer_Tokenpruefung,0);
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'SetDeviceID_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
{$EndRegion Server_Login}
{$Region Kontakte}
function GetKontakte_Intern(AID_Benutzer: string): TJSONObject;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetKontakte_Intern wird ausgeführt', 0);
  Result:= nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection:= conn;
        qry_Work.SQL.Text :=  'SELECT kon.ID as Kontakte_ID ,a.Bezeichnung AS Anrede, kon.Vorname,kon.Nachname,' +
                                               'kon.Strasse_Privat,kon.PLZ_Privat,kon.Ort_Privat,'+
                                               'kon.Telefon_Privat,kon.Handy_Privat, kon.E_mail_Privat,'+
                                               'kon.Geburtsdatum, g.Bezeichnung as Geschlecht,'+
                                               'f.Bezeichnung as Familienstand, s.Bezeichnung as Staatsangehoerigkeit,'+
                                               'k.Bezeichnung as Konfession,kon.Firma,kon.Strasse_Ges,kon.PLZ_Ges,'+
                                               'kon.Ort_Ges,kon.Telefon_Ges,kon.Handy_Ges,kon.E_mail_Ges,Internet_Privat,internet_ges '+
                                               'FROM manager_kontakte kon '+
                                               'LEFT OUTER JOIN manager_Anrede a ON a.ID = kon.ID_Anrede '+
                                               'LEFT OUTER JOIN manager_Geschlecht g ON g.ID = kon.ID_GEschlecht '+
                                               'LEFT OUTER JOIN manager_Familienstand f ON f.ID = kon.ID_Familienstand '+
                                               'LEFT OUTER JOIN manager_Staatsangehoerigkeit s ON s.ID = kon.ID_Staatsangehoerigkeit '+
                                               'LEFT OUTER JOIN manager_Konfession k ON k.ID = kon.ID_Konfession Where kon.ID_Benutzer = :ID_Benutzer';
        qry_Work.ParamByName('ID_Benutzer').AsInteger := StrToInt(AID_Benutzer);
        qry_Work.Open;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Kontakteanzahl+ IntToStr(qry_Work.RecordCount),0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry_Work.FieldByName('Kontakte_ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Salutation', TJSONString.Create(qry_Work.FieldByName('Anrede').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Name', TJSONString.Create(qry_Work.FieldByName('Vorname').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Surname', TJSONString.Create(qry_Work.FieldByName('Nachname').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Street_private', TJSONString.Create(qry_Work.FieldByName('Strasse_Privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Postalcode_private', TJSONString.Create(qry_Work.FieldByName('PLZ_Privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Place_private', TJSONString.Create(qry_Work.FieldByName('Ort_Privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Phone_private', TJSONString.Create(qry_Work.FieldByName('Telefon_Privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Mobile_private', TJSONString.Create(qry_Work.FieldByName('Handy_Privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Mail_private', TJSONString.Create(qry_Work.FieldByName('E_mail_Privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Web_private', TJSONString.Create(qry_Work.FieldByName('Internet_privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Birthday', TJSONString.Create(qry_Work.FieldByName('Geburtsdatum').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Gender', TJSONString.Create(qry_Work.FieldByName('Geschlecht').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Maritalstatus', TJSONString.Create(qry_Work.FieldByName('Familienstand').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Nationality', TJSONString.Create(qry_Work.FieldByName('Staatsangehoerigkeit').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Denomination', TJSONString.Create(qry_Work.FieldByName('Konfession').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Company', TJSONString.Create(qry_Work.FieldByName('Firma').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Street_business', TJSONString.Create(qry_Work.FieldByName('Strasse_Ges').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Postalcode_business', TJSONString.Create(qry_Work.FieldByName('PLZ_Ges').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Place_business', TJSONString.Create(qry_Work.FieldByName('Ort_Ges').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Phone_business', TJSONString.Create(qry_Work.FieldByName('Telefon_Ges').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Mobile_business', TJSONString.Create(qry_Work.FieldByName('Handy_Ges').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Mail_business', TJSONString.Create(qry_Work.FieldByName('E_mail_Ges').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Web_business', TJSONString.Create(qry_Work.FieldByName('Internet_ges').asString)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Contacts', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'GetKontakte_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function SetKontakte_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iSyncID: integer;
  iID_Anrede, iID_Geschlecht, iID_Familienstand, iID_Staatsangehoerigkeit, iID_Konfession: integer;
  iID: integer;
  sAnrede: string;
  sVorname: string;
  sNachname: string;
  sStrasse_pri: string;
  sPLZ_pri: string;
  sOrt_pri: string;
  sTelefon_pri: string;
  sHandy_pri: string;
  sMail_pri: string;
  sWeb_pri: string;
  sGeburtsdatum: string;
  sGeschlecht: string;
  sFamilienstand: string;
  sStaatsangehoerigkeit: string;
  sKonfession: string;
  sFirma: string;
  sStrasse_ges: string;
  sPLZ_ges: string;
  sOrt_ges: string;
  sTelefon_ges:  string;
  sHandy_ges: string;
  sMail_ges: string;
  sWeb_ges: string;
  iID_Kontakt: integer;
  sBild: string;
  bDeleted: boolean;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'SetKontakte_Intern wird ausgeführt', 0);
  Result:= nil;
  try
    iZaehler:= 0;
    joResponseJSON := nil;
    jaDetails := nil;
    jaDetails :=  AJSONObject.GetValue<TJSONArray>('Contacts');

    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection:= conn;
        for var JSonValue in jaDetails do
        begin
          JSonValue.TryGetValue<integer>('ID',iID);
          JSonValue.TryGetValue<string>('Salutation',sAnrede);
          JSonValue.TryGetValue<string>('Name',sVorname);
          JSonValue.TryGetValue<string>('Surname',sNachname);
          JSonValue.TryGetValue<string>('Street_private',sStrasse_pri);
          JSonValue.TryGetValue<string>('Postalcode_private',sPLZ_pri);
          JSonValue.TryGetValue<string>('Place_private',sOrt_pri);
          JSonValue.TryGetValue<string>('Phone_private',sTelefon_pri);
          JSonValue.TryGetValue<string>('Mobile_private',sHandy_pri);
          JSonValue.TryGetValue<string>('Mail_private',sMail_pri);
          JSonValue.TryGetValue<string>('Web_private',sWeb_pri);
          JSonValue.TryGetValue<string>('Birthday',sGeburtsdatum);
          JSonValue.TryGetValue<string>('Gender',sGeschlecht);
          JSonValue.TryGetValue<string>('Maritalstatus',sFamilienstand);
          JSonValue.TryGetValue<string>('Nationality',sStaatsangehoerigkeit);
          JSonValue.TryGetValue<string>('Denomination',sKonfession);
          JSonValue.TryGetValue<string>('Company',sFirma);
          JSonValue.TryGetValue<string>('Street_business',sStrasse_ges);
          JSonValue.TryGetValue<string>('Postalcode_business',sPLZ_ges);
          JSonValue.TryGetValue<string>('Place_business',sOrt_ges);
          JSonValue.TryGetValue<string>('Phone_business',sTelefon_ges);
          JSonValue.TryGetValue<string>('Mobile_business',sHandy_ges);
          JSonValue.TryGetValue<string>('Mail_business',sMail_ges);
          JSonValue.TryGetValue<string>('Web_business',sWeb_ges);
          JSonValue.TryGetValue<integer>('ID_Contact', iID_Kontakt);
          JSonValue.TryGetValue<string>('Image',sBild);
          JSonValue.TryGetValue<boolean>('Deleted',bDeleted);
          if bDeleted then
          begin
            qry_Work.SQL.Text :=  'DELETE FROM manager_kontakte WHERE ID = :ID and ID_Benutzer = :ID_Benutzer';
            qry_Work.ParamByName('ID').asInteger := iID_Kontakt;
            qry_Work.ParamByName('ID_Benutzer').asInteger:= StrToInt(AID_Benutzer);
            qry_Work.ExecSQL;
          end
          else
          begin
            // Check neue Datensatz
            qry_Work.SQL.Text:=  'SELECT ID FROM manager_kontakte WHERE ID = :ID and ID_Benutzer = :ID_Benutzer';
            qry_Work.ParamByName('ID').asInteger := iID_Kontakt;
            qry_Work.ParamByName('ID_Benutzer').asInteger:= StrToInt(AID_Benutzer);
            qry_Work.Open;
            iSyncID:=qry_Work.FieldByName('ID').AsInteger;
            // ID's ermitteln
            iID_Anrede:= -1;
            iID_Geschlecht:= -1;
            iID_Familienstand:= -1;
            iID_Staatsangehoerigkeit:= -1;
            iID_Konfession:= -1;
            // Anrede
            if sAnrede <> '' then
            begin
              iID_Anrede:= GetIDFromTable('manager_Anrede',sAnrede);
            end;
            // Geschlecht
            if sGEschlecht <> '' then
            begin
              iID_Geschlecht:= GetIDFromTable('manager_Geschlecht',sGEschlecht);
            end;
            // Familienstand
            if sFamilienstand <> '' then
            begin
              iID_Familienstand:= GetIDFromTable('manager_Familienstand',sFamilienstand);
            end;
            // Staatsangehoerigkeit
            if sStaatsangehoerigkeit <> '' then
            begin
              iID_Staatsangehoerigkeit:= GetIDFromTable('manager_Staatsangehoerigkeit',sStaatsangehoerigkeit);
            end;
            // Konfession
            if sKonfession <> '' then
            begin
              iID_Konfession:= GetIDFromTable('manager_Konfession',sKonfession);
            end;
            // Prüfen ob Kontakt schon vorhanden
            if (qry_Work.RecordCount = 0) or (iSyncID = 0) then
            begin
              if StrToDate(sGeburtsdatum) = StrToDate('30.12.1899')then
              begin
                qry_Work.SQL.Text:=  'INSERT INTO manager_kontakte (ID_Anrede,Vorname,Nachname,Strasse_Privat,PLZ_Privat,Ort_Privat,Telefon_Privat,Handy_privat,E_Mail_Privat,ID_Geschlecht,' +
                                            'ID_Familienstand,ID_Staatsangehoerigkeit,ID_Konfession,Firma,Strasse_Ges,PLZ_Ges,Ort_Ges,Telefon_Ges,Handy_Ges,E_Mail_Ges,ID_Benutzer' +
                                            ') Values (:ID_Anrede,:Vorname,:Nachname,:Strasse_Privat,:PLZ_Privat,:Ort_Privat,:Telefon_Privat,:Handy_privat,:E_Mail_Privat,:ID_Geschlecht,' +
                                            ':ID_Familienstand,:ID_Staatsangehoerigkeit,:ID_Konfession,:Firma,:Strasse_Ges,:PLZ_Ges,:Ort_Ges,:Telefon_Ges,:Handy_Ges,:E_Mail_Ges,:ID_Benutzer)';
              end
              else begin

                qry_Work.SQL.Text:=  'INSERT INTO manager_kontakte (ID_Anrede,Vorname,Nachname,Strasse_Privat,PLZ_Privat,Ort_Privat,Telefon_Privat,Handy_privat,E_Mail_Privat,Geburtsdatum,ID_Geschlecht,' +
                                            'ID_Familienstand,ID_Staatsangehoerigkeit,ID_Konfession,Firma,Strasse_Ges,PLZ_Ges,Ort_Ges,Telefon_Ges,Handy_Ges,E_Mail_Ges,ID_Benutzer' +
                                            ') Values (:ID_Anrede,:Vorname,:Nachname,:Strasse_Privat,:PLZ_Privat,:Ort_Privat,:Telefon_Privat,:Handy_privat,:E_Mail_Privat,:Geburtsdatum,:ID_Geschlecht,' +
                                            ':ID_Familienstand,:ID_Staatsangehoerigkeit,:ID_Konfession,:Firma,:Strasse_Ges,:PLZ_Ges,:Ort_Ges,:Telefon_Ges,:Handy_Ges,:E_Mail_Ges,:ID_Benutzer)';
                qry_Work.ParamByName('Geburtsdatum').asDate:= StrToDate(sGeburtsdatum);
              end;
              qry_Work.ParamByName('ID_Anrede').asInteger:= iID_Anrede;
              qry_Work.ParamByName('Vorname').asString := sVorname;
              qry_Work.ParamByName('Nachname').asString := sNachname;
              qry_Work.ParamByName('Strasse_Privat').asString:= sStrasse_pri;
              qry_Work.ParamByName('PLZ_Privat').asString:=sPlz_pri;
              qry_Work.ParamByName('Ort_Privat').asString:=sOrt_pri;
              qry_Work.ParamByName('Telefon_Privat').asString:= sTelefon_pri;
              qry_Work.ParamByName('Handy_privat').asString:=sHandy_pri;
              qry_Work.ParamByName('E_Mail_Privat').asString:= smail_pri;
              qry_Work.ParamByName('ID_Geschlecht').asInteger:=iID_Geschlecht;
              qry_Work.ParamByName('ID_Familienstand').asInteger:= iID_Familienstand;
              qry_Work.ParamByName('ID_Staatsangehoerigkeit').asInteger:= iID_Staatsangehoerigkeit;
              qry_Work.ParamByName('ID_Konfession').asInteger:= iID_Konfession;
              qry_Work.ParamByName('Firma').asString:= sFirma;
              qry_Work.ParamByName('Strasse_Ges').asString:=sStrasse_ges;
              qry_Work.ParamByName('PLZ_Ges').asString:= sPLZ_ges;
              qry_Work.ParamByName('Ort_Ges').asString:=sOrt_ges;
              qry_Work.ParamByName('Telefon_Ges').asString:=sTelefon_ges;
              qry_Work.ParamByName('Handy_Ges').asString:=sHandy_ges;
              qry_Work.ParamByName('E_Mail_Ges').asString:=smail_ges;
              qry_Work.ParamByName('ID_Benutzer').asInteger:= StrToInt(AID_Benutzer);
              qry_Work.ExecSQL;
            end
            else begin

              if (StrToDate(sGeburtsdatum) <> StrToDate('30.12.1899')) and (sGeburtsdatum <> '')  then UpdateFieldValues_TDate('Geburtsdatum','manager_Kontakte',StrToDate(sGeburtsdatum),iSyncID);
              if sVorname <> '' then	UpdateFieldValues_String('Vorname','manager_Kontakte',sVorname,iSyncID);
              if sNachname <> '' then UpdateFieldValues_String('Nachname','manager_Kontakte',sNachname,iSyncID);
              if sStrasse_pri <> '' then	UpdateFieldValues_String('Strasse_Privat','manager_Kontakte',sStrasse_pri,iSyncID);
              if sPlz_pri <> '' then UpdateFieldValues_String('PLZ_Privat','manager_Kontakte',sPlz_pri,iSyncID);
              if sOrt_pri <> '' then UpdateFieldValues_String('Ort_Privat','manager_Kontakte',sOrt_pri,iSyncID);
              if sTelefon_pri <> '' then UpdateFieldValues_String('Telefon_Privat','manager_Kontakte',sTelefon_pri,iSyncID);
              if sHandy_pri <> '' then UpdateFieldValues_String('Handy_privat','manager_Kontakte',sHandy_pri,iSyncID);
              if smail_pri <> '' then UpdateFieldValues_String('E_Mail_Privat','manager_Kontakte',smail_pri,iSyncID);
              if sGeschlecht <> '' then UpdateFieldValues_Integer('ID_Geschlecht','manager_Kontakte',iID_Geschlecht,iSyncID);
              if sFamilienstand <> '' then	UpdateFieldValues_Integer('ID_Familienstand','manager_Kontakte',iID_Familienstand,iSyncID);
              if sStaatsangehoerigkeit <> '' then UpdateFieldValues_Integer('ID_Staatsangehoerigkeit','manager_Kontakte',iID_Staatsangehoerigkeit,iSyncID);
              if sKonfession <> '' then UpdateFieldValues_Integer('ID_Konfession','manager_Kontakte',iID_Konfession,iSyncID);
              if sAnrede <> '' then UpdateFieldValues_Integer('ID_Anrede','manager_Kontakte',iID_Anrede,iSyncID);
              if sFirma <> '' then UpdateFieldValues_String('Firma','manager_Kontakte',sFirma,iSyncID);
              if sStrasse_ges <> '' then UpdateFieldValues_String('Strasse_Ges','manager_Kontakte',sStrasse_ges,iSyncID);
              if sPLZ_ges <> '' then	UpdateFieldValues_String('PLZ_Ges','manager_Kontakte',sPLZ_ges,iSyncID);
              if sOrt_ges <> '' then	UpdateFieldValues_String('Ort_Ges','manager_Kontakte',sOrt_ges,iSyncID);
              if sTelefon_ges <> '' then UpdateFieldValues_String('Telefon_Ges','manager_Kontakte',sTelefon_ges,iSyncID);
              if sHandy_ges <> '' then UpdateFieldValues_String('Handy_Ges','manager_Kontakte',sHandy_ges,iSyncID);
              if smail_ges <> '' then UpdateFieldValues_String('E_Mail_Ges','manager_Kontakte',smail_ges,iSyncID);
            end;
          end;
          iZaehler:= iZaehler + 1;
        end;
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        Result := joResponseJSON;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Kontaktepruefung + IntToStr(iZaehler),0);
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'SetKontakte_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
{$EndRegion Kontakte}
{$Region Kalender}
function GetKalender_Intern(AID_Benutzer: string): TJSONObject;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetKalender_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.SQL.Text := 'Select ID as Kalender_ID,EventType,Caption,Location, Message,'+
                                          'if(Kalendername = "Geburtstag",Cast(CONCAT_WS("-", YEAR(NOW()),Month(Start) ,DAY(Start)) AS DATETIME),START) AS Start,'+
                                          'if(Kalendername = "Geburtstag",Cast(CONCAT_WS("-", YEAR(NOW()),Month(Finish) ,DAY(Finish)) AS DATETIME),Finish) AS Finish,'+
                                          'CompleteDay,Reminder,'+
                                          'if(Kalendername = "Geburtstag",CAST(CONCAT_WS(" ",CONCAT_WS("-", YEAR(NOW()),Month(ReminderDate) ,DAY(ReminderDate)), CONCAT_WS("-", Hour(ReminderDate),Minute(ReminderDate) ,Second(ReminderDate))) AS DATETIME),ReminderDate) AS ReminderDate,'+
                                          'ReminderMinutesBeforeStart, Kalendername,RecurrenceInfo,ID_KalenderApp, wiederholung_text FROM manager_kalender ' +
                                          'WHERE (RecurrenceInfo IS NOT NULL OR START >= DATE_ADD(now(), INTERVAL -30 DAY)) AND ID_Benutzer = :ID and bearbeitetam is null' ;
        qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
        qry_Work.Open;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Kalenderanzahl + IntToStr(qry_Work.RecordCount),0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry_Work.FieldByName('Kalender_ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('EventType', TJSONNumber.Create(qry_Work.FieldByName('EventType').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Caption', TJSONString.Create(qry_Work.FieldByName('Caption').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Location', TJSONString.Create(qry_Work.FieldByName('Location').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Message', TJSONString.Create(qry_Work.FieldByName('Message').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Start', TJSONString.Create(qry_Work.FieldByName('Start').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Finish', TJSONString.Create(qry_Work.FieldByName('Finish').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('CompleteDay', TJSONBool.Create(qry_Work.FieldByName('CompleteDay').AsBoolean)));
            joResponseJSONData.AddPair(TJSONPair.Create('Reminder', TJSONBool.Create(qry_Work.FieldByName('Reminder').AsBoolean)));
            joResponseJSONData.AddPair(TJSONPair.Create('Reminderdate', TJSONString.Create(qry_Work.FieldByName('reminderdate').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Reminderbeforestart', TJSONNumber.Create(qry_Work.FieldByName('ReminderMinutesBeforeStart').asInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Calendername', TJSONString.Create(qry_Work.FieldByName('Kalendername').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('ID_Calenderapp', TJSONnumber.Create(qry_Work.FieldByName('ID_KalenderApp').asInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Reccurrencetext', TJSONString.Create(qry_Work.FieldByName('wiederholung_text').asString)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Calendar', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'GetKalender_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function SetKalender_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
  function FormatDateTimeToStr(ADate: TDateTime): String ;
  var
    wJahr,
    wMonat,
    wTag,
    wStunde,
    wMinute,
    wSekunde,
    wMSek: word;
  begin
    Result := '';
    DecodeDateTime(ADate,wJahr,wMonat,wTag,wStunde,wMinute,wSekunde,wMSek);
    Result:= IntToStr(wJahr) + '-' + AddZeros(IntToStr(wMonat), 2) + '-' + AddZeros(IntToStr(wTag), 2) + ' ' +
             AddZeros(IntToStr(wStunde), 2) + ':' + AddZeros(IntToStr(wMinute), 2) +':' + AddZeros(IntToStr(wSekunde), 2)
  end;
var
  iIDCal: integer;
  sCaptionCal: String;
  iEventTypeCal: integer;
  sLocationCal: String;
  sMessageCal: String;
  sStartDateCal: String;
  sFinishDateCal: String;
  bCompleteDayCal: boolean;
  bReminderCal: boolean;
  sReminderDateCal: string;
  iReminderMinutesBeforeStartCal: integer;
  sKalendernameCal: string;
  iID_KalenderCal: integer;
  bDeletedCal: boolean;
  iLabelColorCal,iFontColorCal: integer;
  sStartCal: String;
  sFinishCal: String;
  sReccurrencetextCal: String;
  iSyncID: integer;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'SetKalender_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON := nil;
    jaDetails := nil;
    iZaehler:= 0;
    jaDetails :=  AJSONObject.GetValue<TJSONArray>('Calendar');
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein

        for var JSonValue in jaDetails do
        begin
          JSonValue.TryGetValue<integer>('ID',iID_KalenderCal);
          JSonValue.TryGetValue<integer>('EventType',iEventTypeCal);
          JSonValue.TryGetValue<string>('Caption',sCaptionCal);
          JSonValue.TryGetValue<string>('Location',sLocationCal);
          JSonValue.TryGetValue<string>('Message',sMessageCal);
          JSonValue.TryGetValue<string>('Start',sStartDateCal);
          JSonValue.TryGetValue<string>('Finish',sFinishDateCal);
          JSonValue.TryGetValue<boolean>('CompleteDay',bCompleteDayCal);
          JSonValue.TryGetValue<boolean>('Reminder',bReminderCal);
          JSonValue.TryGetValue<string>('ReminderDate',sReminderDateCal);
          JSonValue.TryGetValue<integer>('ReminderBeforeStart',iReminderMinutesBeforeStartCal);
          JSonValue.TryGetValue<string>('Calendername',sKalendernameCal);
          JSonValue.TryGetValue<integer>('ID_Calendar,',iIDCal);
      //    TryGetValue<integer>('ID_Calendar,',iID_KalenderCal);
          JSonValue.TryGetValue<string>('Reccurrencetext',sReccurrencetextCal);
          JSonValue.TryGetValue<boolean>('Deleted',bDeletedCal);

          // Kalender löschen
          if bDeletedCal then
          begin
            qry_Work.SQL.Text :=  'DELETE FROM manager_kalender WHERE ID = :ID';
            qry_Work.ParamByName('ID').AsInteger := iID_KalenderCal;
            qry_Work.ExecSQL;
          end
          else
          begin
            // Check neue Datensatz
            qry_Work.SQL.Text:=  'SELECT ID,LabelColor,FontColor FROM manager_kalender WHERE ID = :ID_Kalender';
            qry_Work.ParamByName('ID_Kalender').asInteger := iID_KalenderCal;
            qry_Work.Open;
            if qry_Work.RecordCount = 0 then
            begin
              sStartCal:= FormatDateTimeToStr(StrToDateTime(sStartDateCal));
              sFinishCal:=FormatDateTimeToStr(StrToDateTime(sFinishDateCal));
              qry_Work.SQL.Text:=  'SELECT ID,LabelColor,FontColor  FROM manager_kalender WHERE ' +
                                          'Caption = :Caption and START = :Start and Finish = :Finish';
              qry_Work.ParamByName('Caption').asString := sCaptionCal;
              qry_Work.ParamByName('Start').asDateTime := StrToDateTime(sStartDateCal);
              qry_Work.ParamByName('Finish').asDateTime := StrToDateTime(sFinishDateCal);
              qry_Work.Open;
              if qry_Work.RecordCount = 0 then
              begin
                qry_Work.SQL.Text:= 'INSERT INTO manager_kalender(Caption,EventType,Location,Message,' +
                                           'START,Finish,CompleteDay,Reminder,ReminderDate,ReminderMinutesBeforeStart,' +
                                           'ID_Benutzer,Kalendername,LabelColor,FontColor,ID_KalenderAPP) VALUES (:Caption,:EventType,' +
                                           ':Location,:Message,:START,:Finish,:CompleteDay,:Reminder,:ReminderDate,' +
                                           ':ReminderMinutesBeforeStart,:ID_Benutzer,:Kalendername,:LabelColor,:FontColor,:ID_KalenderAPP)';
                qry_Work.ParamByName('Caption').AsString:= sCaptionCal;
                qry_Work.ParamByName('EventType').AsInteger:= iEventTypeCal;
                qry_Work.ParamByName('Location').AsString:= sLocationCal;
                qry_Work.ParamByName('Message').AsString:= sMessageCal;
                qry_Work.ParamByName('START').asDateTime:= StrToDateTime(sStartDateCal);
                qry_Work.ParamByName('Finish').asDateTime:= StrToDateTime(sFinishDateCal);
                qry_Work.ParamByName('ID_KalenderAPP').asInteger:= iIDCal;
                if bCompleteDayCal then
                  qry_Work.ParamByName('CompleteDay').AsString:= 'true'
                else
                  qry_Work.ParamByName('CompleteDay').AsString:= 'false';
                if bReminderCal then
                  qry_Work.ParamByName('Reminder').AsString:= 'true'
                else
                  qry_Work.ParamByName('Reminder').AsString:= 'false';
                if (bReminderCal) and (sReminderDateCal = '') then
                  sReminderDateCal := DateTimeToStr(IncMinute(StrToDateTime(sStartDateCal),-iReminderMinutesBeforeStartCal));
                qry_Work.ParamByName('ReminderDate').asDateTime:= StrToDateTime(sReminderDateCal);
                qry_Work.ParamByName('ReminderMinutesBeforeStart').AsInteger:= iReminderMinutesBeforeStartCal;
                qry_Work.ParamByName('ID_Benutzer').AsInteger:= StrToInt(AID_Benutzer);
                qry_Work.ParamByName('Kalendername').AsString:= sKalendernameCal;
                qry_Work.ParamByName('LabelColor').AsInteger:= 13083265;
                qry_Work.ParamByName('FontColor').AsInteger:= 0;
                qry_Work.ExecSQL;
              end
              else begin
                iSyncID:= qry_Work.FieldByName('ID').asInteger;
                iFontColorCal:= qry_Work.FieldByName('FontColor').AsInteger;
                iLabelColorCal:= qry_Work.FieldByName('LabelColor').AsInteger;
                if sCaptionCal <> '' then UpdateFieldValues_String('Caption','manager_Kalender',sCaptionCal,iSyncID);
                if iEventTypeCal <> -1 then UpdateFieldValues_Integer('EventType','manager_Kalender',iEventTypeCal,iSyncID);
                if sLocationCal <> '' then UpdateFieldValues_String('Location','manager_Kalender',sLocationCal,iSyncID);
                if sMessageCal <> ''  then UpdateFieldValues_String('Message','manager_Kalender',sMessageCal,iSyncID);
                if sStartDateCal <> ''  then UpdateFieldValues_TDateTime('Start','manager_Kalender',StrToDateTime(sStartDateCal),iSyncID);
                if sFinishDateCal <> ''  then UpdateFieldValues_TDateTime('Finish','manager_Kalender',StrToDateTime(sFinishDateCal),iSyncID);
                if iIDCal <> -1 then UpdateFieldValues_Integer('ID_KalenderApp','manager_Kalender',iIDCal,iSyncID);
                if bCompleteDayCal then UpdateFieldValues_String('CompleteDay','manager_Kalender','True',iSyncID) else UpdateFieldValues_String('CompleteDay','manager_Kalender','False',iSyncID);
                if bReminderCal then UpdateFieldValues_String('Reminder','manager_Kalender','True',iSyncID) else UpdateFieldValues_String('Reminder','manager_Kalender','False',iSyncID);
                if iReminderMinutesBeforeStartCal <> 0 then UpdateFieldValues_integer('ReminderMinutesBeforeStart','manager_Kalender',iReminderMinutesBeforeStartCal,iSyncID);
                if sReminderDateCal <> ''  then UpdateFieldValues_TDateTime('ReminderDate','manager_Kalender',StrToDateTime(sReminderDateCal),iSyncID);
                if sKalendernameCal <> '' then UpdateFieldValues_String('Kalendername','manager_Kalender',sKalendernameCal,iSyncID);
                UpdateFieldValues_Integer('Typ','manager_Kalender',2,iSyncID);
                case AnsiIndexStr(sCaptionCal, ['Biomüll', 'Restmüll','Papier','Gelber Sack','Giftmobil']) of
                  // BioMüll
                  0:
                  begin
                    iFontColorCal:= clWhite;
                    iLabelColorCal := 944838;
                  end;
                  // RestMüll
                  1:
                  begin
                    iFontColorCal:= clWhite;
                    iLabelColorCal := 5658199;
                  end;
                  // Papier
                  2:
                  begin
                    iFontColorCal:= clWhite;
                    iLabelColorCal := 13214474;
                  end;
                  // Gelber Sack
                  3:
                  begin
                    iFontColorCal:= clBlack;
                    iLabelColorCal := 56831;
                  end;
                  // Giftmobil
                  4:
                  begin
                    iFontColorCal:= clWhite;
                    iLabelColorCal := 7679146;
                  end;
                end;
                if Pos('Geburtstag',sCaptionCal) > 0 then
                begin
                  iFontColorCal:= 0;
                  iLabelColorCal := 8421376;
                end;
                if (Pos('ganzer Krankheitstag',sCaptionCal) > 0) or (Pos('halber Krankheitstag',sCaptionCal) > 0) then
                begin
                  iFontColorCal:= 0;
                  iLabelColorCal:= 8421631
                end;
                if (Pos('ganzer Urlaubstag',sCaptionCal) > 0) or (Pos('halber Urlaubstag',sCaptionCal) > 0) then
                begin
                  iFontColorCal:= 0;
                  iLabelColorCal:= 16776960;
                end;

                if Pos('Arbeitszeit',sCaptionCal) > 0 then
                begin
                  iFontColorCal:= 0;
                  iLabelColorCal := 8453888;
                end;
                if Pos('Pause',sCaptionCal) > 0 then
                begin
                  iFontColorCal:= 0;
                  iLabelColorCal := 12632256
                end;
                if sLocationCal = 'Feiertag' then
                begin
                  iFontColorCal:= 0;
                  iLabelColorCal := 8453888;
                end;
                if sLocationCal = 'Ferien' then
                begin
                  iFontColorCal:= 0;
                  iLabelColorCal := 8453888;
                end;
                if sLocationCal = 'Kita' then
                begin
                  iFontColorCal:= 0;
                  iLabelColorCal := 8453888;
                end;
                UpdateFieldValues_Integer('LabelColor','manager_kalender',iLabelColorCal,iSyncID);
                UpdateFieldValues_Integer('FontColor','manager_kalender',iFontColorCal,iSyncID);
              end;
            end
            else begin
             iSyncID:= qry_Work.FieldByName('ID').asInteger;
              iFontColorCal:= qry_Work.FieldByName('FontColor').AsInteger;
              iLabelColorCal:= qry_Work.FieldByName('LabelColor').AsInteger;
              if sCaptionCal <> '' then UpdateFieldValues_String('Caption','manager_Kalender',sCaptionCal,iSyncID);
              if iEventTypeCal <> -1 then UpdateFieldValues_Integer('EventType','manager_Kalender',iEventTypeCal,iSyncID);
              if sLocationCal <> '' then UpdateFieldValues_String('Location','manager_Kalender',sLocationCal,iSyncID);
              if sMessageCal <> ''  then UpdateFieldValues_String('Message','manager_Kalender',sMessageCal,iSyncID);
              if sStartDateCal <> ''  then UpdateFieldValues_TDateTime('Start','manager_Kalender',StrToDateTime(sStartDateCal),iSyncID);
              if sFinishDateCal <> ''  then UpdateFieldValues_TDateTime('Finish','manager_Kalender',StrToDateTime(sFinishDateCal),iSyncID);
              if iIDCal <> -1 then UpdateFieldValues_Integer('ID_KalenderApp','manager_Kalender',iIDCal,iSyncID);
              if bCompleteDayCal then UpdateFieldValues_String('CompleteDay','manager_Kalender','True',iSyncID) else UpdateFieldValues_String('CompleteDay','manager_Kalender','False',iSyncID);
              if bReminderCal then UpdateFieldValues_String('Reminder','manager_Kalender','True',iSyncID) else UpdateFieldValues_String('Reminder','manager_Kalender','False',iSyncID);
              if iReminderMinutesBeforeStartCal <> 0 then UpdateFieldValues_integer('ReminderMinutesBeforeStart','manager_Kalender',iReminderMinutesBeforeStartCal,iSyncID);
              if sReminderDateCal <> ''  then UpdateFieldValues_TDateTime('ReminderDate','manager_Kalender',StrToDateTime(sReminderDateCal),iSyncID);
              if sKalendernameCal <> '' then UpdateFieldValues_String('Kalendername','manager_Kalender',sKalendernameCal,iSyncID);
              UpdateFieldValues_Integer('Typ','manager_Kalender',2,iSyncID);
              case AnsiIndexStr(sCaptionCal, ['Biomüll', 'Restmüll','Papier','Gelber Sack','Giftmobil']) of
                // BioMüll
                0:
                begin
                  iFontColorCal:= clWhite;
                  iLabelColorCal := 944838;
                end;
                // RestMüll
                1:
                begin
                  iFontColorCal:= clWhite;
                  iLabelColorCal := 5658199;
                end;
                // Papier
                2:
                begin
                  iFontColorCal:= clWhite;
                  iLabelColorCal := 13214474;
                end;
                // Gelber Sack
                3:
                begin
                  iFontColorCal:= clBlack;
                  iLabelColorCal := 56831;
                end;
                // Giftmobil
                4:
                begin
                  iFontColorCal:= clWhite;
                  iLabelColorCal := 7679146;
                end;
              end;
              if Pos('Geburtstag',sCaptionCal) > 0 then
              begin
                iFontColorCal:= 0;
                iLabelColorCal := 8421376;
              end;
              if (Pos('ganzer Krankheitstag',sCaptionCal) > 0) or (Pos('halber Krankheitstag',sCaptionCal) > 0) then
              begin
                iFontColorCal:= 0;
                iLabelColorCal:= 8421631
              end;
              if (Pos('ganzer Urlaubstag',sCaptionCal) > 0) or (Pos('halber Urlaubstag',sCaptionCal) > 0) then
              begin
                iFontColorCal:= 0;
                iLabelColorCal:= 16776960;
              end;

              if Pos('Arbeitszeit',sCaptionCal) > 0 then
              begin
                iFontColorCal:= 0;
                iLabelColorCal := 8453888;
              end;
              if Pos('Pause',sCaptionCal) > 0 then
              begin
                iFontColorCal:= 0;
                iLabelColorCal := 12632256
              end;
              if sLocationCal = 'Feiertag' then
              begin
                iFontColorCal:= 0;
                iLabelColorCal := 8453888;
              end;
              if sLocationCal = 'Ferien' then
              begin
                iFontColorCal:= 0;
                iLabelColorCal := 8453888;
              end;
              if sLocationCal = 'Kita' then
              begin
                iFontColorCal:= 0;
                iLabelColorCal := 8453888;
              end;
              UpdateFieldValues_Integer('LabelColor','manager_kalender',iLabelColorCal,iSyncID);
              UpdateFieldValues_Integer('FontColor','manager_kalender',iFontColorCal,iSyncID);
            end;
          end;
        end;
        iZaehler:= iZaehler + 1;
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        Result := joResponseJSON;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Kalenderpruefung + IntToStr(iZaehler),0);
      finally
        qry_Work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'SetKalender_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
{$EndRegion Kalender}
{$Region Passwords}
function GetPasswoerter_Intern(AID_Benutzer: string): TJSONObject;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetPasswoerter_Intern wird ausgeführt',0);
  joResponseJSON:= nil;
  try
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.SQL.Text :=  'SELECT pw.id AS passwoerter_ID,pw.Bezeichnung,pw.user,pw.password,pw.link,pw.VPN_SharedSecret, ' +
                                           'pw.APP_IP,ifnull(pw.APP_Port,0) as APP_port,pw.APP_Verschluesselung,pw.MAIL_Posteingangsserver,ifnull(pw.MAIL_PosteingangsPort,0) as MAIL_PosteingangsPort, ' +
                                           'pw.MAIL_PosteingangsVerschluesselung,pw.MAIL_Postausgangsserver,ifnull(pw.MAIL_PostausgangsPort,0) as MAIL_PostausgangsPort, ' +
                                           'pw.MAIL_PostausgangsVerschluesselung,pwt.Bezeichnung as pwtyp,pw.Wlan ' +
                                           'From manager_passwoerter pw ' +
                                           'LEFT OUTER JOIN manager_passwoerter_typ pwt ON pw.ID_Typ = pwt.ID ' +
                                           'Where ID_Benutzer = :ID';
        qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
        qry_Work.Open;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Passwordanzahl + IntToStr(qry_Work.RecordCount),0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry_Work.FieldByName('passwoerter_ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Passwordname', TJSONString.Create(qry_Work.FieldByName('Bezeichnung').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('User', TJSONString.Create(qry_Work.FieldByName('user').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Password', TJSONString.Create(qry_Work.FieldByName('password').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Link', TJSONString.Create(qry_Work.FieldByName('link').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('VPN_SharedSecret', TJSONString.Create(qry_Work.FieldByName('VPN_SharedSecret').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('APP_IP', TJSONString.Create(qry_Work.FieldByName('APP_IP').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('APP_Port', TJSONNumber.Create(qry_Work.FieldByName('APP_Port').asInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('APP_Encryption', TJSONString.Create(qry_Work.FieldByName('APP_Verschluesselung').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Incomingmail_Server', TJSONString.Create(qry_Work.FieldByName('MAIL_Posteingangsserver').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Incomingmail_Port', TJSONNumber.Create(qry_Work.FieldByName('MAIL_PosteingangsPort').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Incomingmail_Encryption', TJSONString.Create(qry_Work.FieldByName('MAIL_PosteingangsVerschluesselung').AsString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Outgoingmail_Server', TJSONString.Create(qry_Work.FieldByName('MAIL_Postausgangsserver').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Outgoingmail_Port', TJSONNumber.Create(qry_Work.FieldByName('MAIL_PostausgangsPort').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Outgoingmail_Encryption', TJSONString.Create(qry_Work.FieldByName('MAIL_PostausgangsVerschluesselung').AsString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Passwordtype', TJSONString.Create(qry_Work.FieldByName('pwtyp').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Wlankey', TJSONString.Create(qry_Work.FieldByName('Wlan').asString)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Passwords', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'GetPasswoerter_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function SetPasswoerter_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iIDPWD,iID_TypPWD: integer;
  sPasswordnamePWD: String;
  sUserPWD: String;
  sPasswordPWD: String;
  sLinkPWD: String;
  sVPN_SharedSecretPWD: string;
  sAPP_IPPWD: string;
  iAPP_PortPWD: integer;
  sAPP_EncryptionPWD: string;
  sIncomingmail_ServerPWD: string;
  iIncomingmail_PortPWD: integer;
  sIncomingmail_EncryptionPWD: string;
  sOutgoingmail_ServerPWD: string;
  iOutgoingmail_PortPWD: integer;
  sOutgoingmail_EncryptionPWD: string;
  sPasswordtypePWD: string;
  sWlankeyPWD:String;
  iID_PasswordPWD: integer;
  bDeletedPWD: boolean;
  iSyncID: integer;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'SetPasswoerter_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON := nil;
    jaDetails := nil;
    iZaehler:= 0;
    jaDetails :=  AJSONObject.GetValue<TJSONArray>('Passwords');
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        for var JSonValue in jaDetails do
        begin
          JSonValue.TryGetValue<integer>('ID',iIDPWD);
          JSonValue.TryGetValue<string>('Passwordname',sPasswordnamePWD);
          JSonValue.TryGetValue<string>('User',sUserPWD);
          JSonValue.TryGetValue<string>('Password',sPasswordPWD);
          JSonValue.TryGetValue<string>('Link',sLinkPWD);
          JSonValue.TryGetValue<string>('VPN_SharedSecret',sVPN_SharedSecretPWD);
          JSonValue.TryGetValue<string>('APP_IP',sAPP_IPPWD);
          JSonValue.TryGetValue<integer>('APP_Port',iAPP_PortPWD);
          JSonValue.TryGetValue<string>('APP_Encryption',sAPP_EncryptionPWD);
          JSonValue.TryGetValue<string>('Incomingmail_Server',sIncomingmail_ServerPWD);
          JSonValue.TryGetValue<integer>('Incomingmail_Port',iIncomingmail_PortPWD);
          JSonValue.TryGetValue<string>('Incomingmail_Encryption', sIncomingmail_EncryptionPWD);
          JSonValue.TryGetValue<string>('Outgoingmail_Server',sOutgoingmail_ServerPWD);
          JSonValue.TryGetValue<integer>('Outgoingmail_Port',iOutgoingmail_PortPWD);
          JSonValue.TryGetValue<string>('Outgoingmail_Encryption', sOutgoingmail_EncryptionPWD);
          JSonValue.TryGetValue<string>('Passwordtype',sPasswordtypePWD);
          JSonValue.TryGetValue<string>('Wlankey',sWlankeyPWD);
          JSonValue.TryGetValue<integer>('ID_Password',iID_PasswordPWD);
          JSonValue.TryGetValue<boolean>('Deleted',bDeletedPWD);
          if bDeletedPWD then
          begin
            qry_Work.SQL.Text:=  'Delete FROM manager_passwoerter WHERE ID = :ID';
            qry_Work.ParamByName('ID').asInteger := iID_PasswordPWD;
            qry_Work.ExecSQL;
          end
          else
          begin
            // Check neue Datensatz
            qry_Work.SQL.Text:=  'SELECT ID FROM manager_passwoerter WHERE ID = :ID';
            qry_Work.ParamByName('ID').asInteger := iID_PasswordPWD;
            qry_Work.Open;
            iSyncID:= qry_Work.FieldByName('ID').AsInteger;
            iID_TypPWD:= -1;
            // Typ
            if sPasswordtypePWD <> '' then
            begin
              iID_TypPWD:= GetIDFromTable('manager_passwoerter_typ',sPasswordtypePWD);
            end;
            if qry_Work.RecordCount = 0 then
            begin
              qry_Work.SQL.Text:= 'INSERT INTO  manager_passwoerter (Bezeichnung,user,password,link,ID_benutzer,' +
                             'VPN_SharedSecret,APP_IP,APP_Port,APP_Verschluesselung,MAIL_Posteingangsserver,' +
                             'MAIL_PosteingangsPort,MAIL_PosteingangsVerschluesselung,MAIL_Postausgangsserver,' +
                             'MAIL_PostausgangsPort,MAIL_PostausgangsVerschluesselung,ID_Typ,WLAN) Values (' +
                             ':Bezeichnung,:user,:password,:link,:ID_benutzer,:VPN_SharedSecret,:APP_IP,:APP_Port,' +
                             ':APP_Verschluesselung,:MAIL_Posteingangsserver,:MAIL_PosteingangsPort,' +
                             ':MAIL_PosteingangsVerschluesselung,:MAIL_Postausgangsserver,:MAIL_PostausgangsPort,' +
                             ':MAIL_PostausgangsVerschluesselung,:ID_Typ,:WLAN)';
              qry_Work.ParamByName('Bezeichnung').asString:= sPasswordnamePWD;
              qry_Work.ParamByName('user').asString:= sUserPWD;
              qry_Work.ParamByName('password').asString:= spasswordPWD;
              qry_Work.ParamByName('link').asString:= slinkPWD;
              qry_Work.ParamByName('ID_benutzer').asInteger:= StrToInt(AID_Benutzer);
              qry_Work.ParamByName('VPN_SharedSecret').asString:= sVPN_SharedSecretPWD;
              qry_Work.ParamByName('APP_IP').asString:= sAPP_IPPWD;
              qry_Work.ParamByName('APP_Port').asInteger:= iAPP_PortPWD;
              qry_Work.ParamByName('APP_Verschluesselung').asString:= sAPP_EncryptionPWD;
              qry_Work.ParamByName('MAIL_Posteingangsserver').asString:= sIncomingmail_ServerPWD;
              qry_Work.ParamByName('MAIL_PosteingangsPort').asInteger:= iIncomingmail_PortPWD;
              qry_Work.ParamByName('MAIL_PosteingangsVerschluesselung').asString:= sIncomingmail_EncryptionPWD;
              qry_Work.ParamByName('MAIL_Postausgangsserver').asString:= sOutgoingmail_ServerPWD;
              qry_Work.ParamByName('MAIL_PostausgangsPort').asInteger:= iOutgoingmail_PortPWD;
              qry_Work.ParamByName('MAIL_PostausgangsVerschluesselung').asString:= sOutgoingmail_EncryptionPWD;
              qry_Work.ParamByName('ID_Typ').asInteger:= iID_TypPWD;
              qry_Work.ParamByName('WLAN').asString:= sWlankeyPWD;
              qry_Work.ExecSQL;
            end
            else
            begin
              if sPasswordnamePWD <> '' then UpdateFieldValues_String('Bezeichnung','manager_passwoerter',sPasswordnamePWD,iSyncID);
              if sUserPWD <> '' then UpdateFieldValues_String('User','manager_passwoerter',sUserPWD,iSyncID);
              if spasswordPWD <> '' then UpdateFieldValues_String('PASSWORD','manager_passwoerter',spasswordPWD,iSyncID);
              if slinkPWD <> '' then UpdateFieldValues_String('link','manager_passwoerter',slinkPWD,iSyncID);
              if sVPN_SharedSecretPWD <> '' then UpdateFieldValues_String('VPN_SharedSecret','manager_passwoerter',sVPN_SharedSecretPWD,iSyncID);
              if sAPP_IPPWD <> '' then UpdateFieldValues_String('APP_IP','manager_passwoerter',sAPP_IPPWD,iSyncID);
              if IntToStr(iAPP_PortPWD) <> '' then UpdateFieldValues_Integer('APP_Port','manager_passwoerter',iAPP_PortPWD,iSyncID);
              if sAPP_EncryptionPWD <> '' then UpdateFieldValues_String('APP_Verschluesselung','manager_passwoerter',sAPP_EncryptionPWD,iSyncID);
              if sIncomingmail_ServerPWD <> '' then UpdateFieldValues_String('MAIL_Posteingangsserver','manager_passwoerter',sIncomingmail_ServerPWD,iSyncID);
              if IntToStr(iIncomingmail_PortPWD) <> '' then UpdateFieldValues_Integer('MAIL_PosteingangsPort','manager_passwoerter',iIncomingmail_PortPWD,iSyncID);
              if sIncomingmail_EncryptionPWD <> '' then UpdateFieldValues_String('MAIL_PosteingangsVerschluesselung','manager_passwoerter',sIncomingmail_EncryptionPWD,iSyncID);
              if sOutgoingmail_ServerPWD <> '' then UpdateFieldValues_String('MAIL_Postausgangsserver','manager_passwoerter',sOutgoingmail_ServerPWD,iSyncID);
              if IntToStr(iOutgoingmail_PortPWD) <> '' then UpdateFieldValues_Integer('MAIL_PostausgangsPort','manager_passwoerter',iOutgoingmail_PortPWD,iSyncID);
              if sOutgoingmail_EncryptionPWD <> '' then UpdateFieldValues_String('MAIL_PostausgangsVerschluesselung','manager_passwoerter',sOutgoingmail_EncryptionPWD,iSyncID);
              if sPasswordtypePWD <> '' then UpdateFieldValues_Integer('ID_Typ','manager_passwoerter',iID_TypPWD,iSyncID);
              if sWlankeyPWD <> '' then UpdateFieldValues_String('WLAN','manager_passwoerter',sWlankeyPWD,iSyncID);
            end;
          end;
          iZaehler:= iZaehler + 1;
        end;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Passwordpruefung + IntToStr(iZaehler),0);
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.Free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'SetPasswoerter_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
{$EndRegion Passwords}
{$Region Serials}
function GetSerials_Intern(AID_Benutzer: string): TJSONObject;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetSerials_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn;
        qry_Work.SQL.Text := 'SELECT s.ID as Serials_ID,s.App AS Bezeichnung, sk.USER AS benutzer, ' +
                                              'sk.Serial AS serialkey, st.Bezeichnung as Typ ' +
                                              'FROM manager_serials S ' +
                                              'LEFT OUTER JOIN Manager_Serials_keys sk ON sk.ID_Serial = s.ID ' +
                                              'LEFT OUTER JOIN Manager_Serials_typ st ON st.ID = s.ID_TYp ' +
                                              'WHERE s.ID_Benutzer = :ID';
        qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
        qry_Work.Open;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Serialsanzahl + IntToStr(qry_Work.RecordCount),0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry_Work.FieldByName('Serials_ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Serialname', TJSONString.Create(qry_Work.FieldByName('Bezeichnung').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('User', TJSONString.Create(qry_Work.FieldByName('benutzer').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Serialkey', TJSONString.Create(qry_Work.FieldByName('serialkey').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('SerialType', TJSONString.Create(qry_Work.FieldByName('Typ').asString)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Serials', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'GetSerials_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function SetSerials_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iID: Integer;
  sSerialname: String;
  sUser: String;
  sSerialkey: String;
  sSerialType: String;
  bDeleted: boolean;
  iID_Serials: integer;
  iID_Typ: integer;
  iID_Serial: integer;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'SetSerials_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON := nil;
    jaDetails := nil;
    iZaehler:= 0;
    jaDetails :=  AJSONObject.GetValue<TJSONArray>('Serials');
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        for var JSonValue in jaDetails do
        begin
          JSonValue.TryGetValue<integer>('ID',iID);
          JSonValue.TryGetValue<string>('Serialname',sSerialname);
          JSonValue.TryGetValue<string>('User',sUser);
          JSonValue.TryGetValue<string>('Serialkey',sSerialkey);
          JSonValue.TryGetValue<string>('SerialType',sSerialType);
          JSonValue.TryGetValue<integer>('ID_Serials',iID_Serials);
          JSonValue.TryGetValue<boolean>('Deleted',bDeleted);
          if bDeleted then
          begin
            qry_Work.SQL.Text:= 'SELECT ID FROM manager_Serials WHERE  ID = :ID_Serials';
            qry_Work.ParamByName('ID_Serials').AsInteger := iID_Serials;
            qry_Work.open;
            iID_Serial:= qry_Work.FieldByName('ID').asInteger;
            qry_Work.Close;
            qry_Work.SQL.Text :=  'DELETE FROM manager_serials_keys WHERE ID_Serial = :ID_Serial';
            qry_Work.ParamByName('ID_Serial').AsInteger := iID_Serial;
            qry_Work.ExecSQL;
            qry_Work.SQL.Text :=  'DELETE FROM manager_serials WHERE ID = :ID_Serial';
            qry_Work.ParamByName('ID_Serial').AsInteger := iID_Serial;
            qry_Work.ExecSQL;
          end
          else
          begin
            qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_Serials WHERE ID = :ID_Serials';
            qry_Work.ParamByName('ID_Serials').AsInteger := iID_Serials;
            qry_Work.Open;
            iAnzahl:= qry_Work.FieldByName('Anzahl').asInteger;
            qry_Work.Close;
            iID_Typ:= -1;
            // Typ
            if sSerialType <> '' then
            begin
              iID_Typ:= GetIDFromTable('manager_serials_typ',sSerialType);
            end;
            if iAnzahl = 0 then
            begin
              qry_Work.SQL.Text:=  'INSERT INTO manager_Serials (App,ID_Benutzer,id_typ' +
                                                      ') Values (:App,:ID_Benutzer,:id_typ)';
              qry_Work.ParamByName('App').AsString:= sSerialname;
              qry_Work.ParamByName('ID_Benutzer').asInteger:=StrToInt(AID_Benutzer);
              qry_Work.ParamByName('id_typ').asInteger:= iID_Typ;
              qry_Work.ExecSQL;
              qry_Work.SQL.Text:= 'SELECT ID FROM manager_Serials WHERE  APP = :APP';
              qry_Work.ParamByName('App').asString := sSerialname;
              qry_Work.open;
              iID_Serial:= qry_Work.FieldByName('ID').asInteger;
              qry_Work.Close;
              qry_Work.SQL.Text:=  'INSERT INTO manager_serials_keys (User,Serial,ID_Serial' +
                                                      ') Values (:User,:serial,:ID_Serial)';
              qry_Work.ParamByName('User').AsString:= sUser;
              qry_Work.ParamByName('Serial').AsString:= sSerialkey;
              qry_Work.ParamByName('ID_Serial').asInteger:=iID_Serial;
              qry_Work.ExecSQL;
            end
            else
            begin
              qry_Work.SQL.Text:= 'SELECT ID FROM manager_Serials WHERE  APP = :APP';
              qry_Work.ParamByName('App').asString := sSerialname;
              qry_Work.open;
              iID_Serial:= qry_Work.FieldByName('ID').asInteger;
              qry_Work.Close;
              qry_Work.SQL.Text:=  'Update manager_Serials SET id_typ = :id_typ ' +
                                                    'Where App = :App';
              qry_Work.ParamByName('APP').AsString:= sSerialname;
              qry_Work.ParamByName('id_typ').AsInteger:= iID_typ;
              qry_Work.ExecSQL;
              qry_Work.SQL.Text:=  'Update manager_serials_keys SET user = :user, serial = :serial  ' +
                                                    'Where ID_Serial = :ID_Serial';
              qry_Work.ParamByName('ID_Serial').AsInteger:= iID_Serial;
              qry_Work.ParamByName('serial').AsString:= sSerialkey;
              qry_Work.ParamByName('user').AsString := suser;
              qry_Work.ExecSQL;
            end;
          end;
          iZaehler:= iZaehler + 1;
        end;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Serialspruefung + IntToStr(iZaehler),0);
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'SetSerials_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
{$EndRegion Serials}
{$Region Ein}
function GetEinnahmen_Intern(AID_Benutzer: string): TJSONObject;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetEinnahmen_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn;
        qry_Work.SQL.Text :=  'SELECT ID AS Finanzen_Einnahmen_ID, Quelle, Betrag, Bezeichnung, FixBetrag ' +
                                               'FROM manager_finanzen_Einnahmen Where ID_Benutzer = :ID';
        qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
        qry_Work.Open;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Einnahmenanzahl + IntToStr(qry_Work.RecordCount),0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry_Work.FieldByName('Finanzen_Einnahmen_ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Transmitter', TJSONString.Create(qry_Work.FieldByName('Quelle').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Amount', TJSONNumber.Create(qry_Work.FieldByName('Betrag').AsFloat)));
            joResponseJSONData.AddPair(TJSONPair.Create('Description', TJSONString.Create(qry_Work.FieldByName('Bezeichnung').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Fixedamount', TJSONNumber.Create(qry_Work.FieldByName('FixBetrag').asFloat)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Receipts', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'GetEinnahmen_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function SetEinnahmen_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iID: Integer;
  sTransmitter: String;
  fAmount: double;
  sDescription: String;
  fFixedamount: double;
  iID_Receipts: Integer;
  bDeleted: boolean;
  iSyncID: Integer;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'SetEinnahmen_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON := nil;
    jaDetails := nil;
    iZaehler:= 0;
    jaDetails :=  AJSONObject.GetValue<TJSONArray>('Receipts');
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn;
        for var JSonValue in jaDetails do
        begin
          JSonValue.TryGetValue<integer>('ID',iID);
          JSonValue.TryGetValue<string>('Transmitter',sTransmitter);
          JSonValue.TryGetValue<Float64>('Amount',fAmount);
          JSonValue.TryGetValue<string>('Description',sDescription);
          JSonValue.TryGetValue<Float64>('Fixedamount',fFixedamount);
          JSonValue.TryGetValue<integer>('ID_Receipts',iID_Receipts);
          JSonValue.TryGetValue<boolean>('Deleted',bDeleted);
          if bDeleted then
          begin
            qry_Work.SQL.Text :=  'DELETE FROM manager_finanzen_einnahmen WHERE ID = :iID_Receipts';
            qry_Work.ParamByName('iID_Receipts').asInteger := iID_Receipts;
            qry_Work.ExecSQL;
          end
          else
          begin
            // Check neue Datensatz
            qry_Work.SQL.Text:=  'SELECT ID FROM manager_finanzen_einnahmen WHERE ID = :ID';
            qry_Work.ParamByName('ID').asInteger := iID_Receipts;
            qry_Work.Open;
            if qry_Work.RecordCount = 0 then
            begin
              qry_Work.SQL.Text:=  'INSERT INTO manager_finanzen_einnahmen (Quelle,Betrag,Bezeichnung,ID_Benutzer,FixBetrag' +
                                                      ') Values (:Quelle,:Betrag,:Bezeichnung,:ID_Benutzer,:FixBetrag)';
              qry_Work.ParamByName('Quelle').AsString:= sTransmitter;
              qry_Work.ParamByName('Betrag').asFloat := fAmount;
              qry_Work.ParamByName('FixBetrag').asFloat := fFixedAmount;
              qry_Work.ParamByName('Bezeichnung').asString := sDescription;
              qry_Work.ParamByName('ID_Benutzer').asInteger:=StrToInt(AID_Benutzer);
              qry_Work.ExecSQL;
            end
            else
            begin
              iSyncID:= qry_Work.FieldByName('ID').AsInteger;
              if sTransmitter <> '' then UpdateFieldValues_String('Quelle','manager_finanzen_einnahmen',sTransmitter,iSyncID);
              if FloatToStr(fAmount) <> '' then UpdateFieldValues_Float('Betrag','manager_finanzen_einnahmen',fAmount,iSyncID);
              if FloatToStr(fFixedamount) <> '' then UpdateFieldValues_Float('FixBetrag','manager_finanzen_einnahmen',fFixedamount,iSyncID);
              if sDescription <> '' then UpdateFieldValues_String('Bezeichnung','manager_finanzen_einnahmen',sDescription,iSyncID);
            end;
          end;
          iZaehler:= iZaehler + 1;
        end;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Einnahmenpruefung + IntToStr(iZaehler),0);
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'GetEinnahmen_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
{$EndRegion Ein}
{$Region Aus}
function GetAusgaben_Intern(AID_Benutzer: string): TJSONObject;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetAusgaben_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn;
        qry_Work.SQL.Text :=  'SELECT id as Finanzen_Ausgaben_ID, Name,Beschreibung,Kontonummer,Bankleitzahl,Betrag,Fixkosten,Gueltig_Monat,Gueltig_Jahr,Verwendungszweck,FixBetrag ' +
                                               'FROM manager_finanzen_ausgaben Where ID_Benutzer = :ID';
        qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
        qry_Work.Open;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Ausgabenanzahl + IntToStr(qry_Work.RecordCount),0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry_Work.FieldByName('Finanzen_Ausgaben_ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Receiver', TJSONString.Create(qry_Work.FieldByName('Name').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Description', TJSONString.Create(qry_Work.FieldByName('Beschreibung').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Accountnumber', TJSONString.Create(qry_Work.FieldByName('Kontonummer').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Bankcode', TJSONString.Create(qry_Work.FieldByName('Bankleitzahl').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Amount', TJSONNumber.Create(qry_Work.FieldByName('Betrag').AsFloat)));
            joResponseJSONData.AddPair(TJSONPair.Create('Fixedcosts', TJSonBool.Create(qry_Work.FieldByName('Fixkosten').AsBoolean)));
            joResponseJSONData.AddPair(TJSONPair.Create('Validmonth', TJSONNumber.Create(qry_Work.FieldByName('Gueltig_Monat').asInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Validyear', TJSONNumber.Create(qry_Work.FieldByName('Gueltig_Jahr').asInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Use', TJSONString.Create(qry_Work.FieldByName('Verwendungszweck').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Fixedamount', TJSONNumber.Create(qry_Work.FieldByName('FixBetrag').asFloat)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Expenditure', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_Work.Free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'GetAusgaben_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function SetAusgaben_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iID: integer;
  sReceiver: string;
  sDescription: string;
  sAccountnumber: string;
  sBankcode: string;
  fAmount: double;
  bFixedcosts: boolean;
  iValidmonth: integer;
  iValidyear: integer;
  sUse: string;
  fFixedamount: double;
  bDeleted: boolean;
  iID_Expenditure: integer;
  iSyncID: integer;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'SetAusgaben_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON := nil;
    jaDetails := nil;
    iZaehler:= 0;
    jaDetails :=  AJSONObject.GetValue<TJSONArray>('Expenditure');
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        for var JSonValue in jaDetails do
        begin
          JSonValue.TryGetValue<integer>('ID',iID);
          JSonValue.TryGetValue<string>('Receiver',sReceiver);
          JSonValue.TryGetValue<string>('Description',sDescription);
          JSonValue.TryGetValue<string>('Accountnumber',sAccountnumber);
          JSonValue.TryGetValue<string>('Bankcode',sBankcode);
          JSonValue.TryGetValue<Float64>('Amount',fAmount);
          JSonValue.TryGetValue<Boolean>('Fixedcosts',bFixedcosts);
          JSonValue.TryGetValue<Integer>('Validmonth',iValidmonth);
          JSonValue.TryGetValue<Integer>('Validyear',iValidyear);
          JSonValue.TryGetValue<string>('Use',sUse);
          JSonValue.TryGetValue<Float64>('Fixedamount',fFixedamount);
          JSonValue.TryGetValue<integer>('ID_Expenditure',iID_Expenditure);
          JSonValue.TryGetValue<Boolean>('Deleted',bDeleted);
          if bDeleted then
          begin
            qry_Work.SQL.Text :=  'DELETE FROM manager_finanzen_Ausgaben WHERE ID = :ID';
            qry_Work.ParamByName('ID').AsInteger := iID_Expenditure;
            qry_Work.ExecSQL;
          end
          else
          begin
            // Check neue Datensatz
            qry_Work.SQL.Text:=  'SELECT ID FROM manager_finanzen_Ausgaben WHERE ID = :ID';
            qry_Work.ParamByName('ID').AsInteger := iID_Expenditure;
            qry_Work.Open;
            if qry_Work.RecordCount = 0 then
            begin
              qry_Work.SQL.Text:=  'INSERT INTO manager_finanzen_Ausgaben (Name,Beschreibung,Kontonummer,Bankleitzahl,Betrag,Fixkosten,Gueltig_Monat,Gueltig_Jahr,ID_Benutzer,Verwendungszweck,FixBetrag' +
                                          ') Values (:Name,:Beschreibung,:Kontonummer,:Bankleitzahl,:Betrag,:Fixkosten,:Gueltig_Monat,:Gueltig_Jahr,:ID_Benutzer,:Verwendungszweck,:FixBetrag)';
              qry_Work.ParamByName('Name').AsString:= sReceiver;
              qry_Work.ParamByName('Beschreibung').asString := sDescription;
              qry_Work.ParamByName('Kontonummer').asString := sAccountnumber;
              qry_Work.ParamByName('Bankleitzahl').asString := sBankcode;
              qry_Work.ParamByName('Betrag').asFloat := fAmount;
              qry_Work.ParamByName('FixBetrag').asFloat := fFixedamount;
              if bFixedcosts then
                qry_Work.ParamByName('Fixkosten').asString := 'true'
              else
                qry_Work.ParamByName('Fixkosten').AsString := 'false';
              qry_Work.ParamByName('Gueltig_Monat').AsInteger := iValidmonth;
              qry_Work.ParamByName('Gueltig_Jahr').AsInteger := iValidyear;
              qry_Work.ParamByName('Verwendungszweck').asString := sUse;
              qry_Work.ParamByName('ID_Benutzer').asInteger:=StrToInt(AID_Benutzer);
              qry_Work.ExecSQL;
            end
            else
            begin
              iSyncID:= qry_Work.FieldByName('ID').AsInteger;
              if sReceiver <> '' then UpdateFieldValues_String('Name','manager_finanzen_Ausgaben',sReceiver,iSyncID);
              if sDescription <> '' then UpdateFieldValues_String('Beschreibung','manager_finanzen_Ausgaben',sDescription,iSyncID);
              if sAccountnumber <> '' then UpdateFieldValues_String('Kontonummer','manager_finanzen_Ausgaben',sAccountnumber,iSyncID);
              if sBankcode <> '' then UpdateFieldValues_String('Bankleitzahl','manager_finanzen_Ausgaben',sBankcode,iSyncID);
              if FloatToStr(fAmount) <> '' then UpdateFieldValues_Float('Betrag','manager_finanzen_Ausgaben',fAmount,iSyncID);
              if FloatToStr(fFixedamount) <> '' then UpdateFieldValues_Float('FixBetrag','manager_finanzen_Ausgaben',fFixedamount,iSyncID);
              if bFixedcosts then UpdateFieldValues_String('Fixkosten','manager_finanzen_Ausgaben','True',iSyncID) else UpdateFieldValues_String('Fixkosten','manager_finanzen_Ausgaben','False',iSyncID);
              if IntToStr(iValidmonth) <> '' then UpdateFieldValues_Integer('Gueltig_Monat','manager_finanzen_Ausgaben',iValidmonth,iSyncID);
              if IntToStr(iValidyear) <> '' then UpdateFieldValues_Integer('Gueltig_Jahr','manager_finanzen_Ausgaben',iValidyear,iSyncID);
              if sUSe <> ''  then UpdateFieldValues_String('Verwendungszweck','manager_finanzen_Ausgaben',sUse,iSyncID);
            end;
          end;
          iZaehler:= iZaehler + 1;
        end;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Ausgabenpruefung + IntToStr(iZaehler),0);
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'SetAusgaben_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
{$EndRegion Aus}
{$Region Belege}
function GetVouchers_Intern(AID_Benutzer: string): TJSONObject;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetVouchers_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;

    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein

        qry_Work.SQL.Text :=  'SELECT ID AS Finanzen_Belege_ID, Nummer, Datum, Aussteller, Betrag, Kategorie, ifnull(Jahr,0) as Jahr, ifnull(Monat,0) as Monat ' +
                                           'FROM manager_finanzen_Belege Where ID_Benutzer = :ID';
        qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
        qry_Work.Open;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Einnahmenanzahl + IntToStr(qry_Work.RecordCount),0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry_Work.FieldByName('Finanzen_Belege_ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Number', TJSONString.Create(qry_Work.FieldByName('Nummer').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Date', TJSONString.Create(DateToStr(qry_Work.FieldByName('Datum').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('Exhibitor', TJSONString.Create(qry_Work.FieldByName('Aussteller').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Amount', TJSONNumber.Create(qry_Work.FieldByName('Betrag').asFloat)));
            joResponseJSONData.AddPair(TJSONPair.Create('Categorie', TJSONNumber.Create(qry_Work.FieldByName('Kategorie').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Month', TJSONNumber.Create(qry_Work.FieldByName('Monat').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Year', TJSONNumber.Create(qry_Work.FieldByName('Jahr').AsInteger)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Vouchers', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'GetVouchers_Intern exception: ' + E.Message, 3);
    end;
  end
end;
function SetVouchers_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iID: Integer;
  sNumber: String;
  sDate: string;
  sExhibitor: String;
  fAmount: double;
  iID_Categorie: Integer;
  iMonth: Integer;
  iYear: Integer;
  iID_Vouchers: Integer;
  bDeleted: boolean;
  iSyncID: Integer;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'SetVouchers_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON := nil;
    jaDetails := nil;
    iZaehler:= 0;
    jaDetails :=  AJSONObject.GetValue<TJSONArray>('Vouchers');

    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein

        for var JSonValue in jaDetails do
        begin
          JSonValue.TryGetValue<integer>('ID',iID);
          JSonValue.TryGetValue<string>('Number',sNumber);
          JSonValue.TryGetValue<string>('Date',sDate);
          JSonValue.TryGetValue<string>('Exhibitor',sExhibitor);
          JSonValue.TryGetValue<Float64>('Amount',fAmount);
          JSonValue.TryGetValue<integer>('Categorie',iID_Categorie);
          JSonValue.TryGetValue<integer>('Month',iMonth);
          JSonValue.TryGetValue<integer>('Year',iYear);
          JSonValue.TryGetValue<integer>('ID_Vouchers',iID_Vouchers);
          JSonValue.TryGetValue<boolean>('Deleted',bDeleted);
          if bDeleted then
          begin
            qry_Work.SQL.Text :=  'DELETE FROM manager_finanzen_belege WHERE ID = :iID_Receipts';
            qry_Work.ParamByName('iID_Receipts').asInteger := iID_Vouchers;
            qry_Work.ExecSQL;
          end
          else
          begin
            // Check neue Datensatz
            qry_Work.SQL.Text:=  'SELECT ID FROM manager_finanzen_belege WHERE ID = :ID';
            qry_Work.ParamByName('ID').asInteger := iID_Vouchers;
            qry_Work.Open;
            if qry_Work.RecordCount = 0 then
            begin
              qry_Work.SQL.Text:=  'INSERT INTO manager_finanzen_belege (Nummer,Datum,Aussteller,Betrag,Kategorie,Monat,Jahr,ID_Benutzer' +
                                          ') Values (:Nummer,:Datum,:Aussteller,:Betrag,:Kategorie,:Monat,:Jahr,:ID_Benutzer)';
              qry_Work.ParamByName('Nummer').AsString:= sNumber;
              qry_Work.ParamByName('Datum').AsDate:= StrToDate(sDate);
              qry_Work.ParamByName('Aussteller').AsString:= sExhibitor;
              qry_Work.ParamByName('Betrag').asFloat := famount;
              qry_Work.ParamByName('Kategorie').asInteger := iID_Categorie;
              qry_Work.ParamByName('Monat').asInteger := iMonth;
              qry_Work.ParamByName('Jahr').asInteger := iYear;
              qry_Work.ParamByName('ID_Benutzer').asInteger:=StrToInt(AID_Benutzer);
              qry_Work.ExecSQL;
            end
            else
            begin
              iSyncID:= qry_Work.FieldByName('ID').AsInteger;
              if sNumber <> '' then UpdateFieldValues_String('Nummer','manager_finanzen_belege',sNumber,iSyncID);
              if sDate <> '' then UpdateFieldValues_TDate('Datum','manager_finanzen_belege',StrToDate(sDate),iSyncID);
              if sExhibitor <> '' then UpdateFieldValues_String('Aussteller','manager_finanzen_belege',sExhibitor,iSyncID);
              if FloatToStr(famount) <> '' then UpdateFieldValues_Float('Betrag','manager_finanzen_belege',famount,iSyncID);
              if IntToStr(iID_Categorie) <> ''  then UpdateFieldValues_Integer('Kategorie','manager_finanzen_belege',iID_Categorie,iSyncID);
              if IntToStr(iMonth) <> '' then UpdateFieldValues_Integer('Monat','manager_finanzen_belege',iMonth,iSyncID);
              if IntToStr(iYear) <> '' then UpdateFieldValues_Integer('Jahr','manager_finanzen_belege',iYear,iSyncID);
            end;
          end;
          iZaehler:= iZaehler + 1;
        end;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Einnahmenpruefung + IntToStr(iZaehler),0);
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'SetVouchers_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
{$EndRegion Belege}
{$Region Gutscheine}
function GetGiftCards_Intern(AID_Benutzer: string): TJSONObject;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetGiftCards_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.SQL.Text :=  'SELECT ID AS Finanzen_Gutschein_ID, Nummer, Bezeichnung, Datum, Wert, RestWert, Abfragepin ' +
                                               'FROM manager_finanzen_Gutschein Where ID_Benutzer = :ID';
        qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
        qry_Work.Open;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Einnahmenanzahl + IntToStr(qry_Work.RecordCount),0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry_Work.FieldByName('Finanzen_Gutschein_ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Number', TJSONString.Create(qry_Work.FieldByName('Nummer').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Description', TJSONString.Create(qry_Work.FieldByName('Bezeichnung').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Date', TJSONString.Create(DatetoStr(qry_Work.FieldByName('Datum').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('Value', TJSONNumber.Create(qry_Work.FieldByName('Wert').AsFloat)));
            joResponseJSONData.AddPair(TJSONPair.Create('Remaining_value', TJSONNumber.Create(qry_Work.FieldByName('RestWert').asFloat)));
            joResponseJSONData.AddPair(TJSONPair.Create('Pincode', TJSONString.Create(qry_Work.FieldByName('Abfragepin').AsString)));

            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Giftcards', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'GetGiftCards_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function SetGiftCards_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iID: Integer;
  sNumber: String;
  sDescription: String;
  sDate: string;
  fValue: double;
  fRemaining_value: double;
  sPincode: string;
  iID_Giftcards: Integer;
  bDeleted: boolean;
  iSyncID: Integer;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'SetGiftCards_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON := nil;
    jaDetails := nil;
    iZaehler:= 0;
    jaDetails :=  AJSONObject.GetValue<TJSONArray>('Giftcards');
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        for var JSonValue in jaDetails do
        begin
          JSonValue.TryGetValue<integer>('ID',iID);
          JSonValue.TryGetValue<string>('Number',sNumber);
          JSonValue.TryGetValue<string>('Description',sDescription);
          JSonValue.TryGetValue<string>('Date',sDate);
          JSonValue.TryGetValue<Float64>('Value',fValue);
          JSonValue.TryGetValue<Float64>('Remaining_value',fRemaining_value);
          JSonValue.TryGetValue<string>('Pincode',sPincode);
          JSonValue.TryGetValue<integer>('ID_Giftcards',iID_Giftcards);
          JSonValue.TryGetValue<boolean>('Deleted',bDeleted);
          if bDeleted then
          begin
            qry_Work.SQL.Text :=  'DELETE FROM manager_finanzen_gutschein WHERE ID = :iID_Receipts';
            qry_Work.ParamByName('iID_Receipts').asInteger := iID_Giftcards;
            qry_Work.ExecSQL;
          end
          else
          begin
            // Check neue Datensatz
            qry_Work.SQL.Text:=  'SELECT ID FROM manager_finanzen_gutschein WHERE ID = :ID';
            qry_Work.ParamByName('ID').asInteger := iID_Giftcards;
            qry_Work.Open;
            if qry_Work.RecordCount = 0 then
            begin
              qry_Work.SQL.Text:=  'INSERT INTO manager_finanzen_gutschein (Nummer,Bezeichnung,Wert,RestWert,Datum,AbfragePin,ID_Benutzer' +
                                          ') Values (:Nummer,:Bezeichnung,:Wert,:RestWert,:Datum,:AbfragePin,:ID_Benutzer)';
              qry_Work.ParamByName('Nummer').AsString:= sNumber;
              qry_Work.ParamByName('Datum').AsDate := StrToDate(sDate);
              qry_Work.ParamByName('Bezeichnung').asString := sDescription;
              qry_Work.ParamByName('Wert').asFloat := fValue;
              qry_Work.ParamByName('RestWert').asFloat := fRemaining_value;
              qry_Work.ParamByName('AbfragePin').asString := sPincode;
              qry_Work.ParamByName('ID_Benutzer').asInteger:=StrToint(AID_Benutzer);
              qry_Work.ExecSQL;
            end
            else
            begin
              iSyncID:= qry_Work.FieldByName('ID').AsInteger;
              if sNumber <> '' then UpdateFieldValues_String('Nummer','manager_finanzen_gutschein',sNumber,iSyncID);
              if sDescription <> '' then UpdateFieldValues_String('Bezeichnung','manager_finanzen_gutschein',sDescription,iSyncID);
              if FloatToStr(fValue) <> '' then UpdateFieldValues_Float('Wert','manager_finanzen_gutschein',fValue,iSyncID);
              if FloatToStr(fRemaining_value) <> '' then UpdateFieldValues_Float('Restwert','manager_finanzen_gutschein',fRemaining_value,iSyncID);
              if sDate <> '' then UpdateFieldValues_TDate('Datum','manager_finanzen_gutschein',StrToDate(sDate),iSyncID);
              if sPincode <> '' then UpdateFieldValues_String('Abfragepin','manager_finanzen_gutschein',sPinCode,iSyncID);
            end;
          end;
          iZaehler:= iZaehler + 1;
        end;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Einnahmenpruefung + IntToStr(iZaehler),0);
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'SetGiftCards_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
{$EndRegion Gutscheine}
{$EndRegion APPapi}
////////////////////////////////////////////////////////////////////////////////
// Time_APP_API_PCM                                                           //
////////////////////////////////////////////////////////////////////////////////
{$Region Time_APP_API_PCM}
function GetContactsZE_Intern(AID_Benutzer: string): TJSONObject;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'SetGiftCards_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.SQL.Text :=  'SELECT kon.ID as Kontakte_ID ,a.Bezeichnung AS Anrede, kon.Vorname,kon.Nachname,' +
                                     'kon.Strasse_Privat,kon.PLZ_Privat,kon.Ort_Privat,'+
                                     'kon.Telefon_Privat,kon.Handy_Privat, kon.E_mail_Privat,'+
                                     'kon.Geburtsdatum, g.Bezeichnung as Geschlecht,'+
                                     'f.Bezeichnung as Familienstand, s.Bezeichnung as Staatsangehoerigkeit,'+
                                     'k.Bezeichnung as Konfession,kon.Firma,kon.Strasse_Ges,kon.PLZ_Ges,'+
                                     'kon.Ort_Ges,kon.Telefon_Ges,kon.Handy_Ges,kon.E_mail_Ges,Internet_Privat as Link,Internet_Ges as LinkFirma, '+
                                     'kon.Urlaub,kon.Eintritt,kon.OffsetResturlaub,kon.OffsetResturlaubJahr,kon.Personalnummer,kon.Sollstunden ' +
                                     'FROM time_user kon '+
                                     'LEFT OUTER JOIN time_Anrede a ON a.ID = kon.ID_Anrede '+
                                     'LEFT OUTER JOIN time_Geschlecht g ON g.ID = kon.ID_GEschlecht '+
                                     'LEFT OUTER JOIN time_Familienstand f ON f.ID = kon.ID_Familienstand '+
                                     'LEFT OUTER JOIN time_Staatsangehoerigkeit s ON s.ID = kon.ID_Staatsangehoerigkeit '+
                                     'LEFT OUTER JOIN time_Konfession k ON k.ID = kon.ID_Konfession Where kon.ID = :ID_Benutzer';
        qry_Work.ParamByName('ID_Benutzer').AsInteger := StrToInt(AID_Benutzer);
        qry_Work.Open;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Kontakteanzahl+ IntToStr(qry_Work.RecordCount),0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry_Work.FieldByName('Kontakte_ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Salutation', TJSONString.Create(qry_Work.FieldByName('Anrede').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Name', TJSONString.Create(qry_Work.FieldByName('Vorname').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Surname', TJSONString.Create(qry_Work.FieldByName('Nachname').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Street_private', TJSONString.Create(qry_Work.FieldByName('Strasse_Privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Postalcode_private', TJSONString.Create(qry_Work.FieldByName('PLZ_Privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Place_private', TJSONString.Create(qry_Work.FieldByName('Ort_Privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Phone_private', TJSONString.Create(qry_Work.FieldByName('Telefon_Privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Mobile_private', TJSONString.Create(qry_Work.FieldByName('Handy_Privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Mail_private', TJSONString.Create(qry_Work.FieldByName('E_mail_Privat').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Web_private', TJSONString.Create(qry_Work.FieldByName('Link').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Birthday', TJSONString.Create(qry_Work.FieldByName('Geburtsdatum').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Gender', TJSONString.Create(qry_Work.FieldByName('Geschlecht').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Maritalstatus', TJSONString.Create(qry_Work.FieldByName('Familienstand').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Nationality', TJSONString.Create(qry_Work.FieldByName('Staatsangehoerigkeit').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Denomination', TJSONString.Create(qry_Work.FieldByName('Konfession').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Company', TJSONString.Create(qry_Work.FieldByName('Firma').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Street_business', TJSONString.Create(qry_Work.FieldByName('Strasse_Ges').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Postalcode_business', TJSONString.Create(qry_Work.FieldByName('PLZ_Ges').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Place_business', TJSONString.Create(qry_Work.FieldByName('Ort_Ges').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Phone_business', TJSONString.Create(qry_Work.FieldByName('Telefon_Ges').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Mobile_business', TJSONString.Create(qry_Work.FieldByName('Handy_Ges').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Mail_business', TJSONString.Create(qry_Work.FieldByName('E_mail_Ges').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Web_business', TJSONString.Create(qry_Work.FieldByName('LinkFirma').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Vacation',TJSONNumber.Create(qry_Work.FieldByName('Urlaub').AsFloat)));
            joResponseJSONData.AddPair(TJSONPair.Create('Entrance',TJSONString.Create(DateToStr(qry_Work.FieldByName('Eintritt').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('OffsetRemaining_vacation',TJSONNumber.Create(qry_Work.FieldByName('OffsetResturlaub').AsFloat)));
            joResponseJSONData.AddPair(TJSONPair.Create('OffsetRemaining_vacation_toYear',TJSONNumber.Create(qry_Work.FieldByName('OffsetResturlaubJahr').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Personnel_number',TJSONNumber.Create(qry_Work.FieldByName('Personalnummer').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Planned_hours',TJSONString.Create(TimeToStr(qry_Work.FieldByName('Sollstunden').AsDateTime))));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Personal', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
        WriteLog(PCM_Logname,'Personaldaten ermitteln',0);
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'SetGiftCards_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function GetLastBooking_Intern(AID_Benutzer: String): TJSONObject;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetLastBooking_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.SQL.Text :=  'SELECT Text FROM time_message where ID_Benutzer = :ID';
        qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
        qry_Work.Open;
        WriteLog(PCM_Logname,'Letzte Buchung ermitteln',0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('LastBooking', TJSONString.Create(qry_Work.FieldByName('Text').asString)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('LastBooking', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'GetLastBooking_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function SetLastBooking_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iZaehler,
  iAnzahl: integer;
  sLastBooking: String;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'SetLastBooking_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON := nil;
    jaDetails := nil;
    iZaehler:= 0;
    jaDetails :=  AJSONObject.GetValue<TJSONArray>('LastBooking');
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        for var JSonValue in jaDetails do
        begin
          JSonValue.TryGetValue<string>('LastBooking',sLastBooking);
          qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM time_message where ID_Benutzer = :ID_Benutzer';
          qry_Work.ParamByName('ID_Benutzer').AsInteger := StrToInt(AID_Benutzer);
          qry_Work.Open;
          iAnzahl:= qry_Work.FieldByName('Anzahl').asInteger;
          qry_Work.Close;
          if iAnzahl = 0 then
          begin
            qry_Work.SQL.Text:=  'INSERT INTO time_message (Text,ID_Benutzer) Values (:Text,:ID_Benutzer)';
            qry_Work.ParamByName('Text').AsString:= sLastBooking;
                      qry_Work.ParamByName('ID_Benutzer').AsInteger := StrToInt(AID_Benutzer);
            qry_Work.ExecSQL;
          end
          else begin
            qry_Work.SQL.Text:=  'Update time_message SET Text = :Text where ID_Benutzer = :ID_Benutzer';
            qry_Work.ParamByName('Text').AsString:= sLastBooking;
            qry_Work.ParamByName('ID_Benutzer').AsInteger := StrToInt(AID_Benutzer);
            qry_Work.ExecSQL;
          end;
        end;
        WriteLog(PCM_Logname,'Letzte Buchung aktualisieren' + IntToStr(iZaehler),0);
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'SetLastBooking_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function GetBookingYear_Intern(AID_Benutzer,AJahr: string): TJSONObject;
var
  wJahr,wMonat,wTag: Word;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetBookingYear_Intern wird ausgeführt',0);
  Result := nil;
  try
    DecodeDate(Date,wJahr,wMonat,wTag);
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.SQL.Text :=  'SELECT ID, Datum, Tag, Kommen, Gehen, Pause1Beginn,Pause1Ende,' +
                                     'Pause2Beginn,Pause2Ende,Sollstunden,SollstundenI,Arbeitszeit,ArbeitszeitI,' +
                                     'Feiertag,Fehltag,Mehrarbeit,MehrarbeitI,Pauseni,FeiertagI,' +
                                     'IFNULL(Abgeschlossen,0) AS Abgeschlossen,Buchungsart, IFNULL(ID_Fehltage,0) AS ID_Fehltage ' +
                                     'FROM time_buchungen Where Datum >= :Von and Datum <= :Bis';
        qry_Work.ParamByName('Von').AsDate:= StartOfAMonth(StrtoInt(AJahr),1);
        qry_Work.ParamByName('Bis').AsDate:= EndOfAMonth(StrtoInt(AJahr),12);
        qry_Work.Open;
        WriteLog(PCM_Logname,'Kontakte vom Server laden',0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry_Work.FieldByName('ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Date', TJSONString.Create(DateToStr(qry_Work.FieldByName('Datum').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('Day', TJSONString.Create(qry_Work.FieldByName('Tag').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Work_begin', TJSONString.Create(TimeToStr(qry_Work.FieldByName('Kommen').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('Work_end', TJSONString.Create(TimeToStr(qry_Work.FieldByName('Gehen').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('Break1_begin', TJSONString.Create(qry_Work.FieldByName('Pause1Beginn').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Break1_end', TJSONString.Create(qry_Work.FieldByName('Pause1Ende').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Break2_begin', TJSONString.Create(qry_Work.FieldByName('Pause2Beginn').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Break2_end', TJSONString.Create(qry_Work.FieldByName('Pause2Ende').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Planned_hours_Time', TJSONString.Create(qry_Work.FieldByName('Sollstunden').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Planned_hours_Integer', TJSONNumber.Create(qry_Work.FieldByName('Sollstundeni').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Working_time_Time', TJSONString.Create(qry_Work.FieldByName('Arbeitszeit').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Working_time_Integer', TJSONNumber.Create(qry_Work.FieldByName('Arbeitszeiti').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Holiday', TJSONNumber.Create(qry_Work.FieldByName('Feiertag').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Absence_day', TJSONString.Create(qry_Work.FieldByName('Fehltag').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Overtime_Time', TJSONString.Create(qry_Work.FieldByName('Mehrarbeit').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Overtime_Integer', TJSONNumber.Create(qry_Work.FieldByName('Mehrarbeiti').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Break_Integer', TJSONNumber.Create(qry_Work.FieldByName('Pauseni').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Holiday_Integer', TJSONNumber.Create(qry_Work.FieldByName('Feiertagi').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Complete', TJSONNumber.Create(qry_Work.FieldByName('Abgeschlossen').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Booking_type', TJSONNumber.Create(qry_Work.FieldByName('Buchungsart').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('ID_Absence_day', TJSONNumber.Create(qry_Work.FieldByName('ID_Fehltage').AsInteger)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Booking', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.Free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'GetBookingYear_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function GetAbsenceconfig_Intern(AID_Benutzer: string): TJSONObject;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetAbsenceconfig_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.SQL.Text :=  'SELECT * FROM time_fehltag';
        qry_Work.Open;
        WriteLog(PCM_Logname,'Fehltagekonfiguration laden',0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry_Work.FieldByName('ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Code', TJSONString.Create(qry_Work.FieldByName('Kuerzel').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Description', TJSONString.Create(qry_Work.FieldByName('Beschreibung').AsString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Type', TJSONNumber.Create(qry_Work.FieldByName('Typ').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Factor', TJSONNumber.Create(qry_Work.FieldByName('Faktor').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Paid', TJSONNumber.Create(qry_Work.FieldByName('Bezahlt').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Subtract', TJSONNumber.Create(qry_Work.FieldByName('SollAbziehen').AsInteger)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Absence_Day_config', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'GetAbsenceconfig_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function GetAbsence_Intern(AID_Benutzer: string): TJSONObject;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetAbsence_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.SQL.Text :=  'SELECT * FROM time_fehltage';
        qry_Work.Open;
        WriteLog(PCM_Logname,'Fehltage laden',0);
        if qry_Work.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry_Work.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry_Work.FieldByName('ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('From', TJSONString.Create(DateToStr(qry_Work.FieldByName('Von').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('To', TJSONString.Create(DateToStr(qry_Work.FieldByName('Bis').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('Code', TJSONString.Create(qry_Work.FieldByName('Kuerzel').AsString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Description', TJSONString.Create(qry_Work.FieldByName('Beschreibung').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Days', TJSONNumber.Create(qry_Work.FieldByName('Tage').AsInteger)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry_Work.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Absence_Day', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'GetAbsence_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function GetMonthValues_Intern(AID_Benutzer: Integer): TDataset;
var
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'GetMonthValues_Intern wird ausgeführt',0);
  Result := nil;
  try
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        qry_Work.SQL.Text :=  'SELECT * FROM time_monatswerte ';
        qry_Work.Open;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Monatswerteanzahl + IntToStr(qry_Work.RecordCount),0);
        Result := qry_Work;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      WriteLog(PCM_Logname,'GetMonthValues_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
function SetOnlineBooking_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iZaehler: Integer;
  sField: string;
  sDate: string;
  sTime: string;
  iType: Integer;
  iBooking_Type: Integer;
  qry_Work: TFDQuery;
  conn: TFDConnection;
begin
  WriteLog(PCM_Logname,'SetOnlineBooking_Intern wird ausgeführt',0);
  Result := nil;
  try
    joResponseJSON := nil;
    jaDetails := nil;
    iZaehler:= 0;
    jaDetails :=  AJSONObject.GetValue<TJSONArray>('OnlineBooking');
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry_Work := TFDQuery.Create(nil);
      try
        qry_Work.Connection := conn; // Muss gepoolt und threadsicher sein
        for var JSonValue in jaDetails do
        begin
          JSonValue.TryGetValue<string>('Date',sDate);
          JSonValue.TryGetValue<string>('Time',sTime);
          JSonValue.TryGetValue<integer>('Type',iType);
          JSonValue.TryGetValue<integer>('Booking_Type',iBooking_Type);
          case iType of
          1: sField:= 'Kommen';
          2: sField:= 'Gehen';
          3: sField:= 'Pause1Beginn';
          4: sField:= 'Pause1Ende';
          5: sField:= 'Pause2Beginn';
          6: sField:= 'Pause2Ende';
          end;

          qry_Work.SQL.Text:=  'Update time_Buchungen Set ' + sField + ' = :time, Buchungsart = :Buchungsart Where ID_Benutzer =:ID and  Datum = :Datum';
          qry_Work.ParamByName('time').AsTime:= StrToTime(sTime);
          qry_Work.ParamByName('Buchungsart').asInteger := iBooking_Type;
          qry_Work.ParamByName('Datum').AsDate:= StrToDate(sDate);
          qry_Work.ParamByName('ID').AsString:= AID_Benutzer;
          qry_Work.ExecSQL;
          iZaehler:= iZaehler + 1;
        end;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Buchungpruefung + IntToStr(iZaehler),0);
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        Result := joResponseJSON;
      finally
        qry_work.free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      joResponseJSON.Free;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(true));
      Result.AddPair('ErrorCode', TJSONNumber.Create(99));
      Result.AddPair('Errormessage', TJSONString.Create('Exception: ' + E.Message));
      WriteLog(PCM_Logname,'SetOnlineBooking_Intern exception: ' + E.Message, 3);
    end;
  end;
end;
{$EndRegion Time_APP_API_PCM}
////////////////////////////////////////////////////////////////////////////////
// Web_APP_API_PCM                                                            //
////////////////////////////////////////////////////////////////////////////////
{$Region WebapiPCM}
function GetLoginWeb_Intern: TJSONObject;
var
  qry: TFDQuery;
  conn: TFDConnection;
  joResponseJSON, joResponseJSONData: TJSONObject;
  jaDetails: TJSONArray;
  sUser, sPass: String;
  iCode: Integer;
  sMessage: string;
begin
  WriteLog(PCM_Logname,'GetLoginWeb_Intern wird ausgeführt', 0);
  Result := nil;
  joResponseJSON := TJSONObject.Create;
  try
    sUser := TDSSessionManager.GetThreadSession.GetData('Username');
    sPass := TDSSessionManager.GetThreadSession.GetData('Password');
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry := TFDQuery.Create(nil);
      try
        qry.Connection := conn;
        qry.SQL.Text := 'SELECT id, passwort, Zurgiff_Web FROM time_user WHERE benutzer = :User';
        qry.ParamByName('User').AsString := sUser;
        qry.Open;

        if qry.RecordCount > 0 then
        begin
          jaDetails := TJSONArray.Create;
          joResponseJSONData := TJSONObject.Create;
          try
            if (sPass = qry.FieldByName('Passwort').AsString) and (qry.FieldByName('Zurgiff_Web').AsBoolean) then
            begin
              iCode := 200;
              sMessage := 'OK';
              joResponseJSON.AddPair('HasError', TJSONBool.Create(false));
              joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(0));
              joResponseJSON.AddPair('Errormessage', TJSONString.Create(''));
              joResponseJSONData.AddPair('Allowed', TJSONBool.Create(True));
              joResponseJSONData.AddPair('ID_User', TJSONNumber.Create(qry.FieldByName('ID').AsInteger));
              joResponseJSON.AddPair('User', sUser);
              joResponseJSON.AddPair('Password', sPass);
              jaDetails.Add(joResponseJSONData);
              joResponseJSONData := nil; // ownership to jaDetails
            end
            else
            begin
              iCode := 401;
              sMessage := 'Unauthorized';
              joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
              joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(1));
              joResponseJSON.AddPair('Errormessage', TJSONString.Create('Benutzer ' + sUser + ' nicht berechtigt'));
              joResponseJSONData.AddPair('Allowed', TJSONBool.Create(False));
              joResponseJSONData.AddPair('ID_User', TJSONNumber.Create(qry.FieldByName('ID').AsInteger));
              joResponseJSON.AddPair('User', sUser);
              joResponseJSON.AddPair('Password', sPass);
              jaDetails.Add(joResponseJSONData);
              joResponseJSONData := nil;
            end;

            joResponseJSON.AddPair('Login', jaDetails);
            jaDetails := nil; // ownership to joResponseJSON
          except
            joResponseJSONData.Free;
            jaDetails.Free;
            raise;
          end;
        end
        else
        begin
          iCode := 200;
          sMessage := 'OK';
          joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
          joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(1));
          joResponseJSON.AddPair('Errormessage', TJSONString.Create('Keine Datensätze vorhanden'));
        end;
        Result := joResponseJSON;
      finally
        qry.Free;
      end;
    finally
      conn.free
    end;
  except
    on e: Exception do
    begin
      FreeAndNil(joResponseJSON);
      joResponseJSON := TJSONObject.Create;
      joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
      joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(2));
      joResponseJSON.AddPair('Errormessage', TJSONString.Create('Keine Verbindung zur Datenbank. Grund: ' + e.Message));
      WriteLog(PCM_Logname,'GetLoginWeb_Intern exception: ' + e.Message, 2);
    end;
  end;
end;
function GetPersonalWeb_intern(AID_Benutzer: string): TJSONObject;
var
  qry: TFDQuery;
  conn: TFDConnection;
  joResponseJSON, joResponseJSONData: TJSONObject;
  jaDetails: TJSONArray;
  iCode: Integer;
  sMessage: string;
begin
  WriteLog(PCM_Logname,'GetPersonalWeb_intern wird ausgeführt', 0);
  Result := nil;
  joResponseJSON := TJSONObject.Create;
  try
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry := TFDQuery.Create(nil);
      try
        qry.Connection := conn;
        qry.SQL.Text := 'SELECT Personalnummer AS PersNr, Nachname AS Nachname, Vorname AS Vorname FROM time_user WHERE ID = :ID';
        qry.ParamByName('ID').AsString := AID_Benutzer;
        qry.Open;

        if qry.RecordCount > 0 then
        begin
          jaDetails := TJSONArray.Create;
          joResponseJSONData := TJSONObject.Create;
          try
            iCode:= 200;
            sMessage:= 'OK';

            joResponseJSON.AddPair('HasError', TJSONBool.Create(false));
            joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(0));
            joResponseJSON.AddPair('Errormessage', TJSONString.Create(''));
            joResponseJSON.AddPair('Personalnumber', TJSONString.Create(qry.FieldByName('PersNr').AsString));
            joResponseJSON.AddPair('Lastname', TJSONString.Create(qry.FieldByName('Nachname').AsString));
            joResponseJSON.AddPair('Name', TJSONString.Create(qry.FieldByName('Vorname').AsString));

            jaDetails.Add(joResponseJSONData);
            joResponseJSONData := nil; // Ownership an jaDetails übergeben
          except
            joResponseJSONData.Free;
            jaDetails.Free;
            raise;
          end;
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
          joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(1));
          joResponseJSON.AddPair('Errormessage', TJSONString.Create('Keine Datensätze vorhanden'));
        end;
        Result := joResponseJSON;
      finally
        qry.Free;
      end;
    finally
      conn.free
    end;
  except
    on e: Exception do
    begin
      FreeAndNil(joResponseJSON);
      joResponseJSON := TJSONObject.Create;
      joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
      joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(2));
      joResponseJSON.AddPair('Errormessage', TJSONString.Create('Keine Verbindung zur Datenbank. Grund: ' + e.Message));
      WriteLog(PCM_Logname,'GetPersonalWeb_intern exception: ' + e.Message, 2);
    end;
  end;
end;
function GetBookinDataWeb_intern(AID_Benutzer: string): TJSONObject;
var
  conn: TFDConnection;
  qry: TFDQuery;
  joResponseJSON, joResponseJSONData: TJSONObject;
  jaDetails: TJSONArray;
  iCode: Integer;
  sMessage: string;
begin
  WriteLog(PCM_Logname,'GetBookinDataWeb_intern wird ausgeführt', 0);
  Result := nil;
  joResponseJSON := TJSONObject.Create;
  joResponseJSONData := TJSONObject.Create;
  jaDetails := TJSONArray.Create;
  try
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry := TFDQuery.Create(nil);
      try
        qry.Connection := conn;
        qry.SQL.Text :=
          'SELECT ' +
          '(SELECT CONCAT(tf.Kuerzel,'' - '',tf.Beschreibung,'', Zeitraum: '', DATE_FORMAT(von, ''%d.%m.%Y''), DATE_FORMAT(bis, ''%d.%m.%Y'')) AS Absence ' +
          'FROM time_buchungen tb ' +
          'LEFT OUTER JOIN time_fehltage tf ON tf.id = tb.ID_Fehltage ' +
          'WHERE tb.Datum >= NOW() AND tb.ID_fehltage > 0 AND tb.ID_benutzer = :ID LIMIT 1) AS NextAbw, ' +
          '(SELECT CONCAT(tft.Bezeichnung,'' am '', DATE_FORMAT(CAST(CONCAT(jahr, ''-'', LPAD(monat, 2, ''0''), ''-'', LPAD(tag, 2, ''0'')) AS DATE), ''%d.%m.%Y'')) as FeiertagNext ' +
          'FROM time_user tu ' +
          'LEFT OUTER JOIN time_firma tf ON tf.ID = tu.ID_Firma ' +
          'LEFT OUTER JOIN time_feiertage tft ON tft.Bl = tf.bl ' +
          'WHERE tu.ID = :ID AND CAST(CONCAT(jahr, ''-'', LPAD(monat, 2, ''0''), ''-'', LPAD(tag, 2, ''0'')) AS DATE) >= NOW() LIMIT 1) AS NextFT, ' +
          'TEXT AS LastBooking ' +
          'FROM time_message WHERE ID_Benutzer = :ID';

        qry.ParamByName('ID').AsString := AID_Benutzer;
        qry.Open;

        if qry.RecordCount > 0 then
        begin
          iCode := 200;
          sMessage := 'OK';

          joResponseJSON.AddPair('HasError', TJSONBool.Create(false));
          joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(0));
          joResponseJSON.AddPair('Errormessage', TJSONString.Create(''));

          if not qry.FieldByName('NextAbw').IsNull then
            joResponseJSON.AddPair('NextAbsence', qry.FieldByName('NextAbw').AsString)
          else
            joResponseJSON.AddPair('NextAbsence', '');

          if not qry.FieldByName('NextFT').IsNull then
            joResponseJSON.AddPair('NextHoliDay', qry.FieldByName('NextFT').AsString)
          else
            joResponseJSON.AddPair('NextHoliDay', '');

          if not qry.FieldByName('LastBooking').IsNull then
            joResponseJSON.AddPair('LastBooking', qry.FieldByName('LastBooking').AsString)
          else
            joResponseJSON.AddPair('LastBooking', '');

          jaDetails.Add(joResponseJSONData);
        end
        else
        begin
          iCode := 200;
          sMessage := 'OK';
          joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
          joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(1));
          joResponseJSON.AddPair('Errormessage', TJSONString.Create('Keine Datensätze vorhanden'));
        end;
         Result := joResponseJSON;
      finally
        qry.Free;
      end;
    finally
      conn.free;
    end;
  except
    on E: Exception do
    begin
      iCode := 409;
      sMessage := 'Database Error';
      joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
      joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(2));
      joResponseJSON.AddPair('Errormessage', TJSONString.Create('Keine Verbindung zur Datenbank. Grund: ' + E.Message));
      WriteLog(PCM_Logname,'GetBookinDataWeb_intern exception: ' + e.Message, 2);
    end;
  end;
end;
function GetMonthYearValuesWeb_intern(AID_Benutzer: string; AMonat, AJahr: integer): TJSONObject;
var
  qry: TFDQuery;
  joResponseJSON, joResponseJSONData: TJSONObject;
  jaDetails: TJSONArray;
  iCode: Integer;
  sMessage: string;
  // Variablen analog zum Original
  iKRGes: integer;
  dULAns, dULVJ, dSoll: double;
  sULGenommen, sULGeplant, sULGenommenJahr: string;
  dULGenommen, dULGeplant, dULGenommenJahr: double;
  dBrutto, dPause, dIStzeit, dUL, dULunb, dKR, dKRunb, dFT: double;
  dSollzeit, dMA, dMAVM, dMAakt: double;
  iBrutto, iPause, iIStzeit, iUL, iULunb, iKR, iKRunb, iFT: integer;
  iSollzeit, iMA, iMAVM, iMAakt: integer;
  sBrutto, sPause, sIStzeit, sUL, sULunb, sKR, sKRunb, sFT, sSollzeit, sMA, sMAVM, sMAakt: string;

  procedure SetVarValues;
  begin
    // Variablen initialisieren
    iULunb:= 0; dULunb:= 0.0; sULunb:= '00:00';
    iKRunb:= 0; dKRunb:= 0.0; sKRunb:= '00:00';
    iUL:= 0; dUL:= 0.0; sUL:= '00:00';
    iKR:= 0; dKR:= 0.0; sKR:= '00:00';
    iFT:= 0; dFT:= 0.0; sFT:= '00:00';
    iBrutto:= 0; dBrutto:= 0.0; sBrutto:= '00:00';
    iPause:= 0; dPause:= 0.0; sPause:= '00:00';
    iIStzeit:= 0; dIStzeit:= 0.0; sIStzeit:= '00:00';
    iSollzeit:= 0; dSollzeit:= 0.0; sSollzeit:= '00:00';
    iMA:= 0; dMA:= 0.0; sMA:= '00:00';
    iMAVM:= 0; dMAVM:= 0.0; sMAVM:= '00:00';
    iMAakt:= 0; dMAakt:= 0.0; sMAakt:= '00:00';
    dULAns:= 0.0; dULVJ:= 0.0; dSoll:= 0.0;
    dULGenommen:= 0.0; sULGenommen:= '00:00';
    dULGenommenJahr:= 0.0; sULGenommenJahr:= '00:00';
    dULGeplant:= 0.0; sULGeplant:= '00:00';
  end;
  procedure GetPersonalValues;
  var
    q: TFDQuery;
    conn: TFDConnection;
  begin
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM'; // mit Pooled=True
      conn.Connected := True;
      q := TFDQuery.Create(nil);
      try
        q.Connection := conn;
        q.SQL.Text :=
          'SELECT if(:Jahr-1 = tf.OffsetResturlaubJahr,tf.OffsetResturlaub,0) AS RULVJ, Urlaub, TIME_TO_SEC(SollStunden) / 3600 AS SollStunden FROM time_user tf WHERE tf.ID = :ID';
        q.ParamByName('ID').AsString := AID_Benutzer;
        q.ParamByName('Jahr').AsInteger := AJahr;
        q.Open;

        if (q.RecordCount > 0) and Assigned(q.FindField('Urlaub')) then
        begin
          dULAns := q.FieldByName('Urlaub').AsFloat;
          dULVJ := q.FieldByName('RULVJ').AsFloat;
          dSoll := q.FieldByName('SollStunden').AsFloat;
        end;
        q.Close;

        q.SQL.Text :=
          'SELECT if(:jahr -1 = tf.OffsetResturlaubJahr,tf.OffsetResturlaub,mw.RestUrlaub) AS RULVJ, Urlaub, TIME_TO_SEC(SollStunden) / 3600 AS SollStunden ' +
          'FROM time_monatswerte mw ' +
          'LEFT OUTER JOIN time_user tf ON tf.ID = mw.ID_Benutzer ' +
          'WHERE mw.ID_Benutzer = :ID ' +
          'and Monat = 12 AND Jahr = :Jahr -1';
        q.ParamByName('ID').AsString := AID_Benutzer;
        q.ParamByName('Jahr').AsInteger := AJahr;
        q.Open;

        if (q.RecordCount > 0) and Assigned(q.FindField('Urlaub')) then
        begin
          dULAns := q.FieldByName('Urlaub').AsFloat;
          if dULVJ = 0 then
            dULVJ := q.FieldByName('RULVJ').AsFloat;
          dSoll := q.FieldByName('SollStunden').AsFloat;
        end;
        q.Close;
      finally
        q.Free;
      end;
    finally
      conn.free;
    end;
  end;
  procedure GetULGenommen(AJahrBol: boolean);
  var
    q: TFDQuery;
    conn: TFDConnection;
    wJahr, wMonat, wTag: word;
  begin
    DecodeDate(Date, wJahr, wMonat, wTag);
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM'; // mit Pooled=True
      conn.Connected := True;
      q := TFDQuery.Create(nil);
      try
        q.Connection := conn;
        q.SQL.Text :=
        'SELECT Ifnull(Round(Sum(Zeb.SollstundenI / zeft.faktor) / (HOUR(zzp.Sollzeit) * 60) + Minute(zzp.Sollzeit),1),0) as Anzahl,' +
        'Ifnull(Round(Sum(Zeb.SollstundenI / zeft.faktor) / ((HOUR(zzp.Sollzeit) * 60) + Minute(zzp.Sollzeit) /60) * HOUR(zzp.Sollzeit) + (Minute(zzp.Sollzeit) / 60 ),2),0) AS AnzahlDez,' +
        'Ifnull(TIME_FORMAT(SEC_TO_TIME(SUM(Zeb.SollstundenI / zeft.faktor) * 60),''%H:%i''),''00:00'') AS AnzahlStd ' +
        'FROM time_buchungen zeb ' +
        'LEFT OUTER JOIN time_buchung zeb1 ON zeb1.ID = zeb.ID_Buchung ' +
        'LEFT OUTER JOIN time_zeitplan zzp ON zzp.id = zeb1.ID_Tagesplan ' +
        'LEFT OUTER JOIN time_Fehltag zeft ON zeft.Kuerzel = zeb.Fehltag ' +
        'WHERE zeb.ID_Benutzer = :ID ' +
        'and zeb.Feiertag <> 1 ' +
        'AND zeb.Sollstunden = zzp.Sollzeit ' +
        'AND zeft.Typ = 1 ' +
        'AND zeft.Bezahlt = 1 ';

        if AJahrBol then
        begin
          if AJahr < wJahr then
          begin
            q.SQL.Text := q.SQL.Text + 'and Year(Zeb.Datum) = :Jahr';
            q.ParamByName('Jahr').AsInteger := AJahr;
          end
          else
          begin
            q.SQL.Text := q.SQL.Text + 'and Month(zeb.Datum) <= :Monat and Year(Zeb.Datum) = :Jahr and zeb.Datum <= NOW()';
            q.ParamByName('Monat').AsInteger := AMonat;
            q.ParamByName('Jahr').AsInteger := AJahr;
          end;
        end
        else
        begin
          q.SQL.Text := q.SQL.Text + 'and Month(zeb.Datum) = :Monat and Year(Zeb.Datum) = :Jahr and zeb.Datum <= NOW() ';
          q.ParamByName('Jahr').AsInteger := AJahr;
          q.ParamByName('Monat').AsInteger := AMonat;
        end;

        q.ParamByName('ID').AsString := AID_Benutzer;

        q.Open;
        if q.RecordCount > 0 then
        begin
          if AJahrBol then
          begin
            sULGenommenJahr := q.FieldByName('AnzahlStd').AsString;
            dULGenommenJahr := q.FieldByName('Anzahl').AsFloat;
          end
          else
          begin
            sULGenommen := q.FieldByName('AnzahlStd').AsString;
            dULGenommen := q.FieldByName('Anzahl').AsFloat;
          end;
        end;
        q.Close;
      finally
        q.Free;
      end;
    finally
      conn.free;
    end;
  end;
  procedure GetULGeplant;
  var
    conn: TFDConnection;
    q: TFDQuery;
  begin
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM'; // mit Pooled=True
      conn.Connected := True;
      q := TFDQuery.Create(nil);
      try
        q.Connection := conn;
        q.SQL.Text :=
        'SELECT Ifnull(Round(Sum(Zeb.SollstundenI / zeft.faktor) / (HOUR(zzp.Sollzeit) * 60) + Minute(zzp.Sollzeit),1),0) as Anzahl,' +
        'Ifnull(Round(Sum(Zeb.SollstundenI / zeft.faktor) / ((HOUR(zzp.Sollzeit) * 60) + Minute(zzp.Sollzeit) /60) * HOUR(zzp.Sollzeit) + (Minute(zzp.Sollzeit) / 60 ),2),0) AS AnzahlDez,' +
        'Ifnull(TIME_FORMAT(SEC_TO_TIME(SUM(Zeb.SollstundenI / zeft.faktor) * 60),''%H:%i''),''00:00'') AS AnzahlStd ' +
        'FROM time_buchungen zeb ' +
        'LEFT OUTER JOIN time_buchung zeb1 ON zeb1.ID = zeb.ID_Buchung ' +
        'LEFT OUTER JOIN time_zeitplan zzp ON zzp.id = zeb1.ID_Tagesplan ' +
        'LEFT OUTER JOIN time_Fehltag zeft ON zeft.Kuerzel = zeb.Fehltag ' +
        'WHERE zeb.ID_Benutzer = :ID ' +
        'and zeb.Feiertag <> 1 ' +
        'AND zeb.Sollstunden = zzp.Sollzeit ' +
        'AND zeft.Typ = 1 ' +
        'AND zeft.Bezahlt = 1 ' +
        'and Year(zeb.Datum) = :Jahr ' +
        'and Month(zeb.Datum) >= :Monat ' +
        'and zeb.Datum > NOW() ';
        q.ParamByName('ID').AsString := AID_Benutzer;
        q.ParamByName('Monat').AsInteger := AMonat;
        q.ParamByName('Jahr').AsInteger := AJahr;
        q.Open;

        if q.RecordCount > 0 then
        begin
          sULGeplant := q.FieldByName('AnzahlStd').AsString;
          dULGeplant := q.FieldByName('Anzahl').AsFloat;
        end;
        q.Close;
      finally
        q.Free;
      end;
    finally
      conn.free;
    end;
  end;
  procedure GetMontValue;
  var
    conn: TFDConnection;
    q: TFDQuery;
  begin
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM'; // mit Pooled=True
      conn.Connected := True;
      q := TFDQuery.Create(nil);
      try
        q.Connection := conn;
        q.SQL.Text :=
          'SELECT IStzeit + Pausen AS Brutto, TIME_FORMAT(SEC_TO_TIME((IStzeit + Pausen) * 60),''%H:%i'') AS BruttoT, ROUND((IStzeit + Pausen) /60,2) AS BruttoD,' +
          'Pausen, TIME_FORMAT(SEC_TO_TIME((Pausen) * 60),''%H:%i'') as PausenT, ROUND((Pausen) /60,2) as PausenD,' +
          'IStzeit, TIME_FORMAT(SEC_TO_TIME((IStzeit) * 60),''%H:%i'') as IStzeitT, ROUND((IStzeit) /60,2) as IStzeitD,' +
          'Sollzeit, TIME_FORMAT(SEC_TO_TIME((Sollzeit) * 60),''%H:%i'') as SollzeitT, ROUND((Sollzeit) /60,2) as SollzeitD,' +
          'Mehrarbeit, TIME_FORMAT(SEC_TO_TIME((Mehrarbeit) * 60),''%H:%i'') as MehrarbeitT, ROUND((Mehrarbeit) /60,2) as MehrarbeitD,' +
          'aktuelleMehrarbeit, TIME_FORMAT(SEC_TO_TIME((aktuelleMehrarbeit) * 60),''%H:%i'') as aktuelleMehrarbeitT, ROUND((aktuelleMehrarbeit) /60,2) as aktuelleMehrarbeitD,' +
          'aktuelleMehrarbeit - Mehrarbeit AS MehrarbeitVM, TIME_FORMAT(SEC_TO_TIME((aktuelleMehrarbeit - Mehrarbeit) * 60),''%H:%i'') as MehrarbeitVMT, ROUND((aktuelleMehrarbeit - Mehrarbeit) /60,2) as MehrarbeitVMD,' +
          'Resturlaub FROM time_Monatswerte WHERE Monat = :Monat AND Jahr = :Jahr AND ID_Benutzer = :ID';
        q.ParamByName('ID').AsString := AID_Benutzer;
        q.ParamByName('Monat').AsInteger := AMonat;
        q.ParamByName('Jahr').AsInteger := AJahr;
        q.Open;

        if q.RecordCount > 0 then
        begin
          iBrutto := q.FieldByName('Brutto').AsInteger;
          dBrutto := q.FieldByName('BruttoD').AsFloat;
          sBrutto := q.FieldByName('BruttoT').AsString;
          iPause := q.FieldByName('Pausen').AsInteger;
          dPause := q.FieldByName('PausenD').AsFloat;
          sPause := q.FieldByName('PausenT').AsString;
          iIStzeit := q.FieldByName('IStzeit').AsInteger;
          dIStzeit := q.FieldByName('IStzeitD').AsFloat;
          sIStzeit := q.FieldByName('IStzeitT').AsString;
          iSollzeit := q.FieldByName('Sollzeit').AsInteger;
          dSollzeit := q.FieldByName('SollzeitD').AsFloat;
          sSollzeit := q.FieldByName('SollzeitT').AsString;
          iMA := q.FieldByName('Mehrarbeit').AsInteger;
          dMA := q.FieldByName('MehrarbeitD').AsFloat;
          sMA := q.FieldByName('MehrarbeitT').AsString;
          iMAVM := q.FieldByName('MehrarbeitVM').AsInteger;
          dMAVM := q.FieldByName('MehrarbeitVMD').AsFloat;
          sMAVM := q.FieldByName('MehrarbeitVMT').AsString;
          iMAakt := q.FieldByName('aktuelleMehrarbeit').AsInteger;
          dMAakt := q.FieldByName('aktuelleMehrarbeitD').AsFloat;
          sMAakt := q.FieldByName('aktuelleMehrarbeitT').AsString;
        end;
        q.Close;
      finally
        q.Free;
      end;
    finally
      conn.free;
    end;
  end;
  procedure GetAbwesenheit(ATyp, ABezahlt: integer);
  var
    conn: TFDConnection;
    q: TFDQuery;
  begin
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM'; // mit Pooled=True
      conn.Connected := True;
      q := TFDQuery.Create(nil);
      try
        q.Connection := conn;
        q.SQL.Text :=
        'SELECT Ifnull(Round(Sum(Zeb.SollstundenI / zeft.faktor) / (HOUR(zzp.Sollzeit) * 60) + Minute(zzp.Sollzeit),1),0) as Anzahl,' +
        'Ifnull(Round(Sum(Zeb.SollstundenI / zeft.faktor) / ((HOUR(zzp.Sollzeit) * 60) + Minute(zzp.Sollzeit) /60) * HOUR(zzp.Sollzeit) + (Minute(zzp.Sollzeit) / 60 ),2),0) AS AnzahlDez,' +
        'Ifnull(TIME_FORMAT(SEC_TO_TIME(SUM(Zeb.SollstundenI / zeft.faktor) * 60),''%H:%i''),''00:00'') AS AnzahlStd ' +
        'FROM time_buchungen zeb ' +
        'LEFT OUTER JOIN time_buchung zeb1 ON zeb1.ID = zeb.ID_Buchung ' +
        'LEFT OUTER JOIN time_zeitplan zzp ON zzp.id = zeb1.ID_Tagesplan ' +
        'LEFT OUTER JOIN time_Fehltag zeft ON zeft.Kuerzel = zeb.Fehltag ' +
        'WHERE zeb.ID_Benutzer = :ID ' +
        'and zeb.Feiertag <> 1 ' +
        'AND zeb.Sollstunden = zzp.Sollzeit ' +
        'AND zeft.Typ = :Typ ' +
        'AND zeft.Bezahlt = :Bez ' +
        'and Year(zeb.Datum) = :Jahr ' +
        'and Month(zeb.Datum) = :Monat';
        q.ParamByName('ID').AsString := AID_Benutzer;
        q.ParamByName('Monat').AsInteger := AMonat;
        q.ParamByName('Jahr').AsInteger := AJahr;
        q.ParamByName('Typ').AsInteger := ATyp;
        q.ParamByName('Bez').AsInteger := ABezahlt;
        q.Open;

        if q.RecordCount > 0 then
        begin
          case ATyp of
            1:
              begin
                case ABezahlt of
                  0:
                    begin
                      iULunb := q.FieldByName('Anzahl').AsInteger;
                      sULunb := q.FieldByName('AnzahlStd').AsString;
                    end;
                  1:
                    begin
                      iUL := q.FieldByName('Anzahl').AsInteger;
                      dUL := q.FieldByName('AnzahlDez').AsFloat;
                    end;
                end;
              end;
            2:
              begin
                case ABezahlt of
                  0:
                    begin
                      iKRunb := q.FieldByName('Anzahl').AsInteger;
                      sKRunb := q.FieldByName('AnzahlStd').AsString;
                    end;
                  1:
                    begin
                      iKR := q.FieldByName('Anzahl').AsInteger;
                      dKR := q.FieldByName('AnzahlDez').AsFloat;
                    end;
                end;
              end;
          end;
        end;
        q.Close;
      finally
        q.Free;
      end;
    finally
      conn.free;
    end;
  end;
  procedure GetKrankYear;
  var
    conn: TFDConnection;
    q: TFDQuery;
  begin
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM'; // mit Pooled=True
      conn.Connected := True;
      q := TFDQuery.Create(nil);
      try
        q.Connection := conn;
        q.SQL.Text :=
          'SELECT Ifnull(Round(Sum(Zeb.SollstundenI / zeft.faktor) / (HOUR(zzp.Sollzeit) * 60) + Minute(zzp.Sollzeit),1),0) as Anzahl,' +
          'Ifnull(Round(Sum(Zeb.SollstundenI / zeft.faktor) / ((HOUR(zzp.Sollzeit) * 60) + Minute(zzp.Sollzeit) /60) * HOUR(zzp.Sollzeit) + (Minute(zzp.Sollzeit) / 60 ),2),0) AS AnzahlDez,' +
          'Ifnull(TIME_FORMAT(SEC_TO_TIME(SUM(Zeb.SollstundenI / zeft.faktor) * 60),''%H:%i''),''00:00'') AS AnzahlStd ' +
          'FROM time_buchungen zeb ' +
          'LEFT OUTER JOIN time_buchung zeb1 ON zeb1.ID = zeb.ID_Buchung ' +
          'LEFT OUTER JOIN time_zeitplan zzp ON zzp.id = zeb1.ID_Tagesplan ' +
          'LEFT OUTER JOIN time_Fehltag zeft ON zeft.Kuerzel = zeb.Fehltag ' +
          'WHERE zeb.ID_Benutzer = :ID ' +
          'and zeb.Feiertag <> 1 ' +
          'AND zeb.Sollstunden = zzp.Sollzeit ' +
          'AND zeft.Typ = 2 ' +
          'AND zeft.Bezahlt = 1 ' +
          'and Year(zeb.Datum) = :Jahr';
        q.ParamByName('ID').AsString := AID_Benutzer;
        q.ParamByName('Jahr').AsInteger := AJahr;
        q.Open;

        if q.RecordCount > 0 then
          iKRGes := q.FieldByName('Anzahl').AsInteger;

        q.Close;
      finally
        q.Free;
      end;
    finally
      conn.free;
    end;
  end;
  procedure GetFT;
  var
    conn: TFDConnection;
    q: TFDQuery;
  begin
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM'; // mit Pooled=True
      conn.Connected := True;
      q := TFDQuery.Create(nil);
      try
        q.Connection := conn;
        q.SQL.Text :=
          'SELECT Ifnull(Sum(if(Feiertag = 2, 0.5,1)),0) AS Anzahl,' +
          'IFNULL(TIME_FORMAT(SEC_TO_TIME(Sum(if(Feiertag = 2, 0.5 * TIME_TO_SEC(SollStunden),1 * TIME_TO_SEC(SollStunden)))),''%H:%i''),''00:00'') AS AnzahlStd,' +
          'IFNULL(Sum(if(Feiertag = 2, 0.5 * TIME_TO_SEC(SollStunden),1 * TIME_TO_SEC(SollStunden)) / 60),0) AS AnzahlDez ' +
          'FROM time_buchungen zeb ' +
          'LEFT OUTER JOIN time_buchung zeb1 ON zeb1.ID = zeb.ID_Buchung ' +
          'LEFT OUTER JOIN time_zeitplan zzp ON zzp.id = zeb1.ID_Tagesplan ' +
          'WHERE zeb.ID_Benutzer = :ID ' +
          'AND zzp.Sollzeit <> ''00:00'' ' +
          'and zeb.Sollstunden = zzp.Sollzeit ' +
          'and Year(zeb.Datum) = :Jahr ' +
          'and Month(zeb.Datum) = :Monat ' +
          'AND zeb.feiertag > 0';
        q.ParamByName('ID').AsString := AID_Benutzer;
        q.ParamByName('Monat').AsInteger := AMonat;
        q.ParamByName('Jahr').AsInteger := AJahr;
        q.Open;

        if q.RecordCount > 0 then
        begin
          iFT := q.FieldByName('Anzahl').AsInteger;
          dFT := q.FieldByName('AnzahlDez').AsFloat;
          sFT := q.FieldByName('AnzahlStd').AsString;
        end;
        q.Close;
      finally
        q.Free;
      end;
    finally
      conn.free;
    end;
  end;
begin
  Result := nil;
  joResponseJSON := TJSONObject.Create;
  joResponseJSONData := TJSONObject.Create;
  jaDetails := TJSONArray.Create;
  try
    WriteLog(PCM_Logname,'GetMonthYearValuesWeb_intern wird ausgeführt', 0);
    SetVarValues;

    GetPersonalValues;
    GetULGenommen(false);
    GetULGenommen(true);
    GetULGeplant;
    GetAbwesenheit(2, 0);
    GetAbwesenheit(1, 0);
    GetAbwesenheit(1, 1);
    GetAbwesenheit(2, 1);
    GetKrankYear;
    GetFT;
    GetMontValue;

    iCode := 200;
    sMessage := 'OK';

    joResponseJSON.AddPair('HasError', TJSONBool.Create(false));
    joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(0));
    joResponseJSON.AddPair('Errormessage', TJSONString.Create(''));

    // Beispielwerte; bitte weitere Werte ergänzen wie in deinem Originalcode
    joResponseJSON.AddPair('UL_Anspruch', TJSONNumber.Create(dULAns));
    joResponseJSON.AddPair('UL_Vorjahr', TJSONNumber.Create(dULVJ));
    joResponseJSON.AddPair('Target_time', TJSONNumber.Create(dSoll));

    joResponseJSON.AddPair('UL_genommenJahr', TJSONString.Create(sULGenommenJahr));
    joResponseJSON.AddPair('UL_genommenJahrD', TJSONNumber.Create(dULGenommenJahr));
    joResponseJSON.AddPair('UL_genommen', TJSONString.Create(sULGenommen));
    joResponseJSON.AddPair('UL_genommenD', TJSONNumber.Create(dULGenommen));

    joResponseJSON.AddPair('UL_geplant', TJSONString.Create(sULGeplant));
    joResponseJSON.AddPair('UL_geplantD', TJSONNumber.Create(dULGeplant));

    joResponseJSON.AddPair('UL', TJSONNumber.Create(iUL));
    joResponseJSON.AddPair('ULD', TJSONNumber.Create(dUL));
    joResponseJSON.AddPair('ULT', TJSONString.Create(sUL));

    joResponseJSON.AddPair('ULunb', TJSONNumber.Create(iULunb));
    joResponseJSON.AddPair('ULunbD', TJSONNumber.Create(dULunb));
    joResponseJSON.AddPair('ULunbT', TJSONString.Create(sULunb));

    joResponseJSON.AddPair('KR', TJSONNumber.Create(iKR));
    joResponseJSON.AddPair('KRD', TJSONNumber.Create(dKR));
    joResponseJSON.AddPair('KRT', TJSONString.Create(sKR));

    joResponseJSON.AddPair('KRYear', TJSONNumber.Create(iKRGes));
    joResponseJSON.AddPair('FTYear', TJSONNumber.Create(GetFeiertage(StrToInt(AID_Benutzer),StartOfAMonth(AJahr,1) ,EndOfAMonth(AJahr,12))));

    joResponseJSON.AddPair('KRunb', TJSONNumber.Create(iKRunb));
    joResponseJSON.AddPair('KRunbD', TJSONNumber.Create(dKRunb));
    joResponseJSON.AddPair('KRunbT', TJSONString.Create(sKRunb));

    joResponseJSON.AddPair('FT', TJSONNumber.Create(iFT));
    joResponseJSON.AddPair('FTD', TJSONNumber.Create(dFT));
    joResponseJSON.AddPair('FTT', TJSONString.Create(sFT));

    joResponseJSON.AddPair('Brutto', TJSONNumber.Create(iBrutto));
    joResponseJSON.AddPair('BruttoD', TJSONNumber.Create(dBrutto));
    joResponseJSON.AddPair('BruttoT', TJSONString.Create(sBrutto));

    joResponseJSON.AddPair('Pause', TJSONNumber.Create(iPause));
    joResponseJSON.AddPair('PauseD', TJSONNumber.Create(dPause));
    joResponseJSON.AddPair('PauseT', TJSONString.Create(sPause));

    joResponseJSON.AddPair('IStzeit', TJSONNumber.Create(iIStzeit));
    joResponseJSON.AddPair('IStzeitD', TJSONNumber.Create(dIStzeit));
    joResponseJSON.AddPair('IStzeitT', TJSONString.Create(sIStzeit));

    joResponseJSON.AddPair('Sollzeit', TJSONNumber.Create(iSollzeit));
    joResponseJSON.AddPair('SollzeitD', TJSONNumber.Create(dSollzeit));
    joResponseJSON.AddPair('SollzeitT', TJSONString.Create(sSollzeit));

    joResponseJSON.AddPair('Mehrarbeit', TJSONNumber.Create(iMA));
    joResponseJSON.AddPair('MehrarbeitD', TJSONNumber.Create(dMA));
    joResponseJSON.AddPair('MehrarbeitT', TJSONString.Create(sMA));

    joResponseJSON.AddPair('MehrarbeitVM', TJSONNumber.Create(iMAVM));
    joResponseJSON.AddPair('MehrarbeitVMD', TJSONNumber.Create(dMAVM));
    joResponseJSON.AddPair('MehrarbeitVMT', TJSONString.Create(sMAVM));

    joResponseJSON.AddPair('aktuelleMehrarbeit', TJSONNumber.Create(iMAakt));
    joResponseJSON.AddPair('aktuelleMehrarbeitD', TJSONNumber.Create(dMAakt));
    joResponseJSON.AddPair('aktuelleMehrarbeitT', TJSONString.Create(sMAakt));

    joResponseJSON.AddPair('Office', TJSONNumber.Create(GetBuchungsart(0,StrToint(AID_Benutzer),StartOfAMonth(AJahr,AMonat) ,EndOfAMonth(AJahr,AMonat))));
    joResponseJSON.AddPair('HomeOffice', TJSONNumber.Create(GetBuchungsart(1,StrToint(AID_Benutzer),StartOfAMonth(AJahr,AMonat) ,EndOfAMonth(AJahr,AMonat))));
    joResponseJSON.AddPair('Summary', TJSONNumber.Create(GetBuchungsart(0,StrToint(AID_Benutzer),StartOfAMonth(AJahr,AMonat) ,EndOfAMonth(AJahr,AMonat)) + GetBuchungsart(1,StrToint(AID_Benutzer),StartOfAMonth(AJahr,AMonat) ,EndOfAMonth(AJahr,AMonat))));
    joResponseJSON.AddPair('OfficeYear', TJSONNumber.Create(GetBuchungsart(0,StrToint(AID_Benutzer),StartOfAMonth(AJahr,1) ,EndOfAMonth(AJahr,12))));
    joResponseJSON.AddPair('HomeOfficeYear', TJSONNumber.Create(GetBuchungsart(1,StrToint(AID_Benutzer),StartOfAMonth(AJahr,1) ,EndOfAMonth(AJahr,12))));
    joResponseJSON.AddPair('SummaryYear', TJSONNumber.Create(GetBuchungsart(0,StrToint(AID_Benutzer),StartOfAMonth(AJahr,1) ,EndOfAMonth(AJahr,12)) + GetBuchungsart(1,StrToint(AID_Benutzer),StartOfAMonth(AJahr,1) ,EndOfAMonth(AJahr,12))));

    jaDetails.Add(joResponseJSONData);
    joResponseJSON.AddPair('Details', jaDetails);

    Result := joResponseJSON;
  except
    on E: Exception do
    begin
      FreeAndNil(joResponseJSON);
      FreeAndNil(joResponseJSONData);
      FreeAndNil(jaDetails);

      joResponseJSON := TJSONObject.Create;
      joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
      joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(2));
      joResponseJSON.AddPair('Errormessage', TJSONString.Create('Keine Verbindung zur Datenbank. Grund: ' + E.Message));
      Result := joResponseJSON;
      WriteLog(PCM_Logname,'GetMonthYearValuesWeb_intern exception: ' + e.Message, 2);
    end;
  end;
end;
function GetFehltageWeb_intern(AID_Benutzer: string): TJSONObject;
var
  qry: TFDQuery;
  conn: TFDConnection;
  joResponseJSON, joResponseJSONData: TJSONObject;
  jaDetails: TJSONArray;
  iCode: Integer;
  sMessage: string;
begin
  Result := nil;
  WriteLog(PCM_Logname,'GetFehltageWeb_intern wird ausgeführt', 0);
  joResponseJSON := TJSONObject.Create;
  try
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry := TFDQuery.Create(nil);
      try
        qry.Connection := conn;
        qry.SQL.Text :=
          'SELECT Kuerzel, Beschreibung, DATE_FORMAT(von, ''%d.%m.%Y'') AS Von, DATE_FORMAT(bis, ''%d.%m.%Y'') AS Bis, tage ' +
          'FROM time_fehltage ' +
          'WHERE YEAR(Von) = YEAR(NOW()) ' +
          'AND ID_Benutzer = :ID ' +
          'ORDER BY YEAR(Von), Month(von), Day(Von) ASC';
        qry.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
        qry.Open;

        WriteLog(PCM_Logname, rs_PCMAPPServer_Kalenderanzahl + IntToStr(qry.RecordCount), 0);

        if qry.RecordCount > 0 then
        begin
          iCode := 200;
          sMessage := 'OK';

          joResponseJSON.AddPair('HasError', TJSONBool.Create(false));
          joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(0));
          joResponseJSON.AddPair('Errormessage', TJSONString.Create(''));

          jaDetails := TJSONArray.Create;
          try
            qry.First;
            while not qry.Eof do
            begin
              joResponseJSONData := TJSONObject.Create;
              try
                joResponseJSONData.AddPair('Kuerzel', TJSONString.Create(qry.FieldByName('Kuerzel').AsString));
                joResponseJSONData.AddPair('Beschreibung', TJSONString.Create(qry.FieldByName('Beschreibung').AsString));
                joResponseJSONData.AddPair('Von', TJSONString.Create(qry.FieldByName('Von').AsString));
                joResponseJSONData.AddPair('Bis', TJSONString.Create(qry.FieldByName('Bis').AsString));
                joResponseJSONData.AddPair('Tage', TJSONString.Create(qry.FieldByName('Tage').AsString));

                jaDetails.Add(joResponseJSONData);
              except
                joResponseJSONData.Free;
                raise;
              end;

              qry.Next;
            end;

            joResponseJSON.AddPair('Fehltage', jaDetails);
          except
            jaDetails.Free;
            raise;
          end;
        end
        else
        begin
          iCode := 200;
          sMessage := 'OK';
          joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
          joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(1));
          joResponseJSON.AddPair('Errormessage', TJSONString.Create('Keine Datensätze vorhanden'));
        end;
        Result := joResponseJSON;
      finally
        qry.Free;
      end;
    finally
      conn.free;
    end;
  except
    on e: Exception do
    begin
      FreeAndNil(joResponseJSON);
      joResponseJSON := TJSONObject.Create;
      joResponseJSON.AddPair('HasError', TJSONBool.Create(true));
      joResponseJSON.AddPair('ErrorCode', TJSONNumber.Create(2));
      joResponseJSON.AddPair('Errormessage', TJSONString.Create('Keine Verbindung zur Datenbank. Grund: ' + e.Message));
      WriteLog(PCM_Logname,'GetFehltageWeb_intern exception: ' + e.Message, 2);
    end;
  end;
end;
function GetFeiertageWeb_intern(AID_Benutzer: string): TJSONObject;
var
  conn: TFDConnection;
  qry:TFDQuery;
begin
  Result := nil;
  WriteLog(PCM_Logname,'GetFeiertageWeb_intern wird ausgeführt', 0);
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry := TFDQuery.Create(nil);
      try
        qry.Connection := conn;
        qry.SQL.Text := 'SELECT tft.Bezeichnung, DATE_FORMAT(CAST(CONCAT(jahr, ''-'', LPAD(monat, 2, ''0''), ''-'', LPAD(tag, 2, ''0'')) AS DATE), ''%d.%m.%Y'') as Datum ' +
                                'FROM time_user tu ' +
                                'LEFT OUTER JOIN time_firma tf ON tf.ID = tu.ID_Firma ' +
                                'LEFT OUTER JOIN time_feiertage tft ON tft.Bl = tf.bl ' +
                                'WHERE tu.ID = :ID AND jahr = Year(NOW()) ' +
                                'order by Jahr,Monat, Tag' ;
        qry.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
        qry.Open;
        WriteLog(PCM_Logname,rs_PCMAPPServer_Kalenderanzahl + IntToStr(qry.RecordCount),0);
        if qry.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('Bezeichnung', TJSONString.Create(qry.FieldByName('Bezeichnung').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Datum', TJSONString.Create(qry.FieldByName('Datum').asString)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Feiertage', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'GetFeiertageWeb_intern exception: ' + e.Message, 2);
    end;
  end;
end;
function GetLastBookingWeb_Intern(AID_Benutzer: String): TJSONObject;
var
  conn: TFDConnection;
  qry:TFDQuery;
begin
  WriteLog(PCM_Logname,'GetLastBookingWeb_Intern wird ausgeführt', 0);
  Result := nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry := TFDQuery.Create(nil);
      try
        qry.Connection := conn;
        qry.SQL.Text :=  'SELECT Text FROM time_message where ID_Benutzer = :ID';
        qry.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
        qry.Open;

        if qry.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('LastBooking', TJSONString.Create(StringReplace(qry.FieldByName('Text').asString, 'Letzte Buchung: ','',[rfIgnoreCase, rfReplaceAll]))));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('LastBooking', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry.free;
      end;
    finally
      conn.Free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'GetLastBookingWeb_Intern exception: ' + e.Message, 2);
    end;
  end;
end;
function GetBookingWeb_Intern(AID_Benutzer: string): TJSONObject;
var
  conn: TFDConnection;
  qry:TFDQuery;
begin
  WriteLog(PCM_Logname,'GetBookingWeb_Intern wird ausgeführt', 0);
  Result := nil;
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;

    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry := TFDQuery.Create(nil);
      try
        qry.Connection := conn;
        qry.SQL.Text :=  'Select Kommen, Gehen, Pause1Beginn,Pause1ende,Pause2Beginn,Pause2ende From time_buchungen Where Datum = :Datum and ID_Benutzer = :ID';
        qry.ParamByName('Datum').AsDate:= Date;
        qry.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
        qry.Open;
        WriteLog(PCM_Logname,'Letzte Buchung ermitteln',0);
        if qry.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('Work_Begin', TJSONString.Create(TimeToStr(qry.FieldByName('Kommen').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('Work_End', TJSONString.Create(TimeToStr(qry.FieldByName('Gehen').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('Break1_Begin', TJSONString.Create(TimeToStr(qry.FieldByName('Pause1Beginn').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('Break1_End', TJSONString.Create(TimeToStr(qry.FieldByName('Pause1ende').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('Break2_Begin', TJSONString.Create(TimeToStr(qry.FieldByName('Pause2Beginn').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('Break3_End', TJSONString.Create(TimeToStr(qry.FieldByName('Pause2ende').AsDateTime))));

            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Booking', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'GetBookingWeb_Intern exception: ' + e.Message, 2);
    end;
  end;
end;
function SetLastBookingWeb_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iZaehler,
  iAnzahl: integer;
  sLastBooking: String;
  conn: TFDConnection;
  qry:TFDQuery;
begin
  Result := nil;
  WriteLog(PCM_Logname,'SetLastBookingWeb_Intern wird ausgeführt', 0);
  try
    joResponseJSON := nil;
    jaDetails := nil;
    iZaehler:= 0;
    AJSONObject.TryGetValue<string>('LastBooking',sLastBooking);
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry := TFDQuery.Create(nil);
      try
        qry.Connection := conn;
        qry.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_message ';
        qry.Open;
        iAnzahl:= qry.FieldByName('Anzahl').asInteger;
        qry.Close;
        if iAnzahl = 0 then
        begin
          qry.SQL.Text:=  'INSERT INTO time_message (Text) Values (:Text)';
          qry.ParamByName('Text').AsString:= sLastBooking;
          qry.ExecSQL;
        end
        else begin
          qry.SQL.Text:=  'Update time_message SET Text = :Text';
          qry.ParamByName('Text').AsString:= sLastBooking;
          qry.ExecSQL;
        end;

        WriteLog(PCM_Logname,'Letzte Buchung aktualisieren' + IntToStr(iZaehler),0);
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        Result := joResponseJSON;
      finally
        qry.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'SetLastBookingWeb_Intern exception: ' + e.Message, 2);
    end;
  end;
end;
function SetOnlineBookingWeb_Intern(AID_Benutzer: string; ATest: Boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  conn: TFDConnection;
  qry:TFDQuery;
  iZaehler: Integer;
  sField: string;
  sDate: string;
  sTime: string;
  iType: Integer;
  iBooking_Type: Integer;
begin
  Result := nil;
  WriteLog(PCM_Logname,'SetOnlineBookingWeb_Intern wird ausgeführt', 0);
  try
    joResponseJSON := nil;
    jaDetails := nil;
    iZaehler:= 0;
    jaDetails :=  AJSONObject.GetValue<TJSONArray>('OnlineBooking');
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry := TFDQuery.Create(nil);
      try
        qry.Connection := conn;
        for var JSonValue in jaDetails do
        begin
          JSonValue.TryGetValue<string>('Date',sDate);
          JSonValue.TryGetValue<string>('Time',sTime);
          JSonValue.TryGetValue<integer>('Type',iType);
          JSonValue.TryGetValue<integer>('Booking_Type',iBooking_Type);
          case iType of
          1:
            begin
              sField:= 'Kommen';
              qry.SQL.Text:=  'Update time_Buchungen Set ' + sField + ' = :time, Buchungsart = :Buchungsart Where ID_Benutzer =:ID and  Datum = :Datum';
              qry.ParamByName('Buchungsart').asInteger := iBooking_Type;
            end;
          2:
            begin
              sField:= 'Gehen';
              qry.SQL.Text:=  'Update time_Buchungen Set ' + sField + ' = :time, Buchungsart = :Buchungsart Where ID_Benutzer =:ID and  Datum = :Datum';
              qry.ParamByName('Buchungsart').asInteger := iBooking_Type;
            end;
          3:
            begin
               sField:= 'Pause1Beginn';
               qry.SQL.Text:=  'Update time_Buchungen Set ' + sField + ' = :time Where ID_Benutzer =:ID and  Datum = :Datum';
            end;
          4:
            begin
               sField:= 'Pause1Ende';
               qry.SQL.Text:=  'Update time_Buchungen Set ' + sField + ' = :time Where ID_Benutzer =:ID and  Datum = :Datum';
            end;
          5:
            begin
               sField:= 'Pause2Beginn';
               qry.SQL.Text:=  'Update time_Buchungen Set ' + sField + ' = :time Where ID_Benutzer =:ID and  Datum = :Datum';
            end;
          6:
            begin
               sField:= 'Pause2Ende';
               qry.SQL.Text:=  'Update time_Buchungen Set ' + sField + ' = :time Where ID_Benutzer =:ID and  Datum = :Datum';
            end;
          end;

          qry.ParamByName('time').AsTime:= StrToTime(sTime);
          qry.ParamByName('Datum').AsDate:= StrToDate(sDate);
          qry.ParamByName('ID').AsString:= AID_Benutzer;
          qry.ExecSQL;

          qry.SQL.Text:=  'Select Count(*) as Anzahl From time_Message Where ID_Benutzer =:ID';
          qry.ParamByName('ID').AsString:= AID_Benutzer;
          qry.open;
          var iAnzahl := qry.FieldByName('Anzahl').AsInteger;
          qry.Close;
          if iAnzahl > 0 then
          begin
            qry.SQL.Text:=  'Update time_Message Set Text  = :Text Where ID_Benutzer =:ID';
            qry.ParamByName('Text').AsString:= 'Letzte Buchung: ' + sField + ' am ' + sDate + ' ' + sTime;
            qry.ParamByName('ID').AsString:= AID_Benutzer;
            qry.ExecSQL;
          end
          else begin
            qry.SQL.Text:=  'Insert Into time_Message (Text,ID_Benutzer) Values (:Text,:ID)';
            qry.ParamByName('Text').AsString:= 'Letzte Buchung: ' + sField + ' am ' + sDate + ' ' + sTime;
            qry.ParamByName('ID').AsString:= AID_Benutzer;
            qry.ExecSQL;
          end;
          iZaehler:= iZaehler + 1;
        end;
        if not Assigned(joResponseJSON) then
          joResponseJSON := TJSONObject.Create;
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        Result := joResponseJSON;
      finally
        qry.free;
      end;
    finally
      conn.free;
    end;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'SetOnlineBookingWeb_Intern exception: ' + e.Message, 2);
    end;
  end;
end;
function CalcBookingWeb_Intern(AID_Benutzer: string; AMonat, AJahr: integer): TJSONObject;
begin
  Result := nil;
  WriteLog(PCM_Logname,'CalcBookingWeb_Intern wird ausgeführt', 0);
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  try
    WriteLog(PCM_Logname,'Berechnung',0);
    BerechneTage(0,AMonat,AJahr,StrToInt(AID_Benutzer));
    BerechneMonat(AMonat,AJahr,StrToInt(AID_Benutzer));
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    Result := joResponseJSON;
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'CalcBookingWeb_Intern exception: ' + e.Message, 2);
    end;
  end;
end;
function GetAbsenceWeb_intern(AID_Benutzer: string; AMonat, AJahr: integer): TJSONObject;
var
  conn: TFDConnection;
  qry: TFDQuery;
begin
  Result:= nil;
  WriteLog(PCM_Logname,'GetAbsenceWeb_intern wird ausgeführt', 0);
  try
    joResponseJSON:= nil;
    joResponseJSONData:= nil;
    jaDetails:= nil;
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    conn := TFDConnection.Create(nil);
    try
      conn.ConnectionDefName := 'PCM';
      conn.Connected := True;
      qry := TFDQuery.Create(nil);
      try
        qry.Connection := conn;
        qry.SQL.Text :=  'SELECT b.ID, b.Datum, b.Tag, ft.ColorFont,FT.Color, if(b.Datum > NOW(),''00:00:00'',b.Sollstunden)  AS Sollstunden, ' +
                                     'IF(b.Feiertag = 1,''FT1'',IF(b.Feiertag = 2,IF(b.Fehltag <> '' '',CONCAT(b.Fehltag,''-FT2''),''FT2''),b.Fehltag)) AS AbW, ' +
                                     'IF(b.Fehltag = '' '','''',b.Fehltag) AS Fehltag,Feiertag ' +
                                     'FROM time_buchungen b ' +
                                     'LEFT OUTER JOIN time_fehltag ft ON ft.kuerzel = b.Fehltag ' +
                                     'WHERE ID_Benutzer = :ID AND ' +
                                     'YEAR(Datum)= :Jahr ';
        if AMonat > 0  then
        begin
          qry.SQL.Text:= qry.SQL.Text +'AND MONTH(Datum)= :Monat ';
          qry.ParamByName('Monat').AsInteger:= AMonat;
        end;
        qry.SQL.Text:= qry.SQL.Text +'Order by Datum asc ';
        qry.ParamByName('ID').AsString:= AID_Benutzer;
        qry.ParamByName('Jahr').AsInteger:= AJahr;
        qry.Open;
        if qry.RecordCount > 0 then
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          if not Assigned(jaDetails) then
            jaDetails := TJSONArray.Create;
          while not qry.eof do
          begin
            if not Assigned(joResponseJSONData) then
              joResponseJSONData := TJSONObject.Create;
            joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(qry.FieldByName('ID').AsInteger)));
            joResponseJSONData.AddPair(TJSONPair.Create('Datum', TJSONString.Create(DateToStr(qry.FieldByName('Datum').AsDateTime))));
            joResponseJSONData.AddPair(TJSONPair.Create('Day', TJSONString.Create(qry.FieldByName('Tag').AsString)));
            joResponseJSONData.AddPair(TJSONPair.Create('ColorFont', TJSONString.Create(qry.FieldByName('ColorFont').AsString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Color', TJSONString.Create(qry.FieldByName('Color').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Target_time', TJSONString.Create(qry.FieldByName('Sollstunden').asString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Abs', TJSONString.Create(qry.FieldByName('Abw').AsString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Absence', TJSONString.Create(qry.FieldByName('Fehltag').AsString)));
            joResponseJSONData.AddPair(TJSONPair.Create('Holiday', TJSONNumber.Create(qry.FieldByName('Feiertag').AsInteger)));
            jaDetails.Add(joResponseJSONData);
            joResponseJSONData:= nil;
            qry.Next;
          end;
          joResponseJSON.AddPair(TJSONPair.Create('Absence_Day', jaDetails));
        end
        else
        begin
          iCode:= 200;
          sMessage:= 'OK';
          joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Datensätze vorhanden')));
        end;
        Result := joResponseJSON;
      finally
        qry.Free;
      end;
    finally
      conn.free;
    end
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      WriteLog(PCM_Logname,'GetAbsenceWeb_intern exception: ' + e.Message, 2);
    end;
  end;


end;
{$EndRegion WebapiPCM}
end.
