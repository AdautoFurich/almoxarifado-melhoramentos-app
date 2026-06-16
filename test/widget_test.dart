import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:almoxarifadomelhoramentos/main.dart';

void main() {
  Future<void> openCreateItemForm(WidgetTester tester) async {
    final showFormButton = find.byKey(
      const ValueKey('show-create-item-form-button'),
      skipOffstage: false,
    );

    await tester.ensureVisible(showFormButton);
    await tester.pump();
    await tester.tap(showFormButton);
    await tester.pump();
  }

  testWidgets('cadastra item e permite buscar por codigo', (tester) async {
    await tester.pumpWidget(const AlmoxarifadoApp());

    expect(find.byKey(const ValueKey('company-logo')), findsOneWidget);
    expect(find.text('Nenhum item encontrado.'), findsOneWidget);

    await openCreateItemForm(tester);
    await tester.enterText(
      find.bySemanticsLabel('Nome do item'),
      'Redução final',
    );
    await tester.enterText(
      find.bySemanticsLabel('Código do item'),
      '435140170000',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Cadastrar item').last);
    await tester.pump();

    expect(find.text('Redução final'), findsOneWidget);
    expect(find.text('Código: 4351.4017.0000'), findsOneWidget);

    final searchField = find.byKey(
      const ValueKey('inventory-search-field'),
      skipOffstage: false,
    );

    await tester.ensureVisible(searchField);
    await tester.pump();
    await tester.enterText(searchField, '435140170000');
    await tester.pump();

    expect(find.text('4351.4017.0000'), findsOneWidget);
    expect(find.text('Redução final'), findsOneWidget);
  });

  testWidgets('bloqueia cadastro com codigo duplicado', (tester) async {
    await tester.pumpWidget(const AlmoxarifadoApp());

    await openCreateItemForm(tester);
    await tester.enterText(
      find.bySemanticsLabel('Nome do item'),
      'Redução final',
    );
    await tester.enterText(
      find.bySemanticsLabel('Código do item'),
      '435140170000',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Cadastrar item').last);
    await tester.pump();

    await openCreateItemForm(tester);
    await tester.enterText(find.bySemanticsLabel('Nome do item'), 'Outro item');
    await tester.enterText(
      find.bySemanticsLabel('Código do item'),
      '435140170000',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Cadastrar item').last);
    await tester.pump();

    expect(
      find.text('Já existe um item cadastrado com este código'),
      findsOneWidget,
    );
    expect(find.text('Código: 4351.4017.0000'), findsOneWidget);
  });

  testWidgets('edita item cadastrado', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AlmoxarifadoApp());

    await openCreateItemForm(tester);
    await tester.enterText(find.bySemanticsLabel('Nome do item'), 'Parafuso');
    await tester.enterText(
      find.bySemanticsLabel('Código do item'),
      '111122223333',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Cadastrar item').last);
    await tester.pump();

    final editButton = find.byTooltip('Editar item', skipOffstage: false);

    await tester.ensureVisible(editButton);
    await tester.pump();
    await tester.tap(editButton);
    await tester.pump();

    await tester.enterText(find.bySemanticsLabel('Nome do item'), 'Porca');
    await tester.enterText(
      find.bySemanticsLabel('Código do item'),
      '444455556666',
    );
    final saveButton = find.widgetWithText(
      FilledButton,
      'Salvar alterações',
      skipOffstage: false,
    );

    await tester.ensureVisible(saveButton);
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Porca'), findsOneWidget);
    expect(find.text('Código: 4444.5555.6666'), findsOneWidget);
    expect(find.text('Parafuso'), findsNothing);
  });

  testWidgets('exclui item cadastrado com confirmacao', (tester) async {
    await tester.pumpWidget(const AlmoxarifadoApp());

    await openCreateItemForm(tester);
    await tester.enterText(find.bySemanticsLabel('Nome do item'), 'Arruela');
    await tester.enterText(
      find.bySemanticsLabel('Código do item'),
      '777788889999',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Cadastrar item').last);
    await tester.pump();

    final deleteButton = find.byTooltip('Excluir item', skipOffstage: false);

    await tester.ensureVisible(deleteButton);
    await tester.pump();
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Excluir item?'), findsOneWidget);
    expect(find.text('Arruela'), findsWidgets);
    expect(find.text('7777.8888.9999'), findsOneWidget);

    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Arruela'), findsNothing);
    expect(find.text('Nenhum item encontrado.'), findsOneWidget);
  });
}
