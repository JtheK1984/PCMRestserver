program PCMRestserver;

uses
  Vcl.SvcMgr,
  Web.WebReq,
  Windows,
  IdHTTPWebBrokerBridge,
  RESTServer.Service.Version.vers1 in 'Helper\RESTServer.Service.Version.vers1.pas' {frmServerMethods: TDSServerModule},
  PCM.Main in 'PCM.Main.pas' {PCM_Restserver: TService},
  PCMService.WebModules in 'Helper\PCMService.WebModules.pas' {webPCMModul: TWebModule},
  PCM.Data in 'PCM.Data.pas' {dm_PCM: TDataModule},
  PCMService.vers0 in 'Helper\PCMService.vers0.pas',
  PCMService.API.Methods in 'Helper\PCMService.API.Methods.pas',
  RESTServer.Service.Records in 'Helper\RESTServer.Service.Records.pas';

{$R *.RES}

{$SetPEOptFlags IMAGE_DLLCHARACTERISTICS_TERMINAL_SERVER_AWARE}
{$SetPEFlags IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP or IMAGE_FILE_NET_RUN_FROM_SWAP or IMAGE_FILE_LARGE_ADDRESS_AWARE}
begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TPCM_Restserver, PCM_Restserver);
  Application.CreateForm(Tdm_PCM, dm_PCM);
  Application.Run;
end.

