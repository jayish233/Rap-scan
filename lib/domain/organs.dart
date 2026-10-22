/// The 13 allowed body-map organ keys (PRD §7.4.2). Pure Dart.
library;

enum Organ {
  brain('Brain'),
  eyes('Eyes'),
  teeth('Teeth'),
  throat('Throat'),
  heart('Heart'),
  lungs('Lungs'),
  liver('Liver'),
  stomach('Stomach'),
  pancreas('Pancreas'),
  kidneys('Kidneys'),
  intestines('Intestines'),
  skin('Skin'),
  bones('Bones');

  const Organ(this.label);
  final String label;

  static Organ? fromKey(String key) {
    final k = key.trim().toLowerCase();
    for (final o in Organ.values) {
      if (o.name == k) return o;
    }
    return null;
  }
}
