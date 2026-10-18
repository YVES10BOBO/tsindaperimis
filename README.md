# Amategeko y'Umuhanda — Flutter (frontend)

App yo kwiga amategeko y'umuhanda no kwitegura ikizamini cy'uruhushya rwo gutwara.
Iyi ni **frontend gusa**: amakuru ari muri code (`lib/data/`), nta backend irahuzwa.

## Uko wayitangiza

Muri folder `C:\learningApp` fungura terminal:

```bash
flutter create . --project-name amategeko_app --platforms android,ios
flutter pub get
flutter run
```

`flutter create .` yongeramo folders za Android/iOS gusa; ntisiba amadosiye ari muri `lib/`.

## Imiterere ya code

```
lib/
  main.dart, app.dart          Gutangiza app
  core/                        Amabara, theme, imiterere y'ikizamini
  data/                        Models, categories 7 n'amasomo, ibibazo, repository
  state/app_state.dart         Umukoresha, iterambere, ibyabitswe, ibisubizo
  widgets/                     Cards, progress, options, ibimenyetso (RoadSign)
  screens/                     Amapaji yose
```

## Amapaji

- Welcome: Injira, Iyandikishe, cyangwa Komeza nka Mushyitsi (guest mode)
- Ahabanza: iterambere, gushakisha, ibyiciro 7, Imyitozo n'Ikizamini
- Icyiciro → Amasomo → Isomo (bika, umva, "Narangije")
- Imyitozo: ikibazo kimwe kimwe, igisubizo n'impamvu ako kanya; subiramo amakosa
- Ikizamini cy'igerageza: ibibazo 20, isaha, "Uzagaruka", imbonerahamwe y'ibibazo
- Ibisubizo + Reba amakosa yawe
- Iterambere: ijanisha, imibare, uko uhagaze muri buri cyiciro, ibizamini biheruka
- Ibindi: konti, Premium (MoMo / Airtel Money), Ibyo nabitse, Ubutumwa, Ururimi

## Ibisigaye (intambwe zikurikira)

1. Kubika amakuru muri telefoni (SQLite / sqflite) kugira ngo ikore offline kandi iterambere ntirisibe.
2. Backend (REST API + JWT) no guhuza kwishyura na MTN MoMo / Airtel Money.
3. Amajwi mu Kinyarwanda, Icyongereza n'Igifaransa.
4. Gusimbuza ibimenyetso bishushanyije amafoto yemewe.

## Icyitonderwa

Ibibazo, amasomo n'imiterere y'ikizamini (`lib/core/exam_config.dart`) ni iby'urugero.
Bigomba kugenzurwa n'itegeko rigenga imikoreshereze y'imihanda mu Rwanda n'amabwiriza ya Polisi mbere yo gusohora app.
