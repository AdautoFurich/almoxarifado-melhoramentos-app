import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:almoxarifadomelhoramentos/main.dart';

void main() {
  Future<void> pumpInventoryApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const AlmoxarifadoApp());
  }

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

  Future<void> tapFormSubmit(
    WidgetTester tester, {
    String label = 'Cadastrar item',
  }) async {
    final submitButton = find.widgetWithText(
      FilledButton,
      label,
      skipOffstage: false,
    );

    await tester.ensureVisible(submitButton);
    await tester.pump();
    await tester.tap(submitButton);
    await tester.pump();
  }

  testWidgets('cadastra item e permite buscar por codigo', (tester) async {
    await pumpInventoryApp(tester);

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
    await tapFormSubmit(tester);

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
    await pumpInventoryApp(tester);

    await openCreateItemForm(tester);
    await tester.enterText(
      find.bySemanticsLabel('Nome do item'),
      'Redução final',
    );
    await tester.enterText(
      find.bySemanticsLabel('Código do item'),
      '435140170000',
    );
    await tapFormSubmit(tester);

    await openCreateItemForm(tester);
    await tester.enterText(find.bySemanticsLabel('Nome do item'), 'Outro item');
    await tester.enterText(
      find.bySemanticsLabel('Código do item'),
      '435140170000',
    );
    await tapFormSubmit(tester);

    expect(
      find.text('Já existe um item cadastrado com este código'),
      findsOneWidget,
    );
    expect(find.text('Código: 4351.4017.0000'), findsOneWidget);
  });

  testWidgets('recolhe formulario de cadastro', (tester) async {
    await pumpInventoryApp(tester);

    await openCreateItemForm(tester);

    expect(find.bySemanticsLabel('Nome do item'), findsOneWidget);

    final collapseButton = find.text('Recolher', skipOffstage: false);

    await tester.ensureVisible(collapseButton);
    await tester.pump();
    await tester.tap(collapseButton);
    await tester.pump();

    expect(find.bySemanticsLabel('Nome do item'), findsNothing);
    expect(
      find.byKey(const ValueKey('show-create-item-form-button')),
      findsOneWidget,
    );
  });

  testWidgets('fecha formulario pelo botao do cabecalho', (tester) async {
    await pumpInventoryApp(tester);

    await openCreateItemForm(tester);

    expect(find.bySemanticsLabel('Nome do item'), findsOneWidget);

    await tester.tap(find.byTooltip('Fechar cadastro'));
    await tester.pump();

    expect(find.bySemanticsLabel('Nome do item'), findsNothing);
    expect(
      find.byKey(const ValueKey('show-create-item-form-button')),
      findsOneWidget,
    );
  });

  testWidgets('edita item cadastrado', (tester) async {
    await pumpInventoryApp(tester);

    await openCreateItemForm(tester);
    await tester.enterText(find.bySemanticsLabel('Nome do item'), 'Parafuso');
    await tester.enterText(
      find.bySemanticsLabel('Código do item'),
      '111122223333',
    );
    await tapFormSubmit(tester);

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
    await tapFormSubmit(tester, label: 'Salvar alterações');

    expect(find.text('Porca'), findsOneWidget);
    expect(find.text('Código: 4444.5555.6666'), findsOneWidget);
    expect(find.text('Parafuso'), findsNothing);
  });

  testWidgets('abre detalhes do item ao tocar no cadastro', (tester) async {
    await pumpInventoryApp(tester);

    await openCreateItemForm(tester);
    await tester.enterText(find.bySemanticsLabel('Nome do item'), 'Registro');
    await tester.enterText(
      find.bySemanticsLabel('Código do item'),
      '123456789012',
    );
    await tester.enterText(
      find.bySemanticsLabel('Descrição do item'),
      'Registro usado na linha principal.',
    );
    await tapFormSubmit(tester);

    await tester.tap(find.text('Registro'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhes do item'), findsOneWidget);
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Código'), findsOneWidget);
    expect(find.text('Descrição'), findsOneWidget);
    expect(find.text('1234.5678.9012'), findsOneWidget);
    expect(find.text('Registro usado na linha principal.'), findsOneWidget);

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhes do item'), findsNothing);
  });

  testWidgets('exclui item cadastrado com confirmacao', (tester) async {
    await pumpInventoryApp(tester);

    await openCreateItemForm(tester);
    await tester.enterText(find.bySemanticsLabel('Nome do item'), 'Arruela');
    await tester.enterText(
      find.bySemanticsLabel('Código do item'),
      '777788889999',
    );
    await tapFormSubmit(tester);

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
