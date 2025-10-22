object webPCMModul: TwebPCMModul
  Actions = <
    item
      Default = True
      Name = 'DefaultHandler'
      PathInfo = '/'
      OnAction = WebModule1DefaultHandlerAction
    end>
  BeforeDispatch = WebModuleBeforeDispatch
  Height = 500
  Width = 621
  PixelsPerInch = 144
  object wdispAuth: TDSHTTPWebDispatcher
    DSContext = 'PCM/'
    RESTContext = 'Sandbox/'
    Server = DSServer1
    Filters = <>
    AuthenticationManager = authMngr
    WebDispatch.PathInfo = 'PCM/Sandbox/v0*'
    Left = 132
    Top = 101
  end
  object authMngr: TDSAuthenticationManager
    OnUserAuthenticate = authMngrUserAuthenticate
    Roles = <>
    Left = 132
    Top = 185
  end
  object dsSrvClassAuth: TDSServerClass
    OnGetClass = dsSrvClassAuthGetClass
    Server = DSServer1
    LifeCycle = 'Invocation'
    Left = 156
    Top = 17
  end
  object wdispService: TDSHTTPWebDispatcher
    DSContext = 'PCM/'
    RESTContext = 'sandbox-api/'
    Server = DSServer1
    Filters = <>
    AuthenticationManager = authMngr
    WebDispatch.PathInfo = 'PCM/sandbox-api*'
    Left = 244
    Top = 133
  end
  object dsSrvClassService_V1: TDSServerClass
    OnGetClass = dsSrvClassService_V1GetClass
    Server = DSServer1
    LifeCycle = 'Invocation'
    Left = 276
    Top = 17
  end
  object wdispServiceHTTPS: TDSHTTPWebDispatcher
    DSContext = 'PCM/'
    RESTContext = 'api/'
    Server = DSServer1
    Filters = <>
    AuthenticationManager = authMngr
    WebDispatch.PathInfo = 'PCM/api*'
    Left = 372
    Top = 101
  end
  object DSServer1: TDSServer
    Left = 36
    Top = 17
  end
end
