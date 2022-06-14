class CariHmodel {
  int chid;
  String tarih;
  String tahsno;
  String carikod;
  String borc;
  String alacak;
  String islemtip;
  String kuladi;
  String aciklama;
  String kayno;
  dynamic value;
  CariHmodel(
      this.tarih,
      this.tahsno,
      this.carikod,
      this.borc,
      this.alacak,
      this.islemtip,
      this.kuladi,
      this.aciklama,
      this.kayno); // Constructor'ımızı oluşturduk.
  CariHmodel.withID(this.chid, this.tarih, this.tahsno, this.carikod, this.borc,
      this.alacak, this.islemtip, this.kuladi, this.aciklama, this.kayno);
  CariHmodel.withJ(
      {this.chid,
      this.tarih,
      this.tahsno,
      this.carikod,
      this.borc,
      this.alacak,
      this.islemtip,
      this.kuladi,
      this.aciklama,
      this.kayno});
  @override
  toString() => '$chid $tarih $tahsno $carikod $borc $alacak $islemtip $kayno';
  factory CariHmodel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return CariHmodel.withJ(
        chid: json["chid"],
        tarih: json["tarih"],
        tahsno: json["tahsno"],
        carikod: json["carikod"],
        borc: json["borc"],
        alacak: json["alacak"],
        islemtip: json["islemtip"],
        kuladi: json["kuladi"],
        aciklama: json["aciklama"],
        kayno: json["kayno"]);
  }
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>(); //Geçici bir map nesnesi
    map["tarih"] = tarih;
    map["tahsno"] = tahsno;
    map["carikod"] = carikod;
    map["borc"] = borc;
    map["alacak"] = alacak;
    map["islemtip"] = islemtip;
    map["kuladi"] = kuladi;
    map["aciklama"] = aciklama;
    map["kayno"] = kayno;
    return map; //Bu mapimizi döndürüyoruz.
  }

  Map<String, dynamic> toJson() {
    return {
      "chid": this.chid,
      "tarih": this.tarih,
      "tahsno": this.tahsno,
      "carikod": this.carikod,
      "borc": this.borc,
      "alacak": this.alacak,
      "islemtip": this.islemtip,
      "kuladi": this.kuladi,
      "aciklama": this.aciklama,
      "kayno": this.kayno
    };
  }

  static List<CariHmodel> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => CariHmodel.fromJson(item)).toList();
  }

  CariHmodel.fromMap(Map<String, dynamic> map) {
    this.tarih = map["tarih"];
    this.tahsno = map["tahsno"];
    this.carikod = map["carikod"];
    this.borc = map["borc"];
    this.alacak = map["alacak"];
    this.islemtip = map["islemtip"];
    this.kuladi = map["kuladi"];
    this.aciklama = map["aciklama"];
    this.kayno = map["kayno"];
  }
}
