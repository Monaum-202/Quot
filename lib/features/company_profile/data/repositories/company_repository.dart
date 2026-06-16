import 'package:hive/hive.dart';
import '../../../../core/constants/hive_box_names.dart';
import '../models/company_model.dart';

class CompanyRepository {
  final Box<CompanyModel> _box = Hive.box(HiveBoxNames.company);

  CompanyModel? get company => _box.get('company');

  Future<void> saveCompany(CompanyModel model) async {
    await _box.put('company', model);
  }
}
