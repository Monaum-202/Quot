import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/template_model.dart';
import '../data/repositories/template_repository.dart';

part 'template_provider.g.dart';

@riverpod
class Templates extends _$Templates {
  late final TemplateRepository _repository;

  @override
  List<TemplateModel> build() {
    _repository = TemplateRepository();
    return _repository.templates;
  }

  void refresh() {
    state = _repository.templates;
  }

  Future<void> addTemplate(TemplateModel template) async {
    await _repository.addTemplate(template);
    refresh();
  }

  Future<void> deleteTemplate(String id) async {
    await _repository.deleteTemplate(id);
    refresh();
  }
}
