class StokHmodel {
  int shid; // her not'a kolayca ulaşmak adına bir id,
  String tarih; // her not için bir başlık,
  String stokkod;
  String stokad;
  String carikod;
  String cariunvan;
  String sipno;
  String miktar;
  String fiyat;
  String sfiyat1;
  String sfiyat2;
  String kod4;
  String kuladi;
  String aciklama;
  dynamic value;
  StokHmodel(
      this.tarih,
      this.stokkod,
      this.stokad,
      this.carikod,
      this.cariunvan,
      this.sipno,
      this.miktar,
      this.fiyat,
      this.sfiyat1,
      this.sfiyat2,
      this.kod4,
      this.kuladi,
      this.aciklama); // Constructor'ımızı oluşturduk.
  //Ekleme işlemlerinde direkt olarak id atadığı için id kullanmadık.
  StokHmodel.withID(
      this.shid,
      this.tarih,
      this.stokkod,
      this.stokad,
      this.carikod,
      this.cariunvan,
      this.sipno,
      this.miktar,
      this.fiyat,
      this.sfiyat1,
      this.sfiyat2,
      this.kod4,
      this.kuladi,
      this.aciklama);
  StokHmodel.withJ(
      {this.shid,
      this.tarih,
      this.stokkod,
      this.stokad,
      this.carikod,
      this.cariunvan,
      this.sipno,
      this.miktar,
      this.fiyat,
      this.sfiyat1,
      this.sfiyat2,
      this.kod4,
      this.kuladi,
      this.aciklama});

  //Stokhareket.withL({this.label, this.value});
  // Silme ve güncelleme gibi işlemler için ise id'li bir constructor oluşturduk.
  @override
  toString() =>
      '$shid $tarih $stokkod $stokad $carikod $cariunvan $sipno $miktar $fiyat $sfiyat1 $sfiyat2 $kod4 $kuladi $aciklama';

//Sqlite'da devamlı "map"ler ile çalışacağımız için yardımcı methodlarımızı hazırlayalım.
//Verilerimizi okurken de map olarak okuyacağız, nesnemizi yazdırırkende map'e çevireceğiz.
  factory StokHmodel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return StokHmodel.withJ(
        shid: json["shid"],
        tarih: json["tarih"],
        stokkod: json["stokkod"],
        stokad: json["stokad"],
        carikod: json["carikod"],
        cariunvan: json["cariunvan"],
        sipno: json["sipno"],
        miktar: json["miktar"],
        fiyat: json["fiyat"],
        sfiyat1: json["sfiyat1"],
        sfiyat2: json["sfiyat2"],
        kod4: json["kod4"],
        kuladi: json["kuladi"],
        aciklama: json["aciklama"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "tarih": this.tarih,
      "stokkod": this.stokkod,
      "stokad": this.stokad,
      "carikod": this.carikod,
      "cariunvan": this.cariunvan,
      "miktar": this.miktar,
      "fiyat": this.fiyat,
      "kod4": this.kod4,
      "sipno": this.sipno,
      "kuladi": this.kuladi,
      "aciklama": this.aciklama,
      "sfiyat1": this.sfiyat1,
      "sfiyat2": this.sfiyat2,
    };
  }

  // factory Stokhareket.fromJsonlabel(Map<String, dynamic> json) {
  //   return Stokhareket.withL(label: json['firma'], value: json['sid']);
  // }
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>(); //Geçici bir map nesnesi
    //  map["shid"] = shid;
    map["tarih"] = tarih;
    map["stokkod"] = stokkod;
    map["stokad"] = stokad;
    map["carikod"] = carikod;
    map["cariunvan"] = cariunvan;
    map["sipno"] = sipno;
    map["miktar"] = miktar;
    map["fiyat"] = fiyat;
    map["sfiyat1"] = sfiyat1;
    map["sfiyat2"] = sfiyat2;
    map["kod4"] = kod4;
    map["kuladi"] = kuladi;
    map["aciklama"] = aciklama;
    return map; //Bu mapimizi döndürüyoruz.
  }

  static List<StokHmodel> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => StokHmodel.fromJson(item)).toList();
  }

  StokHmodel.fromMap(Map<String, dynamic> map) {
    //  this.shid = map["shid"];
    this.tarih = map["tarih"];
    this.stokkod = map["stokkod"];
    this.stokad = map["stokad"];
    this.carikod = map["carikod"];
    this.cariunvan = map["cariunvan"];
    this.sipno = map["sipno"];
    this.miktar = map["miktar"];
    this.fiyat = map["fiyat"];
    this.sfiyat1 = map["sfiyat1"];
    this.sfiyat2 = map["sfiyat2"];
    this.kod4 = map["kod4"];
    this.kuladi = map["kuladi"];
    this.aciklama = map["aciklama"];
  }
}
