# ✨ Astro AI - Akıllı Astroloji Asistanı

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)
![Gemini AI](https://img.shields.io/badge/Google%20Gemini-8E75B2?style=for-the-badge&logo=google&logoColor=white)

Astro AI, kullanıcıların doğum yeri ve zamanına göre astronomik gezegen konumlarını hesaplayıp, Google Gemini yapay zeka modeli ile kişiselleştirilmiş modern astroloji yorumları üreten full-stack bir mobil/web uygulamasıdır.

## 🚀 Özellikler
* **Otomatik Konum Çözümleme:** Kullanıcının girdiği şehir adı (Geopy/Nominatim) otomatik olarak enlem ve boylama çevrilir.
* **Hassas Astronomik Hesaplama:** İsviçre efemeris (SwissEph) kütüphanesi kullanılarak Zodyak dereceleri, Güneş ve Yükselen burçlar milimetrik hesaplanır.
* **Yapay Zeka Yorumu:** Gemini 3.8-flash modeli, haritaya özel, modern ve motive edici (yazılım metaforları içeren) günlük yorumlar üretir.
* **Modern Arayüz:** Flutter ile geliştirilmiş, kullanıcı dostu takvim ve saat seçiciler içeren şık Material 3 tasarımı.

## 🛠️ Kullanılan Teknolojiler
* **Frontend:** Flutter, Dart, HTTP
* **Backend:** Python, FastAPI, Uvicorn, CORS Middleware
* **Astronomik Motor:** Pyswisseph
* **Yapay Zeka & API:** Google Generative AI (Gemini), Geopy

## 💻 Kurulum ve Çalıştırma

**1. Backend (Python) Kurulumu**
```bash
# Gerekli kütüphaneleri yükleyin
pip install fastapi uvicorn pyswisseph google-generativeai geopy

# Sunucuyu başlatın
python -m uvicorn main:app --reload

#(Not: main.py içerisine kendi Gemini API anahtarınızı eklemeyi unutmayın.)