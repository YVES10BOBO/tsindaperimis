/// Izina rya app riri hamwe gusa: rihindure hano rihinduke hose muri app.
/// (Izina rigaragara munsi y'agashushanyo kuri telefoni rihindurwa muri
/// android/app/src/main/AndroidManifest.xml → android:label.)
class AppInfo {
  AppInfo._();

  static const String name = "Amategeko y'Umuhanda";
  static const String tagline = 'Iga. Witoze. Tsinda.\nMenya amategeko, urinde ubuzima.';
  static const String version = '0.2.0';

  /// Premium ihishwe kugeza kwishyura nyabyo (MTN MoMo / Airtel Money) bihujwe.
  /// Ubu ibirimo byose ni ubuntu; shyiramo `true` iyo kwishyura byakozwe.
  static const bool premiumEnabled = false;

  /// Utubuto two kumva amajwi (🔊) duhishwe ku bakoresha kugeza amajwi yafashwe.
  /// Shyiramo `true` iyo amajwi y'amasomo/ibibazo yashyizweho muri dashboard.
  static const bool audioEnabled = false;
}
