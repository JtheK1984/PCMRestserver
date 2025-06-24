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
  function BadRequest: TJSONObject;
  function GetIDFromTable(ATable,AValue: String) : Integer;
  function CheckTokenGueltig(sToken: String): Boolean;
  function CheckUser: boolean;
  function AddZeros(AValue: String; ACount: integer): string;
  function FormatDateTimeToStr(ADate: TDateTime): String;
  procedure UpdateFieldValues_String(AField, ATable, AValue: String; AID:Integer);Overload;
  procedure UpdateFieldValues_Ansistring(AField, ATable: String; AValue: Ansistring; AID:Integer);Overload
  procedure UpdateFieldValues_TDateTime(AField, ATable: String; AValue: TDateTime; AID:Integer);Overload
  procedure UpdateFieldValues_TDate(AField, ATable: String; AValue: TDate; AID:Integer);Overload
  procedure UpdateFieldValues_Boolean(AField, ATable: String; AValue: Boolean; AID:Integer);Overload
  procedure UpdateFieldValues_Integer(AField, ATable: String; AValue: Integer; AID:Integer);Overload
  procedure UpdateFieldValues_Float(AField, ATable: String; AValue: Double; AID:Integer);Overload
  //////////////////////////////////////////////////////////////////////////////
  // WebAPI - PCM                                                             //
  //////////////////////////////////////////////////////////////////////////////
  function CreateToken_Intern: TJSONObject;
  function RefreshToken_Intern(const AJSONObject: TJSONObject): TJSONObject;
  function DeleteToken_Intern(const sToken: String;iProg: Integer): TJSONObject;
  function CreateBackup_Intern(const sToken, sPath: String): TJSONObject;
  function GetKalenderConfig_Intern(const AJSONObject: TJSONObject): TJSONObject;
  //////////////////////////////////////////////////////////////////////////////
  // TimeAPPAPI - PCM                                                         //
  //////////////////////////////////////////////////////////////////////////////
  function GetContactsZE_Intern(AID_Benutzer: string): TJSONObject;
  function GetLastBooking_Intern(AID_Benutzer: string): TJSONObject;
  function SetLastBooking_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
  function GetBookingYear_Intern(AID_Benutzer,AJahr: string): TJSONObject;
  function GetAbsenceconfig_Intern(AID_Benutzer: string): TJSONObject;
  function GetAbsence_Intern(AID_Benutzer: string): TJSONObject;
  function SetOnlineBooking_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
  function GetMonthValues_Intern(AID_Benutzer: Integer): TDataset;

  //////////////////////////////////////////////////////////////////////////////
  // APPAPI - PCM                                                             //
  //////////////////////////////////////////////////////////////////////////////
  // Servercheck
  function Checkserver_Intern: TJSONObject;
  // Prüfen ob Login erlaubt
  function CheckLogin_Intern: TJSONObject;
  // Set Token
  function SetDeviceID_Intern(const AJSONObject: TJSONObject): TJSONObject;
  // Kontakte ermitteln
  function GetKontakte_Intern(AID_Benutzer: string): TJSONObject;
  // Kontakte übernehmen
  function SetKontakte_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
  // Kalender ermitteln
  function GetKalender_Intern(AID_Benutzer: string): TJSONObject;
  // Kalender übernehmen
  function SetKalender_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
  // Passwörter ermitteln
  function GetPasswoerter_Intern(AID_Benutzer: string): TJSONObject;
  // Passwörter übernehmen
  function SetPasswoerter_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
  // Serials ermitteln
  function GetSerials_Intern(AID_Benutzer: string): TJSONObject;
  // Serials übernehmen
  function SetSerials_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
  // Einnnahmen ermitteln
  function GetEinnahmen_Intern(AID_Benutzer: string): TJSONObject;
  // Einnnahmen übernehmen
  function SetEinnahmen_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
  // Ausgaben ermitteln
  function GetAusgaben_Intern(AID_Benutzer: string): TJSONObject;
  // Ausgaben übernehmen
  function SetAusgaben_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
    // Ausgaben ermitteln
  function GetVouchers_Intern(AID_Benutzer: string): TJSONObject;
  // Ausgaben übernehmen
  function SetVouchers_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
    // Ausgaben ermitteln
  function GetGiftCards_Intern(AID_Benutzer: string): TJSONObject;
  // Ausgaben übernehmen
  function SetGiftCards_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
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
  PCM.Data,
  PCM.Functions,
  PCM.Main,
  PCM.Strings;
  {$EndRegion Uses}
////////////////////////////////////////////////////////////////////////////////
// Hilfsfunktionen                                                            //
////////////////////////////////////////////////////////////////////////////////
{$Region Hilfsfunktionen}
function BadRequest: TJSONObject;
var
  sUser: String;
  sPass: String;
begin
  joResponseJSON := nil;
  jaDetails := nil;
  sUser := TDSSessionManager.GetThreadSession.GetData('Username');
  sPass := TDSSessionManager.GetThreadSession.GetData('Password');
  dm_PCM.qry_Work.sql.text:= 'SELECT ID,Benutzer, Passwort, RestApi FROM Benutzer WHERE Benutzer = :User';
  dm_PCM.qry_Work.ParamByName('User').AsString := sUser;
  dm_PCM.qry_Work.Open;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    if (sPass <> dm_PCM.qry_Work.FieldByName('Passwort').AsString) then
    begin
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('falsches Passwort')));
    end;
    if (dm_PCM.qry_Work.FieldByName('RestAPI').AsBoolean = false) then
    begin
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(4)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Benutzer nicht berechtigt')));
    end;
  end
  else begin
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Benutzer nicht gefunden')));
  end;


  WriteLog(PCM_Logname,rs_PCMAPPServer_Tokenpruefung,0);
  Result := joResponseJSON;
end;
function GetIDFromTable(ATable,AValue: String) : Integer;
begin
  dm_PCM.qry_Work.SQL.Text := 'SELECT ID From ' + ATable + ' Where Bezeichnung = :Bezeichnung' ;
  dm_PCM.qry_Work.ParamByName('Bezeichnung').asString := AValue;
  dm_PCM.qry_Work.Open;
  if dm_PCM.qry_Work.RecordCount = 0 then
  begin
    dm_PCM.qry_Work.Close;
    dm_PCM.qry_Work.SQL.Text := 'Insert Into ' + ATable + ' (Bezeichnung) Values (:Bezeichnung)' ;
    dm_PCM.qry_Work.ParamByName('Bezeichnung').asString := AValue;
    dm_PCM.qry_Work.ExecSQL;
    dm_PCM.qry_Work.SQL.Text := 'SELECT ID From ' + ATable + ' Where Bezeichnung = :Bezeichnung' ;
    dm_PCM.qry_Work.ParamByName('Bezeichnung').asString := AValue;
    dm_PCM.qry_Work.Open;
    Result:= dm_PCM.qry_Work.FieldByName('ID').asInteger;
  end
  else
  begin
    Result:= dm_PCM.qry_Work.FieldByName('ID').asInteger;
  end;
  dm_PCM.qry_Work.Close;
end;
function CheckTokenGueltig(sToken: String): Boolean;
begin
    dm_PCM.qry_Work.SQL.Text := 'SELECT Gueltig_Bis FROM Benutzer WHERE Token = :Token and Gueltig_Bis >= :Jetzt';
    dm_PCM.qry_work.ParamByName('Token').AsString := sToken;
    dm_PCM.qry_work.ParamByName('Jetzt').AsDateTime := Now;
    dm_PCM.qry_work.Open;
    if dm_PCM.qry_work.RecordCount > 0 then
      Result := True
    else
      Result := False;
    dm_PCM.qry_work.Close;
end;
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
function CheckUser: boolean;
var
  sUser, sPass: String;
begin
  Result:= false;
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  sUser := TDSSessionManager.GetThreadSession.GetData('Username');
  sPass := TDSSessionManager.GetThreadSession.GetData('Password');
  dm_PCM.qry_Work.sql.text:= 'SELECT ID,Benutzer, Passwort, RestApi FROM Benutzer WHERE Benutzer = :User';
  dm_PCM.qry_Work.ParamByName('User').AsString := sUser;
  dm_PCM.qry_Work.Open;
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    if (sPass = dm_PCM.qry_Work.FieldByName('Passwort').AsString) AND (dm_PCM.qry_Work.FieldByName('RestAPI').AsBoolean = True) then
    begin
      Result:= true;
    end;
  end;
end;
procedure UpdateFieldValues_String(AField, ATable, AValue: String; AID:Integer);Overload;
var
  qry_Update: TFDQuery;
begin
  qry_Update:= TFDQuery.Create(nil);
  qry_Update.Connection:= dm_PCM.con_PCM;
  qry_Update.SQL.Text:= 'Update ' + ATable + ' Set ' + AField + '=:AValue Where ID = :ID';
  qry_Update.ParamByName('Avalue').AsString:= AValue;
  qry_Update.ParamByName('ID').AsInteger:= AID;
  qry_Update.ExecSQL;
  FreeAndNil(qry_Update);
end;
procedure UpdateFieldValues_Ansistring(AField, ATable: String; AValue: Ansistring; AID:Integer);Overload
var
  qry_Update: TFDQuery;
begin
  qry_Update:= TFDQuery.Create(nil);
  qry_Update.Connection:= dm_PCM.con_PCM;
  qry_Update.SQL.Text:= 'Update ' + ATable + ' Set ' + AField + '=:AValue Where ID = :ID';
  qry_Update.ParamByName('Avalue').asMemo:= AValue;
  qry_Update.ParamByName('ID').AsInteger:= AID;
  qry_Update.ExecSQL;
  FreeAndNil(qry_Update);
end;
procedure UpdateFieldValues_TDateTime(AField, ATable: String; AValue: TDateTime; AID:Integer);Overload
var
  qry_Update: TFDQuery;
begin
  qry_Update:= TFDQuery.Create(nil);
  qry_Update.Connection:= dm_PCM.con_PCM;
  qry_Update.SQL.Text:= 'Update ' + ATable + ' Set ' + AField + '=:AValue Where ID = :ID';
  qry_Update.ParamByName('Avalue').AsDateTime:= AValue;
  qry_Update.ParamByName('ID').AsInteger:= AID;
  qry_Update.ExecSQL;
  FreeAndNil(qry_Update);
end;
procedure UpdateFieldValues_TDate(AField, ATable: String; AValue: TDate; AID:Integer);Overload
var
  qry_Update: TFDQuery;
begin
  qry_Update:= TFDQuery.Create(nil);
  qry_Update.Connection:= dm_PCM.con_PCM;
  qry_Update.SQL.Text:= 'Update ' + ATable + ' Set ' + AField + '=:AValue Where ID = :ID';
  qry_Update.ParamByName('Avalue').AsDate:= AValue;
  qry_Update.ParamByName('ID').AsInteger:= AID;
  qry_Update.ExecSQL;
  FreeAndNil(qry_Update);
end;
procedure UpdateFieldValues_Boolean(AField, ATable: String; AValue: Boolean; AID:Integer);Overload
var
  qry_Update: TFDQuery;
begin
  qry_Update:= TFDQuery.Create(nil);
  qry_Update.Connection:= dm_PCM.con_PCM;
  qry_Update.SQL.Text:= 'Update ' + ATable + ' Set ' + AField + '=:AValue Where ID = :ID';
  qry_Update.ParamByName('Avalue').AsBoolean:= AValue;
  qry_Update.ParamByName('ID').AsInteger:= AID;
  qry_Update.ExecSQL;
  FreeAndNil(qry_Update);
end;
procedure UpdateFieldValues_Integer(AField, ATable: String; AValue: Integer; AID:Integer);Overload
var
  qry_Update: TFDQuery;
begin
  qry_Update:= TFDQuery.Create(nil);
  qry_Update.Connection:= dm_pcm.con_PCM;
  qry_Update.SQL.Text:= 'Update ' + ATable + ' Set ' + AField + '=:AValue Where ID = :ID';
  qry_Update.ParamByName('Avalue').AsInteger:= AValue;
  qry_Update.ParamByName('ID').AsInteger:= AID;
  qry_Update.ExecSQL;
  FreeAndNil(qry_Update);
end;
procedure UpdateFieldValues_Float(AField, ATable: String; AValue: Double; AID:Integer);Overload
var
  qry_Update: TFDQuery;
begin
  qry_Update:= TFDQuery.Create(nil);
  qry_Update.Connection:= dm_pcm.con_PCM;
  qry_Update.SQL.Text:= 'Update ' + ATable + ' Set ' + AField + '=:AValue Where ID = :ID';
  qry_Update.ParamByName('Avalue').AsFloat:= AValue;
  qry_Update.ParamByName('ID').AsInteger:= AID;
  qry_Update.ExecSQL;
  FreeAndNil(qry_Update);
end;
{$EndRegion Hilfsfunktionen}
////////////////////////////////////////////////////////////////////////////////
// WebAPI - PCM                                                               //
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
begin
  joResponseJSON:= nil;
  try
    try
      sUser := TDSSessionManager.GetThreadSession.GetData('Username');
      WriteLog(PCM_Logname,sUser,0);
      sPass := TDSSessionManager.GetThreadSession.GetData('Password');
      WriteLog(PCM_Logname,sPass ,0);
      if not Assigned(joResponseJSON) then
        joResponseJSON := TJSONObject.Create;
      dm_PCM.qry_Work.Sql.Text := 'SELECT ID, RestAPI FROM Benutzer WHERE Benutzer =:Username AND Passwort=:Password';
      dm_PCM.qry_Work.ParamByName('Username').AsString := sUser;
      dm_PCM.qry_Work.ParamByName('Password').AsString := sPass;
      dm_PCM.qry_Work.Open;
      if dm_PCM.qry_Work.RecordCount > 0 then
      begin
        iID_MA_Stammdaten := dm_PCM.qry_Work.FieldByName('ID').AsInteger;
        bRestAPI:= dm_PCM.qry_Work.FieldByName('RestAPI').asBoolean;
        if bRestAPI then
        begin
          sToken := RandomString(70);
          dm_PCM.qry_Work.Sql.Text := 'Update Benutzer Set Token = :Token, Gueltig_Bis = :Gueltig_Bis Where ID = :ID';
          dm_PCM.qry_Work.ParamByName('Token').AsString := sToken;
          dm_PCM.qry_Work.ParamByName('Gueltig_Bis').AsDateTime := IncMinute(Now, PCM_Restserver.RESTServerConfig.TokenTimeout);
          dm_PCM.qry_Work.ParamByName('ID').AsInteger := iID_MA_Stammdaten;
          dm_PCM.qry_Work.ExecSQL;
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
    except
      on e:exception do
      begin
        iCode:= 409;
        sMessage:= 'Database Error';
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(3)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      end;
    end;
    Result := joResponseJSON;
  finally
    dm_PCM.qry_Work.Close;
  end;
end;
function RefreshToken_Intern(const AJSONObject: TJSONObject): TJSONObject;
var
  sToken: string;
begin
  joResponseJSON:= nil;
  sToken:= AJSONObject.GetValue<String>('Token');
  try
    try
      if not Assigned(joResponseJSON) then
        joResponseJSON := TJSONObject.Create;
      if CheckTokenGueltig(sToken) then
      begin
          dm_PCM.qry_Work.Sql.Text := 'Update Benutzer Set Gueltig_Bis = :Gueltig_Bis Where Token = :Token';
          dm_PCM.qry_Work.ParamByName('Token').AsString := sToken;
          dm_PCM.qry_Work.ParamByName('Gueltig_Bis').AsDateTime := IncMinute(Now, PCM_Restserver.RESTServerConfig.TokenTimeout);
          dm_PCM.qry_Work.ExecSQL;
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
    except
      on e:exception do
      begin
        iCode:= 409;
        sMessage:= 'Database Error';
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(3)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      end;
    end;
    Result := joResponseJSON;
  finally
    dm_PCM.qry_Work.Close;
  end;
end;
function DeleteToken_Intern(const sToken: String;iProg: Integer): TJSONObject;
begin
  joResponseJSON:= nil;
  try
    try
      if not Assigned(joResponseJSON) then
        joResponseJSON := TJSONObject.Create;
      if CheckTokenGueltig(sToken) then
      begin
          dm_PCM.qry_Work.Sql.Text := 'Update Benutzer Set Token = '''' Where Token = :Token';
          dm_PCM.qry_Work.ParamByName('Token').AsString := sToken;
          dm_PCM.qry_Work.ExecSQL;
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
    except
      on e:exception do
      begin
        iCode:= 409;
        sMessage:= 'Database Error';
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(3)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
      end;
    end;

    Result := joResponseJSON;
  finally
    dm_PCM.qry_Work.Close;
  end;
end;
function CreateBackup_Intern(const sToken, sPath: String): TJSONObject;
begin
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
end;
function GetKalenderConfig_Intern(const AJSONObject: TJSONObject): TJSONObject;
var
  qWork: TFDQuery;
  iID_Benutzer: integer;
  sToken: string;
begin
  qWork := TFDQuery.Create(nil);
  try
    iID_Benutzer := AJSONObject.GetValue<Integer>('ID_Benutzer');
    sToken := AJSONObject.GetValue<String>('Token');
    if not Assigned(joResponseJSON) then
      joResponseJSON := TJSONObject.Create;
    if CheckTokenGueltig(sToken) then
    begin
      qWork.SQL.Text := 'SELECT Kalender,Link,Benutzer,Passwort,Erinnerung,ErinnerungVor,LabelColor,FontColor FROM manager_kalender_config WHERE ID_Benutzer = :ID_Benutzer';
      qWork.ParamByName('ID_Benutzer').AsInteger := iID_Benutzer;
      qWork.Open;
      if qWork.RecordCount > 0 then
      begin
        while not qWork.Eof do
        begin
          joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
          joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
          joResponseJSON.AddPair(TJSONPair.Create('Kalender', qWork.FieldByName('Link').AsString));
          joResponseJSON.AddPair(TJSONPair.Create('Link', qWork.FieldByName('Link').AsString));
          joResponseJSON.AddPair(TJSONPair.Create('Benutzer', qWork.FieldByName('Benutzer').AsString));
          joResponseJSON.AddPair(TJSONPair.Create('Passwort', qWork.FieldByName('Passwort').AsString));
          joResponseJSON.AddPair(TJSONPair.Create('Erinnerung', TJSONBool.Create(qWork.FieldByName('Erinnerung').AsBoolean)));
          joResponseJSON.AddPair(TJSONPair.Create('ErinnerungVor', TJSONNumber.Create(qWork.FieldByName('ErinnerungVor').AsInteger)));
          joResponseJSON.AddPair(TJSONPair.Create('LabelColor', TJSONNumber.Create(qWork.FieldByName('LabelColor').AsInteger)));
          joResponseJSON.AddPair(TJSONPair.Create('FontColor', TJSONNumber.Create(qWork.FieldByName('FontColor').AsInteger)));
//          iCount := iCount + 1;
          qWork.Next;
        end;
        qWork.Close;
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
    qWork.Close;
    qWork.Free;
  end;
end;
{$EndRegion Webapi}
////////////////////////////////////////////////////////////////////////////////
// APP-API - PCM                                                              //
////////////////////////////////////////////////////////////////////////////////
{$Region APPapi}
// Server und Login
{$Region Server_Login}
//Checkserver
function Checkserver_intern: TJSONObject;
begin
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
      WriteLog(PCM_Logname,'Checkserver:' + e.Message,2);
  end;
end;
// Login ermitteln
function CheckLogin_Intern: TJSONObject;
var
  sUser, sPass: String;
begin
try
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  sUser := TDSSessionManager.GetThreadSession.GetData('Username');
  sPass := TDSSessionManager.GetThreadSession.GetData('Password');
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  try
    WriteLog(PCM_Logname,rs_PCMAPPServer_BenutzerausPCMpruefen,0);
    dm_PCM.qry_Work.sql.text:= 'SELECT ID,Benutzer, Passwort, RestApi FROM Benutzer WHERE Benutzer = :User';
    dm_PCM.qry_Work.ParamByName('User').AsString := sUser;
    dm_PCM.qry_Work.Open;
    if dm_PCM.qry_Work.RecordCount > 0 then
    begin
      if not Assigned(jaDetails) then
        jaDetails := TJSONArray.Create;
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      if (sPass = dm_PCM.qry_Work.FieldByName('Passwort').AsString) AND (dm_PCM.qry_Work.FieldByName('RestAPI').AsBoolean = True) then
      begin
        iCode:= 200;
        sMessage:= 'OK';
        joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
        joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
        joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
        joResponseJSONData.AddPair(TJSONPair.Create('Allowed', TJSONBool.Create(True)));
        joResponseJSONData.AddPair(TJSONPair.Create('ID_User', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('ID').asInteger)));
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
        joResponseJSONData.AddPair(TJSONPair.Create('ID_User', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('ID').asInteger)));
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
  except
    on e:exception do
    begin
      iCode:= 409;
      sMessage:= 'Database Error';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(2)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Keine Verbindung zur Datenbank. Grund:' + e.Message)));
    end;
  end;
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
  except
    on e:Exception do
      WriteLog(PCM_Logname,'Checklogin:' + e.Message,2);
  end;
end;
// Set Token
function SetDeviceID_Intern(const AJSONObject: TJSONObject): TJSONObject;
var
  iID_Benutzer: Integer;
  sToken: string;
  sDeviceID: string;
  iDeviceType: integer;
begin
  try
  iZaehler:= 0;
  joResponseJSON := nil;
  jaDetails := nil;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Device');
  for var JSonValue in jaDetails do
  begin
    JSonValue.TryGetValue<string>('DeviceToken',sToken);
    JSonValue.TryGetValue<string>('DeviceID',sDeviceID);
    JSonValue.TryGetValue<integer>('DeviceType',iDeviceType);
    JSonValue.TryGetValue<integer>('ID_Benutzer',iID_Benutzer);

    dm_PCM.qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_devices ' +
                                'WHERE ID_Benutzer = :ID_Benutzer and DeviceID = :DeviceID and DeviceType = :DeviceType';
    dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger := iID_Benutzer;
    dm_PCM.qry_Work.ParamByName('DeviceID').asString := sDeviceID;
    dm_PCM.qry_Work.ParamByName('DeviceType').asInteger := iDeviceType;
    dm_PCM.qry_Work.Open;
    iAnzahl:= dm_PCM.qry_Work.FieldByName('Anzahl').asInteger;
    dm_PCM.qry_Work.Close;
    if iAnzahl = 0 then
    begin
      dm_PCM.qry_Work.SQL.Text:=  'INSERT INTO manager_devices (ID_Benutzer,DeviceToken,DeviceID,DeviceType' +
                                              ') Values (:ID_Benutzer,:DeviceToken,:DeviceID,:DeviceType)';
      dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger := iID_Benutzer;
      dm_PCM.qry_Work.ParamByName('DeviceToken').asString := sToken;
      dm_PCM.qry_Work.ParamByName('DeviceID').asString := sDeviceID;
      dm_PCM.qry_Work.ParamByName('DeviceType').asInteger := iDeviceType;
      dm_PCM.qry_Work.ExecSQL;
    end
    else begin
      dm_PCM.qry_Work.SQL.Text:=  'Update manager_devices SET DeviceToken= :DeviceToken ' +
                                  'WHERE ID_Benutzer = :ID_Benutzer and DeviceID = :DeviceID and DeviceType = :DeviceType';
      dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger := iID_Benutzer;
      dm_PCM.qry_Work.ParamByName('DeviceToken').asString := sToken;
      dm_PCM.qry_Work.ParamByName('DeviceID').asString := sDeviceID;
      dm_PCM.qry_Work.ParamByName('DeviceType').asInteger := iDeviceType;
      dm_PCM.qry_Work.ExecSQL;
    end;
  end;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
  joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
  joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
  WriteLog(PCM_Logname,rs_PCMAPPServer_Tokenpruefung,0);
  Result := joResponseJSON;
  except
    on e:Exception do
      WriteLog(PCM_Logname,'SeDevice:' + e.Message,2);
  end;
end;
{$EndRegion Server_Login}
// Kontakte
{$Region Kontakte}
// Kontakte ermitteln
function GetKontakte_Intern(AID_Benutzer: string): TJSONObject;
begin
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text :=  'SELECT kon.ID as Kontakte_ID ,a.Bezeichnung AS Anrede, kon.Vorname,kon.Nachname,' +
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
  dm_PCM.qry_Work.ParamByName('ID_Benutzer').AsInteger := StrToInt(AID_Benutzer);
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,rs_PCMAPPServer_Kontakteanzahl+ IntToStr(dm_PCM.qry_Work.RecordCount),0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Kontakte_ID').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Salutation', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Anrede').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Name', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Vorname').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Surname', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Nachname').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Street_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Strasse_Privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Postalcode_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('PLZ_Privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Place_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Ort_Privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Phone_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Telefon_Privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Mobile_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Handy_Privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Mail_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('E_mail_Privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Web_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Internet_privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Birthday', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Geburtsdatum').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Gender', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Geschlecht').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Maritalstatus', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Familienstand').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Nationality', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Staatsangehoerigkeit').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Denomination', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Konfession').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Company', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Firma').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Street_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Strasse_Ges').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Postalcode_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('PLZ_Ges').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Place_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Ort_Ges').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Phone_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Telefon_Ges').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Mobile_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Handy_Ges').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Mail_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('E_mail_Ges').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Web_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Internet_ges').asString)));
      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
end;
// Kontakte übernehmen
function SetKontakte_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
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
begin
  iZaehler:= 0;
  joResponseJSON := nil;
  jaDetails := nil;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Contacts');
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
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_kontakte WHERE ID = :ID and ID_Benutzer = :ID_Benutzer';
      dm_PCM.qry_Work.ParamByName('ID').asInteger := iID_Kontakt;
      dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger:= StrToInt(AID_Benutzer);
      dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
      // Check neue Datensatz
      dm_PCM.qry_Work.SQL.Text:=  'SELECT ID FROM manager_kontakte WHERE ID = :ID and ID_Benutzer = :ID_Benutzer';
      dm_PCM.qry_Work.ParamByName('ID').asInteger := iID_Kontakt;
      dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger:= StrToInt(AID_Benutzer);
      dm_PCM.qry_Work.Open;
      iSyncID:=dm_PCM.qry_Work.FieldByName('ID').AsInteger;
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
      if (dm_PCM.qry_Work.RecordCount = 0) or (iSyncID = 0) then
      begin
        if StrToDate(sGeburtsdatum) = StrToDate('30.12.1899')then
        begin
          dm_PCM.qry_Work.SQL.Text:=  'INSERT INTO manager_kontakte (ID_Anrede,Vorname,Nachname,Strasse_Privat,PLZ_Privat,Ort_Privat,Telefon_Privat,Handy_privat,E_Mail_Privat,ID_Geschlecht,' +
                                      'ID_Familienstand,ID_Staatsangehoerigkeit,ID_Konfession,Firma,Strasse_Ges,PLZ_Ges,Ort_Ges,Telefon_Ges,Handy_Ges,E_Mail_Ges,ID_Benutzer' +
                                      ') Values (:ID_Anrede,:Vorname,:Nachname,:Strasse_Privat,:PLZ_Privat,:Ort_Privat,:Telefon_Privat,:Handy_privat,:E_Mail_Privat,:ID_Geschlecht,' +
                                      ':ID_Familienstand,:ID_Staatsangehoerigkeit,:ID_Konfession,:Firma,:Strasse_Ges,:PLZ_Ges,:Ort_Ges,:Telefon_Ges,:Handy_Ges,:E_Mail_Ges,:ID_Benutzer)';
        end
        else begin

          dm_PCM.qry_Work.SQL.Text:=  'INSERT INTO manager_kontakte (ID_Anrede,Vorname,Nachname,Strasse_Privat,PLZ_Privat,Ort_Privat,Telefon_Privat,Handy_privat,E_Mail_Privat,Geburtsdatum,ID_Geschlecht,' +
                                      'ID_Familienstand,ID_Staatsangehoerigkeit,ID_Konfession,Firma,Strasse_Ges,PLZ_Ges,Ort_Ges,Telefon_Ges,Handy_Ges,E_Mail_Ges,ID_Benutzer' +
                                      ') Values (:ID_Anrede,:Vorname,:Nachname,:Strasse_Privat,:PLZ_Privat,:Ort_Privat,:Telefon_Privat,:Handy_privat,:E_Mail_Privat,:Geburtsdatum,:ID_Geschlecht,' +
                                      ':ID_Familienstand,:ID_Staatsangehoerigkeit,:ID_Konfession,:Firma,:Strasse_Ges,:PLZ_Ges,:Ort_Ges,:Telefon_Ges,:Handy_Ges,:E_Mail_Ges,:ID_Benutzer)';
          dm_PCM.qry_Work.ParamByName('Geburtsdatum').asDate:= StrToDate(sGeburtsdatum);
        end;
        dm_PCM.qry_Work.ParamByName('ID_Anrede').asInteger:= iID_Anrede;
        dm_PCM.qry_Work.ParamByName('Vorname').asString := sVorname;
        dm_PCM.qry_Work.ParamByName('Nachname').asString := sNachname;
        dm_PCM.qry_Work.ParamByName('Strasse_Privat').asString:= sStrasse_pri;
        dm_PCM.qry_Work.ParamByName('PLZ_Privat').asString:=sPlz_pri;
        dm_PCM.qry_Work.ParamByName('Ort_Privat').asString:=sOrt_pri;
        dm_PCM.qry_Work.ParamByName('Telefon_Privat').asString:= sTelefon_pri;
        dm_PCM.qry_Work.ParamByName('Handy_privat').asString:=sHandy_pri;
        dm_PCM.qry_Work.ParamByName('E_Mail_Privat').asString:= smail_pri;
        dm_PCM.qry_Work.ParamByName('ID_Geschlecht').asInteger:=iID_Geschlecht;
        dm_PCM.qry_Work.ParamByName('ID_Familienstand').asInteger:= iID_Familienstand;
        dm_PCM.qry_Work.ParamByName('ID_Staatsangehoerigkeit').asInteger:= iID_Staatsangehoerigkeit;
        dm_PCM.qry_Work.ParamByName('ID_Konfession').asInteger:= iID_Konfession;
        dm_PCM.qry_Work.ParamByName('Firma').asString:= sFirma;
        dm_PCM.qry_Work.ParamByName('Strasse_Ges').asString:=sStrasse_ges;
        dm_PCM.qry_Work.ParamByName('PLZ_Ges').asString:= sPLZ_ges;
        dm_PCM.qry_Work.ParamByName('Ort_Ges').asString:=sOrt_ges;
        dm_PCM.qry_Work.ParamByName('Telefon_Ges').asString:=sTelefon_ges;
        dm_PCM.qry_Work.ParamByName('Handy_Ges').asString:=sHandy_ges;
        dm_PCM.qry_Work.ParamByName('E_Mail_Ges').asString:=smail_ges;
        dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger:= StrToInt(AID_Benutzer);
        dm_PCM.qry_Work.ExecSQL;
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
end;
{$EndRegion Kontakte}
// Kalender
{$Region Kalender}
// Kalender ermitteln
function GetKalender_Intern(AID_Benutzer: string): TJSONObject;
begin
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text := 'Select ID as Kalender_ID,EventType,Caption,Location, Message,'+
                                        'if(Kalendername = "Geburtstag",Cast(CONCAT_WS("-", YEAR(NOW()),Month(Start) ,DAY(Start)) AS DATETIME),START) AS Start,'+
                                        'if(Kalendername = "Geburtstag",Cast(CONCAT_WS("-", YEAR(NOW()),Month(Finish) ,DAY(Finish)) AS DATETIME),Finish) AS Finish,'+
                                        'CompleteDay,Reminder,'+
                                        'if(Kalendername = "Geburtstag",CAST(CONCAT_WS(" ",CONCAT_WS("-", YEAR(NOW()),Month(ReminderDate) ,DAY(ReminderDate)), CONCAT_WS("-", Hour(ReminderDate),Minute(ReminderDate) ,Second(ReminderDate))) AS DATETIME),ReminderDate) AS ReminderDate,'+
                                        'ReminderMinutesBeforeStart, Kalendername,RecurrenceInfo,ID_KalenderApp, wiederholung_text FROM manager_kalender ' +
                                        'WHERE (RecurrenceInfo IS NOT NULL OR START >= DATE_ADD(now(), INTERVAL -30 DAY)) AND ID_Benutzer = :ID and bearbeitetam is null' ;
  dm_PCM.qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,rs_PCMAPPServer_Kalenderanzahl + IntToStr(dm_PCM.qry_Work.RecordCount),0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Kalender_ID').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('EventType', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('EventType').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Caption', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Caption').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Location', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Location').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Message', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Message').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Start', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Start').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Finish', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Finish').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('CompleteDay', TJSONBool.Create(dm_PCM.qry_Work.FieldByName('CompleteDay').AsBoolean)));
      joResponseJSONData.AddPair(TJSONPair.Create('Reminder', TJSONBool.Create(dm_PCM.qry_Work.FieldByName('Reminder').AsBoolean)));
      joResponseJSONData.AddPair(TJSONPair.Create('Reminderdate', TJSONString.Create(dm_PCM.qry_Work.FieldByName('reminderdate').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Reminderbeforestart', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('ReminderMinutesBeforeStart').asInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Calendername', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Kalendername').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('ID_Calenderapp', TJSONnumber.Create(dm_PCM.qry_Work.FieldByName('ID_KalenderApp').asInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Reccurrencetext', TJSONString.Create(dm_PCM.qry_Work.FieldByName('wiederholung_text').asString)));
      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
end;
// Kalender übernehmen
function SetKalender_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
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
begin
  joResponseJSON := nil;
  jaDetails := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Calendar');
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
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_kalender WHERE ID = :ID';
      dm_PCM.qry_Work.ParamByName('ID').AsInteger := iID_KalenderCal;
      dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
      // Check neue Datensatz
      dm_PCM.qry_Work.SQL.Text:=  'SELECT ID,LabelColor,FontColor FROM manager_kalender WHERE ID = :ID_Kalender';
      dm_PCM.qry_Work.ParamByName('ID_Kalender').asInteger := iID_KalenderCal;
      dm_PCM.qry_Work.Open;
      if dm_PCM.qry_Work.RecordCount = 0 then
      begin
        sStartCal:= FormatDateTimeToStr(StrToDateTime(sStartDateCal));
        sFinishCal:=FormatDateTimeToStr(StrToDateTime(sFinishDateCal));
        dm_PCM.qry_Work.SQL.Text:=  'SELECT ID,LabelColor,FontColor  FROM manager_kalender WHERE ' +
                                    'Caption = :Caption and START = :Start and Finish = :Finish';
        dm_PCM.qry_Work.ParamByName('Caption').asString := sCaptionCal;
        dm_PCM.qry_Work.ParamByName('Start').asDateTime := StrToDateTime(sStartDateCal);
        dm_PCM.qry_Work.ParamByName('Finish').asDateTime := StrToDateTime(sFinishDateCal);
        dm_PCM.qry_Work.Open;
        if dm_PCM.qry_Work.RecordCount = 0 then
        begin
          dm_PCM.qry_Work.SQL.Text:= 'INSERT INTO manager_kalender(Caption,EventType,Location,Message,' +
                                     'START,Finish,CompleteDay,Reminder,ReminderDate,ReminderMinutesBeforeStart,' +
                                     'ID_Benutzer,Kalendername,LabelColor,FontColor,ID_KalenderAPP) VALUES (:Caption,:EventType,' +
                                     ':Location,:Message,:START,:Finish,:CompleteDay,:Reminder,:ReminderDate,' +
                                     ':ReminderMinutesBeforeStart,:ID_Benutzer,:Kalendername,:LabelColor,:FontColor,:ID_KalenderAPP)';
          dm_PCM.qry_Work.ParamByName('Caption').AsString:= sCaptionCal;
          dm_PCM.qry_Work.ParamByName('EventType').AsInteger:= iEventTypeCal;
          dm_PCM.qry_Work.ParamByName('Location').AsString:= sLocationCal;
          dm_PCM.qry_Work.ParamByName('Message').AsString:= sMessageCal;
          dm_PCM.qry_Work.ParamByName('START').asDateTime:= StrToDateTime(sStartDateCal);
          dm_PCM.qry_Work.ParamByName('Finish').asDateTime:= StrToDateTime(sFinishDateCal);
          dm_PCM.qry_Work.ParamByName('ID_KalenderAPP').asInteger:= iIDCal;
          if bCompleteDayCal then
            dm_PCM.qry_Work.ParamByName('CompleteDay').AsString:= 'true'
          else
            dm_PCM.qry_Work.ParamByName('CompleteDay').AsString:= 'false';
          if bReminderCal then
            dm_PCM.qry_Work.ParamByName('Reminder').AsString:= 'true'
          else
            dm_PCM.qry_Work.ParamByName('Reminder').AsString:= 'false';
          if (bReminderCal) and (sReminderDateCal = '') then
            sReminderDateCal := DateTimeToStr(IncMinute(StrToDateTime(sStartDateCal),-iReminderMinutesBeforeStartCal));
          dm_PCM.qry_Work.ParamByName('ReminderDate').asDateTime:= StrToDateTime(sReminderDateCal);
          dm_PCM.qry_Work.ParamByName('ReminderMinutesBeforeStart').AsInteger:= iReminderMinutesBeforeStartCal;
          dm_PCM.qry_Work.ParamByName('ID_Benutzer').AsInteger:= StrToInt(AID_Benutzer);
          dm_PCM.qry_Work.ParamByName('Kalendername').AsString:= sKalendernameCal;
          dm_PCM.qry_Work.ParamByName('LabelColor').AsInteger:= 13083265;
          dm_PCM.qry_Work.ParamByName('FontColor').AsInteger:= 0;
          dm_PCM.qry_Work.ExecSQL;
        end
        else begin
          iSyncID:= dm_PCM.qry_Work.FieldByName('ID').asInteger;
          iFontColorCal:= dm_PCM.qry_Work.FieldByName('FontColor').AsInteger;
          iLabelColorCal:= dm_PCM.qry_Work.FieldByName('LabelColor').AsInteger;
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
       iSyncID:= dm_PCM.qry_Work.FieldByName('ID').asInteger;
        iFontColorCal:= dm_PCM.qry_Work.FieldByName('FontColor').AsInteger;
        iLabelColorCal:= dm_PCM.qry_Work.FieldByName('LabelColor').AsInteger;
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
end;
{$EndRegion Kalender}
// Passwörter
{$Region Passwords}
// Passwörter ermitteln
function GetPasswoerter_Intern(AID_Benutzer: string): TJSONObject;
begin
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text :=  'SELECT pw.id AS passwoerter_ID,pw.Bezeichnung,pw.user,pw.password,pw.link,pw.VPN_SharedSecret, ' +
                                         'pw.APP_IP,ifnull(pw.APP_Port,0) as APP_port,pw.APP_Verschluesselung,pw.MAIL_Posteingangsserver,ifnull(pw.MAIL_PosteingangsPort,0) as MAIL_PosteingangsPort, ' +
                                         'pw.MAIL_PosteingangsVerschluesselung,pw.MAIL_Postausgangsserver,ifnull(pw.MAIL_PostausgangsPort,0) as MAIL_PostausgangsPort, ' +
                                         'pw.MAIL_PostausgangsVerschluesselung,pwt.Bezeichnung as pwtyp,pw.Wlan ' +
                                         'From manager_passwoerter pw ' +
                                         'LEFT OUTER JOIN manager_passwoerter_typ pwt ON pw.ID_Typ = pwt.ID ' +
                                         'Where ID_Benutzer = :ID';
  dm_PCM.qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,rs_PCMAPPServer_Passwordanzahl + IntToStr(dm_PCM.qry_Work.RecordCount),0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('passwoerter_ID').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Passwordname', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Bezeichnung').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('User', TJSONString.Create(dm_PCM.qry_Work.FieldByName('user').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Password', TJSONString.Create(dm_PCM.qry_Work.FieldByName('password').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Link', TJSONString.Create(dm_PCM.qry_Work.FieldByName('link').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('VPN_SharedSecret', TJSONString.Create(dm_PCM.qry_Work.FieldByName('VPN_SharedSecret').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('APP_IP', TJSONString.Create(dm_PCM.qry_Work.FieldByName('APP_IP').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('APP_Port', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('APP_Port').asInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('APP_Encryption', TJSONString.Create(dm_PCM.qry_Work.FieldByName('APP_Verschluesselung').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Incomingmail_Server', TJSONString.Create(dm_PCM.qry_Work.FieldByName('MAIL_Posteingangsserver').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Incomingmail_Port', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('MAIL_PosteingangsPort').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Incomingmail_Encryption', TJSONString.Create(dm_PCM.qry_Work.FieldByName('MAIL_PosteingangsVerschluesselung').AsString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Outgoingmail_Server', TJSONString.Create(dm_PCM.qry_Work.FieldByName('MAIL_Postausgangsserver').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Outgoingmail_Port', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('MAIL_PostausgangsPort').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Outgoingmail_Encryption', TJSONString.Create(dm_PCM.qry_Work.FieldByName('MAIL_PostausgangsVerschluesselung').AsString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Passwordtype', TJSONString.Create(dm_PCM.qry_Work.FieldByName('pwtyp').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Wlankey', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Wlan').asString)));
      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
end;
// Passwörter übernehmen
function SetPasswoerter_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
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
begin
  joResponseJSON := nil;
  jaDetails := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Passwords');
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
      dm_PCM.qry_Work.SQL.Text:=  'Delete FROM manager_passwoerter WHERE ID = :ID';
      dm_PCM.qry_Work.ParamByName('ID').asInteger := iID_PasswordPWD;
      dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
      // Check neue Datensatz
      dm_PCM.qry_Work.SQL.Text:=  'SELECT ID FROM manager_passwoerter WHERE ID = :ID';
      dm_PCM.qry_Work.ParamByName('ID').asInteger := iID_PasswordPWD;
      dm_PCM.qry_Work.Open;
      iSyncID:= dm_PCM.qry_Work.FieldByName('ID').AsInteger;
      iID_TypPWD:= -1;
      // Typ
      if sPasswordtypePWD <> '' then
      begin
        iID_TypPWD:= GetIDFromTable('manager_passwoerter_typ',sPasswordtypePWD);
      end;
      if dm_PCM.qry_Work.RecordCount = 0 then
      begin
        dm_PCM.qry_Work.SQL.Text:= 'INSERT INTO  manager_passwoerter (Bezeichnung,user,password,link,ID_benutzer,' +
											 'VPN_SharedSecret,APP_IP,APP_Port,APP_Verschluesselung,MAIL_Posteingangsserver,' +
											 'MAIL_PosteingangsPort,MAIL_PosteingangsVerschluesselung,MAIL_Postausgangsserver,' +
											 'MAIL_PostausgangsPort,MAIL_PostausgangsVerschluesselung,ID_Typ,WLAN) Values (' +
											 ':Bezeichnung,:user,:password,:link,:ID_benutzer,:VPN_SharedSecret,:APP_IP,:APP_Port,' +
											 ':APP_Verschluesselung,:MAIL_Posteingangsserver,:MAIL_PosteingangsPort,' +
											 ':MAIL_PosteingangsVerschluesselung,:MAIL_Postausgangsserver,:MAIL_PostausgangsPort,' +
											 ':MAIL_PostausgangsVerschluesselung,:ID_Typ,:WLAN)';
        dm_PCM.qry_Work.ParamByName('Bezeichnung').asString:= sPasswordnamePWD;
        dm_PCM.qry_Work.ParamByName('user').asString:= sUserPWD;
        dm_PCM.qry_Work.ParamByName('password').asString:= spasswordPWD;
        dm_PCM.qry_Work.ParamByName('link').asString:= slinkPWD;
        dm_PCM.qry_Work.ParamByName('ID_benutzer').asInteger:= StrToInt(AID_Benutzer);
        dm_PCM.qry_Work.ParamByName('VPN_SharedSecret').asString:= sVPN_SharedSecretPWD;
        dm_PCM.qry_Work.ParamByName('APP_IP').asString:= sAPP_IPPWD;
        dm_PCM.qry_Work.ParamByName('APP_Port').asInteger:= iAPP_PortPWD;
        dm_PCM.qry_Work.ParamByName('APP_Verschluesselung').asString:= sAPP_EncryptionPWD;
        dm_PCM.qry_Work.ParamByName('MAIL_Posteingangsserver').asString:= sIncomingmail_ServerPWD;
        dm_PCM.qry_Work.ParamByName('MAIL_PosteingangsPort').asInteger:= iIncomingmail_PortPWD;
        dm_PCM.qry_Work.ParamByName('MAIL_PosteingangsVerschluesselung').asString:= sIncomingmail_EncryptionPWD;
        dm_PCM.qry_Work.ParamByName('MAIL_Postausgangsserver').asString:= sOutgoingmail_ServerPWD;
        dm_PCM.qry_Work.ParamByName('MAIL_PostausgangsPort').asInteger:= iOutgoingmail_PortPWD;
        dm_PCM.qry_Work.ParamByName('MAIL_PostausgangsVerschluesselung').asString:= sOutgoingmail_EncryptionPWD;
        dm_PCM.qry_Work.ParamByName('ID_Typ').asInteger:= iID_TypPWD;
        dm_PCM.qry_Work.ParamByName('WLAN').asString:= sWlankeyPWD;
        dm_PCM.qry_Work.ExecSQL;
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
end;
{$EndRegion Passwords}
// Serials
{$Region Serials}
// Serials ermitteln
function GetSerials_Intern(AID_Benutzer: string): TJSONObject;
begin
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text := 'SELECT s.ID as Serials_ID,s.App AS Bezeichnung, sk.USER AS benutzer, ' +
                                        'sk.Serial AS serialkey, st.Bezeichnung as Typ ' +
                                        'FROM manager_serials S ' +
                                        'LEFT OUTER JOIN Manager_Serials_keys sk ON sk.ID_Serial = s.ID ' +
                                        'LEFT OUTER JOIN Manager_Serials_typ st ON st.ID = s.ID_TYp ' +
                                        'WHERE s.ID_Benutzer = :ID';
  dm_PCM.qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,rs_PCMAPPServer_Serialsanzahl + IntToStr(dm_PCM.qry_Work.RecordCount),0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Serials_ID').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Serialname', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Bezeichnung').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('User', TJSONString.Create(dm_PCM.qry_Work.FieldByName('benutzer').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Serialkey', TJSONString.Create(dm_PCM.qry_Work.FieldByName('serialkey').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('SerialType', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Typ').asString)));
      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
end;
// Serials übernehmen
function SetSerials_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
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
begin
  joResponseJSON := nil;
  jaDetails := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Serials');
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
      dm_PCM.qry_Work.SQL.Text:= 'SELECT ID FROM manager_Serials WHERE  ID = :ID_Serials';
      dm_PCM.qry_Work.ParamByName('ID_Serials').AsInteger := iID_Serials;
      dm_PCM.qry_Work.open;
      iID_Serial:= dm_PCM.qry_Work.FieldByName('ID').asInteger;
      dm_PCM.qry_Work.Close;
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_serials_keys WHERE ID_Serial = :ID_Serial';
      dm_PCM.qry_Work.ParamByName('ID_Serial').AsInteger := iID_Serial;
      dm_PCM.qry_Work.ExecSQL;
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_serials WHERE ID = :ID_Serial';
      dm_PCM.qry_Work.ParamByName('ID_Serial').AsInteger := iID_Serial;
      dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
      dm_PCM.qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_Serials WHERE ID = :ID_Serials';
      dm_PCM.qry_Work.ParamByName('ID_Serials').AsInteger := iID_Serials;
      dm_PCM.qry_Work.Open;
      iAnzahl:= dm_PCM.qry_Work.FieldByName('Anzahl').asInteger;
      dm_PCM.qry_Work.Close;
      iID_Typ:= -1;
      // Typ
      if sSerialType <> '' then
      begin
        iID_Typ:= GetIDFromTable('manager_serials_typ',sSerialType);
      end;
      if iAnzahl = 0 then
      begin
        dm_PCM.qry_Work.SQL.Text:=  'INSERT INTO manager_Serials (App,ID_Benutzer,id_typ' +
                                                ') Values (:App,:ID_Benutzer,:id_typ)';
        dm_PCM.qry_Work.ParamByName('App').AsString:= sSerialname;
        dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger:=StrToInt(AID_Benutzer);
        dm_PCM.qry_Work.ParamByName('id_typ').asInteger:= iID_Typ;
        dm_PCM.qry_Work.ExecSQL;
        dm_PCM.qry_Work.SQL.Text:= 'SELECT ID FROM manager_Serials WHERE  APP = :APP';
        dm_PCM.qry_Work.ParamByName('App').asString := sSerialname;
        dm_PCM.qry_Work.open;
        iID_Serial:= dm_PCM.qry_Work.FieldByName('ID').asInteger;
        dm_PCM.qry_Work.Close;
        dm_PCM.qry_Work.SQL.Text:=  'INSERT INTO manager_serials_keys (User,Serial,ID_Serial' +
                                                ') Values (:User,:serial,:ID_Serial)';
        dm_PCM.qry_Work.ParamByName('User').AsString:= sUser;
        dm_PCM.qry_Work.ParamByName('Serial').AsString:= sSerialkey;
        dm_PCM.qry_Work.ParamByName('ID_Serial').asInteger:=iID_Serial;
        dm_PCM.qry_Work.ExecSQL;
      end
      else
      begin
        dm_PCM.qry_Work.SQL.Text:= 'SELECT ID FROM manager_Serials WHERE  APP = :APP';
        dm_PCM.qry_Work.ParamByName('App').asString := sSerialname;
        dm_PCM.qry_Work.open;
        iID_Serial:= dm_PCM.qry_Work.FieldByName('ID').asInteger;
        dm_PCM.qry_Work.Close;
  			dm_PCM.qry_Work.SQL.Text:=  'Update manager_Serials SET id_typ = :id_typ ' +
                                              'Where App = :App';
        dm_PCM.qry_Work.ParamByName('APP').AsString:= sSerialname;
        dm_PCM.qry_Work.ParamByName('id_typ').AsInteger:= iID_typ;
        dm_PCM.qry_Work.ExecSQL;
  			dm_PCM.qry_Work.SQL.Text:=  'Update manager_serials_keys SET user = :user, serial = :serial  ' +
                                              'Where ID_Serial = :ID_Serial';
        dm_PCM.qry_Work.ParamByName('ID_Serial').AsInteger:= iID_Serial;
        dm_PCM.qry_Work.ParamByName('serial').AsString:= sSerialkey;
        dm_PCM.qry_Work.ParamByName('user').AsString := suser;
        dm_PCM.qry_Work.ExecSQL;
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
end;
{$EndRegion Serials}
// Einnahmen
{$Region Ein}
// Einnahmen ermitteln
function GetEinnahmen_Intern(AID_Benutzer: string): TJSONObject;
begin         //  Receipts
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text :=  'SELECT ID AS Finanzen_Einnahmen_ID, Quelle, Betrag, Bezeichnung, FixBetrag ' +
                                         'FROM manager_finanzen_Einnahmen Where ID_Benutzer = :ID';
  dm_PCM.qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,rs_PCMAPPServer_Einnahmenanzahl + IntToStr(dm_PCM.qry_Work.RecordCount),0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Finanzen_Einnahmen_ID').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Transmitter', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Quelle').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Amount', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Betrag').AsFloat)));
      joResponseJSONData.AddPair(TJSONPair.Create('Description', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Bezeichnung').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Fixedamount', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('FixBetrag').asFloat)));
      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
end;
// Einnnahmen übernehmen
function SetEinnahmen_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
var
  iID: Integer;
  sTransmitter: String;
  fAmount: double;
  sDescription: String;
  fFixedamount: double;
  iID_Receipts: Integer;
  bDeleted: boolean;
  iSyncID: Integer;
begin
  joResponseJSON := nil;
  jaDetails := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Receipts');
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
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_finanzen_einnahmen WHERE ID = :iID_Receipts';
      dm_PCM.qry_Work.ParamByName('iID_Receipts').asInteger := iID_Receipts;
      dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
      // Check neue Datensatz
      dm_PCM.qry_Work.SQL.Text:=  'SELECT ID FROM manager_finanzen_einnahmen WHERE ID = :ID';
      dm_PCM.qry_Work.ParamByName('ID').asInteger := iID_Receipts;
      dm_PCM.qry_Work.Open;
      if dm_PCM.qry_Work.RecordCount = 0 then
      begin
        dm_PCM.qry_Work.SQL.Text:=  'INSERT INTO manager_finanzen_einnahmen (Quelle,Betrag,Bezeichnung,ID_Benutzer,FixBetrag' +
                                                ') Values (:Quelle,:Betrag,:Bezeichnung,:ID_Benutzer,:FixBetrag)';
        dm_PCM.qry_Work.ParamByName('Quelle').AsString:= sTransmitter;
        dm_PCM.qry_Work.ParamByName('Betrag').asFloat := fAmount;
        dm_PCM.qry_Work.ParamByName('FixBetrag').asFloat := fFixedAmount;
        dm_PCM.qry_Work.ParamByName('Bezeichnung').asString := sDescription;
        dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger:=StrToInt(AID_Benutzer);
        dm_PCM.qry_Work.ExecSQL;
      end
      else
      begin
        iSyncID:= dm_Pcm.qry_Work.FieldByName('ID').AsInteger;
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
end;
{$EndRegion Ein}
// Ausgaben
{$Region Aus}
// Ausgaben ermitteln
function GetAusgaben_Intern(AID_Benutzer: string): TJSONObject;
begin             //Expenditure
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text :=  'SELECT id as Finanzen_Ausgaben_ID, Name,Beschreibung,Kontonummer,Bankleitzahl,Betrag,Fixkosten,Gueltig_Monat,Gueltig_Jahr,Verwendungszweck,FixBetrag ' +
                                         'FROM manager_finanzen_ausgaben Where ID_Benutzer = :ID';
  dm_PCM.qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,rs_PCMAPPServer_Ausgabenanzahl + IntToStr(dm_PCM.qry_Work.RecordCount),0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Finanzen_Ausgaben_ID').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Receiver', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Name').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Description', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Beschreibung').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Accountnumber', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Kontonummer').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Bankcode', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Bankleitzahl').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Amount', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Betrag').AsFloat)));
      joResponseJSONData.AddPair(TJSONPair.Create('Fixedcosts', TJSonBool.Create(dm_PCM.qry_Work.FieldByName('Fixkosten').AsBoolean)));
      joResponseJSONData.AddPair(TJSONPair.Create('Validmonth', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Gueltig_Monat').asInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Validyear', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Gueltig_Jahr').asInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Use', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Verwendungszweck').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Fixedamount', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('FixBetrag').asFloat)));
      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
end;
// Ausgaben übernehmen
function SetAusgaben_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
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
begin
  joResponseJSON := nil;
  jaDetails := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Expenditure');
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
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_finanzen_Ausgaben WHERE ID = :ID';
      dm_PCM.qry_Work.ParamByName('ID').AsInteger := iID_Expenditure;
      dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
      // Check neue Datensatz
      dm_PCM.qry_Work.SQL.Text:=  'SELECT ID FROM manager_finanzen_Ausgaben WHERE ID = :ID';
      dm_PCM.qry_Work.ParamByName('ID').AsInteger := iID_Expenditure;
      dm_PCM.qry_Work.Open;
      if dm_PCM.qry_Work.RecordCount = 0 then
      begin
        dm_PCM.qry_Work.SQL.Text:=  'INSERT INTO manager_finanzen_Ausgaben (Name,Beschreibung,Kontonummer,Bankleitzahl,Betrag,Fixkosten,Gueltig_Monat,Gueltig_Jahr,ID_Benutzer,Verwendungszweck,FixBetrag' +
                                    ') Values (:Name,:Beschreibung,:Kontonummer,:Bankleitzahl,:Betrag,:Fixkosten,:Gueltig_Monat,:Gueltig_Jahr,:ID_Benutzer,:Verwendungszweck,:FixBetrag)';
        dm_PCM.qry_Work.ParamByName('Name').AsString:= sReceiver;
        dm_PCM.qry_Work.ParamByName('Beschreibung').asString := sDescription;
        dm_PCM.qry_Work.ParamByName('Kontonummer').asString := sAccountnumber;
        dm_PCM.qry_Work.ParamByName('Bankleitzahl').asString := sBankcode;
        dm_PCM.qry_Work.ParamByName('Betrag').asFloat := fAmount;
        dm_PCM.qry_Work.ParamByName('FixBetrag').asFloat := fFixedamount;
        if bFixedcosts then
          dm_PCM.qry_Work.ParamByName('Fixkosten').asString := 'true'
        else
          dm_PCM.qry_Work.ParamByName('Fixkosten').AsString := 'false';
        dm_PCM.qry_Work.ParamByName('Gueltig_Monat').AsInteger := iValidmonth;
        dm_PCM.qry_Work.ParamByName('Gueltig_Jahr').AsInteger := iValidyear;
        dm_PCM.qry_Work.ParamByName('Verwendungszweck').asString := sUse;
        dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger:=StrToInt(AID_Benutzer);
        dm_PCM.qry_Work.ExecSQL;
      end
      else
      begin
        iSyncID:= dm_Pcm.qry_Work.FieldByName('ID').AsInteger;
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
end;
{$EndRegion Aus}
// Belege
{$Region Belege}
// Belege ermitteln
function GetVouchers_Intern(AID_Benutzer: string): TJSONObject;
begin
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text :=  'SELECT ID AS Finanzen_Belege_ID, Nummer, Datum, Aussteller, Betrag, Kategorie, ifnull(Jahr,0) as Jahr, ifnull(Monat,0) as Monat ' +
                                         'FROM manager_finanzen_Belege Where ID_Benutzer = :ID';
  dm_PCM.qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,rs_PCMAPPServer_Einnahmenanzahl + IntToStr(dm_PCM.qry_Work.RecordCount),0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Finanzen_Belege_ID').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Number', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Nummer').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Date', TJSONString.Create(DateToStr(dm_PCM.qry_Work.FieldByName('Datum').AsDateTime))));
      joResponseJSONData.AddPair(TJSONPair.Create('Exhibitor', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Aussteller').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Amount', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Betrag').asFloat)));
      joResponseJSONData.AddPair(TJSONPair.Create('Categorie', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Kategorie').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Month', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Monat').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Year', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Jahr').AsInteger)));


      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
end;
// Belege übernehmen
function SetVouchers_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
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
begin

  joResponseJSON := nil;
  jaDetails := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Vouchers');
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
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_finanzen_belege WHERE ID = :iID_Receipts';
      dm_PCM.qry_Work.ParamByName('iID_Receipts').asInteger := iID_Vouchers;
      dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
      // Check neue Datensatz
      dm_PCM.qry_Work.SQL.Text:=  'SELECT ID FROM manager_finanzen_belege WHERE ID = :ID';
      dm_PCM.qry_Work.ParamByName('ID').asInteger := iID_Vouchers;
      dm_PCM.qry_Work.Open;
      if dm_PCM.qry_Work.RecordCount = 0 then
      begin
        dm_PCM.qry_Work.SQL.Text:=  'INSERT INTO manager_finanzen_belege (Nummer,Datum,Aussteller,Betrag,Kategorie,Monat,Jahr,ID_Benutzer' +
                                    ') Values (:Nummer,:Datum,:Aussteller,:Betrag,:Kategorie,:Monat,:Jahr,:ID_Benutzer)';
        dm_PCM.qry_Work.ParamByName('Nummer').AsString:= sNumber;
        dm_PCM.qry_Work.ParamByName('Datum').AsDate:= StrToDate(sDate);
        dm_PCM.qry_Work.ParamByName('Aussteller').AsString:= sExhibitor;
        dm_PCM.qry_Work.ParamByName('Betrag').asFloat := famount;
        dm_PCM.qry_Work.ParamByName('Kategorie').asInteger := iID_Categorie;
        dm_PCM.qry_Work.ParamByName('Monat').asInteger := iMonth;
        dm_PCM.qry_Work.ParamByName('Jahr').asInteger := iYear;
        dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger:=StrToInt(AID_Benutzer);
        dm_PCM.qry_Work.ExecSQL;
      end
      else
      begin
        iSyncID:= dm_Pcm.qry_Work.FieldByName('ID').AsInteger;
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
end;
{$EndRegion Belege}
// Gutscheine
{$Region Gutscheine}
// Gutscheine ermitteln
function GetGiftCards_Intern(AID_Benutzer: string): TJSONObject;
begin         //  Receipts
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text :=  'SELECT ID AS Finanzen_Gutschein_ID, Nummer, Bezeichnung, Datum, Wert, RestWert, Abfragepin ' +
                                         'FROM manager_finanzen_Gutschein Where ID_Benutzer = :ID';
  dm_PCM.qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,rs_PCMAPPServer_Einnahmenanzahl + IntToStr(dm_PCM.qry_Work.RecordCount),0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Finanzen_Gutschein_ID').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Number', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Nummer').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Description', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Bezeichnung').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Date', TJSONString.Create(DatetoStr(dm_PCM.qry_Work.FieldByName('Datum').AsDateTime))));
      joResponseJSONData.AddPair(TJSONPair.Create('Value', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Wert').AsFloat)));
      joResponseJSONData.AddPair(TJSONPair.Create('Remaining_value', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('RestWert').asFloat)));
      joResponseJSONData.AddPair(TJSONPair.Create('Pincode', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Abfragepin').AsString)));

      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
end;
// Gutscheine übernehmen
function SetGiftCards_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
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
begin
  try
  joResponseJSON := nil;
  jaDetails := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Giftcards');
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
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_finanzen_gutschein WHERE ID = :iID_Receipts';
      dm_PCM.qry_Work.ParamByName('iID_Receipts').asInteger := iID_Giftcards;
      dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
      // Check neue Datensatz
      dm_PCM.qry_Work.SQL.Text:=  'SELECT ID FROM manager_finanzen_gutschein WHERE ID = :ID';
      dm_PCM.qry_Work.ParamByName('ID').asInteger := iID_Giftcards;
      dm_PCM.qry_Work.Open;
      if dm_PCM.qry_Work.RecordCount = 0 then
      begin
        dm_PCM.qry_Work.SQL.Text:=  'INSERT INTO manager_finanzen_gutschein (Nummer,Bezeichnung,Wert,RestWert,Datum,AbfragePin,ID_Benutzer' +
                                    ') Values (:Nummer,:Bezeichnung,:Wert,:RestWert,:Datum,:AbfragePin,:ID_Benutzer)';
        dm_PCM.qry_Work.ParamByName('Nummer').AsString:= sNumber;
        dm_PCM.qry_Work.ParamByName('Datum').AsDate := StrToDate(sDate);
        dm_PCM.qry_Work.ParamByName('Bezeichnung').asString := sDescription;
        dm_PCM.qry_Work.ParamByName('Wert').asFloat := fValue;
        dm_PCM.qry_Work.ParamByName('RestWert').asFloat := fRemaining_value;
        dm_PCM.qry_Work.ParamByName('AbfragePin').asString := sPincode;
        dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger:=StrToint(AID_Benutzer);
        dm_PCM.qry_Work.ExecSQL;
      end
      else
      begin
        iSyncID:= dm_PCM.qry_Work.FieldByName('ID').AsInteger;
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
  except
    on e:Exception do
      WriteLog(PCM_Logname,'SetGutschein:' + e.Message,2);
  end;
end;
{$EndRegion Gutscheine}
{$EndRegion APPapi}
{$Region TimeAPPapi}
function GetContactsZE_Intern(AID_Benutzer: string): TJSONObject;
begin
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text :=  'SELECT kon.ID as Kontakte_ID ,a.Bezeichnung AS Anrede, kon.Vorname,kon.Nachname,' +
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
                               'LEFT OUTER JOIN time_Konfession k ON k.ID = kon.ID_Konfession Where kon.ID_Zeiterfasser = :ID_Benutzer';
  dm_PCM.qry_Work.ParamByName('ID_Benutzer').AsInteger := StrToInt(AID_Benutzer);
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,rs_PCMAPPServer_Kontakteanzahl+ IntToStr(dm_PCM.qry_Work.RecordCount),0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Kontakte_ID').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Salutation', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Anrede').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Name', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Vorname').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Surname', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Nachname').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Street_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Strasse_Privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Postalcode_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('PLZ_Privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Place_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Ort_Privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Phone_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Telefon_Privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Mobile_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Handy_Privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Mail_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('E_mail_Privat').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Web_private', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Link').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Birthday', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Geburtsdatum').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Gender', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Geschlecht').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Maritalstatus', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Familienstand').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Nationality', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Staatsangehoerigkeit').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Denomination', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Konfession').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Company', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Firma').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Street_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Strasse_Ges').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Postalcode_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('PLZ_Ges').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Place_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Ort_Ges').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Phone_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Telefon_Ges').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Mobile_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Handy_Ges').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Mail_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('E_mail_Ges').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Web_business', TJSONString.Create(dm_PCM.qry_Work.FieldByName('LinkFirma').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Vacation',TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Urlaub').AsFloat)));
      joResponseJSONData.AddPair(TJSONPair.Create('Entrance',TJSONString.Create(DateToStr(dm_PCM.qry_Work.FieldByName('Eintritt').AsDateTime))));
      joResponseJSONData.AddPair(TJSONPair.Create('OffsetRemaining_vacation',TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('OffsetResturlaub').AsFloat)));
      joResponseJSONData.AddPair(TJSONPair.Create('OffsetRemaining_vacation_toYear',TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('OffsetResturlaubJahr').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Personnel_number',TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Personalnummer').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Planned_hours',TJSONString.Create(TimeToStr(dm_PCM.qry_Work.FieldByName('Sollstunden').AsDateTime))));
      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
  WriteLog(PCM_Logname,'Personaldaten ermitteln',0);
end;
function GetLastBooking_Intern(AID_Benutzer: String): TJSONObject;
begin
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text :=  'SELECT Text FROM time_message ';
//  dm_PCM.qry_Work.ParamByName('ID').AsInteger := StrToInt(AID_Benutzer);
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,'Letzte Buchung ermitteln',0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('LastBooking', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Text').asString)));
      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
end;
function SetLastBooking_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
var
  iZaehler,
  iAnzahl: integer;
  sLastBooking: String;
begin
  joResponseJSON := nil;
  jaDetails := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('LastBooking');
  for var JSonValue in jaDetails do
  begin
    JSonValue.TryGetValue<string>('LastBooking',sLastBooking);
    dm_PCM.qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_message ';
    dm_PCM.qry_Work.Open;
    iAnzahl:= dm_PCM.qry_Work.FieldByName('Anzahl').asInteger;
    dm_PCM.qry_Work.Close;
    if iAnzahl = 0 then
    begin
      dm_PCM.qry_Work.SQL.Text:=  'INSERT INTO time_message (Text) Values (:Text)';
      dm_PCM.qry_Work.ParamByName('Text').AsString:= sLastBooking;
      dm_PCM.qry_Work.ExecSQL;
    end
    else begin
      dm_PCM.qry_Work.SQL.Text:=  'Update time_message SET Text = :Text';
      dm_PCM.qry_Work.ParamByName('Text').AsString:= sLastBooking;
      dm_PCM.qry_Work.ExecSQL;
    end;
  end;
  WriteLog(PCM_Logname,'Letzte Buchung aktualisieren' + IntToStr(iZaehler),0);
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
  joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
  joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
  Result := joResponseJSON;
end;
function GetBookingYear_Intern(AID_Benutzer,AJahr: string): TJSONObject;
var
  wJahr,wMonat,wTag: Word;
begin
  DecodeDate(Date,wJahr,wMonat,wTag);
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text :=  'SELECT ID, Datum, Tag, Kommen, Gehen, Pause1Beginn,Pause1Ende,' +
                               'Pause2Beginn,Pause2Ende,Sollstunden,SollstundenI,Arbeitszeit,ArbeitszeitI,' +
                               'Feiertag,Fehltag,Mehrarbeit,MehrarbeitI,Pauseni,FeiertagI,' +
                               'IFNULL(Abgeschlossen,0) AS Abgeschlossen,Buchungsart, IFNULL(ID_Fehltage,0) AS ID_Fehltage ' +
                               'FROM time_buchungen Where Datum >= :Von and Datum <= :Bis';
  dm_PCM.qry_Work.ParamByName('Von').AsDate:= StartOfAMonth(StrtoInt(AJahr),1);
  dm_PCM.qry_Work.ParamByName('Bis').AsDate:= EndOfAMonth(StrtoInt(AJahr),12);
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,'Kontakte vom Server laden',0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('ID').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Date', TJSONString.Create(DateToStr(dm_PCM.qry_Work.FieldByName('Datum').AsDateTime))));
      joResponseJSONData.AddPair(TJSONPair.Create('Day', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Tag').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Work_begin', TJSONString.Create(TimeToStr(dm_PCM.qry_Work.FieldByName('Kommen').AsDateTime))));
      joResponseJSONData.AddPair(TJSONPair.Create('Work_end', TJSONString.Create(TimeToStr(dm_PCM.qry_Work.FieldByName('Gehen').AsDateTime))));
      joResponseJSONData.AddPair(TJSONPair.Create('Break1_begin', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Pause1Beginn').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Break1_end', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Pause1Ende').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Break2_begin', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Pause2Beginn').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Break2_end', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Pause2Ende').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Planned_hours_Time', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Sollstunden').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Planned_hours_Integer', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Sollstundeni').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Working_time_Time', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Arbeitszeit').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Working_time_Integer', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Arbeitszeiti').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Holiday', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Feiertag').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Absence_day', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Fehltag').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Overtime_Time', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Mehrarbeit').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Overtime_Integer', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Mehrarbeiti').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Break_Integer', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Pauseni').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Holiday_Integer', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Feiertagi').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Complete', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Abgeschlossen').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Booking_type', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Buchungsart').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('ID_Absence_day', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('ID_Fehltage').AsInteger)));
      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
end;
function GetAbsenceconfig_Intern(AID_Benutzer: string): TJSONObject;
begin
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text :=  'SELECT * FROM time_fehltag';
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,'Fehltagekonfiguration laden',0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('ID').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Code', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Kuerzel').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Description', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Beschreibung').AsString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Type', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Typ').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Factor', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Faktor').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Paid', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Bezahlt').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('Subtract', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('SollAbziehen').AsInteger)));
      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
end;
function GetAbsence_Intern(AID_Benutzer: string): TJSONObject;
begin
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text :=  'SELECT * FROM time_fehltage';
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,'Fehltage laden',0);
  if dm_PCM.qry_Work.RecordCount > 0 then
  begin
    iCode:= 200;
    sMessage:= 'OK';
    joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
    joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
    joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
    if not Assigned(jaDetails) then
      jaDetails := TJSONArray.Create;
    while not dm_PCM.qry_work.eof do
    begin
      if not Assigned(joResponseJSONData) then
        joResponseJSONData := TJSONObject.Create;
      joResponseJSONData.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('ID').AsInteger)));
      joResponseJSONData.AddPair(TJSONPair.Create('From', TJSONString.Create(DateToStr(dm_PCM.qry_Work.FieldByName('Von').AsDateTime))));
      joResponseJSONData.AddPair(TJSONPair.Create('To', TJSONString.Create(DateToStr(dm_PCM.qry_Work.FieldByName('Bis').AsDateTime))));
      joResponseJSONData.AddPair(TJSONPair.Create('Code', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Kuerzel').AsString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Description', TJSONString.Create(dm_PCM.qry_Work.FieldByName('Beschreibung').asString)));
      joResponseJSONData.AddPair(TJSONPair.Create('Days', TJSONNumber.Create(dm_PCM.qry_Work.FieldByName('Tage').AsInteger)));
      jaDetails.Add(joResponseJSONData);
      joResponseJSONData:= nil;
      dm_PCM.qry_work.Next;
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
  dm_PCM.qry_Work.Close;
  Result := joResponseJSON;
end;
function GetMonthValues_Intern(AID_Benutzer: Integer): TDataset;
begin
  dm_PCM.qry_Work.SQL.Text :=  'SELECT * FROM time_monatswerte ';
  dm_PCM.qry_Work.Open;
  WriteLog(PCM_Logname,rs_PCMAPPServer_Monatswerteanzahl + IntToStr(dm_PCM.qry_Work.RecordCount),0);
  Result := dm_PCM.qry_Work;
end;
function SetOnlineBooking_Intern(AID_Benutzer: string; const AJSONObject: TJSONObject): TJSONObject;
var
  iZaehler: Integer;
  sField: string;
  sDate: string;
  sTime: string;
  iType: Integer;
  iBooking_Type: Integer;
begin
  joResponseJSON := nil;
  jaDetails := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('OnlineBooking');
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

    dm_PCM.qry_Work.SQL.Text:=  'Update time_Buchungen Set ' + sField + ' = :time, Buchungsart = :Buchungsart Where Datum = :Datum';
    dm_PCM.qry_Work.ParamByName('time').AsTime:= StrToTime(sTime);
    dm_PCM.qry_Work.ParamByName('Buchungsart').asInteger := iBooking_Type;
    dm_PCM.qry_Work.ParamByName('Datum').AsDate:= StrToDate(sDate);
    dm_PCM.qry_Work.ExecSQL;
    iZaehler:= iZaehler + 1;
  end;
  WriteLog(PCM_Logname,rs_PCMAPPServer_Buchungpruefung + IntToStr(iZaehler),0);
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
  joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
  joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
  Result := joResponseJSON;
end;
{$EndRegion TimeAPPapi}
end.
