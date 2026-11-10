from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import swisseph as swe
import google.generativeai as genai
from geopy.geocoders import Nominatim # İŞTE YENİ EKLENEN GEOPY KODU BURADA

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# AŞAĞIDAKİ SATIRA KENDİ GEMINI API ANAHTARINI YAPIŞTIRMAYI UNUTMA!
genai.configure(api_key="BURAYA_API_ANAHTARI_GELECEK")
model = genai.GenerativeModel('gemini-3.8-flash')

ZODYAK = ["Koç", "Boğa", "İkizler", "Yengeç", "Aslan", "Başak", 
          "Terazi", "Akrep", "Yay", "Oğlak", "Kova", "Balık"]

# Şehir ismini otomatik olarak enlem ve boylama çeviren fonksiyon
def sehir_koordinat_bul(sehir_adi: str):
    try:
        geolocator = Nominatim(user_agent="astro_app_sinem")
        location = geolocator.geocode(sehir_adi)
        if location:
            return location.latitude, location.longitude
        return None, None
    except:
        return None, None

# Artık "enlem" ve "boylam" yerine "sehir" parametresi alıyoruz
@app.get("/gunluk-yorum")
def gunluk_yorum_uret(yil: int, ay: int, gun: int, saat: float, sehir: str, utc_farki: int = 3):
    
    # Flutter'dan gelen şehir adını koordinata çeviriyoruz
    enlem, boylam = sehir_koordinat_bul(sehir)
    
    if enlem is None or boylam is None:
        return {"gunluk_yorum": f"'{sehir}' şehri haritada bulunamadı. Lütfen geçerli bir şehir girin (Örn: Ankara).", "gunes_burcu": "", "yukselen_burcu": ""}

    utc_saat = saat - utc_farki
    julian_day = swe.julday(yil, ay, gun, utc_saat)
    
    gunes_hesap = swe.calc_ut(julian_day, swe.SUN)
    gunes_burcu = ZODYAK[int(gunes_hesap[0][0] // 30)]
    
    evler, ascmc = swe.houses(julian_day, enlem, boylam, b'P')
    yukselen_burcu = ZODYAK[int(ascmc[0] // 30)]
    
    prompt = f"Sen modern, samimi ve motive edici bir astrologsun. Güneş burcu {gunes_burcu}, Yükselen burcu {yukselen_burcu} olan biri için bugünün gökyüzü enerjilerini yorumla. İçinde yazılım veya kodlama ile ilgili ufak eğlenceli bir metafor geçsin. Lütfen sadece 2 kısa paragraf olsun."
    
    try:
        cevap = model.generate_content(prompt)
        ai_yorumu = cevap.text
    except Exception as e:
        ai_yorumu = f"Yapay zeka ile iletişim kurulamadı: {str(e)}"
        
    return {
        "gunes_burcu": gunes_burcu,
        "yukselen_burcu": yukselen_burcu,
        "gunluk_yorum": ai_yorumu
    }