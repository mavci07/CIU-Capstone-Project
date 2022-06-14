class ShGecici {
  // her not'a kolayca ulaşmak adına bir id,
  String tarih;
  String stokkod;
  String carikod;
  String cariunvan;
  String stokad; //her not için bir açıklama tanımladık.
  String miktar;
  String fiyat;
  String sfiyat1;
  String sfiyat2;
  String kod4;
  String sipno;
  String kuladi;
  String aciklama;
  dynamic value;
  ShGecici(
      this.tarih,
      this.stokkod,
      this.carikod,
      this.cariunvan,
      this.stokad,
      this.miktar,
      this.fiyat,
      this.sfiyat1,
      this.sfiyat2,
      this.kod4,
      this.sipno,
      this.kuladi,
      this.aciklama); // Constructor'ımızı oluşturduk.
  //Ekleme işlemlerinde direkt olarak id atadığı için id kullanmadık.
  ShGecici.withID(
      this.tarih,
      this.stokkod,
      this.carikod,
      this.cariunvan,
      this.stokad,
      this.miktar,
      this.fiyat,
      this.sfiyat1,
      this.sfiyat2,
      this.kod4,
      this.sipno,
      this.kuladi,
      this.aciklama);
  ShGecici.withJ(
      {this.tarih,
      this.stokkod,
      this.carikod,
      this.cariunvan,
      this.stokad,
      this.miktar,
      this.fiyat,
      this.sfiyat1,
      this.sfiyat2,
      this.kod4,
      this.sipno,
      this.kuladi,
      this.aciklama});
  //Stokhareket.withL({this.label, this.value});
  // Silme ve güncelleme gibi işlemler için ise id'li bir constructor oluşturduk.
  @override
  toString() => '$stokkod $stokad $cariunvan $miktar $fiyat $aciklama';

//Sqlite'da devamlı "map"ler ile çalışacağımız için yardımcı methodlarımızı hazırlayalım.
//Verilerimizi okurken de map olarak okuyacağız, nesnemizi yazdırırkende map'e çevireceğiz.
  factory ShGecici.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return ShGecici.withJ(
        tarih: json["tarih"],
        stokkod: json["stokkod"],
        carikod: json["carikod"],
        cariunvan: json["cariunvan"],
        stokad: json["stokad"],
        miktar: json["miktar"],
        fiyat: json["fiyat"],
        sfiyat1: json["sfiyat1"],
        sfiyat2: json["sfiyat2"],
        kod4: json["kod4"],
        sipno: json["sipno"],
        kuladi: json["kuladi"],
        aciklama: json["aciklama"]);
  }
  // factory Stokhareket.fromJsonlabel(Map<String, dynamic> json) {
  //   return Stokhareket.withL(label: json['firma'], value: json['sid']);
  // }
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>(); //Geçici bir map nesnesi
    //  map["shid"] = shid;
    map["tarih"] = tarih;
    map["stokkod"] = stokkod;
    map["carikod"] = carikod;
    map["cariunvan"] = cariunvan;
    map["stokad"] = stokad;
    map["miktar"] = miktar;
    map["fiyat"] = fiyat;
    map["sfiyat1"] = sfiyat1;
    map["sfiyat2"] = sfiyat2;
    map["kod4"] = kod4;
    map["sipno"] = sipno;
    map["kuladi"] = kuladi;
    map["aciklama"] = aciklama;
    return map; //Bu mapimizi döndürüyoruz.
  }

  static List<ShGecici> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => ShGecici.fromJson(item)).toList();
  }

  ShGecici.fromMap(Map<String, dynamic> map) {
    this.tarih = map["tarih"];
    this.stokkod = map["stokkod"];
    this.carikod = map["carikod"];
    this.cariunvan = map["cariunvan"];
    this.stokad = map["stokad"];
    this.miktar = map["miktar"];
    this.fiyat = map["fiyat"];
    this.sfiyat1 = map["sfiyat1"];
    this.sfiyat2 = map["sfiyat2"];
    this.kod4 = map["kod4"];
    this.sipno = map["sipno"];
    this.kuladi = map["kuladi"];
    this.aciklama = map["aciklama"];
  }
}
