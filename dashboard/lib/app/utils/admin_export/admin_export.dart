// ignore: avoid_web_libraries_in_flutter
// ignore_for_file: deprecated_member_use

import 'dart:html' as html;

import 'package:excel/excel.dart' as xls;

import '../../modules/admin_screen/models/admin_models.dart';

/// Builds an .xlsx file from the given companies and triggers a browser download.
void exportCompaniesToExcel(List<AdminCompany> companies) {
  final workbook = xls.Excel.createExcel();

  // Rename default sheet instead of creating a second one.
  final defaultSheetName = workbook.getDefaultSheet()!;
  workbook.rename(defaultSheetName, 'Companies');
  final sheet = workbook['Companies'];

  const headers = [
    'ID',
    'Company Name',
    'Email',
    'Phone',
    'Business Type',
    'Location',
    'Places',
    'Joined',
  ];
  sheet.appendRow(headers.map((h) => xls.TextCellValue(h)).toList());

  for (final c in companies) {
    sheet.appendRow([
      xls.TextCellValue(c.id),
      xls.TextCellValue(c.name),
      xls.TextCellValue(c.email),
      xls.TextCellValue(c.phone),
      xls.TextCellValue(c.businessType),
      xls.TextCellValue(c.location),
      xls.IntCellValue(c.places),
      xls.TextCellValue(c.joined),
    ]);
  }

  // Light header styling.
  for (var col = 0; col < headers.length; col++) {
    final cell = sheet.cell(xls.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
    cell.cellStyle = xls.CellStyle(bold: true);
  }

  final bytes = workbook.encode();
  if (bytes == null) return;

  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  html.AnchorElement(href: url)
    ..setAttribute('download', 'companies_export_$timestamp.xlsx')
    ..click();

  html.Url.revokeObjectUrl(url);
}

/// Builds an .xlsx file from the given places and triggers a browser download.
void exportPlacesToExcel(List<AdminPlace> places) {
  final workbook = xls.Excel.createExcel();

  final defaultSheetName = workbook.getDefaultSheet()!;
  workbook.rename(defaultSheetName, 'Places');
  final sheet = workbook['Places'];

  const headers = [
    'Place',
    'Description',
    'Company',
    'Category',
    'Province',
    'Fee',
    'Submitted',
    'Status',
  ];
  sheet.appendRow(headers.map((h) => xls.TextCellValue(h)).toList());

  for (final p in places) {
    sheet.appendRow([
      xls.TextCellValue(p.name),
      xls.TextCellValue(p.subtitle),
      xls.TextCellValue(p.company),
      xls.TextCellValue(p.category),
      xls.TextCellValue(p.province),
      xls.TextCellValue(p.fee),
      xls.TextCellValue(p.submittedDate),
      xls.TextCellValue(p.status.name),
    ]);
  }

  for (var col = 0; col < headers.length; col++) {
    final cell = sheet.cell(xls.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
    cell.cellStyle = xls.CellStyle(bold: true);
  }

  final bytes = workbook.encode();
  if (bytes == null) return;

  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  html.AnchorElement(href: url)
    ..setAttribute('download', 'places_export_$timestamp.xlsx')
    ..click();

  html.Url.revokeObjectUrl(url);
}