import Foundation

// Temel kişisel bilgiler
var ad: String = "Berke"
var yas: Int = 26
var boy: Double = 1.83
var ogrenciMi: Bool = true

// Optional değişkenler (boş olabilir)
var telefonNumarasi: String? = nil
var eposta: String? = "berkeozguder@gmail.com"



// Kişisel bilgi kartı
print("👤 Kişisel Bilgi Kartı")
print("Ad: \(ad)")
print("Yaş: \(yas)")
print("Boy: \(boy) m")
print("Öğrenci mi?: \(ogrenciMi ? "Evet" : "Hayır")")

// Güvenli unwrap (if let)
if let telefon = telefonNumarasi {
    print("Telefon: \(telefon)")
} else {
    print("Telefon bilgisi mevcut değil.")
}

if let mail = eposta {
    print("E-posta: \(mail)")
} else {
    print("E-posta bilgisi mevcut değil.")
}
