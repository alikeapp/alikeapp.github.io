---
layout: page
title: Gizlilik Politikası
permalink: /tr/privacy/
lang: tr
page_key: privacy
description: "Alike fotoğraflarınla nasıl çalışır: cihaz üzerinde analiz, hiçbir şey yüklenmez, analitik yok ve silme yalnızca senin onayınla olur."
---

Son güncelleme: 22 Eylül 2026

Alike, fotoğraf kitaplığındaki görsel olarak benzer fotoğrafları bulup gruplayan ve böylece onları gözden geçirip yer açmanı sağlayan bir iOS uygulamasıdır. Alike'ı, Ukrayna merkezli bağımsız bir geliştirici olan Oleksandr Solokha yürütür.

Bu gizlilik politikası, Alike'ın neyi topladığını ve neyi toplamadığını, verilerinin nerede durduğunu ve bunlar üzerinde nasıl bir denetimin olduğunu anlatır.

**Kısacası: Alike'ın hesabı, oturum açması ve sunucusu yok. Fotoğrafların ve Alike'ın onlar hakkında öğrendiği her şey cihazında kalır.**

## İletişim

Destek, hata bildirimi, gizlilik soruları ya da satın alma sorunları için:

[oleksandr.solokha@gmail.com](mailto:oleksandr.solokha@gmail.com)

## Alike neye erişir

### Fotoğraf kitaplığın

Alike, fotoğraf kitaplığına erişimi başlangıçta bir kez ister. Bu erişim iki şey için gereklidir: görsel olarak benzer olanları bulmak üzere fotoğrafları karşılaştırmak ve — yalnızca sen istediğinde — saklamayı seçtiğin bir fotoğrafın iyileştirilmiş sürümünü kaydetmek.

Tam erişim verebilirsin ya da sınırlı erişim verip Alike'ın hangi fotoğrafları göreceğini kendin seçebilirsin. Bunu istediğin zaman iOS Ayarları'nda «Gizlilik ve Güvenlik» → «Fotoğraflar» → «Alike» yolundan değiştirebilir veya geri alabilirsin.

Alike, görüntü verilerini ve iOS'un her öğe için sunduğu meta verileri okur: oluşturma tarihi, varsa yaklaşık konum, dosya boyutu ve öğenin bir ekran görüntüsü ya da favori olup olmadığı. Bunlar, hangi fotoğrafların karşılaştırmaya değdiğini önceden elemek ve sana grup ayrıntılarını göstermek içindir.

### Bildirimler

Alike, bildirim iznini yalnızca ayarlarda haftalık temizlik anımsatıcısını açarsan ister, başka hiçbir durumda istemez. Bu anımsatıcıyı hiç açmazsan Alike hiç sormaz.

Açarsan, iOS anımsatıcıyı cihazında yerel olarak zamanlar. Alike anlık bildirim kullanmaz ve uzak bildirimler için herhangi bir belirteç kaydetmez ya da almaz.

## Alike fotoğraflarınla ne yapar

### Analiz tamamen cihazında çalışır

Alike, fotoğrafları iPhone'unda yerel olarak çalışan Apple'ın Vision çerçevesiyle karşılaştırır. Her fotoğraf sayısal bir öznitelik izine indirgenir ve bu izler, senin seçtiğin duyarlılık düzeyine göre yeterince yakın olduğunda fotoğraflar gruplanır.

**Fotoğrafların hiçbir zaman yüklenmez.** Hiçbir fotoğraf, küçük resim, öznitelik izi ya da analiz sonucu Alike tarafından cihazının dışına aktarılmaz. Bir şey gönderilebilecek bir Alike sunucusu yoktur.

### Sonuçlar yerel olarak saklanır

Alike, uygulamayı her açtığında yeniden taramak zorunda kalmayasın diye sonuçlarını cihazında Core Data ve yerel dosyalarla saklar. Bu yerel depolamaya fotoğraf tanımlayıcıları, öznitelik izleri, grup üyelikleri, tahmini boyutlar, gözden geçirme ilerlemen ve seçimlerin, temizlik geçmişi, Alike'ın senin seçtiğin en iyi karelerden öğrendiği ağırlıklar ve uygulama tercihlerin dahildir.

Bunların hepsi cihazında Alike'ın kendi yalıtılmış deposunda durur ve cihazını yedekliyorsan yedeklerine dahil olur.

### Sakladığın fotoğrafı iyileştirmek

Alike, bir gruptaki en iyi kareyi iyileştirebilir. Bunu asla kendiliğinden yapmaz: sonuç sana önizleme olarak gösterilir ve ancak sen uyguladıktan sonra, her seferinde tek bir fotoğraf için kaydedilir. İşlem cihazında yapılır ve hiçbir şey yüklenmez. iOS aslı saklar — değişiklik, Alike'a ait olarak işaretlenmiş, aslı bozmayan bir düzenleme olarak kaydedilir; böylece Apple Fotoğraflar'da görünür ve her iki uygulamadan da geri alınabilir. Hiçbir kopya oluşturulmaz. İyileştirme; video için, Sınırlı Erişim'de ve sistemin düzenlenemez olarak işaretlediği fotoğraflar için sunulmaz, üzerinde başka bir uygulamanın düzenlemesi bulunan bir fotoğraf ise ancak sen kabul ettikten sonra değiştirilir.

### Hangi fotoğrafları yeğlediğini öğrenmek

Alike'ın önerdiğinden farklı bir en iyi kare seçtiğinde uygulama, iki fotoğrafın kalite ölçümleri arasındaki farkı saklar ve sonraki grupları senin beğenine daha yakın sıralamak için kullanır. Yalnızca uygulama içinde yaptığın seçimlerden öğrenir. Bu değerler fotoğraf değil, türetilmiş sayılardır; cihazında kalır ve hiçbir yere gönderilmez. Ayarlar'da öğrenilenleri sıfırlayan bir düğme vardır.

## Çökme raporları

Alike beklenmedik şekilde kapanırsa iOS daha sonra, Apple'ın MetricKit çerçevesi aracılığıyla uygulamaya bu çökmeyle ilgili bir tanılama raporu verebilir. Alike bu raporu cihazındaki kendi depolama alanında saklar — en fazla en yeni 20 tanesini — ve kendiliğinden onunla başka hiçbir şey yapmaz.

Bir sonraki açılışta, bir işin ortasında değilken, Alike raporu gönderip göndermeyeceğini yalnızca bir kez sorar. **Raporu Gönder**, raporun ekli olduğu ve "İletişim" bölümündeki adrese yazılmış bir e-posta açar: önce okuyabilirsin ve e-posta ancak sen kendi posta hesabından gönderirsen gider. Mail ayarlı değilse bunun yerine adresi gösteren paylaşım sayfası açılır; raporun nereye gideceğini sen seçersin. **Şimdi Değil** hiçbir şey göndermez ve Alike o raporu bir daha asla sormaz.

Rapor; çökmenin yığın izini — Alike'ın kodunun hangi kısmının çalıştığını —, uygulama sürümünü, iOS sürümünü, cihaz modelini ve iOS'un eklediği istisna türü, işlemci mimarisi ve bölge biçimi ayarın gibi teknik ayrıntıları içerir. Bazı çökmelerde Alike'ın o anda ürettiği hata mesajını da içerir. Raporu iOS yazar; Alike onu hiçbir şey eklemeden ya da ayıklamadan olduğu gibi gönderir — bu yüzden göndermeden önce eki oku. Fotoğraf içermez. E-postayla gönderirsen geliştirici, her e-postanın taşıdığı bilgileri de alır; örneğin e-posta adresini.

Gönderilen bir rapor yalnızca o çökmeyi bulmak ve düzeltmek için kullanılır ve kimseyle paylaşılmaz.

## Alike neyi toplamaz

Alike'ta analitik, üçüncü taraf çökme raporlama hizmeti, reklam ya da herhangi bir türde izleme yoktur. Somut olarak Alike şunları yapmaz:

- fotoğraflarını ya da onlardan türetilen verileri yüklemek;
- analitik ya da kullanım olayları toplamak;
- reklam tanımlayıcısı (IDFA) kullanmak veya izleme izni istemek;
- senin hakkında bir profil oluşturmak;
- kişisel verileri paylaşmak, satmak ya da kiralamak — paylaşılabilecek hiçbir veri toplanmadığı için;
- çerez ya da web işaretçisi kullanmak.

Alike kendiliğinden ağ isteği yapmaz. Tek dışa dönük etkinliği Apple yürütür: StoreKit üzerinden abonelik satın alımları ve dokunduğunda App Store ya da e-posta bağlantılarının açılması.

## Fotoğrafları silme

Silmek her zaman senin kararındır ve her zaman açık bir onay ister.

Bir temizliği onayladığında Alike, seçtiğin fotoğrafları silmesi için iOS'a istek gönderir. Bir şey kaldırılmadan önce iOS kendi sistem onayını gösterir. Silinen fotoğraflar **«Son Silinenler»** albümüne gider; iOS onları yaklaşık 30 gün orada tutar ve oradan geri alabilirsin.

Alike hiçbir zaman sessizce fotoğraf silmez, seçmediğin fotoğrafları silmez ve iOS'un onayını atlayamaz.

## Abonelikler ve satın alımlar

Alike Pro, Apple üzerinden satılan, otomatik yenilenen bir aboneliktir. Satın alımları baştan sona Apple, StoreKit aracılığıyla yürütür.

Alike, Apple'dan yalnızca ücretli özellikleri açmak ve satın alımları geri yüklemek için gerekeni alır: hak durumun, planının ürün tanımlayıcısı ve işlem durumu. **Alike hiçbir zaman ödeme kartı bilgilerini, fatura adresini ya da Apple Hesabı kimlik bilgilerini almaz.**

Apple'ın satın alma bilgilerini nasıl işlediği [Apple'ın gizlilik politikasına](https://www.apple.com/legal/privacy/) tabidir. Abonelikler, iptaller ve iadeler Apple ve App Store üzerinden yürütülür.

## Denetim sende

| Ne istiyorsun | Nasıl yapılır |
| --- | --- |
| Fotoğraf erişimini değiştirmek ya da sınırlamak | iOS Ayarları → Gizlilik ve Güvenlik → Fotoğraflar → Alike |
| Bildirimleri durdurmak | Alike ayarlarında haftalık temizlik anımsatıcısını kapat ya da iOS Ayarları → Bildirimler |
| İyileştirilmiş bir fotoğrafı aslına döndürmek | Alike: grup ayrıntılarında «Orijinale dön»; ya da Apple Fotoğraflar: Düzenle → Geri Al |
| En İyi Kare'nin öğrendiklerini sıfırlamak | Alike Ayarları → «En İyi Kare Öğrenimini Sıfırla» |
| Bir çökme raporunu reddetmek | Şimdi Değil'e dokun — Alike o raporu bir daha asla sormaz |
| Alike'ın sakladığı her şeyi silmek | Alike Ayarları → Veriler ve Gizlilik → Alike Verilerini Sil |
| Tüm verileri tamamen kaldırmak | Alike uygulamasını cihazdan sil |

### Alike Verilerini Sil

Ayarlar → Veriler ve Gizlilik → **Alike Verilerini Sil**, Alike'ın cihazında sakladığı her şeyi kaldırır: tarama sonuçları ve analiz önbellekleri, temizlik ilerlemesi ve geçmişi, Alike'ın senin seçtiğin en iyi karelerden öğrendiği ağırlıklar, cihazda bekleyen çökme raporları ile Alike tercihlerin. Bu işlem geri alınamaz.

Fotoğraflarına, «Son Silinenler» albümüne, fotoğraf erişimi iznine ya da Alike Pro aboneliğine **dokunmaz**. Silme sonrasında Alike, fotoğraf erişimini ikinci kez sormadan tanıtımını yeniden gösterir.

Uygulamayı silersen Alike'ın tüm yerel verileri de onunla birlikte gider.

## Hukuki dayanak ve haklarım

Alike'ın kendisi kişisel veri toplamaz ya da aktarmaz; bu nedenle bu politikanın anlattığı her şey için geliştiricide erişilebilecek, düzeltilebilecek, dışa aktarılabilecek ya da silinebilecek hiçbir kişisel veri yoktur. Tek istisna, e-postayla göndermeyi seçtiğin bir çökme raporudur: Bu durumda geliştiricide o e-posta ve eki bulunur; bunlar, göndererek verdiğin rızaya dayanılarak yalnızca çökmeyi düzeltmek amacıyla işlenir. Silinmelerini dilediğin zaman yukarıdaki adresten isteyebilirsin.

Tüm işleme, senin denetiminde, cihazında yerel olarak gerçekleşir ve «Alike Verilerini Sil» ile ya da uygulamayı silerek istediğin zaman kendin kaldırabilirsin.

AB'de, Birleşik Krallık'ta, Ukrayna'da, Kaliforniya'da ya da veri koruma hakları bulunan başka bir bölgedeysen bu haklar geçerliliğini korur — yalnızca bunların ilişkilendirilebileceği bir sunucu tarafı veri yığını yoktur. Aksini düşünüyorsan yukarıdaki adresten yaz, yanıt veririz.

## Çocuklar

Alike 13 yaşından küçük çocuklara yönelik değildir ve bilerek onlardan bilgi toplamaz. Uygulamanın hesap sistemi, kullanıcı tarafından oluşturulan içeriği ve iletişim özellikleri yoktur.

## Bu politikadaki değişiklikler

Bu politika değişirse güncellenmiş sürüm, yeni bir «Son güncelleme» tarihiyle bu sayfada yayımlanır. Uygulamanın verilerinle nasıl çalıştığına dair esaslı değişiklikler ayrıca App Store sürüm notlarında da belirtilir.

## Uygulanacak hukuk

Bu gizlilik politikası Ukrayna hukukuna tabidir; kendi ikamet ülkenin hukuku uyarınca sana tanınan emredici veri koruma ve tüketici hakları saklıdır.
