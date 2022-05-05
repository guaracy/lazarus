unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  fpjson, jsonparser,
  opensslsockets, fphttpclient;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    lblMessage: TLabel;
    RadioGroup1: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure RadioGroup1SelectionChanged(Sender: TObject);
  private
    httpCliente : TFPHTTPClient;
    tms:TMemoryStream;
    procedure ProximoAnimal;
    procedure ProximaPessoa;
    procedure ProximaImagem;
    procedure Mensagem(aMSG:string);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

/// https://ahungry.com/blog/2020-04-24-Puny-GUI-Puppy-Finder.html


procedure TForm1.FormCreate(Sender: TObject);
begin
  httpCliente := TFPHTTPClient.Create(nil);
  tms:=TMemoryStream.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(httpCliente) then
    FreeAndNil(httpCliente);
  if Assigned(tms) then
    FreeAndNil(tms);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  RadioGroup1.ItemIndex:=0;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  ProximaImagem;
end;

procedure TForm1.RadioGroup1SelectionChanged(Sender: TObject);
begin
  ProximaImagem;
end;

procedure TForm1.ProximoAnimal;
const
  cURL = 'https://dog.ceo/api/breeds/image/random';
var
  jData : TJSONData;
  aURL : String;
begin
  try
    aURL := httpCliente.Get(cURL);
  except
    ShowMessage('Erro na leitura da imagem.');
    exit;
  end;
  jData := GetJSON(aURL);
  aURL:=jData.GetPath('message').AsString;
  httpCliente.Get(aURL,tms);
  tms.Seek(0,soFromBeginning);
  image1.Picture.LoadFromStream(tms);
  tms.Seek(0,soFromBeginning);
  image1.Stretch:=(image1.Width<image1.Picture.Bitmap.Width) or (image1.Height<image1.Picture.Bitmap.Height);
  jData.Free;
  Mensagem(aURL);
end;

procedure TForm1.ProximaPessoa;
const
  cURL ='https://thispersondoesnotexist.com/image';
begin
  try
    httpCliente.Get(cURL,tms);
  except
    ShowMessage('Erro na leitura da imagem.');
    exit;
  end;
  tms.Seek(0,soFromBeginning);
  image1.Picture.LoadFromStream(tms);
  tms.Seek(0,soFromBeginning);
  //image1.Stretch:=(image1.Width<image1.Picture.Bitmap.Width) or (image1.Height<image1.Picture.Bitmap.Height);
  with image1.Picture.Bitmap do
    image1.Stretch:=(image1.Width<Width) or (image1.Height<Height);
  Mensagem(cURL);
end;

procedure TForm1.ProximaImagem;
begin
  if RadioGroup1.ItemIndex = 0 then
    ProximoAnimal
  else
    ProximaPessoa;

end;

procedure TForm1.Mensagem(aMSG: string);
begin
  with image1.Picture.Bitmap do
    lblMessage.Caption:=Format('%s (%ux%u)',[aMSG,Width,Height]);
end;

end.

