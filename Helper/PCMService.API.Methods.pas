unit PCMService.API.Methods;

interface

uses
  System.JSON,
  Datasnap.DSSession,
  PCM.Main,
  PCM.Data,
  PCM.Functions,
  System.Dateutils,
  Data.db,
  FireDAC.Comp.Client,
  Vcl.Graphics,
  Winapi.Windows,
  Data.DBXPlatform,FireDac.Stan.Param;

  function GetIDFromTable(ATable,AValue: String) : Integer;
  function CheckTokenGueltig(sToken: String): Boolean;
  function AddZeros(AValue: String; ACount: integer): string;
  function FormatDateTimeToStr(ADate: TDateTime): String;

  //////////////////////////////////////////////////////////////////////////////
  // WebAPI - PCM                                                             //
  //////////////////////////////////////////////////////////////////////////////
  function CreateToken_Intern: TJSONObject;
  function RefreshToken_Intern(const AJSONObject: TJSONObject): TJSONObject;
  function DeleteToken_Intern(const sToken: String;iProg: Integer): TJSONObject;
  function CreateBackup_Intern(const sToken, sPath: String): TJSONObject;
  function GetKalenderConfig_Intern(const AJSONObject: TJSONObject): TJSONObject;
  //////////////////////////////////////////////////////////////////////////////
  // APPAPI - PCM                                                             //
  //////////////////////////////////////////////////////////////////////////////
  // Servercheck
  function Checkserver_Intern: TJSONObject;
  // Login ermitteln
  function GetLogin_Intern: TJSONObject;
  // Kontakte ermitteln
  function GetKontakte_Intern(AID_Benutzer: string): TJSONObject;
  // Kontakte übernehmen
  function SetKontakte_Intern(AID_Benutzer: string; ATest: boolean; const AJSONObject: TJSONObject): TJSONObject;
  // Kalender ermitteln
  function GetKalender_Intern(AID_Benutzer: string): TJSONObject;
  // Kalender übernehmen
  function SetKalender_Intern(AID_Benutzer: string; ATest: boolean; const AJSONObject: TJSONObject): TJSONObject;
  // Passwörter ermitteln
  function GetPasswoerter_Intern(AID_Benutzer: string): TJSONObject;
  // Passwörter übernehmen
  function SetPasswoerter_Intern(AID_Benutzer: string; ATest: boolean; const AJSONObject: TJSONObject): TJSONObject;
  // Serials ermitteln
  function GetSerials_Intern(AID_Benutzer: string): TJSONObject;
  // Serials übernehmen
  function SetSerials_Intern(AID_Benutzer: string; ATest: boolean; const AJSONObject: TJSONObject): TJSONObject;
  // Ausgaben ermitteln
  function GetAusgaben_Intern(AID_Benutzer: string): TJSONObject;
  // Ausgaben übernehmen
  function SetAusgaben_Intern(AID_Benutzer: string; ATest: boolean; const AJSONObject: TJSONObject): TJSONObject;
  // Einnnahmen ermitteln
  function GetEinnahmen_Intern(AID_Benutzer: string): TJSONObject;
  // Einnnahmen übernehmen
  function SetEinnahmen_Intern(AID_Benutzer: string; ATest: boolean; const AJSONObject: TJSONObject): TJSONObject;

var
  joResponseJSON: TJSONObject;
  joResponseJSONData: TJSONObject;
  jaDetails: TJSonArray;
  JSonValue: TJSonValue;
  iZaehler: integer;
  iAnzahl: integer;

implementation

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.NetEncoding,
  PCM.Strings;

// ID aus Zusatztabellen ermitteln
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
// Prüfen ob Token gültig ist
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
// Nullen hinzufügen
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
// Formatierung des Datums
function FormatDateTimeToStr(ADate: TDateTime): String ;
var
  wJahr,wMonat,wTag,wStunde,wMinute,wSekunde,wMSek: word;
begin
  Result := '';
  DecodeDateTime(ADate,wJahr,wMonat,wTag,wStunde,wMinute,wSekunde,wMSek);
  Result:= IntToStr(wJahr) + '-' + AddZeros(IntToStr(wMonat), 2) + '-' + AddZeros(IntToStr(wTag), 2) + ' ' +
           AddZeros(IntToStr(wStunde), 2) + ':' + AddZeros(IntToStr(wMinute), 2) +':' + AddZeros(IntToStr(wSekunde), 2)
end;
////////////////////////////////////////////////////////////////////////////////
// WebAPI - PCM                                                               //
////////////////////////////////////////////////////////////////////////////////
// Token ermitteln
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
// Token erneuern
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
// Token löschen
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
// Backup erzeugen
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
// Kalenderconfig
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
////////////////////////////////////////////////////////////////////////////////
// APP-API - PCM                                                              //
////////////////////////////////////////////////////////////////////////////////
//Checkserver
function Checkserver_intern: TJSONObject;
begin
  joResponseJSON:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
  joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
  joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
  Result := joResponseJSON;
end;
// Login ermitteln
function GetLogin_Intern: TJSONObject;
var
  sUser, sPass: String;
begin
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  sUser := TDSSessionManager.GetThreadSession.GetData('Username');
  sPass := TDSSessionManager.GetThreadSession.GetData('Password');
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  try
    dm_PCM.qry_Work.SQL.Text := 'SELECT ID, Benutzer, Passwort, Startseite FROM Benutzer WHERE Benutzer =:Username AND Passwort=:Password';
    dm_PCM.qry_Work.ParamByName('Username').AsString := sUser;
    dm_PCM.qry_Work.ParamByName('Password').AsString := sPass;
    dm_PCM.qry_Work.Open;
    if dm_PCM.qry_Work.RecordCount > 0 then
    begin
      iCode:= 200;
      sMessage:= 'OK';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(false)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(0)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('')));
      joResponseJSON.AddPair(TJSONPair.Create('ID_User', dm_PCM.qry_work.FieldByName('ID').asInteger));
      joResponseJSON.AddPair(TJSONPair.Create('User', sUser));
      joResponseJSON.AddPair(TJSONPair.Create('Password', sPass));
      joResponseJSON.AddPair(TJSONPair.Create('Startpage', dm_PCM.qry_work.FieldByName('Startseite').asInteger));
    end
    else
    begin
      iCode:= 401;
      sMessage:= 'Unauthorized';
      joResponseJSON.AddPair(TJSONPair.Create('HasError',TJSONBool.Create(true)));
      joResponseJSON.AddPair(TJSONPair.Create('ErrorCode',TJSONNumber.Create(1)));
      joResponseJSON.AddPair(TJSONPair.Create('Errormessage',TJSONString.Create('Benutzer ' + sUSer + ' nicht gefunden oder falsches Passwort')));
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
end;
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
function SetKontakte_Intern(AID_Benutzer: string; ATest: boolean; const AJSONObject: TJSONObject): TJSONObject;
var
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
  iID_Kontakt: integer;
  sBild: string;
  bDeleted: boolean;
begin
  iZaehler:= 0;
  joResponseJSON := nil;
  jaDetails := nil;
  jSonValue := nil;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Contacts');
  for JSonValue in jaDetails do
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
    JSonValue.TryGetValue<integer>('ID_Contact', iID_Kontakt);
    JSonValue.TryGetValue<string>('Image',sBild);
    JSonValue.TryGetValue<boolean>('Deleted',bDeleted);
    if bDeleted then
    begin
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_kontakte WHERE ID_Benutzer = :ID_Benutzer AND Vorname = :Vorname AND Nachname = :Nachname';
      dm_PCM.qry_Work.ParamByName('Vorname').asString := sVorname;
      dm_PCM.qry_Work.ParamByName('Nachname').asString := sNachname;
      dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger:= StrToInt(AID_Benutzer);
      if not ATest then
        dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
      // Check neue Datensatz
      dm_PCM.qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_kontakte WHERE ID_Benutzer = :ID_Benutzer AND Vorname = :Vorname AND Nachname = :Nachname';
      dm_PCM.qry_Work.ParamByName('Vorname').asString := sVorname;
      dm_PCM.qry_Work.ParamByName('Nachname').asString := sNachname;
      dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger:= StrToInt(AID_Benutzer);
      dm_PCM.qry_Work.Open;
      iAnzahl:= dm_PCM.qry_Work.FieldByName('Anzahl').asInteger;
      dm_PCM.qry_Work.Close;
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
      if iAnzahl = 0 then
      begin
        if sGeburtsdatum ='' then
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
        if not ATest then
          dm_PCM.qry_Work.ExecSQL;
      end
      else
      begin
        if sGeburtsdatum = '' then
        begin
					dm_PCM.qry_Work.SQL.Text:=  'Update manager_kontakte SET ID_Anrede= :ID_Anrede,Strasse_Privat= :Strasse_Privat,PLZ_Privat= :PLZ_Privat,Ort_Privat= :Ort_Privat,' +
																								'Telefon_Privat= :Telefon_Privat,Handy_privat= :Handy_privat,E_Mail_Privat= :E_Mail_Privat,ID_Geschlecht= :ID_Geschlecht,ID_Familienstand= :ID_Familienstand,' +
																								'ID_Staatsangehoerigkeit= :ID_Staatsangehoerigkeit,ID_Konfession= :ID_Konfession,Firma= :Firma,Strasse_Ges= :Strasse_Ges,PLZ_Ges= :PLZ_Ges,Ort_Ges= :Ort_Ges,' +
																								'Telefon_Ges= :Telefon_Ges,Handy_Ges= :Handy_Ges,E_Mail_Ges= :E_Mail_Ges '  +
                                                'Where Nachname = :Nachname and Vorname = :Vorname';
        end
        else begin
          dm_PCM.qry_Work.SQL.Text:=  'Update manager_kontakte SET ID_Anrede= :ID_Anrede,Geburtsdatum= :Geburtsdatum,Strasse_Privat= :Strasse_Privat,PLZ_Privat= :PLZ_Privat,Ort_Privat= :Ort_Privat,' +
																								'Telefon_Privat= :Telefon_Privat,Handy_privat= :Handy_privat,E_Mail_Privat= :E_Mail_Privat,ID_Geschlecht= :ID_Geschlecht,ID_Familienstand= :ID_Familienstand,' +
																								'ID_Staatsangehoerigkeit= :ID_Staatsangehoerigkeit,ID_Konfession= :ID_Konfession,Firma= :Firma,Strasse_Ges= :Strasse_Ges,PLZ_Ges= :PLZ_Ges,Ort_Ges= :Ort_Ges,' +
																								'Telefon_Ges= :Telefon_Ges,Handy_Ges= :Handy_Ges,E_Mail_Ges = :E_Mail_Ges ' +
                                                'Where Nachname = :Nachname and Vorname = :Vorname';
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
        if not ATest then
          dm_PCM.qry_Work.ExecSQL;
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
function SetKalender_Intern(AID_Benutzer: string; ATest: boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iID: integer;
  sCaption: String;
  iEventType: integer;
  sLocation: String;
  sMessage: String;
  sStart,sStartDate: String;
  sFinish,sFinishDate: String;
  bCompleteDay: boolean;
  bReminder: boolean;
  sReminderDate: string;
  iReminderMinutesBeforeStart: integer;
  sKalendername: string;
  iID_Kalender: integer;
  bDeleted: boolean;
  iLabelColor,iFontColor: integer;
begin
  joResponseJSON := nil;
  jaDetails := nil;
  jSonValue := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Calendar');
  for JSonValue in jaDetails do
  begin
    JSonValue.TryGetValue<integer>('ID',iID);
    JSonValue.TryGetValue<string>('Caption',sCaption);
    JSonValue.TryGetValue<integer>('EventType',iEventType);
    JSonValue.TryGetValue<string>('Location',sLocation);
    JSonValue.TryGetValue<string>('Message',sMessage);
    JSonValue.TryGetValue<string>('Start',sStartDate);
    JSonValue.TryGetValue<string>('Finish',sFinishDate);
    JSonValue.TryGetValue<boolean>('CompleteDay',bCompleteDay);
    JSonValue.TryGetValue<boolean>('Reminder',bReminder);
    JSonValue.TryGetValue<string>('Reminderdate',sReminderDate);
    JSonValue.TryGetValue<integer>('Reminderbeforestart',iReminderMinutesBeforeStart);
    JSonValue.TryGetValue<string>('Calendername',sKalendername);
    JSonValue.TryGetValue<integer>('ID_Calender,',iID_Kalender);
    JSonValue.TryGetValue<boolean>('Deleted',bDeleted);
    // Kalender löschen
    if bDeleted then
    begin
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_kalender WHERE ID = :ID';
      dm_PCM.qry_Work.ParamByName('ID').AsInteger := iID_Kalender;
      if not ATest then
        dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
//      // Check neue Datensatz
      dm_PCM.qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_kalender WHERE ID = :ID_Kalender';
      dm_PCM.qry_Work.ParamByName('ID_Kalender').asInteger := iID_Kalender;
      dm_PCM.qry_Work.Open;
      iAnzahl:= dm_PCM.qry_Work.FieldByName('Anzahl').asInteger;
      dm_PCM.qry_Work.Close;
      if iAnzahl = 0 then
      begin
        dm_PCM.qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_kalender WHERE ' +
                                    'Caption = :Caption and START = :Start and Finish = :Finish';
        dm_PCM.qry_Work.ParamByName('Caption').asString := sCaption;
        dm_PCM.qry_Work.ParamByName('Start').asDateTime := StrToDateTime(sStartDate);
        dm_PCM.qry_Work.ParamByName('Finish').asDateTime := StrToDateTime(sFinishDate);
        dm_PCM.qry_Work.Open;
        iAnzahl:= dm_PCM.qry_Work.FieldByName('Anzahl').asInteger;
        dm_PCM.qry_Work.Close;
        if iAnzahl = 0 then
        begin
          dm_PCM.qry_Work.SQL.Text:= 'INSERT INTO manager_kalender(Caption,EventType,Location,Message,' +
                                               'START,Finish,CompleteDay,Reminder,ReminderDate,ReminderMinutesBeforeStart,' +
                                               'ID_Benutzer,Kalendername,LabelColor,FontColor,ID_KalenderAPP) VALUES (:Caption,:EventType,' +
                                               ':Location,:Message,:START,:Finish,:CompleteDay,:Reminder,:ReminderDate,' +
                                               ':ReminderMinutesBeforeStart,:ID_Benutzer,:Kalendername,:LabelColor,:FontColor,:ID_KalenderAPP)';
          dm_PCM.qry_Work.ParamByName('Caption').AsString:= sCaption;
          dm_PCM.qry_Work.ParamByName('EventType').AsInteger:= iEventType;
          dm_PCM.qry_Work.ParamByName('Location').AsString:= sLocation;
          dm_PCM.qry_Work.ParamByName('Message').AsString:= sMessage;
          dm_PCM.qry_Work.ParamByName('START').asDateTime:= StrToDateTime(sStartDate);
          dm_PCM.qry_Work.ParamByName('Finish').asDateTime:= StrToDateTime(sFinishDate);
          dm_PCM.qry_Work.ParamByName('ID_KalenderAPP').asInteger:= iID;
          if bCompleteDay then
            dm_PCM.qry_Work.ParamByName('CompleteDay').AsString:= 'true'
          else
            dm_PCM.qry_Work.ParamByName('CompleteDay').AsString:= 'false';
          if bReminder then
            dm_PCM.qry_Work.ParamByName('Reminder').AsString:= 'true'
          else
            dm_PCM.qry_Work.ParamByName('Reminder').AsString:= 'false';
          if (bReminder) and (sReminderDate = '') then
            sReminderDate := DateTimeToStr(IncMinute(StrToDateTime(sStartDate),-iReminderMinutesBeforeStart));
          dm_PCM.qry_Work.ParamByName('ReminderDate').asDateTime:= StrToDateTime(sReminderDate);
          dm_PCM.qry_Work.ParamByName('ReminderMinutesBeforeStart').AsInteger:= iReminderMinutesBeforeStart;
          dm_PCM.qry_Work.ParamByName('ID_Benutzer').AsInteger:= StrToInt(AID_Benutzer);
          dm_PCM.qry_Work.ParamByName('Kalendername').AsString:= sKalendername;
          dm_PCM.qry_Work.ParamByName('LabelColor').AsInteger:= 13083265;
          dm_PCM.qry_Work.ParamByName('FontColor').AsInteger:= 0;
          if not ATest then
            dm_PCM.qry_Work.ExecSQL;
        end;
      end
      else
      begin
        dm_PCM.qry_Work.SQL.Text:= 'Update manager_kalender SET Caption = :Caption, EventType = :EventType,' +
																						 'Location = :Location, Message = :Message, START = :Start,' +
																						 'Finish = :Finish, CompleteDay = :CompleteDay, Reminder = :Reminder,' +
																						 'ReminderDate = :ReminderDate, ReminderMinutesBeforeStart = :ReminderMinutesBeforeStart,' +
                                             'ID_Benutzer = :ID_Benutzer, Kalendername = :Kalendername, LabelColor = :LabelColor,' +
    																				 'FontColor = :FontColor,ID_KalenderApp = :ID_KalenderApp WHERE ID = :ID';
        dm_PCM.qry_Work.ParamByName('Caption').AsString:= sCaption;
        dm_PCM.qry_Work.ParamByName('EventType').AsInteger:= iEventType;
        dm_PCM.qry_Work.ParamByName('Location').AsString:= sLocation;
        dm_PCM.qry_Work.ParamByName('Message').AsString:= sMessage;
        dm_PCM.qry_Work.ParamByName('START').asDateTime:= StrToDateTime(sStartDate);
        dm_PCM.qry_Work.ParamByName('Finish').asDateTime:= StrToDateTime(sFinishDate);
        dm_PCM.qry_Work.ParamByName('ID_KalenderAPP').asInteger:= iID;
        if bCompleteDay then
          dm_PCM.qry_Work.ParamByName('CompleteDay').AsString:= 'true'
        else
          dm_PCM.qry_Work.ParamByName('CompleteDay').AsString:= 'false';
        if bReminder then
          dm_PCM.qry_Work.ParamByName('Reminder').AsString:= 'true'
        else
          dm_PCM.qry_Work.ParamByName('Reminder').AsString:= 'false';
        dm_PCM.qry_Work.ParamByName('ReminderDate').asDateTime:= StrToDateTime(sReminderDate);
        dm_PCM.qry_Work.ParamByName('ReminderMinutesBeforeStart').AsInteger:= iReminderMinutesBeforeStart;
        dm_PCM.qry_Work.ParamByName('ID_Benutzer').AsInteger:= StrToInt(AID_Benutzer);
        dm_PCM.qry_Work.ParamByName('Kalendername').AsString:= sKalendername;
        iLabelColor:= 13083265;
        iFontColor:= 0;
        case AnsiIndexStr(sCaption, ['Biomüll', 'Restmüll','Papier','Gelber Sack','Giftmobil']) of
          // BioMüll
          0:
          begin
            iFontColor:= clWhite;
            iLabelColor := 944838;
          end;
          // RestMüll
          1:
          begin
            iFontColor:= clWhite;
            iLabelColor := 5658199;
          end;
          // Papier
          2:
          begin
            iFontColor:= clWhite;
            iLabelColor := 13214474;
          end;
          // Gelber Sack
          3:
          begin
            iFontColor:= clBlack;
            iLabelColor := 56831;
          end;
          // Giftmobil
          4:
          begin
            iFontColor:= clWhite;
            iLabelColor := 7679146;
          end;
        end;
        dm_PCM.qry_Work.ParamByName('LabelColor').AsInteger:= iLabelColor;
        dm_PCM.qry_Work.ParamByName('FontColor').AsInteger:= iFontColor;
        if not ATest then
          dm_PCM.qry_Work.ExecSQL;
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
  WriteLog(PCM_Logname,rs_PCMAPPServer_Kalenderpruefung + IntToStr(iZaehler),0);
end;
// Passwörter ermitteln
function GetPasswoerter_Intern(AID_Benutzer: string): TJSONObject;
begin
  joResponseJSON:= nil;
  joResponseJSONData:= nil;
  jaDetails:= nil;
  if not Assigned(joResponseJSON) then
    joResponseJSON := TJSONObject.Create;
  dm_PCM.qry_Work.SQL.Text :=  'SELECT pw.id AS passwoerter_ID,pw.Bezeichnung,pw.user,pw.password,pw.link,pw.VPN_SharedSecret, ' +
                                         'pw.APP_IP,pw.APP_Port,pw.APP_Verschluesselung,pw.MAIL_Posteingangsserver,pw.MAIL_PosteingangsPort, ' +
                                         'pw.MAIL_PosteingangsVerschluesselung,pw.MAIL_Postausgangsserver,pw.MAIL_PostausgangsPort, ' +
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
function SetPasswoerter_Intern(AID_Benutzer: string; ATest: boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iID,iID_Typ: integer;
  sPasswordname: String;
  sUser: String;
  sPassword: String;
  sLink: String;
  sVPN_SharedSecret: string;
  sAPP_IP: string;
  iAPP_Port: integer;
  sAPP_Encryption: string;
  sIncomingmail_Server: string;
  iIncomingmail_Port: integer;
  sIncomingmail_Encryption: string;
  sOutgoingmail_Server: string;
  iOutgoingmail_Port: integer;
  sOutgoingmail_Encryption: string;
  sPasswordtype: string;
  sWlankey:String;
  bDeleted: boolean;
begin
  joResponseJSON := nil;
  jaDetails := nil;
  jSonValue := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Passwords');
  for JSonValue in jaDetails do
  begin
    JSonValue.TryGetValue<integer>('ID',iID);
    JSonValue.TryGetValue<string>('Passwordname',sPasswordname);
    JSonValue.TryGetValue<string>('User',sUser);
    JSonValue.TryGetValue<string>('Password',sPassword);
    JSonValue.TryGetValue<string>('Link',sLink);
    JSonValue.TryGetValue<string>('VPN_SharedSecret',sVPN_SharedSecret);
    JSonValue.TryGetValue<string>('sAPP_IP',sAPP_IP);
    JSonValue.TryGetValue<integer>('APP_Port',iAPP_Port);
    JSonValue.TryGetValue<string>('APP_Encryption',sAPP_Encryption);
    JSonValue.TryGetValue<string>('Incomingmail_Server',sIncomingmail_Server);
    JSonValue.TryGetValue<integer>('Incomingmail_Port',iIncomingmail_Port);
    JSonValue.TryGetValue<string>('Incomingmail_Encryption', sIncomingmail_Encryption);
    JSonValue.TryGetValue<string>('Outgoingmail_Server',sOutgoingmail_Server);
    JSonValue.TryGetValue<integer>('Outgoingmail_Port',iOutgoingmail_Port);
    JSonValue.TryGetValue<string>('Outgoingmail_Encryption', sOutgoingmail_Encryption);
     JSonValue.TryGetValue<string>('Passwordtype',sPasswordtype);
    JSonValue.TryGetValue<string>('Wlankey',sWlankey);
    JSonValue.TryGetValue<boolean>('Deleted',bDeleted);
    if bDeleted then
    begin
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_passwoerter WHERE Bezeichnung = :Bezeichnung';
      dm_PCM.qry_Work.ParamByName('Bezeichnung').AsString := sPasswordname;
      if not ATest then
        dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
//      // Check neue Datensatz
      dm_PCM.qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_passwoerter WHERE Bezeichnung = :Bezeichnung';
      dm_PCM.qry_Work.ParamByName('Bezeichnung').asString := sPasswordname;
      dm_PCM.qry_Work.Open;
      iAnzahl:= dm_PCM.qry_Work.FieldByName('Anzahl').asInteger;
      dm_PCM.qry_Work.Close;
      iID_Typ:= -1;
      // Typ
      if sPasswordtype <> '' then
      begin
        iID_Typ:= GetIDFromTable('manager_passwoerter_typ',sPasswordtype);
      end;
      if iAnzahl = 0 then
      begin
        dm_PCM.qry_Work.SQL.Text:= 'INSERT INTO  manager_passwoerter (Bezeichnung,user,password,link,ID_benutzer,' +
											 'VPN_SharedSecret,APP_IP,APP_Port,APP_Verschluesselung,MAIL_Posteingangsserver,' +
											 'MAIL_PosteingangsPort,MAIL_PosteingangsVerschluesselung,MAIL_Postausgangsserver,' +
											 'MAIL_PostausgangsPort,MAIL_PostausgangsVerschluesselung,ID_Typ,WLAN) Values (' +
											 ':Bezeichnung,:user,:password,:link,:ID_benutzer,:VPN_SharedSecret,:APP_IP,:APP_Port,' +
											 ':APP_Verschluesselung,:MAIL_Posteingangsserver,:MAIL_PosteingangsPort,' +
											 ':MAIL_PosteingangsVerschluesselung,:MAIL_Postausgangsserver,:MAIL_PostausgangsPort,' +
											 ':MAIL_PostausgangsVerschluesselung,:ID_Typ,:WLAN)';
        dm_PCM.qry_Work.ParamByName('Bezeichnung').asString:= sPasswordname;
        dm_PCM.qry_Work.ParamByName('user').asString:= sUser;
        dm_PCM.qry_Work.ParamByName('password').asString:= spassword;
        dm_PCM.qry_Work.ParamByName('link').asString:= slink;
        dm_PCM.qry_Work.ParamByName('ID_benutzer').asInteger:= StrToInt(AID_Benutzer);
        dm_PCM.qry_Work.ParamByName('VPN_SharedSecret').asString:= sVPN_SharedSecret;
        dm_PCM.qry_Work.ParamByName('APP_IP').asString:= sAPP_IP;
        dm_PCM.qry_Work.ParamByName('APP_Port').asInteger:= iAPP_Port;
        dm_PCM.qry_Work.ParamByName('APP_Verschluesselung').asString:= sAPP_Encryption;
        dm_PCM.qry_Work.ParamByName('MAIL_Posteingangsserver').asString:= sIncomingmail_Server;
        dm_PCM.qry_Work.ParamByName('MAIL_PosteingangsPort').asInteger:= iIncomingmail_Port;
        dm_PCM.qry_Work.ParamByName('MAIL_PosteingangsVerschluesselung').asString:= sIncomingmail_Encryption;
        dm_PCM.qry_Work.ParamByName('MAIL_Postausgangsserver').asString:= sOutgoingmail_Server;
        dm_PCM.qry_Work.ParamByName('MAIL_PostausgangsPort').asInteger:= iOutgoingmail_Port;
        dm_PCM.qry_Work.ParamByName('MAIL_PostausgangsVerschluesselung').asString:= sOutgoingmail_Encryption;
        dm_PCM.qry_Work.ParamByName('ID_Typ').asInteger:= iID_Typ;
        dm_PCM.qry_Work.ParamByName('WLAN').asString:= sWlankey;
        if not ATest then
          dm_PCM.qry_Work.ExecSQL;
      end
      else
      begin
		    dm_PCM.qry_Work.SQL.Text:= 'Update manager_passwoerter SET Bezeichnung = :Bezeichnung, user = :user, password = :password, link = :link,' +
											 'ID_benutzer = :ID_benutzer, VPN_SharedSecret = :VPN_SharedSecret, APP_IP = :APP_IP, APP_Port = :APP_Port,' +
											 'APP_Verschluesselung = :APP_Verschluesselung, MAIL_Posteingangsserver = :MAIL_Posteingangsserver, MAIL_PosteingangsPort = :MAIL_PosteingangsPort,' +
											 'MAIL_PosteingangsVerschluesselung = :MAIL_PosteingangsVerschluesselung,MAIL_Postausgangsserver = :MAIL_Postausgangsserver,' +
											 'MAIL_PostausgangsPort = :MAIL_PostausgangsPort, MAIL_PostausgangsVerschluesselung = :MAIL_PostausgangsVerschluesselung,'+
											 'ID_Typ = :ID_Typ,WLAN = :WLAN Where Bezeichnung = :Bezeichnung';
        dm_PCM.qry_Work.ParamByName('Bezeichnung').asString:= sPasswordname;
        dm_PCM.qry_Work.ParamByName('user').asString:= sUser;
        dm_PCM.qry_Work.ParamByName('password').asString:= sPassword;
        dm_PCM.qry_Work.ParamByName('link').asString:= slink;
        dm_PCM.qry_Work.ParamByName('ID_benutzer').asInteger:= StrToInt(AID_Benutzer);
        dm_PCM.qry_Work.ParamByName('VPN_SharedSecret').asString:= sVPN_SharedSecret;
        dm_PCM.qry_Work.ParamByName('APP_IP').asString:= sAPP_IP;
        dm_PCM.qry_Work.ParamByName('APP_Port').asInteger:= iAPP_Port;
        dm_PCM.qry_Work.ParamByName('APP_Verschluesselung').asString:= sAPP_Encryption;
        dm_PCM.qry_Work.ParamByName('MAIL_Posteingangsserver').asString:= sIncomingmail_Server;
        dm_PCM.qry_Work.ParamByName('MAIL_PosteingangsPort').asInteger:= iIncomingmail_port;
        dm_PCM.qry_Work.ParamByName('MAIL_PosteingangsVerschluesselung').asString:= sIncomingmail_Encryption;
        dm_PCM.qry_Work.ParamByName('MAIL_Postausgangsserver').asString:= sOutgoingmail_Server;
        dm_PCM.qry_Work.ParamByName('MAIL_PostausgangsPort').asInteger:= iOutgoingmail_Port;
        dm_PCM.qry_Work.ParamByName('MAIL_PostausgangsVerschluesselung').asString:= sOutgoingmail_Encryption;
        dm_PCM.qry_Work.ParamByName('ID_Typ').asInteger:= iID_Typ;
        dm_PCM.qry_Work.ParamByName('WLAN').asString:= sWlankey;
        if not ATest then
          dm_PCM.qry_Work.ExecSQL;
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
function SetSerials_Intern(AID_Benutzer: string; ATest: boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iID: Integer;
  sSerialname: String;
  sUser: String;
  sSerialkey: String;
  sSerialType: String;
  bDeleted: boolean;
  iID_Serial: integer;
  iID_Typ: integer;
begin
  joResponseJSON := nil;
  jaDetails := nil;
  jSonValue := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Serials');
  for JSonValue in jaDetails do
  begin
    JSonValue.TryGetValue<integer>('ID',iID);
    JSonValue.TryGetValue<string>('Serialname',sSerialname);
    JSonValue.TryGetValue<string>('User',sUser);
    JSonValue.TryGetValue<string>('Serialkey',sSerialkey);
    JSonValue.TryGetValue<string>('SerialType',sSerialType);
    JSonValue.TryGetValue<boolean>('Deleted',bDeleted);
    if bDeleted then
    begin
      dm_PCM.qry_Work.SQL.Text:= 'SELECT ID FROM manager_Serials WHERE  APP = :APP';
      dm_PCM.qry_Work.ParamByName('App').asString := sSerialname;
      dm_PCM.qry_Work.open;
      iID_Serial:= dm_PCM.qry_Work.FieldByName('ID').asInteger;
      dm_PCM.qry_Work.Close;
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_serials_keys WHERE ID_Serial = :ID_Serial';
      dm_PCM.qry_Work.ParamByName('ID_Serial').AsInteger := iID_Serial;
      if not ATest then
        dm_PCM.qry_Work.ExecSQL;
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_serials WHERE ID = :ID_Serial';
      dm_PCM.qry_Work.ParamByName('ID_Serial').AsInteger := iID_Serial;
      if not ATest then
        dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
      dm_PCM.qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_Serials WHERE App = :App';
      dm_PCM.qry_Work.ParamByName('App').asString := sSerialname;
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
        if not ATest then
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
        if not ATest then
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
function SetAusgaben_Intern(AID_Benutzer: string; ATest: boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iID: integer;
  sReceiver: string;
  sDescription: string;
  sAccountnumber: string;
  sBankcode: string;
  sAmount: string;
  bFixedcosts: boolean;
  iValidmonth: integer;
  iValidyear: integer;
  sUse: string;
  sFixedamount: string;
  bDeleted: boolean;
begin
  joResponseJSON := nil;
  jaDetails := nil;
  jSonValue := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Expenditure');
  for JSonValue in jaDetails do
  begin
    JSonValue.TryGetValue<integer>('ID',iID);
    JSonValue.TryGetValue<string>('Receiver',sReceiver);
    JSonValue.TryGetValue<string>('Description',sDescription);
    JSonValue.TryGetValue<string>('Accountnumber',sAccountnumber);
    JSonValue.TryGetValue<string>('Bankcode',sBankcode);
    JSonValue.TryGetValue<string>('Amount',sAmount);
    JSonValue.TryGetValue<Boolean>('Fixedcosts',bFixedcosts);
    JSonValue.TryGetValue<Integer>('Validmonth',iValidmonth);
    JSonValue.TryGetValue<Integer>('Validyear',iValidyear);
    JSonValue.TryGetValue<string>('Use',sUse);
    JSonValue.TryGetValue<string>('Fixedamount',sFixedamount);
    JSonValue.TryGetValue<Boolean>('Deleted',bDeleted);
    if bDeleted then
    begin
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_finanzen_Ausgaben WHERE Name = :Name';
      dm_PCM.qry_Work.ParamByName('Name').asString := sReceiver;
      dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
      // Check neue Datensatz
      dm_PCM.qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_finanzen_Ausgaben WHERE Name = :Name';
      dm_PCM.qry_Work.ParamByName('Name').asString := sReceiver;
      dm_PCM.qry_Work.Open;
      iAnzahl:= dm_PCM.qry_Work.FieldByName('Anzahl').asInteger;
      dm_PCM.qry_Work.Close;
      if iAnzahl = 0 then
      begin
        dm_PCM.qry_Work.SQL.Text:=  'INSERT INTO manager_finanzen_Ausgaben (Name,Beschreibung,Kontonummer,Bankleitzahl,Betrag,Fixkosten,Gueltig_Monat,Gueltig_Jahr,ID_Benutzer,Verwendungszweck,FixBetrag' +
                                                ') Values (:Name,:Beschreibung,:Kontonummer,:Bankleitzahl,:Betrag,:Fixkosten,:Gueltig_Monat,:Gueltig_Jahr,:ID_Benutzer,:Verwendungszweck,:FixBetrag)';
        dm_PCM.qry_Work.ParamByName('Name').AsString:= sReceiver;
        dm_PCM.qry_Work.ParamByName('Beschreibung').asString := sDescription;
        dm_PCM.qry_Work.ParamByName('Kontonummer').asString := sAccountnumber;
        dm_PCM.qry_Work.ParamByName('Bankleitzahl').asString := sBankcode;
        dm_PCM.qry_Work.ParamByName('Betrag').asFloat := StrToFloat(StringReplace(sAmount,'.',',',[rfReplaceAll]));
        dm_PCM.qry_Work.ParamByName('FixBetrag').asFloat := StrToFloat(StringReplace(sFixedamount,'.',',',[rfReplaceAll]));
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
        dm_PCM.qry_Work.SQL.Text:=  'Update manager_finanzen_Ausgaben SET Name = :Name,Beschreibung = :Beschreibung,Kontonummer = :Kontonummer,Bankleitzahl = :Bankleitzahl, ' +
                                              'Betrag = :Betrag,Fixkosten = :Fixkosten,Gueltig_Monat = :Gueltig_Monat,Gueltig_Jahr = :Gueltig_Jahr,Verwendungszweck = :Verwendungszweck, ' +
                                              'FixBetrag = :FixBetrag ' +
                                              'Where Name = :Name';
        dm_PCM.qry_Work.ParamByName('Name').AsString:= sReceiver;
        dm_PCM.qry_Work.ParamByName('Beschreibung').asString := sDescription;
        dm_PCM.qry_Work.ParamByName('Kontonummer').asString := sAccountnumber;
        dm_PCM.qry_Work.ParamByName('Bankleitzahl').asString := sBankcode;
        dm_PCM.qry_Work.ParamByName('Betrag').asFloat := StrToFloat(StringReplace(sAmount,'.',',',[rfReplaceAll]));
        dm_PCM.qry_Work.ParamByName('FixBetrag').asFloat := StrToFloat(StringReplace(sFixedamount,'.',',',[rfReplaceAll]));
        if bFixedcosts then
          dm_PCM.qry_Work.ParamByName('Fixkosten').asString := 'true'
        else
          dm_PCM.qry_Work.ParamByName('Fixkosten').AsString := 'false';
        dm_PCM.qry_Work.ParamByName('Gueltig_Monat').AsInteger := iValidmonth;
        dm_PCM.qry_Work.ParamByName('Gueltig_Jahr').AsInteger := iValidYear;
        dm_PCM.qry_Work.ParamByName('Verwendungszweck').asString := sUse;
        dm_PCM.qry_Work.ExecSQL;
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
function SetEinnahmen_Intern(AID_Benutzer: string; ATest: boolean; const AJSONObject: TJSONObject): TJSONObject;
var
  iID: Integer;
  sTransmitter: String;
  sAmount: String;
  sDescription: String;
  sFixedamount: String;
  bDeleted: boolean;
begin
  joResponseJSON := nil;
  jaDetails := nil;
  jSonValue := nil;
  iZaehler:= 0;
  jaDetails :=  AJSONObject.GetValue<TJSONArray>('Receipts');
  for JSonValue in jaDetails do
  begin
    JSonValue.TryGetValue<integer>('ID',iID);
    JSonValue.TryGetValue<string>('Transmitter',sTransmitter);
    JSonValue.TryGetValue<string>('Amount',sAmount);
    JSonValue.TryGetValue<string>('Description',sDescription);
    JSonValue.TryGetValue<string>('Fixedamount',sFixedamount);
    JSonValue.TryGetValue<boolean>('Deleted',bDeleted);
    if bDeleted then
    begin
      dm_PCM.qry_Work.SQL.Text :=  'DELETE FROM manager_finanzen_einnahmen WHERE Quelle = :Quelle';
      dm_PCM.qry_Work.ParamByName('Quelle').asString := sTransmitter;
      if not ATest then
        dm_PCM.qry_Work.ExecSQL;
    end
    else
    begin
      // Check neue Datensatz
      dm_PCM.qry_Work.SQL.Text:=  'SELECT COUNT(*) as Anzahl FROM manager_finanzen_einnahmen WHERE Quelle = :Quelle';
      dm_PCM.qry_Work.ParamByName('Quelle').asString := sTransmitter;
      dm_PCM.qry_Work.Open;
      iAnzahl:= dm_PCM.qry_Work.FieldByName('Anzahl').asInteger;
      dm_PCM.qry_Work.Close;
      if iAnzahl = 0 then
      begin
        dm_PCM.qry_Work.SQL.Text:=  'INSERT INTO manager_finanzen_einnahmen (Quelle,Betrag,Bezeichnung,ID_Benutzer,FixBetrag' +
                                                ') Values (:Quelle,:Betrag,:Bezeichnung,:ID_Benutzer,:FixBetrag)';
        dm_PCM.qry_Work.ParamByName('Quelle').AsString:= sTransmitter;
        dm_PCM.qry_Work.ParamByName('Betrag').asFloat := StrToFloat(StringReplace(sAmount,'.',',',[rfReplaceAll]));
        dm_PCM.qry_Work.ParamByName('FixBetrag').asFloat := StrToFloat(StringReplace(sFixedAmount,'.',',',[rfReplaceAll]));
        dm_PCM.qry_Work.ParamByName('Bezeichnung').asString := sDescription;
        dm_PCM.qry_Work.ParamByName('ID_Benutzer').asInteger:=StrToInt(AID_Benutzer);
        if not ATest then
          dm_PCM.qry_Work.ExecSQL;
      end
      else
      begin
        dm_PCM.qry_Work.SQL.Text:=  'Update manager_finanzen_einnahmen SET FixBetrag= :FixBetrag,Betrag= :Betrag,Bezeichnung= :Bezeichnung ' +
                                              'Where Quelle = :Quelle';
        dm_PCM.qry_Work.ParamByName('Quelle').AsString:= sTransmitter;
        dm_PCM.qry_Work.ParamByName('Betrag').asFloat := StrToFloat(StringReplace(sAmount,'.',',',[rfReplaceAll]));
        dm_PCM.qry_Work.ParamByName('FixBetrag').asFloat := StrToFloat(StringReplace(sFixedAmount,'.',',',[rfReplaceAll]));
        dm_PCM.qry_Work.ParamByName('Bezeichnung').asString := sDescription;
        if not ATest then
          dm_PCM.qry_Work.ExecSQL;
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
end.
