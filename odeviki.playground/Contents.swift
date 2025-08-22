import Foundation

enum Hata: Error, CustomStringConvertible {
    case sifiraBolme
    var description: String { "⚠️ Sıfıra bölme yapılamaz!" }
}

enum Islem {
    case topla, cikar, carp, bol
}

/// İki sayıyı verilen işleme göre hesap yapar.
func islemYap(_ a: Double, _ b: Double, neYap: Islem) -> Result<Double, Hata> {
    switch neYap {
    case .topla: return .success(a + b)
    case .cikar: return .success(a - b)
    case .carp:  return .success(a * b)
    case .bol:
        guard b != 0 else { return .failure(.sifiraBolme) }
        return .success(a / b)
    }
}

// Örnek kullanım
let s1 = islemYap(12, 4, neYap: .topla)
let s2 = islemYap(12, 4, neYap: .cikar)
let s3 = islemYap(12, 4, neYap: .carp)
let s4 = islemYap(12, 4, neYap: .bol)
let s5 = islemYap(12, 0, neYap: .bol) // hata örneği

// Sonuçları yazdır
for (i, sonuc) in [s1, s2, s3, s4, s5].enumerated() {
    switch sonuc {
    case .success(let deger): print("İşlem \(i+1): \(deger)")
    case .failure(let hata): print("İşlem \(i+1): \(hata.description)")
    }
}

// MARK: - 2) Closure ile filtreleme ve sıralama

let sayilar = [12, 3, 45, 6, 9, 10, 2, 33, 18]
let isimler = ["ayşe", "Berke", "cem", "deniz", "Alp", "birgül", "Can"]

// Çift sayıları seç
let ciftler = sayilar.filter { $0 % 2 == 0 }

// 10’dan büyükleri seç ve küçükten büyüğe sırala
let ondanBuyuk = sayilar.filter { $0 > 10 }.sorted { $0 < $1 }

// "b/B" ile başlayan isimler
let bIleBaslayanlar = isimler.filter { $0.lowercased().hasPrefix("b") }

// Sayıları büyükten küçüğe sırala
let buyuktenKucuge = sayilar.sorted { $0 > $1 }

// İsimleri harfe göre sırala (küçük/büyük harf fark etmez)
let isimlerSirali = isimler.sorted { a, b in
    let aa = a.lowercased(), bb = b.lowercased()
    if aa == bb { return a.count < b.count } // aynıysa kısa olan önce
    return aa < bb
}


print("Çift sayılar:", ciftler)
print("10’dan büyük olanlar:", ondanBuyuk)
print("'B/b' ile başlayanlar:", bIleBaslayanlar)
print("Sayılar büyükten küçüğe:", buyuktenKucuge)
print("İsimler sıralı:", isimlerSirali)
