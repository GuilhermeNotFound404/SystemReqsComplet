program SistemaPedido;

uses
  System.StartUpCopy,
  FMX.Forms,
  Menu in 'Menu.pas' {Form1},
  Tipo in 'Tipo.pas' {Form2},
  Cliente in 'Cliente.pas' {Form3},
  Marca in 'Marca.pas' {Form4},
  Product in 'Product.pas' {Form5},
  Venda in 'Venda.pas' {Form6};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm6, Form6);
  Application.Run;
end.
