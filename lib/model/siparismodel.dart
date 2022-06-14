class Siparismodel {
  int shid; // her not'a kolayca ulaşmak adına bir id,
  String tarih; // her not için bir başlık,
  String stokkod; //her not için bir açıklama tanımladık.
  String carikod;
  String sipno;
  String miktar;
  dynamic value;
  Siparismodel(this.tarih, this.stokkod, this.carikod, this.sipno,
      this.miktar); // Constructor'ımızı oluşturduk.
  Siparismodel.withID(this.shid, this.tarih, this.stokkod, this.carikod,
      this.sipno, this.miktar);
  Siparismodel.withJ(
      {this.shid,
      this.tarih,
      this.stokkod,
      this.carikod,
      this.sipno,
      this.miktar});
  @override
  toString() => '$shid $tarih $stokkod $carikod $sipno $miktar';
  factory Siparismodel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Siparismodel.withJ(
        shid: json["shid"],
        tarih: json["tarih"],
        stokkod: json["stokkod"],
        carikod: json["carikod"],
        sipno: json["sipno"],
        miktar: json["miktar"]);
  }
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>(); //Geçici bir map nesnesi
    map["shid"] = shid;
    map["tarih"] = tarih;
    map["stokkod"] = stokkod;
    map["carikod"] = carikod;
    map["sipno"] = sipno;
    map["miktar"] = miktar;
    return map; //Bu mapimizi döndürüyoruz.
  }

  static List<Siparismodel> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => Siparismodel.fromJson(item)).toList();
  }

  Siparismodel.fromMap(Map<String, dynamic> map) {
    this.shid = map["shid"];
    this.tarih = map["tarih"];
    this.stokkod = map["stokkod"];
    this.carikod = map["carikod"];
    this.sipno = map["sipno"];
    this.miktar = map["miktar"];
  }
}
