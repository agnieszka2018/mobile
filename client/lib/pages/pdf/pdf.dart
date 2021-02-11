import 'package:client/database/Database.dart';
import 'package:client/models/User.dart';
import 'package:client/shared/drawer.dart';
import 'package:client/shared/showNewDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../shared/specializations_map.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

class DocumentPage extends StatefulWidget {
  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  String code = "";
  String url = "";
  bool isLoading = true;
  PDFDocument document;
  bool error = false;

  @override
  void initState() {
    super.initState();
    _getSpecializationCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        title: const Text('Program specjalizacji'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : (error
              ? Center(
                  child: Text('Nie udało się pobrać programu specjalizacji'))
              : PDFViewer(document: document)),
    );
  }

  Future<void> _getSpecializationCode() async {
    User user = await DatabaseProvider.db.getUser();

    code =
        specializations[user.specialization].toString().padLeft(4, '0') ?? '';

    try {
      if (code != "" && code.isNotEmpty) {
        url =
            "https://cmkp.edu.pl/wp-content/uploads/akredytacja2018/$code-program-1.pdf";
        _downloadFile();
      } else {
        error = true;
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showNewDialog(context, Text('Błąd'), Text('Wystąpił błąd'));
      error = true;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _downloadFile() async {
    document = await PDFDocument.fromURL(
      url,
      cacheManager: CacheManager(
        Config(
          "CacheKey",
          stalePeriod: const Duration(days: 180),
          maxNrOfCacheObjects: 10,
        ),
      ),
    );
    setState(() {
      isLoading = false;
    });
  }
}
