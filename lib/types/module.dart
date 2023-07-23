class Module {
  String moduleName;
  String moduleId;
  int type;

  static const int ONOFF = 0;
  static const int SLIDER = 1;
  static const int VALUE = 2;

  Module({required this.moduleName, required this.moduleId, required this.type,});

  bool onOffVal = false;
  double doubleVal = 0;

  get value => (type == ONOFF? onOffVal: doubleVal);
  set setValue(dynamic val) => (type == ONOFF? (onOffVal = val): (doubleVal = val));

  String unit = "";
  set setUnit(String unit) => this.unit = unit;

  List<double> valueRange = [0,100];
  get startVal => valueRange[0];
  get endVal => valueRange[1];
  set setValueRange(List<double> range) => valueRange = range;

  bool decimal = false;
  set setDecimal(bool val) => decimal = val;

  bool sendRequest() {
    if(type==ONOFF){
      print("set $moduleId to $onOffVal");
      return true;
    }
    else if(type==SLIDER){
      print("set $moduleId to $doubleVal");
      return true;
    }
    else {
      print("value of $moduleId is $doubleVal");
      return true;
    }

  }

}

class ModuleList {
  List<Module> comp = [];

  ModuleList(this.comp);

  void reOrder(List<int> reorderList) {
    List<Module> newComp = [];
    for(int i in reorderList) {
      newComp.add(comp[i]);
    }
    comp = newComp;
  }

  Module? findByID(String id) {
    for(Module module in comp) {
      if(module.moduleId == id) {
        return module;
      }
    }
    return null;
  }

}