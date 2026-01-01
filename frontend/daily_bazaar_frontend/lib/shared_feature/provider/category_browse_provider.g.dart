// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_browse_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryBrowseController)
final categoryBrowseControllerProvider = CategoryBrowseControllerFamily._();

final class CategoryBrowseControllerProvider
    extends
        $AsyncNotifierProvider<CategoryBrowseController, CategoryBrowseState> {
  CategoryBrowseControllerProvider._({
    required CategoryBrowseControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryBrowseControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryBrowseControllerHash();

  @override
  String toString() {
    return r'categoryBrowseControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CategoryBrowseController create() => CategoryBrowseController();

  @override
  bool operator ==(Object other) {
    return other is CategoryBrowseControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryBrowseControllerHash() =>
    r'166ec7d6249bebb01843fa4f7c75f22b218275a7';

final class CategoryBrowseControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryBrowseController,
          AsyncValue<CategoryBrowseState>,
          CategoryBrowseState,
          FutureOr<CategoryBrowseState>,
          String
        > {
  CategoryBrowseControllerFamily._()
    : super(
        retry: null,
        name: r'categoryBrowseControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryBrowseControllerProvider call(String parentCategoryId) =>
      CategoryBrowseControllerProvider._(
        argument: parentCategoryId,
        from: this,
      );

  @override
  String toString() => r'categoryBrowseControllerProvider';
}

abstract class _$CategoryBrowseController
    extends $AsyncNotifier<CategoryBrowseState> {
  late final _$args = ref.$arg as String;
  String get parentCategoryId => _$args;

  FutureOr<CategoryBrowseState> build(String parentCategoryId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CategoryBrowseState>, CategoryBrowseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CategoryBrowseState>, CategoryBrowseState>,
              AsyncValue<CategoryBrowseState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
