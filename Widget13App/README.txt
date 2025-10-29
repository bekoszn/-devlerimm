# 📱 Widget13App – Görev Takip Widget’ı

## 🎯 Amaç
Bu proje, SwiftUI tabanlı bir **görev takip uygulaması** için **etkileşimli widget** geliştirmeyi amaçlar.  
Kullanıcılar ana uygulamada görev ekleyebilir, widget üzerinden bu görevleri **tamamlayabilir veya geri alabilir**.  
Tüm veriler **SwiftData** ve **App Groups** aracılığıyla ana uygulama ile widget arasında **gerçek zamanlı** paylaşılır.

---

## 🧩 Kullanılan Teknolojiler
- **SwiftUI** → Uygulama ve widget arayüzleri  
- **WidgetKit** → Ana ekranda görevleri gösteren widget yapısı  
- **App Intents** → Widget üzerinden etkileşimli işlem (tamamlama / hızlı ekleme)  
- **SwiftData** → Görevlerin kalıcı olarak saklanması  
- **App Groups** → Uygulama ve widget arasında veri paylaşımı  

---

## ⚙️ Widget Yapısının Kısa Açıklaması
- **TaskWidget.swift** dosyası, `TimelineProvider` kullanarak görev listesini SwiftData üzerinden okur.  
- Her 30 dakikada bir otomatik yenileme yapılır, ayrıca görev ekleme/silme sonrası anında güncellenir.  
- `TaskWidgetEntryView`, kullanıcıya son 4 görevi gösterir.  
- `SharedModelContainer` ile App Group altında tek bir veri deposu paylaşılır.  

---

## ✨ Etkileşimli Özellikler
- **Görev Tamamlama:**  
  Her görev satırında bir buton bulunur. Kullanıcı butona dokunduğunda, `ToggleTaskIntent` çalışır.  
  Bu intent, görev durumunu (`isCompleted`) değiştirir ve widget’ı anında yeniler.

- **Hızlı Görev Ekleme:**  
  Üst kısımdaki “+” butonu `AddQuickTaskIntent`’i tetikler.  
  Bu intent, “Quick Task” adlı yeni bir görev oluşturur ve listeye ekler.

- **Gerçek Zamanlı Senkronizasyon:**  
  `WidgetCenter.shared.reloadAllTimelines()` çağrıları sayesinde hem ana uygulama hem widget her işlemden sonra senkronize olur.

---
