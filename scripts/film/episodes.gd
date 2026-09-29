class_name Episodes
extends RefCounted
## Video senaryoları. Her bölüm bir set ve adımlardan oluşur; adımlar sırayla oynatılır (film_studio.gd).
## Konumlar set noktasıdır ("ev.yatak", bkz. film_sets.gd POINTS) ya da Vector3.
##
## Adımlar:
##   {"title": "yazı", "t": sn}                       ekranın ortasında büyük başlık
##   {"place": "emir", "at": nokta, "look": nokta, "lie": bool}   oyuncuyu sahneye koyar
##   {"cam": nokta, "look": nokta, "t": sn}             kamerayı götürür (t=0 kesme)
##   {"say": "emir", "text": "..."}                     diyalog kutusu; okunma süresi kadar bekler
##   {"walk": "emir", "to": nokta, "wait": false}       yürür (wait false: yürürken sonraki adıma geçer)
##   {"lie": "emir", "value": false}                    yatar/kalkar
##   {"turn": "emir", "to": nokta}                      bir yere döner
##   {"hide": "emir"}                                   sahneden çıkarır
##   {"time": 0.26}                                     günün saati (0.25 gündoğumu, 0.5 öğle)
##   {"wait": sn}

const LIST := [
	{
		"id": "bolum1", "name": "Bölüm 1: Okul Sabahı", "set": "ev", "time": 0.27,
		"steps": [
			{"place": "emir", "at": "ev.yatak", "lie": true},
			{"place": "anne", "at": "ev.ocak", "look": "ev.mutfak"},
			{"cam": "ev.kam_dis", "look": "ev.kapi_disi", "t": 0},
			{"title": "EmirCRAFT\nBölüm 1: Okul Sabahı", "t": 2.5},
			{"cam": "ev.kam_yatak", "look": "ev.yatak", "t": 2.0},
			{"say": "emir", "text": "Hıı... Sabah mı oldu?"},
			{"cam": "ev.kam_mutfak", "look": "ev.ocak", "t": 0},
			{"say": "anne", "text": "Emir! Kalk oğlum, okula geç kalacaksın!"},
			{"cam": "ev.kam_yatak", "look": "ev.yatak", "t": 0},
			{"lie": "emir", "value": false},
			{"place": "emir", "at": "ev.yatak_yani", "look": "ev.mutfak"},
			{"say": "emir", "text": "Tamam anne, geliyorum!"},
			{"cam": "ev.kam_oda", "look": "ev.masa", "t": 1.2},
			{"walk": "emir", "to": "ev.mutfak"},
			{"turn": "anne", "to": "ev.mutfak"},
			{"turn": "emir", "to": "ev.ocak"},
			{"say": "anne", "text": "Günaydın uykucu! Önce elini yüzünü yıka, sonra kahvaltı."},
			{"say": "emir", "text": "Günaydın anne! Kahvaltıda ne var?"},
			{"say": "anne", "text": "Senin sevdiğin fırın elma ve çilek!"},
			{"say": "emir", "text": "Yaşasın! En sevdiğim!"},
			{"walk": "emir", "to": "ev.canta"},
			{"say": "emir", "text": "Çantam, kalemlerim, defterim... Hepsi tamam!"},
			{"walk": "anne", "to": "ev.masa", "wait": false},
			{"walk": "emir", "to": "ev.kapi_ici"},
			{"turn": "emir", "to": "ev.masa"},
			{"say": "anne", "text": "Beslenmeni unutma. Arkadaşlarına iyi davran!"},
			{"say": "emir", "text": "Merak etme anne. Görüşürüz!"},
			{"cam": "ev.kam_kapi", "look": "ev.kapi_disi", "t": 0},
			{"walk": "emir", "to": "ev.yol"},
			{"title": "Yarın: Okulda ilk gün!", "t": 2.5},
		],
	},
	{
		"id": "okul1", "name": "Bölüm 2: Teneffüs", "set": "okul", "time": 0.4,
		"steps": [
			{"place": "emir", "at": "okul.kaydirak", "look": "okul.bahce"},
			{"place": "ali", "at": "okul.bahce", "look": "okul.kaydirak"},
			{"place": "zeynep", "at": "okul.top_alani", "look": "okul.bahce"},
			{"cam": "okul.kam_bahce", "look": "okul.bahce", "t": 0},
			{"title": "EmirCRAFT\nBölüm 2: Teneffüs", "t": 2.5},
			{"say": "ali", "text": "Emir! Saklambaç oynayalım mı?"},
			{"walk": "emir", "to": Vector3(55.5, 11, 17.5)},
			{"turn": "emir", "to": "okul.bahce"},
			{"say": "emir", "text": "Olur! Ama bu sefer ebe sensin Ali!"},
			{"walk": "zeynep", "to": Vector3(53.5, 11, 17.0)},
			{"say": "zeynep", "text": "Ben de varım! Kum havuzunun arkasına saklanacağım."},
			{"say": "ali", "text": "Tamam, gözlerimi kapatıyorum. Bir... iki... üç..."},
			{"walk": "emir", "to": "okul.sinif_kapi", "wait": false},
			{"walk": "zeynep", "to": "okul.top_alani"},
			{"say": "ali", "text": "...on! Önüm arkam sağım solum sobe!"},
			{"cam": "okul.kam_sinif", "look": "okul.sinif_kapi", "t": 1.5},
			{"say": "emir", "text": "Hiii... Sınıfa saklandım, burayı asla bulamaz!"},
			{"place": "ogretmen", "at": "okul.tahta", "look": "okul.sinif_kapi"},
			{"say": "ogretmen", "text": "Emir? Teneffüste sınıfta ne arıyorsun?"},
			{"turn": "emir", "to": "okul.tahta"},
			{"say": "emir", "text": "Şşş öğretmenim! Saklambaç oynuyoruz!"},
			{"say": "ogretmen", "text": "Hahaha! O zaman ben seni görmedim."},
			{"title": "Ali Emir'i bulabilecek mi?\nDevamı gelecek bölümde!", "t": 3.0},
		],
	},
	{
		"id": "hasta", "name": "Bölüm 3: Sahte Hasta", "set": "ev", "time": 0.28,
		"steps": [
			{"place": "emir", "at": "ev.yatak", "lie": true},
			{"place": "anne", "at": "ev.kapi_ici", "look": "ev.yatak"},
			{"cam": "ev.kam_dis", "look": "ev.kapi_disi", "t": 0},
			{"title": "EmirCRAFT\nBölüm 3: Sahte Hasta", "t": 2.5},
			{"cam": "ev.kam_yatak", "look": "ev.yatak", "t": 1.5},
			{"say": "emir", "text": "(Bugün matematik sınavı var... Bir planım var!)"},
			{"say": "emir", "text": "Anneee... Öhö öhö! Çok hastayım, okula gidemem..."},
			{"walk": "anne", "to": "ev.yatak_yani"},
			{"turn": "anne", "to": "ev.yatak"},
			{"say": "anne", "text": "Hmm... Ateşin var mı bakalım?"},
			{"say": "emir", "text": "Evet! Çok yüksek! Belki bin derece!"},
			{"say": "anne", "text": "Bin derece mi? O zaman bugünkü lunaparka gidemeyiz..."},
			{"lie": "emir", "value": false},
			{"place": "emir", "at": "ev.yatak_yani", "look": "ev.mutfak"},
			{"turn": "anne", "to": "ev.yatak_yani"},
			{"say": "emir", "text": "LUNAPARK MI?! İyileştim! Mucize oldu!"},
			{"say": "anne", "text": "Hahaha! Lunapark hafta sonu. Şimdi hadi okula, sınavın var!"},
			{"say": "emir", "text": "Eyvah... Yakalandım!"},
			{"title": "Yalan söyleyen yakalanır!", "t": 2.5},
		],
	},
	{
		"id": "odev", "name": "Bölüm 4: Ödevi Köpek Yedi", "set": "okul", "time": 0.35,
		"steps": [
			{"place": "ogretmen", "at": "okul.tahta", "look": "okul.sinif_kapi"},
			{"place": "ali", "at": "okul.sira_1", "look": "okul.tahta"},
			{"place": "zeynep", "at": "okul.sira_2", "look": "okul.tahta"},
			{"place": "emir", "at": "okul.sira_3", "look": "okul.tahta"},
			{"cam": "okul.kam_sinif", "look": "okul.tahta", "t": 0},
			{"title": "EmirCRAFT\nBölüm 4: Ödevi Köpek Yedi", "t": 2.5},
			{"say": "ogretmen", "text": "Günaydın çocuklar! Ödevlerinizi toplayalım."},
			{"say": "zeynep", "text": "Buyurun öğretmenim, iki sayfa yazdım!"},
			{"say": "ogretmen", "text": "Aferin Zeynep! Ali, senin ödevin?"},
			{"say": "ali", "text": "Öğretmenim... Ödevimi köpeğim yedi!"},
			{"say": "ogretmen", "text": "Ali, senin köpeğin yok ki."},
			{"say": "ali", "text": "Eee... Komşunun köpeği! Çok acıkmıştı!"},
			{"cam": "okul.kam_tahta", "look": "okul.sira_3", "t": 1.0},
			{"say": "ogretmen", "text": "Peki Emir, senin ödevin nerede?"},
			{"say": "emir", "text": "Benimki burada öğretmenim! Ama biraz... ıslak."},
			{"say": "ogretmen", "text": "Islak mı? Ne oldu ona?"},
			{"say": "emir", "text": "Ali'nin komşusunun köpeği onu da yalamış!"},
			{"say": "zeynep", "text": "Hahaha! O köpek bütün sınıfın ödevini yiyecek!"},
			{"say": "ogretmen", "text": "Tamam, tamam! Yarın ödevler kuru ve eksiksiz gelsin!"},
			{"title": "Ödevini zamanında yap,\nköpeğe fırsat verme!", "t": 3.0},
		],
	},
]


static func find(id: String) -> Dictionary:
	for e in LIST:
		if e["id"] == id:
			return e
	return LIST[0]
