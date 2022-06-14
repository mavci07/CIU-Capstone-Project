class Carimodel {
  int cid;
  String carikod;
  String cariunvan;
  String borc;
  String alacak;
  String bakiye;
  String grupkodu;
  int bolgekodu;
  dynamic value;
  Carimodel(this.carikod, this.cariunvan, this.borc, this.alacak, this.bakiye,
      this.grupkodu, this.bolgekodu);
  Carimodel.withID(this.cid, this.carikod, this.cariunvan, this.borc,
      this.alacak, this.bakiye, this.grupkodu, this.bolgekodu);
  Carimodel.withJ(
      {this.cid,
      this.carikod,
      this.cariunvan,
      this.borc,
      this.alacak,
      this.bakiye,
      this.grupkodu,
      this.bolgekodu});
  //Carimodel.withL({this.label, this.value});

  @override
  toString() => '$carikod $cariunvan $borc $alacak $bakiye $grupkodu';

  factory Carimodel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Carimodel.withJ(
      cid: json["cid"],
      carikod: json["carikod"],
      cariunvan: json["cariunvan"],
      borc: json["borc"],
      alacak: json["alacak"],
      bakiye: json["bakiye"],
      grupkodu: json["grupkodu"],
      bolgekodu: json["bolgekodu"],
    );
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["carikod"] = carikod;
    map["cariunvan"] = cariunvan;
    map["borc"] = borc;
    map["alacak"] = alacak;
    map["bakiye"] = bakiye;
    map["grupkodu"] = grupkodu;
    map["bolgekodu"] = bolgekodu;
    return map;
  }

  static List<Carimodel> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => Carimodel.fromJson(item)).toList();
  }

  Carimodel.fromMap(Map<String, dynamic> map) {
    this.carikod = map["carikod"];
    this.cariunvan = map["cariunvan"];
    this.borc = map["borc"];
    this.alacak = map["alacak"];
    this.bakiye = map["bakiye"];
    this.grupkodu = map["grupkodu"];
    this.bolgekodu = map["bolgekodu"];
  }
}
