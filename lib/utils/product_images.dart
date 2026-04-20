String? getProductImageAsset(String? productName) {
  if (productName == null) return null;
  
  final name = productName.toLowerCase();
  
  if (name.contains('bonaqua')) return 'assets/images/bonaqua-1l.png';
  if (name.contains('coca') || name.contains('coca-cola') || name.contains('coca cola')) return 'assets/images/cocacola-1l.png';
  if (name.contains('яйца') || name.contains('казгер')) return 'assets/images/eggs-kazger.jpg';
  if (name.contains('кублей')) return 'assets/images/kublei.jpg';
  if (name.contains('махеев') || name.contains('шашлык')) return 'assets/images/maheev.png';
  if (name.contains('ряба') || name.contains('майонез')) return 'assets/images/ryaba.jpeg';
  if (name.contains('молоко') || name.contains('петропавловск')) return 'assets/images/milk-petropavlovsk.jpg';
  if (name.contains('milka')) return 'assets/images/milka.png';
  if (name.contains('piala') || name.contains('чай')) return 'assets/images/piala.jpg';
  if (name.contains('red bull') || name.contains('redbull')) return 'assets/images/redbull.png';
  if (name.contains('twix')) return 'assets/images/twix.jpg';
  
  return null;
}
