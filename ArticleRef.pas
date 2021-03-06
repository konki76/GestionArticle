unit ArticleRef;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBTables, StdCtrls, Grids, DBGrids, ExtCtrls, MemDS,
  DBAccess, MyAccess, CheckLst;

type
  TFormRecherche = class(TForm)
    mag: TMyConnection;
    Q_mag: TMyQuery;
    LabelRef: TLabel;
    B_Rechercher: TButton;
    EditRef: TEdit;
    BtnFermer: TButton;
    STextExistence: TStaticText;
    B_Ajout: TButton;
    CLB_Mag: TCheckListBox;
    B_Supprimer: TButton;
    B_Voir: TButton;
    procedure B_RechercherClick(Sender: TObject);
    procedure BtnFermerClick(Sender: TObject);
    procedure sqlCreate(Sender: TObject);
    procedure B_AjoutClick(Sender: TObject);
    procedure B_VoirClick(Sender: TObject);
    procedure CLB_MagClickCheck(Sender: TObject);
    procedure B_SupprimerClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormRecherche: TFormRecherche;
  ref: String;
  magasins: tstringlist;
implementation

uses AjoutArticle, AffichageArticle;

{$R *.dfm}
procedure TFormRecherche.B_RechercherClick(Sender: TObject);
var i: integer;
begin
  ref:= UpperCase(EditRef.Text);
  if (length(ref) = 6) then
  begin
    with Q_mag do
		begin
      if (CLB_Mag.Items.Count = 0) then
	    begin
				for i:=0 to (magasins.Count - 1) do
				begin
					close;
					SQL.Clear;
					SQL.add('SELECT codeArticle FROM '+ LowerCase(magasins[i]) +
          ' WHERE codeArticle = ' + quotedstr(ref) );
					open;
					if FieldByName('codeArticle').AsString = ref then
					begin
	        	CLB_Mag.Items.add(magasins[i]);
					end;
				end;
	   	end;
		end;

  end  {
    with Q_article_divers do
    begin
      active:=false;
      SQL.Clear;
      SQL.add('SELECT type FROM article_divers WHERE type = ' + quotedstr(ref) );
      active:=true;
    end;
    if Q_article_divers.FieldByName('type').AsString = ref then
    begin
      L_article_divers.Caption:= 'existe';
    end
    else begin
      L_article_divers.Caption:= 'null';
    end;
  }

  else begin
    showMessage('Veuillez renseignez une r�f�rence de 6 caract�res');
  end;
end {BtnRechClick};

procedure TFormRecherche.BtnFermerClick(Sender: TObject);
begin
  FormRecherche.Close;
end;

procedure TFormRecherche.sqlCreate(Sender: TObject);
begin
  STextExistence.Caption := 'Liste des magasins dans laquelle la '+
  #13#10+'r�f�rence est pr�sente:';
  STextExistence.Height := 40;
  with Q_mag do
  begin
    close;
    SQL.Clear;
    SQL.add('SELECT nomMagasin FROM refmag ' );
    open;
    magasins:= TStringList.Create;
    while not Eof do
    begin
      magasins.Add(FieldByName('nomMagasin').AsString);
      next;
    end
  end;
end;

procedure TFormRecherche.B_AjoutClick(Sender: TObject);
begin
  FormAjout.Show;
end;


procedure TFormRecherche.B_VoirClick(Sender: TObject);
begin
  FormAffichageArticle.L_Magasin.Caption := CLB_Mag.Items[CLB_Mag.ItemIndex];
  FormAffichageArticle.L_CodeArticle.Caption := EditRef.Text;
  with Q_Mag do
  begin
	  try
      close;
	    SQL.Clear;
	    SQL.Add('SELECT designation, prix FROM '+ LowerCase(CLB_Mag.Items[CLB_Mag.ItemIndex]) +' WHERE codeArticle = :codeArticle');
			ParamByName('codeArticle').AsString := EditRef.Text;
			Open;
			while not Eof do
      begin
        FormAffichageArticle.L_Designation.Caption := FieldByName('designation').AsString;
        FormAffichageArticle.L_Prix.Caption := FieldByName('prix').AsString;
        next;
      end;
	    finally
	      Free;
	    end;
  end;
  FormAffichageArticle.Show;
end;

procedure TFormRecherche.CLB_MagClickCheck(Sender: TObject);
begin
  B_Voir.Visible := true;
  B_Supprimer.Visible := true;
end;

procedure TFormRecherche.B_SupprimerClick(Sender: TObject);
begin
  with Q_Mag do
  begin
	  try
	    SQL.Clear;
	    SQL.Add('DELETE FROM '+ LowerCase(CLB_Mag.Items[CLB_Mag.ItemIndex]) +' WHERE codeArticle = :codeArticle);');
			ParamByName('codeArticle').AsString := EditRef.Text;
			Execute;
	  finally
	    Free;
	  end;
  end;
end;

end.
