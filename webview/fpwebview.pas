program fpwebview;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,
  math, sysutils,
  webview;

var
  w: PWebView;
  html: String;
  i : integer = 0;

const
  head = 'data:text/html;charset=utf-8,'+{$INCLUDE head.inc}
  body = {$INCLUDE body.inc}
  foot = {$INCLUDE foot.inc}

procedure MontaTabela(const seq: PChar; const req: PChar; arg: Pointer); cdecl;
var
  s: String;
begin
  s:='<thead><tr class=\"w3-red\"><th>Nome</th><th>Sobrenome</th><th>Idade</th></tr></thead>';
  s:=s+Format('<tr><td>%s</td><td>%s</td><td>%u</td></tr><tr>',['Antônio','Santos',Random(50)]);
  s:=s+Format('<tr><td>%s</td><td>%s</td><td>%u</td></tr><tr>',['Miguel','Sobral',Random(50)]);
  s:=s+Format('<tr><td>%s</td><td>%s</td><td>%u</td></tr><tr>',['João','Rios',Random(50)]);
  s:=Format('{result: "%s"}',[s]);
  webview_return(w,seq,WebView_Return_Ok,PChar(s));
end;

procedure Contador(const seq: PChar; const req: PChar; arg: Pointer); cdecl;
var
  s: String;
begin
  inc(i);
  s:=Format('{result: "%u"}',[i]);
  webview_return(w,seq,WebView_Return_Ok,PChar(s));
end;

begin
  { Set math masks. libwebview throws at least one of these from somewhere deep inside. }
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
  w := webview_create(WebView_DevTools, nil);
  webview_set_size(w, 700, 700, WebView_Hint_None);
  webview_set_title(w, PChar('FreePascal + Webview'));
  webview_bind(w, PChar('HostContador'), @Contador, nil);
  webview_bind(w, PChar('HostModTabela'), @MontaTabela, nil);
  html:=head+body+foot;
  webview_navigate(w, PChar(html));
  webview_run(w);
  webview_destroy(w);
end.

