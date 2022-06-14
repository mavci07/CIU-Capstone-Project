class Stokmodel {
  int sid;
  String stokkod;
  String stokad;
  String birim;
  String barkod1;
  String barkod2;
  String barkod3;
  String sfiyat1;
  String sfiyat2;
  String kod4;
  String kod9;
  String label;
  dynamic value;
  Stokmodel(this.stokkod, this.stokad, this.birim, this.barkod1, this.barkod2,
      this.barkod3, this.sfiyat1, this.sfiyat2, this.kod4, this.kod9);
  Stokmodel.withID(
      this.sid,
      this.stokkod,
      this.stokad,
      this.birim,
      this.barkod1,
      this.barkod2,
      this.barkod3,
      this.sfiyat1,
      this.sfiyat2,
      this.kod4,
      this.kod9);
  Stokmodel.withJ(
      {this.sid,
      this.stokkod,
      this.stokad,
      this.birim,
      this.barkod1,
      this.barkod2,
      this.barkod3,
      this.sfiyat1,
      this.sfiyat2,
      this.kod4,
      this.kod9});
  Stokmodel.withL({this.label, this.value});

  @override
  toString() =>
      '$stokkod $stokad $birim $barkod1 $barkod2 $barkod3 $sfiyat1 $sfiyat2 $kod4 $kod9';

  factory Stokmodel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Stokmodel.withJ(
        sid: json["sid"],
        stokkod: json["stokkod"],
        stokad: json["stokad"],
        birim: json["birim"],
        barkod1: json["barkod1"],
        barkod2: json["barkod2"],
        barkod3: json["barkod3"],
        sfiyat1: json["sfiyat1"],
        sfiyat2: json["sfiyat2"],
        kod4: json["kod4"],
        kod9: json["kod9"]);
  }
  factory Stokmodel.fromJsonlabel(Map<String, dynamic> json) {
    return Stokmodel.withL(label: json['stokad'], value: json['stokkod']);
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    //map["cid"] = cid;
    map["stokkod"] = stokkod;
    map["stokad"] = stokad;
    map["birim"] = birim;
    map["barkod1"] = barkod1;
    map["barkod2"] = barkod2;
    map["barkod3"] = barkod3;
    map["sfiyat1"] = sfiyat1;
    map["sfiyat2"] = sfiyat2;
    map["kod4"] = kod4;
    map["kod9"] = kod9;
    return map;
  }

  static List<Stokmodel> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => Stokmodel.fromJson(item)).toList();
  }

  Stokmodel.fromMap(Map<String, dynamic> map) {
    // this.cid = map["cid"];
    this.stokkod = map["stokkod"];
    this.stokad = map["stokad"];
    this.birim = map["birim"];
    this.barkod1 = map["barkod1"];
    this.barkod2 = map["barkod2"];
    this.barkod3 = map["barkod3"];
    this.sfiyat1 = map["sfiyat1"];
    this.sfiyat2 = map["sfiyat2"];
    this.kod4 = map["kod4"];
    this.kod9 = map["kod9"];
  }
}
