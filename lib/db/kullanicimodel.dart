class Kullanicilar {
  int id;
  String kuladi;
  String pass;
  String name;
  int grup;
  int durum;
  String serino;
  String nakitkarsihesap;
  String kkkarsihesap;
  String rutkodu;

  Kullanicilar(this.kuladi, this.pass, this.name, this.grup, this.durum,
      this.serino, this.nakitkarsihesap, this.kkkarsihesap, this.rutkodu);
  Kullanicilar.login(this.kuladi, this.pass);
  Kullanicilar.withID(
      this.id,
      this.kuladi,
      this.pass,
      this.name,
      this.grup,
      this.durum,
      this.serino,
      this.nakitkarsihesap,
      this.kkkarsihesap,
      this.rutkodu);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["id"] = id;
    map["kuladi"] = kuladi;
    map["pass"] = pass;
    map["name"] = name;
    map["grup"] = grup;
    map["durum"] = durum;
    map["serino"] = serino;
    map["nakitkarsihesap"] = nakitkarsihesap;
    map["kkkarsihesap"] = kkkarsihesap;
    map["rutkodu"] = rutkodu;
    return map;
  }

  Kullanicilar.fromMap(Map<String, dynamic> map) {
    this.id = map["id"];
    this.kuladi = map["kuladi"];
    this.pass = map["pass"];
    this.name = map["name"];
    this.grup = map["grup"];
    this.durum = map["durum"];
    this.serino = map["serino"];
    this.nakitkarsihesap = map["nakitkarsihesap"];
    this.kkkarsihesap = map["kkkarsihesap"];
    this.rutkodu = map["rutkodu"];
  }
}
