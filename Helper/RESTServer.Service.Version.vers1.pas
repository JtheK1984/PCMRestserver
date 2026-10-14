unit RESTServer.Service.Version.vers1;

interface

uses
  {$Region Uses}
  WinApi.Windows,
  System.SysUtils,
  System.Classes,
  System.JSON,
  REST.JSON,
  Data.DB,
  Data.DBXCommon,
  Data.DBXPlatform,
  Datasnap.DSAuth,
  DataSnap.DSProviderDataModuleAdapter,
  Datasnap.DSServer,
  DataSnap.DSSession,
  IdBaseComponent,
  IdHash,
  IdHashCRC,
  IdHashMessageDigest,
  IdHashSHA,
  IdSASL,
  IdSASL_CRAMBase,
  IdSASL_CRAM_MD5,
  IdSASLUserPass,
  RESTServer.Service.Records;
  {$EndRegion Uses}
{$DEFINE PCMService}
type
  {$Region Type}
  {$METHODINFO ON}
  v1 = class(TComponent)
  private
    { Private-Deklarationen }
    procedure ResultToJSONContent(const AJSONObject: TJSONObject);
    function GetArchivSection(const ASection: string): TJSONObject;
  public
    { Public-Deklarationen }
    ////////////////////////////////////////////////////////////////////////////
    // PCM - RESTfunktionen                                                   //
    ////////////////////////////////////////////////////////////////////////////
    {$Region Rest-API}
    // Token erstellen
    [TRoleAuth('WebAPI_PCM')]
    function Createtoken: TJSONObject;
    // Token erneuern
    [TRoleAuth('WebAPI_PCM')]
    function AcceptRefreshtoken(const AJSONObject: TJSONObject): TJSONObject;
    // Token löschen
    [TRoleAuth('WebAPI_PCM')]
    function CancelDeletetoken: TJSONObject;
    // Backup erstellen
    [TRoleAuth('WebAPI_PCM')]
    function UpdateCreateBackup: TJSONObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetKalenderConfig(const AJSONObject: TJSONObject): TJSONObject;
    {$EndRegion Rest-API}
    ////////////////////////////////////////////////////////////////////////////
    // TimeAPP - RESTfunktionen                                               //
    ////////////////////////////////////////////////////////////////////////////
    {$Region TimeAPP-API}
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetContactsZE: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetLastBooking: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetLastBooking(const AJSONObject: TJSONObject): TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetBookingYear: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetAbsenceconfig: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetAbsence: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetOnlineBooking(const AJSONObject: TJSONObject): TJSonObject;


//    [TRoleAuth('WebAPI_PCM')]
//    function GetMonthValues(AID_Benutzer: Integer): TDataset;
    {$EndRegion TimeAPP-API}
    ////////////////////////////////////////////////////////////////////////////
    // Web-APP - RESTfunktionen                                               //
    ////////////////////////////////////////////////////////////////////////////
    {$Region Web-APP-API}
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetLogin: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetEmployee: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetBookingData: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetMonthYearValues: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetFehltage: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetFeiertage: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetLastBook: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetLastBook(const AJSONObject: TJSONObject): TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetOnlineBook: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetOnlineBook(const AJSONObject: TJSONObject): TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateCalcMonth: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetAbsenceDays: TJSonObject;
    {$EndRegion Web-APP-API}
    ////////////////////////////////////////////////////////////////////////////
    // APP - RESTfunktionen                                                   //
    ////////////////////////////////////////////////////////////////////////////
    {$Region APP-API}
    // Login ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function CheckServer: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetArchivConfiguration: TJSONObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetArchivMainCategories: TJSONObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetArchivSubCategories: TJSONObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetArchivIndices: TJSONObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetArchivAssignments: TJSONObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetArchivDocuments: TJSONObject;
    [TRoleAuth('WebAPI_PCM')]
    function CheckLogin: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function CheckLoginTime: TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetDeviceID(const AJSONObject: TJSONObject): TJSonObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateSendPushTest(const AJSONObject: TJSONObject): TJSONObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateSendTimePushTest(const AJSONObject: TJSONObject): TJSONObject;
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetTimeDeviceID(const AJSONObject: TJSONObject): TJSONObject;
    [TRoleAuth('WebAPI_PCM')]
    function UpdateSendArchivPushTest(const AJSONObject: TJSONObject): TJSONObject;
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetArchivDeviceID(const AJSONObject: TJSONObject): TJSONObject;
    // kontakte ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetContacts: TJSonObject;
    // kontakte übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetContacts(const AJSONObject: TJSONObject): TJSonObject;
    // Kalender ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetCalendar: TJSonObject;
    // Kalender übernhmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetCalendar(const AJSONObject: TJSONObject): TJSonObject;
    // Passwörter ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetPasswords: TJSONObject;
    // Passwörter übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetPasswords(const AJSONObject: TJSONObject): TJSONObject;
    // Serials ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetSerials: TJSONObject;
    // Serials übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetSerials(const AJSONObject: TJSONObject): TJSONObject;
    // Ausgaben ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetExpenditure: TJSONObject;
    // Ausgaben übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetExpenditure(const AJSONObject: TJSONObject): TJSONObject;
    // Einnahmen ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetReceipts: TJSONObject;
    // Einnahmen übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetReceipts(const AJSONObject: TJSONObject): TJSONObject;
    // Belege ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetVouchers: TJSONObject;
    // Belege übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetVouchers(const AJSONObject: TJSONObject): TJSONObject;
    // Gutscheine ermitteln
    [TRoleAuth('WebAPI_PCM')]
    function UpdateGetGiftCards: TJSONObject;
    // Gutscheine übernehmen
    [TRoleAuth('WebAPI_PCM')]
    function AcceptSetGiftCards(const AJSONObject: TJSONObject): TJSONObject;
    {$EndRegion APP-API}
  end;
  {$METHODINFO OFF}
  {$EndRegion Type}
implementation

uses
  {$Region Uses}
  System.Diagnostics,
  PCM.Data,
  PCMService.API.Methods,
  PCM.Firebase,
  PCM.TimePush,
  PCM.ArchivPush,
  FireDAC.Comp.Client,
  PCMService.WebModules;
  {$EndRegion Uses}
////////////////////////////////////////////////////////////////////////////////
// Hilfsfunktionen                                                            //
////////////////////////////////////////////////////////////////////////////////
{$Region Hilfsfunktionen}
procedure LogFetchResult(const AApp, AEndpoint: string;
  const AResult: TJSONObject; const AStarted: TStopwatch);
var
  Value: TJSONValue;
  Details: string;
  Severity: Integer;
begin
  try
    Details := Format('app=%s endpoint=%s phase=completed duration_ms=%d http=%d',
      [AApp, AEndpoint, AStarted.ElapsedMilliseconds, GetInvocationMetadata.ResponseCode]);
    Severity := 0;
    if GetInvocationMetadata.ResponseCode >= 400 then Severity := 1;
    if AResult = nil then
    begin
      Details := Details + ' result=nil';
      Severity := 2;
    end
    else
    begin
      Value := AResult.GetValue('HasError');
      if Value is TJSONBool then
      begin
        Details := Details + ' has_error=' + Value.ToJSON;
        if SameText(Value.ToJSON, 'true') then Severity := 1;
      end;
      Value := AResult.GetValue('ErrorCode');
      if Value is TJSONNumber then Details := Details + ' error_code=' + Value.ToJSON;
    end;
    LogApiDiagnostic(Details, Severity);
  except
    // Logging must not alter the response or hide an application error.
  end;
end;

function v1.GetArchivSection(const ASection: string): TJSONObject;
var
  Metadata: TDSInvocationMetadata;
  FetchStarted: TStopwatch;
begin
  FetchStarted := TStopwatch.StartNew;
  LogApiDiagnostic('app=PCMArchiv endpoint=' + 'Archiv/' + ASection + ' phase=started');
  try
    Metadata := GetInvocationMetadata;
    if CheckUser then
      Result := GetArchivConfiguration_Intern(ASection)
    else
    begin
      Metadata.ResponseCode := 401;
      Result := TJSONObject.Create;
      Result.AddPair('HasError', TJSONBool.Create(True));
      Result.AddPair('ErrorCode', TJSONNumber.Create(401));
      Result.AddPair('Errormessage', 'Nicht autorisiert.');
    end;
    ResultToJSONContent(Result);
    LogFetchResult('PCMArchiv', 'Archiv/' + ASection, Result, FetchStarted);
  except
    on E: Exception do
    begin
      LogApiDiagnostic(Format('app=PCMArchiv endpoint=%s phase=exception duration_ms=%d exception=%s',
        ['Archiv/' + ASection, FetchStarted.ElapsedMilliseconds, E.ClassName]), 2);
      raise;
    end;
  end;
end;

function v1.UpdateGetArchivConfiguration: TJSONObject;
begin
  Result := GetArchivSection('');
end;

function v1.UpdateGetArchivMainCategories: TJSONObject;
begin
  Result := GetArchivSection('MainCategories');
end;

function v1.UpdateGetArchivSubCategories: TJSONObject;
begin
  Result := GetArchivSection('SubCategories');
end;

function v1.UpdateGetArchivIndices: TJSONObject;
begin
  Result := GetArchivSection('Indices');
end;

function v1.UpdateGetArchivDocuments: TJSONObject;
begin
  Result := GetArchivSection('Documents');
end;

function v1.UpdateGetArchivAssignments: TJSONObject;
begin
  Result := GetArchivSection('Assignments');
end;

procedure v1.ResultToJSONContent(const AJSONObject: TJSONObject);
var
  metaData: TDSInvocationMetadata;
begin
  metaData:= GetInvocationMetadata;
  metaData.ResponseContentType := 'application/json; charset=utf-8';
  metaData.ResponseContent := AJSONObject.ToJSON;
end;
{$EndRegion Hilfsfunktionen}
////////////////////////////////////////////////////////////////////////////////
// PCM - RESTfunktionen                                                       //
////////////////////////////////////////////////////////////////////////////////
{$Region Web-Api}
function v1.Createtoken: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  Result := CreateToken_Intern;
  metaData.ResponseCode:= iCode;
  metaData.ResponseMessage:= sMessage;
  ResultToJSONContent(Result);
end;
function v1.AcceptRefreshtoken(const AJSONObject: TJSONObject): TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  Result := RefreshToken_Intern(AJSONObject);
  metaData.ResponseCode:= iCode;
  metaData.ResponseMessage:= sMessage;
  ResultToJSONContent(Result);
end;
function v1.CancelDeletetoken: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
 metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count > 1 then
  begin
    Result := DeleteToken_Intern(StringReplace(metaData.QueryParams[0],'Token=','',[rfReplaceAll,rfIgnoreCase]),
    StrToInt(StringReplace(metaData.QueryParams[1],'Program=','',[rfReplaceAll,rfIgnoreCase])));
  end
  else
  begin
    Result := DeleteToken_Intern('',999);
  end;
  metaData.ResponseCode:= iCode;
  metaData.ResponseMessage:= sMessage;
  ResultToJSONContent(Result);
end;
function v1.UpdateCreateBackup: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if metaData.QueryParams.Count > 1 then
  begin
    Result := CreateBackup_Intern(StringReplace(metaData.QueryParams[0],'Token=','',[rfReplaceAll,rfIgnoreCase]),
    StringReplace(metaData.QueryParams[1],'Path=','',[rfReplaceAll,rfIgnoreCase]));
  end
  else
  begin
    metaData.ResponseCode:= 400;
    Result := CreateBackup_Intern('','');
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetKalenderConfig(const AJSONObject: TJSONObject): TJSONObject;
begin
  Result := GetKalenderConfig_Intern(AJSONObject);
  ResultToJSONContent(Result);
end;
{$EndRegion Web-Api}
////////////////////////////////////////////////////////////////////////////////
// APP - RESTfunktionen                                                       //
////////////////////////////////////////////////////////////////////////////////
{$Region APP-Api}
{$Region Server_Login}
function v1.CheckServer: TJSonObject;
var
  FetchStarted: TStopwatch;
begin
  FetchStarted := TStopwatch.StartNew;
  LogApiDiagnostic('app=Shared endpoint=' + 'CheckServer' + ' phase=started');
  try
    Result:= CheckServer_Intern;
    ResultToJSONContent(Result);
    LogFetchResult('Shared', 'CheckServer', Result, FetchStarted);
  except
    on E: Exception do
    begin
      LogApiDiagnostic(Format('app=Shared endpoint=%s phase=exception duration_ms=%d exception=%s',
        ['CheckServer', FetchStarted.ElapsedMilliseconds, E.ClassName]), 2);
      raise;
    end;
  end;
end;
function v1.CheckLogin: TJSonObject;
begin
  Result:= CheckLogin_Intern;
  ResultToJSONContent(Result);
end;
function v1.CheckLoginTime: TJSonObject;
var
  FetchStarted: TStopwatch;
begin
  FetchStarted := TStopwatch.StartNew;
  LogApiDiagnostic('app=PCMTime endpoint=' + 'CheckLoginTime' + ' phase=started');
  try
    Result:= CheckLoginTime_Intern;
    ResultToJSONContent(Result);
    LogFetchResult('PCMTime', 'CheckLoginTime', Result, FetchStarted);
  except
    on E: Exception do
    begin
      LogApiDiagnostic(Format('app=PCMTime endpoint=%s phase=exception duration_ms=%d exception=%s',
        ['CheckLoginTime', FetchStarted.ElapsedMilliseconds, E.ClassName]), 2);
      raise;
    end;
  end;
end;
function TimePushResponse(const Request: TJSONObject; RegisterDevice: Boolean): TJSONObject;
begin
  if not CheckUserApp then
  begin
    GetInvocationMetadata.ResponseCode := 401;
    Result := BadRequest;
    Exit;
  end;
  try
    Result := TimePushRequest(Request,RegisterDevice);
  except on E: Exception do
    begin
      Result := TJSONObject.Create;
      Result.AddPair('success',TJSONBool.Create(False));
      Result.AddPair('HasError',TJSONBool.Create(True));
      Result.AddPair('ErrorCode',TJSONNumber.Create(1));
      Result.AddPair('Errormessage',E.Message);
    end;
  end;
end;

function v1.UpdateSendTimePushTest(const AJSONObject: TJSONObject): TJSONObject;
begin
  Result := TimePushResponse(AJSONObject,False);
  ResultToJSONContent(Result);
end;

function v1.AcceptSetTimeDeviceID(const AJSONObject: TJSONObject): TJSONObject;
begin
  Result := TimePushResponse(AJSONObject,True);
  ResultToJSONContent(Result);
end;
function ArchivPushResponse(const Request: TJSONObject; RegisterDevice: Boolean): TJSONObject;
begin
  if not CheckUser then
  begin
    GetInvocationMetadata.ResponseCode := 401;
    Result := BadRequest;
    Exit;
  end;
  try
    Result := ArchivPushRequest(Request,RegisterDevice);
  except on E: Exception do
    begin
      Result := TJSONObject.Create;
      Result.AddPair('success',TJSONBool.Create(False));
      Result.AddPair('HasError',TJSONBool.Create(True));
      Result.AddPair('ErrorCode',TJSONNumber.Create(1));
      Result.AddPair('Errormessage',E.Message);
    end;
  end;
end;

function v1.UpdateSendArchivPushTest(const AJSONObject: TJSONObject): TJSONObject;
begin
  Result := ArchivPushResponse(AJSONObject,False);
  ResultToJSONContent(Result);
end;

function v1.AcceptSetArchivDeviceID(const AJSONObject: TJSONObject): TJSONObject;
begin
  Result := ArchivPushResponse(AJSONObject,True);
  ResultToJSONContent(Result);
end;
function v1.UpdateSendPushTest(const AJSONObject: TJSONObject): TJSONObject;
var
  Token, UserName: string;
  Conn: TFDConnection;
  Query: TFDQuery;
begin
  if not CheckUser then
  begin
    GetInvocationMetadata.ResponseCode := 401;
    Result := BadRequest;
    ResultToJSONContent(Result);
    Exit;
  end;
  Result := nil;
  try
    if (AJSONObject = nil) or not AJSONObject.TryGetValue<string>('DeviceToken', Token) or (Trim(Token) = '') then
      raise Exception.Create('DeviceToken fehlt');
    UserName := TDSSessionManager.GetThreadSession.GetData('Username');
    Conn := TFDConnection.Create(nil);
    try
      Conn.ConnectionDefName := 'PCM';
      Conn.Connected := True;
      Query := TFDQuery.Create(nil);
      try
        Query.Connection := Conn;
        Query.SQL.Text := 'SELECT d.DeviceToken FROM manager_devices d JOIN Benutzer b ON b.ID = d.ID_Benutzer WHERE b.Benutzer = :Benutzer AND d.DeviceToken = :Token';
        Query.ParamByName('Benutzer').AsString := UserName;
        Query.ParamByName('Token').AsString := Token;
        Query.Open;
        if Query.IsEmpty then
          raise Exception.Create('Geraet nicht fuer diesen Benutzer registriert. Bitte zuerst die App synchronisieren.');
      finally
        Query.Free;
      end;
    finally
      Conn.Free;
    end;
    Result := SendFirebaseTest(Token);
  except
    on E: Exception do
    begin
      Result := TJSONObject.Create;
      Result.AddPair('success', TJSONBool.Create(False));
      Result.AddPair('Errormessage', E.Message);
    end;
  end;
  ResultToJSONContent(Result);
end;
function v1.acceptSetDeviceID(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    metaData.ResponseCode:= 200;
    Result:= SetDeviceID_intern(AJSONObject);
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$ENdRegion Server_Login}
{$Region Kontakte}
function v1.UpdateGetContacts: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetKontakte_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetKontakte_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.acceptSetContacts(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetKontakte_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetKontakte_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetKontakte_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$EndRegion Kontakte}
{$Region Kalender}
function v1.UpdateGetCalendar: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetKalender_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetKalender_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.AcceptSetCalendar(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 2 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetKalender_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        StrTobool(StringReplace(metaData.QueryParams[1],'test=','',[rfReplaceAll,rfIgnoreCase])),
        AJSONObject);
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result:= SetKalender_Intern('',false,AJSONObject);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
{$EndRegion Kalender}
{$Region Passwords}
function v1.UpdateGetPasswords: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetPasswoerter_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetPasswoerter_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.AcceptSetPasswords(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetPasswoerter_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetPasswoerter_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetPasswoerter_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$EndRegion Passwords}
{$Region Serials}
function v1.UpdateGetSerials: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetSerials_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetSerials_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.AcceptSetSerials(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetSerials_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetSerials_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetSerials_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$ENdRegion Serials}
{$Region Einnahmen}
function v1.UpdateGetReceipts: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetEinnahmen_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetEinnahmen_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.AcceptSetReceipts(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetEinnahmen_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetEinnahmen_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetEinnahmen_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$EndRegion Einnahmen}
{$Region Ausgaben}
function v1.UpdateGetExpenditure: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetAusgaben_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetAusgaben_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.AcceptSetExpenditure(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetAusgaben_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetAusgaben_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetAusgaben_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$EndRegion Ausgaben}
{$Region Belege}
function v1.UpdateGetVouchers: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetVouchers_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetVouchers_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.AcceptSetVouchers(const AJSONObject: TJSONObject): TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetVouchers_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetVouchers_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetVouchers_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$EndRegion Belege}
{$Region Gutscheine}
function v1.UpdateGetGiftCards: TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetGiftCards_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetGiftCards_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.AcceptSetGiftCards(const AJSONObject: TJSONObject): TJSONObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetGiftCards_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetGiftCards_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetGiftCards_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$EndRegion Gutscheine}
{$EndRegion APP-Api}
{$Region TimeAPP-Api}
function v1.UpdateGetContactsZE: TJSonObject;
var
  metaData: TDSInvocationMetadata;
  FetchStarted: TStopwatch;
begin
  FetchStarted := TStopwatch.StartNew;
  LogApiDiagnostic('app=PCMTime endpoint=' + 'UpdateGetContactsZE' + ' phase=started');
  try
    metaData := GetInvocationMetadata;
    if CheckUserApp then
    begin
      if metaData.QueryParams.Count = 1 then
      begin
        Result := GetContactsZE_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result := GetContactsZE_Intern('');
      end;
    end
    else begin
      metaData.ResponseCode:= 401;
      Result:= BadRequest;
    end;
    ResultToJSONContent(Result);
    LogFetchResult('PCMTime', 'UpdateGetContactsZE', Result, FetchStarted);
  except
    on E: Exception do
    begin
      LogApiDiagnostic(Format('app=PCMTime endpoint=%s phase=exception duration_ms=%d exception=%s',
        ['UpdateGetContactsZE', FetchStarted.ElapsedMilliseconds, E.ClassName]), 2);
      raise;
    end;
  end;
end;
function v1.UpdateGetLastBooking: TJSonObject;
var
  metaData: TDSInvocationMetadata;
  FetchStarted: TStopwatch;
begin
  FetchStarted := TStopwatch.StartNew;
  LogApiDiagnostic('app=PCMTime endpoint=' + 'UpdateGetLastBooking' + ' phase=started');
  try
    metaData := GetInvocationMetadata;
    if CheckUserApp then
    begin
      if metaData.QueryParams.Count = 1 then
      begin
        Result := GetLastBooking_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result := GetPasswoerter_Intern('');
      end;
    end
    else begin
      metaData.ResponseCode:= 401;
      Result:= BadRequest;
    end;
    ResultToJSONContent(Result);
    LogFetchResult('PCMTime', 'UpdateGetLastBooking', Result, FetchStarted);
  except
    on E: Exception do
    begin
      LogApiDiagnostic(Format('app=PCMTime endpoint=%s phase=exception duration_ms=%d exception=%s',
        ['UpdateGetLastBooking', FetchStarted.ElapsedMilliseconds, E.ClassName]), 2);
      raise;
    end;
  end;
end;
function v1.AcceptSetLastBooking(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetLastBooking_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetLastBooking_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetLastBooking_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
function v1.UpdateGetBookingYear: TJSonObject;
var
  metaData: TDSInvocationMetadata;
  FetchStarted: TStopwatch;
begin
  FetchStarted := TStopwatch.StartNew;
  LogApiDiagnostic('app=PCMTime endpoint=' + 'UpdateGetBookingYear' + ' phase=started');
  try
    metaData := GetInvocationMetadata;
    if CheckUserApp then
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        Result := GetBookingYear_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),StringReplace(metaData.QueryParams[1],'Year=','',[rfReplaceAll,rfIgnoreCase]));
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result := GetBookingYear_Intern('','');
      end;
    end
    else begin
      metaData.ResponseCode:= 401;
      Result:= BadRequest;
    end;
    ResultToJSONContent(Result);
    LogFetchResult('PCMTime', 'UpdateGetBookingYear', Result, FetchStarted);
  except
    on E: Exception do
    begin
      LogApiDiagnostic(Format('app=PCMTime endpoint=%s phase=exception duration_ms=%d exception=%s',
        ['UpdateGetBookingYear', FetchStarted.ElapsedMilliseconds, E.ClassName]), 2);
      raise;
    end;
  end;
end;
function v1.UpdateGetAbsenceconfig: TJSonObject;
var
  metaData: TDSInvocationMetadata;
  FetchStarted: TStopwatch;
begin
  FetchStarted := TStopwatch.StartNew;
  LogApiDiagnostic('app=PCMTime endpoint=' + 'UpdateGetAbsenceconfig' + ' phase=started');
  try
    metaData := GetInvocationMetadata;
    if CheckUserApp then
    begin
      if metaData.QueryParams.Count = 1 then
      begin
        Result := GetAbsenceconfig_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result := GetAbsenceconfig_Intern('');
      end;
    end
    else begin
      metaData.ResponseCode:= 401;
      Result:= BadRequest;
    end;
    ResultToJSONContent(Result);
    LogFetchResult('PCMTime', 'UpdateGetAbsenceconfig', Result, FetchStarted);
  except
    on E: Exception do
    begin
      LogApiDiagnostic(Format('app=PCMTime endpoint=%s phase=exception duration_ms=%d exception=%s',
        ['UpdateGetAbsenceconfig', FetchStarted.ElapsedMilliseconds, E.ClassName]), 2);
      raise;
    end;
  end;
end;
function v1.UpdateGetAbsence: TJSonObject;
var
  metaData: TDSInvocationMetadata;
  FetchStarted: TStopwatch;
begin
  FetchStarted := TStopwatch.StartNew;
  LogApiDiagnostic('app=PCMTime endpoint=' + 'UpdateGetAbsence' + ' phase=started');
  try
    metaData := GetInvocationMetadata;
    if CheckUserApp then
    begin
      if metaData.QueryParams.Count = 1 then
      begin
        Result := GetAbsence_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result := GetAbsence_Intern('');
      end;
    end
    else begin
      metaData.ResponseCode:= 401;
      Result:= BadRequest;
    end;
    ResultToJSONContent(Result);
    LogFetchResult('PCMTime', 'UpdateGetAbsence', Result, FetchStarted);
  except
    on E: Exception do
    begin
      LogApiDiagnostic(Format('app=PCMTime endpoint=%s phase=exception duration_ms=%d exception=%s',
        ['UpdateGetAbsence', FetchStarted.ElapsedMilliseconds, E.ClassName]), 2);
      raise;
    end;
  end;
end;
function v1.AcceptSetOnlineBooking(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetOnlineBooking_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetOnlineBooking_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetOnlineBooking_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
{$EndRegion TimeAPP-Api}
////////////////////////////////////////////////////////////////////////////////
// Web-APP - RESTfunktionen                                                   //
////////////////////////////////////////////////////////////////////////////////
function v1.UpdateGetLogin: TJSonObject;
begin
  Result:= GetLoginWeb_Intern;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetEmployee: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetPersonalWeb_intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetPersonalWeb_intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetBookingData: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetBookinDataWeb_intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetBookinDataWeb_intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetMonthYearValues: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 3 then
    begin
      Result := GetMonthYearValuesWeb_intern(
      StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
      StrToint(StringReplace(metaData.QueryParams[1],'Month=','',[rfReplaceAll,rfIgnoreCase])),
      StrToint(StringReplace(metaData.QueryParams[2],'Year=','',[rfReplaceAll,rfIgnoreCase])));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetMonthYearValuesWeb_intern('',0,0);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetFehltage: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetFehltageWeb_intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetFehltageWeb_intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetFeiertage: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetFeiertageWeb_intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetFeiertageWeb_intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetLastBook: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetLastBookingWeb_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetLastBookingWeb_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.AcceptSetLastBook(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetLastBookingWeb_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetLastBookingWeb_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetLastBookingWeb_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
function v1.UpdateGetOnlineBook: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      Result := GetBookingWeb_Intern(StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetBookingWeb_Intern('');
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.AcceptSetOnlineBook(const AJSONObject: TJSONObject): TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUser then
  begin
    if metaData.QueryParams.Count = 1 then
    begin
      metaData.ResponseCode:= 200;
      Result:= SetOnlineBookingWeb_Intern(
        StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
        false,
        AJSONObject);
    end
    else
    begin
      if metaData.QueryParams.Count = 2 then
      begin
        metaData.ResponseCode:= 200;
        Result:= SetOnlineBookingWeb_Intern(
          StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
          true,
          AJSONObject);
      end
      else
      begin
        metaData.ResponseCode:= 400;
        Result:= SetOnlineBookingWeb_Intern('',false,AJSONObject);
      end;
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result)
end;
function v1.UpdateCalcMonth: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 3 then
    begin
      Result := CalcBookingWeb_Intern(
      StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
      StrToint(StringReplace(metaData.QueryParams[1],'Month=','',[rfReplaceAll,rfIgnoreCase])),
      StrToint(StringReplace(metaData.QueryParams[2],'Year=','',[rfReplaceAll,rfIgnoreCase])));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := CalcBookingWeb_Intern('',0,0);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
function v1.UpdateGetAbsenceDays: TJSonObject;
var
  metaData: TDSInvocationMetadata;
begin
  metaData := GetInvocationMetadata;
  if CheckUserWeb then
  begin
    if metaData.QueryParams.Count = 3 then
    begin
      Result := GetAbsenceWeb_intern(
      StringReplace(metaData.QueryParams[0],'ID_User=','',[rfReplaceAll,rfIgnoreCase]),
      StrToint(StringReplace(metaData.QueryParams[1],'Month=','',[rfReplaceAll,rfIgnoreCase])),
      StrToint(StringReplace(metaData.QueryParams[2],'Year=','',[rfReplaceAll,rfIgnoreCase])));
    end
    else
    begin
      metaData.ResponseCode:= 400;
      Result := GetAbsenceWeb_intern('',0,0);
    end;
  end
  else begin
    metaData.ResponseCode:= 401;
    Result:= BadRequest;
  end;
  ResultToJSONContent(Result);
end;
end.

