{
  ElgWOL.Pas
  ---------------------------------------------------------

    MORPHEE : Impl�mentation d'un "Wake On LAN"
    Par LEVEUGLE Damien

    ElGuevel (c) 2006
    Elguevel@Free.Fr

  ---------------------------------------------------------
    Notre unit� permettant le WakeOnLAN
  ---------------------------------------------------------
}


unit ElgWOL;

{.DATA}
interface

uses Windows, Winsock, ElgMAC;

procedure GoWOL( sAdresseMac : string ); // Fonction de reveille des machines

const MORPHEE_PORT_DEST = 3700;

{.CODE}
implementation

{ Construit le paquet et lance sur le r�seau }
procedure GoWOL( sAdresseMac : string );
var
  StructWSA   : WSAData;      // Structure pour initialiser la socket
  Sckt        : Integer;      // Handle de notre Socket
  Sckaddrin   : sockaddr_in;  // Structure de param�tres de la socket
  MagicPack   : TMagicPack;   // Trableau contenant le paquet magique
  AdresseMac  : TAdresseMac;  // Adresse MAC
  OptionVal   : Integer;      // Option utilis� pour la socket
begin
  (* On initialise *)
  // Initialisation (valeurs par d�faut)
  OptionVal := 1;
  FillChar( sckaddrin, SizeOf( sckaddrin ), #0 );
  // On transforme l'adresse mac sous forme chaine en tableau binaire
  StrToMac( AdresseMac, sAdresseMac );
  (* On construit le paquet magique *)
  CreateMagicPack( AdresseMAC, MagicPack );
  (* On va envoyer la trame *)
  try
    if ( WSAStartup( MAKEWORD(2,2), StructWSA ) = 0 ) then
    begin
      // Cr�e la socket et renvoi son Handle
      Sckt := Socket( AF_INET, SOCK_DGRAM, IPPROTO_IP );
      // Si socket cr�e on continue ...
      if ( Sckt <> INVALID_SOCKET ) then
      begin
        // Ensuite on la configure
  	Sckaddrin.sin_family      := AF_INET;
  	Sckaddrin.sin_addr.s_addr := Longint( INADDR_BROADCAST ); // ( 255.255.255.255 )
        Sckaddrin.sin_port        := htons( MORPHEE_PORT_DEST ); // je donne un port mais �� n'a pas d'importance !
        // On r�gle quelques options sur la socket afin de pouvoir broadcaster ( diffusion sur tout le r�seau )
        setsockopt( Sckt, SOL_SOCKET, SO_BROADCAST, PChar(@OptionVal), SizeOf(OptionVal) );
        // On se connecte
  	if ( connect( Sckt, Sckaddrin, 16 ) < 0 ) then
  	begin
          MessageBoxA( 0, PChar('Impossible de se connecter'), PChar('Stop'), MB_ICONWARNING );
          Exit;
  	end;
        // On envoi le paquet magique
  	sendto( Sckt, MagicPack, SizeOf(MagicPack), 0, Sckaddrin, SizeOf( Sckaddrin ) );
        // On ferme la socket
  	closesocket( Sckt );
      end else
        MessageBoxA( 0, PChar('Impossible de cr�er la socket'), PChar('Stop'), MB_ICONWARNING );
    end else
      MessageBoxA( 0, PChar('Impossible d''initialiser la socket'), PChar('Stop'), MB_ICONWARNING );
  finally
    WSACleanup(); // Nettoye buffer

  end; // Fin Try

end;  // Fin Begin

end.
