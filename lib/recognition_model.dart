class RecognitionModel {
  List<Results>? results;

  RecognitionModel({this.results});

  RecognitionModel.fromJson(dynamic json) {
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results?.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (results != null) {
      map['results'] = results?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Results {
  num? score;
  Species? species;
  Gbif? gbif;
  Powo? powo;

  Results({this.score, this.species, this.gbif, this.powo});

  Results.fromJson(dynamic json) {
    score = json['score'];
    species = json['species'] != null ? Species.fromJson(json['species']) : null;
    gbif = json['gbif'] != null ? Gbif.fromJson(json['gbif']) : null;
    powo = json['powo'] != null ? Powo.fromJson(json['powo']) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['score'] = score;
    if (species != null) {
      map['species'] = species?.toJson();
    }
    if (gbif != null) {
      map['gbif'] = gbif?.toJson();
    }
    if (powo != null) {
      map['powo'] = powo?.toJson();
    }
    return map;
  }
}

class Species {
  String? scientificNameWithoutAuthor;
  String? scientificNameAuthorship;
  Genus? genus;
  Family? family;
  List<String>? commonNames;
  String? scientificName;

  Species({
    this.scientificNameWithoutAuthor,
    this.scientificNameAuthorship,
    this.genus,
    this.family,
    this.commonNames,
    this.scientificName,
  });

  Species.fromJson(dynamic json) {
    scientificNameWithoutAuthor = json['scientificNameWithoutAuthor'];
    scientificNameAuthorship = json['scientificNameAuthorship'];
    genus = json['genus'] != null ? Genus.fromJson(json['genus']) : null;
    family = json['family'] != null ? Family.fromJson(json['family']) : null;
    commonNames = json['commonNames'] != null ? json['commonNames'].cast<String>() : [];
    scientificName = json['scientificName'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['scientificNameWithoutAuthor'] = scientificNameWithoutAuthor;
    map['scientificNameAuthorship'] = scientificNameAuthorship;
    if (genus != null) {
      map['genus'] = genus?.toJson();
    }
    if (family != null) {
      map['family'] = family?.toJson();
    }
    map['commonNames'] = commonNames;
    map['scientificName'] = scientificName;
    return map;
  }
}

class Genus {
  String? scientificNameWithoutAuthor;
  String? scientificNameAuthorship;
  String? scientificName;

  Genus({this.scientificNameWithoutAuthor, this.scientificNameAuthorship, this.scientificName});

  Genus.fromJson(dynamic json) {
    scientificNameWithoutAuthor = json['scientificNameWithoutAuthor'];
    scientificNameAuthorship = json['scientificNameAuthorship'];
    scientificName = json['scientificName'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['scientificNameWithoutAuthor'] = scientificNameWithoutAuthor;
    map['scientificNameAuthorship'] = scientificNameAuthorship;
    map['scientificName'] = scientificName;
    return map;
  }
}

class Family {
  String? scientificNameWithoutAuthor;
  String? scientificNameAuthorship;
  String? scientificName;

  Family({this.scientificNameWithoutAuthor, this.scientificNameAuthorship, this.scientificName});

  Family.fromJson(dynamic json) {
    scientificNameWithoutAuthor = json['scientificNameWithoutAuthor'];
    scientificNameAuthorship = json['scientificNameAuthorship'];
    scientificName = json['scientificName'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['scientificNameWithoutAuthor'] = scientificNameWithoutAuthor;
    map['scientificNameAuthorship'] = scientificNameAuthorship;
    map['scientificName'] = scientificName;
    return map;
  }
}

class Gbif {
  String? id;
  Gbif({this.id});
  Gbif.fromJson(dynamic json) { id = json['id']; }
  Map<String, dynamic> toJson() => {'id': id};
}

class Powo {
  String? id;
  Powo({this.id});
  Powo.fromJson(dynamic json) { id = json['id']; }
  Map<String, dynamic> toJson() => {'id': id};
}
