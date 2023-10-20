unit PCMService.WebModules;

interface

uses
  System.SysUtils, System.Classes, IdHashMessageDigest,
  Web.HTTPApp, Web.WebFileDispatcher, Web.HTTPProd,
  Datasnap.DSHTTPWebBroker, Datasnap.DSServer, DataSnap.DSAuth, Datasnap.DSCommonServer,
  IPPeerServer, IdContext, Datasnap.DSHTTP, Data.DBXPlatform,
  DbxCompressionFilter, DbxSocketChannelNative, Datasnap.DSTCPServerTransport,
  Datasnap.DSHTTPCommon,RESTServer.Service.Records ;

type
  TwebPCMModul = class(TWebModule)
    wdispAuth: TDSHTTPWebDispatcher;
    authMngr: TDSAuthenticationManager;
    dsSrvClassAuth: TDSServerClass;
    wdispService: TDSHTTPWebDispatcher;
    dsSrvClassService_V1: TDSServerClass;
    wdispServiceHTTPS: TDSHTTPWebDispatcher;
    DSServer1: TDSServer;
    procedure dsSrvClassAuthGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure authMngrUserAuthenticate(Sender: TObject;
      const Protocol, Context, User, Password: string; var valid: Boolean;
      UserRoles: TStrings);
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure dsSrvClassService_V1GetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);

  private
    { Private-Deklarationen }

  public
    { Public-Deklarationen }

  end;

var
  WebModuleClass: TComponentClass = TwebPCMModul;


implementation


{$R *.dfm}

uses
  Web.WebReq, Vcl.Dialogs, Datasnap.DSSession,
  PCMService.vers0,
  RESTServer.Service.Version.vers1,
  PCM.Data,
  PCM.Functions;

procedure TwebPCMModul.WebModule1DefaultHandlerAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.StatusCode:= 200;
  Response.Content := '{' + slinebreak  +
                      '  "ErrorCode": 1,' + slinebreak  +
                      '  "Errormessage": " unknown API-Call"' + slinebreak  +
                      '}';
end;
procedure TwebPCMModul.WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.SetCustomHeader('Access-Control-Allow-Origin','*');
  Response.SetCustomHeader('Access-Control-Allow-Methods','POST, GET, OPTIONS, DELETE, PUT');
  Response.SetCustomHeader('Access-Control-Allow-Headers','append,delete,entries,foreach,get,has,keys,set,values,Authorization');
  Response.SetCustomHeader('Access-Control-Expose-Headers','*');
  if Trim(Request.GetFieldByName('Access-Control-Request-Headers')) <> '' then
  begin
    Response.SetCustomHeader('Access-Control-Allow-Headers', Request.GetFieldByName('Access-Control-Request-Headers'));
    Handled := True;
  end;
end;
procedure TwebPCMModul.dsSrvClassAuthGetClass(DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := PCMService.vers0.v0;
end;
procedure TwebPCMModul.dsSrvClassService_V1GetClass(DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := RESTServer.Service.Version.vers1.v1;
end;
procedure TwebPCMModul.authMngrUserAuthenticate(Sender: TObject; const Protocol, Context, User, Password: string; var valid: Boolean; UserRoles: TStrings);
var
  sMD5PassLogin,sMD5PassConst: String;
begin
  TDSSessionManager.GetThreadSession.PutData('Username',User);
//  if User = 'PCM' then
//  begin
    with TIdHashMessageDigest5.Create do
    begin
      sMD5PassLogin := HashStringAsHex(Password);
      sMD5PassLogin := LowerCase(sMD5PassLogin);
      sMD5PassConst := HashStringAsHex(Password);
      sMD5PassConst := LowerCase(sMD5PassConst);
      Free;
    end;
    TDSSessionManager.GetThreadSession.PutData('Password', sMD5PassLogin);
    if sMD5PassConst = sMD5PassLogin then
    begin
      UserRoles.Add('WebAPI_PCM');
      UserRoles.Add('WebAPI_PCMManager');
      UserRoles.Add('WebAPI_PCMMP3');
      UserRoles.Add('App_PCM');
      valid := True;
    end
    else begin
//      WriteLog(PCM_Logname,'Falsches Passwort',1);
    end;
end;

initialization

finalization
  Web.WebReq.FreeWebModules;

end.

