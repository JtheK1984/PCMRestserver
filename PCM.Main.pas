unit PCM.Main;

interface

uses
  {$Region Ues}
  Data.Bind.Components,
  Data.Bind.ObjectScope,
  Data.DB,
  Datasnap.DSHTTP,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.UI,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Error,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Pool,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  IdBaseComponent,
  IdComponent,
  IdContext,
  IdCustomHTTPServer,
  IdCustomTCPServer,
  IdHTTPServer,
  IdHTTPWebBrokerBridge,
  IdIOHandler,
  IdIOHandlerSocket,
  IdIOHandlerStack,
  IdServerIOHandler,
  IdSSL,
  IdSSLOpenSSL,
  IdSSLOpenSSLHeaders,
  inifiles,
  Registry,
  REST.Authenticator.Basic,
  REST.Client,
  REST.Types,
  RESTServer.Service.Records,
  System.Classes,
  system.DateUtils,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.SvcMgr,
  Web.HTTPApp,
  Winapi.Messages,
  Winapi.Windows;
  {$EndRegion Ues}
type
  {$Region Type}
  TMyIdSSLContext = class(TIdSSLContext)
end;
type
  TAufgabenThread = class(TThread)
  private
    { Private-Deklarationen }
  public
    Proc: TProcedure;
end;
type
  TPCM_Restserver = class(TService)
    tmrServiceStart: TTimer;
    FDManager: TFDManager;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure DoParseAuthentication(AContext: TIdContext; const AAuthType, AAuthData: String; var VUsername, VPassword: String; var VHandled: Boolean);
    procedure DoParseAuthenticationHTTPS(AContext: TIdContext; const AAuthType, AAuthData: String; var VUsername, VPassword: String; var VHandled: Boolean);
    procedure tmrServiceStartTimer(Sender: TObject);
    procedure ServiceAfterInstall(Sender: TService);
    procedure IdHTTPServer1QuerySSLPort(APort: Word; var VUseSSL: Boolean);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    FIOHandleSSL: TIdServerIOHandlerSSLOpenSSL;
    FServer_HTTP: TIdHTTPWebBrokerBridge;
    FServer_HTTPS: TIdHTTPWebBrokerBridge;
    RESTServerConfig: TRESTServerConfig;
    function GetServiceController: TServiceController; override;
  end;
  {$EndRegion Type}
var
  {$Region var}
  PCM_Restserver: TPCM_Restserver;
  fINI: TextFile;
  filename: String;
  {$EndRegion var}
implementation
{$R *.dfm}
uses
  {$Region Uses}
  PCM.Functions,
  PCM.Data,
  PCMService.WebModules,
  Datasnap.DSSession,
  IdGlobal,
  PCM.Strings;
  {$EndRegion Uses}
////////////////////////////////////////////////////////////////////////////////
// Servicefunctions                                                           //
////////////////////////////////////////////////////////////////////////////////
{$Region Servicefunctions}
procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  PCM_Restserver.Controller(CtrlCode);
end;
function TPCM_Restserver.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;
procedure TPCM_Restserver.DoParseAuthentication(AContext: TIdContext; const AAuthType, AAuthData: String; var VUsername, VPassword: String;  var VHandled: Boolean);
begin
  VHandled := True;
end;
procedure TPCM_Restserver.DoParseAuthenticationHTTPS(AContext: TIdContext; const AAuthType, AAuthData: String; var VUsername, VPassword: String;  var VHandled: Boolean);
begin
  VHandled := True;
end;
procedure TPCM_Restserver.IdHTTPServer1QuerySSLPort(APort: Word; var VUseSSL: Boolean);
begin
  VUseSSL:= true;
end;
procedure TPCM_Restserver.ServiceAfterInstall(Sender: TService);
var
  reg: TRegistry;
begin
  reg := TRegistry.Create(KEY_READ or KEY_Write);
  try
    reg.RootKey:= HKEY_LOCAL_MACHINE;
    Writelog(PCM_Logname,rs_PCMRestserver_Registry,0);
    if reg.OpenKey('System\CurrentControlSet\Services\PCM_Service',False) then
      reg.WriteString('Description','PCM-Resterver');
  finally
    reg.Free;
  end;
end;
procedure TPCM_Restserver.ServiceStart(Sender: TService;var Started: Boolean);
begin
  if dm_PCM.ReadServerAdress then
  begin
    WriteLog(PCM_LOGname,rs_Function_Helper_Verbindungerfolgreich,0);
    tmrServiceStart.Enabled := True;
  end;
end;
procedure TPCM_Restserver.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  FServer_HTTP.Active := False;
  FServer_HTTPS.Active := False;
  FServer_HTTP.Bindings.Clear;
  FServer_HTTPS.Bindings.Clear;
  FIOHandleSSL.Free;
end;
procedure TPCM_Restserver.tmrServiceStartTimer(Sender: TObject);
var
  FSSLContext: TMyIdSSLContext;
begin
  tmrServiceStart.Enabled := False;
  try
    RESTServerConfig.LoadData;
    if not Assigned(FServer_HTTP) then
    begin
      FServer_HTTP := TIdHTTPWebBrokerBridge.Create(nil);
      FServer_HTTP.OnParseAuthentication := DoParseAuthentication;
    end;

    if not Assigned(FServer_HTTPS) then
    begin
      FServer_HTTPS := TIdHTTPWebBrokerBridge.Create(nil);
      FServer_HTTPS.OnParseAuthentication := DoParseAuthenticationHTTPS;
    end;

    if not Assigned(dm_PCM) then
    begin
      Application.CreateForm(Tdm_PCM, dm_PCM);
    end;


    if not FServer_HTTP.Active then
    begin
      FServer_HTTP.Bindings.Clear;
      FServer_HTTP.DefaultPort:= RESTServerConfig.Port_HTTP;
      FServer_HTTP.ReuseSocket:= rstrue;
      FServer_HTTP.Active := True;
    end;
    if not FServer_HTTPS.Active then
    begin
      FServer_HTTPS.Bindings.Clear;

      FIOHandleSSL := TIdServerIOHandlerSSLOpenSSL.Create(FServer_HTTPS);
      FIOHandleSSL.SSLOptions.CertFile := RESTServerConfig.SSL_PublicKey;
      Writelog(PCM_Logname,'CertFile: ' + RESTServerConfig.SSL_PublicKey,0);
      FIOHandleSSL.SSLOptions.KeyFile := RESTServerConfig.SSL_PrivateKey;
      Writelog(PCM_Logname,'KeyFile: ' + RESTServerConfig.SSL_PrivateKey,0);

      if Length(RESTServerConfig.SSL_CA_Key) > 0 then
      begin
        FIOHandleSSL.SSLOptions.RootCertFile := RESTServerConfig.SSL_CA_Key;
        Writelog(PCM_Logname,'RootCertFile: ' + RESTServerConfig.SSL_CA_Key,0);
      end;
      FIOHandleSSL.SSLOptions.Method := TIdSSLVersion.sslvTLSv1_2;
      FIOHandleSSL.SSLOptions.SSLVersions := [TIdSSLVersion.sslvTLSv1_2];
      FIOHandleSSL.SSLOptions.CipherList := //'ECDHE-ECDSA-AES128-GCM-SHA256:' +
        'ECDHE-RSA-AES128-GCM-SHA:' +
        'ECDHE-RSA-AES128-GCM-SHA256:' +
        //'ECDHE-RSA-AES256-GCM-SHA384:' +
        //'ECDHE-ECDSA-AES256-GCM-SHA384:' +
        'DHE-RSA-AES128-GCM-SHA:' +
        'DHE-RSA-AES128-GCM-SHA256:' +
        //'ECDHE-RSA-AES128-SHA256:' +
        //'DHE-RSA-AES128-SHA256:' +
        //'ECDHE-RSA-AES256-SHA384:' +
        //'DHE-RSA-AES256-SHA384:' +
        //'ECDHE-RSA-AES256-SHA256:' +
        //'DHE-RSA-AES256-SHA256:' +
        'HIGH:' +
        '!aNULL:' +
        '!eNULL:' +
        '!EXPORT:' +
        '!DES:' +
        '!RC4:' +
        '!MD5:' +
        '!PSK:' +
        '!SRP:' +
        '!CAMELLIA';
      FServer_HTTPS.IOHandler := fIOHandleSSL;
      FServer_HTTPS.DefaultPort := RESTServerConfig.Port_HTTPS;
      FServer_HTTPS.ReuseSocket:= rstrue;
      FServer_HTTPS.OnQuerySSLPort :=  IdHTTPServer1QuerySSLPort;
      FServer_HTTPS.Active := True;
      FSSLContext := TMyIdSSLContext(FIOHandleSSL.SSLContext);
      SSL_CTX_set_ecdh_auto(FSSLContext.fContext, 1);
    end;
  except
    ON Ex: Exception DO
    BEGIN
      Writelog(PCM_logname,rs_PCMRestserver_StartError + Ex.Message,2);
    END;
  end;
end;
{$EndRegion Servicefunctions}
end.
